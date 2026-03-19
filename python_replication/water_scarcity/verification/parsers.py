from __future__ import annotations

from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
from xml.etree import ElementTree as ET
from zipfile import BadZipFile, ZipFile

try:
    import openpyxl  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    openpyxl = None

try:
    import xlrd  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    xlrd = None


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
OLE_SIGNATURE = b"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1"


@dataclass(frozen=True)
class ParseOutcome:
    ok: bool
    parser_name: str
    detail: str
    degraded: bool = False


def _local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def _non_empty_xml_text(root: ET.Element, element_name: str) -> bool:
    for element in root.iter():
        if _local_name(element.tag) != element_name:
            continue
        if (element.text or "").strip():
            return True
    return False


def _parse_text(path: Path) -> ParseOutcome:
    text = path.read_text(encoding="utf-8", errors="ignore")
    if not text.strip():
        return ParseOutcome(False, "text", "Text file is empty after trimming whitespace.")
    return ParseOutcome(True, "text", "Text file contains non-empty content.")


def _parse_smcl(path: Path) -> ParseOutcome:
    text = path.read_text(encoding="utf-8", errors="ignore")
    if not text.strip():
        return ParseOutcome(False, "smcl", "SMCL file is empty after trimming whitespace.")
    if "{smcl}" not in text[:200]:
        return ParseOutcome(False, "smcl", "SMCL marker token {smcl} is missing from the file header.")
    return ParseOutcome(True, "smcl", "SMCL file is non-empty and contains the SMCL header marker.")


def _parse_png(path: Path) -> ParseOutcome:
    raw = path.read_bytes()
    if len(raw) < 24:
        return ParseOutcome(False, "png", "PNG file is too short to contain the required header and IHDR chunk.")
    if not raw.startswith(PNG_SIGNATURE):
        return ParseOutcome(False, "png", "PNG signature is invalid.")
    if raw[12:16] != b"IHDR":
        return ParseOutcome(False, "png", "PNG IHDR chunk is missing or malformed.")
    width = int.from_bytes(raw[16:20], byteorder="big")
    height = int.from_bytes(raw[20:24], byteorder="big")
    if width <= 0 or height <= 0:
        return ParseOutcome(False, "png", "PNG width and height must both be positive.")
    return ParseOutcome(True, "png", f"PNG dimensions validated ({width}x{height}).")


def _parse_xml_spreadsheet(path: Path) -> ParseOutcome:
    try:
        root = ET.fromstring(path.read_text(encoding="utf-8", errors="ignore"))
    except ET.ParseError as exc:
        return ParseOutcome(False, "xml-xls", f"SpreadsheetML parsing failed: {exc}.")
    worksheets = [element for element in root.iter() if _local_name(element.tag) == "Worksheet"]
    if not worksheets:
        return ParseOutcome(False, "xml-xls", "SpreadsheetML workbook does not contain any Worksheet elements.")
    if not _non_empty_xml_text(root, "Data"):
        return ParseOutcome(False, "xml-xls", "SpreadsheetML workbook does not contain any non-empty Data cells.")
    return ParseOutcome(True, "xml-xls", f"SpreadsheetML workbook contains {len(worksheets)} worksheet(s) and non-empty cell data.")


def _parse_xls_with_xlrd(path: Path) -> ParseOutcome:
    if xlrd is None:  # pragma: no cover - exercised by fallback path in this environment
        return ParseOutcome(False, "xlrd", "xlrd is not installed in the active Python environment.")
    try:
        workbook = xlrd.open_workbook(path.as_posix(), on_demand=True)
    except Exception as exc:  # pragma: no cover - depends on optional dependency
        return ParseOutcome(False, "xlrd", f"xlrd could not open the legacy XLS file: {exc}.")
    if workbook.nsheets < 1:
        return ParseOutcome(False, "xlrd", "Legacy XLS workbook contains no sheets.")
    has_non_empty_cell = False
    for sheet_index in range(workbook.nsheets):
        sheet = workbook.sheet_by_index(sheet_index)
        for row_index in range(sheet.nrows):
            for col_index in range(sheet.ncols):
                value = sheet.cell_value(row_index, col_index)
                if str(value).strip():
                    has_non_empty_cell = True
                    break
            if has_non_empty_cell:
                break
        if has_non_empty_cell:
            break
    if not has_non_empty_cell:
        return ParseOutcome(False, "xlrd", "Legacy XLS workbook contains sheets but no non-empty cells.")
    return ParseOutcome(True, "xlrd", f"Legacy XLS workbook contains {workbook.nsheets} sheet(s) and non-empty cells.")


def _parse_xls_ole_fallback(path: Path) -> ParseOutcome:
    raw = path.read_bytes()
    if not raw.startswith(OLE_SIGNATURE):
        return ParseOutcome(False, "xls-ole-fallback", "Legacy XLS file is missing the OLE compound-file header.")
    if len(raw) <= 512:
        return ParseOutcome(False, "xls-ole-fallback", "Legacy XLS file is too short to be a valid OLE workbook.")
    return ParseOutcome(
        True,
        "xls-ole-fallback",
        "Legacy XLS file has a valid OLE header and non-trivial size; install xlrd for sheet/cell-level validation.",
        degraded=True,
    )


def _parse_xls(path: Path) -> ParseOutcome:
    raw = path.read_bytes()
    if raw.lstrip().startswith(b"<?xml"):
        return _parse_xml_spreadsheet(path)
    if raw.startswith(OLE_SIGNATURE):
        if xlrd is not None:
            return _parse_xls_with_xlrd(path)
        return _parse_xls_ole_fallback(path)
    return ParseOutcome(False, "xls", "XLS file is neither SpreadsheetML XML nor a legacy OLE workbook.")


def _parse_xlsx_with_openpyxl(path: Path) -> ParseOutcome:
    if openpyxl is None:  # pragma: no cover - exercised by stdlib fallback in this environment
        return ParseOutcome(False, "openpyxl", "openpyxl is not installed in the active Python environment.")
    try:
        workbook = openpyxl.load_workbook(path, read_only=True, data_only=True)
    except Exception as exc:  # pragma: no cover - depends on optional dependency
        return ParseOutcome(False, "openpyxl", f"openpyxl could not open the XLSX workbook: {exc}.")
    if not workbook.worksheets:
        return ParseOutcome(False, "openpyxl", "XLSX workbook contains no worksheets.")
    has_non_empty_cell = False
    for worksheet in workbook.worksheets:
        for row in worksheet.iter_rows(values_only=True):
            if any(str(value).strip() for value in row if value is not None):
                has_non_empty_cell = True
                break
        if has_non_empty_cell:
            break
    if not has_non_empty_cell:
        return ParseOutcome(False, "openpyxl", "XLSX workbook contains worksheets but no non-empty cells.")
    return ParseOutcome(True, "openpyxl", f"XLSX workbook contains {len(workbook.worksheets)} worksheet(s) and non-empty cells.")


def _parse_xlsx_stdlib(path: Path) -> ParseOutcome:
    try:
        with ZipFile(path) as archive:
            workbook_xml = ET.fromstring(archive.read("xl/workbook.xml"))
            rels_xml = ET.fromstring(archive.read("xl/_rels/workbook.xml.rels"))
            relationship_map = {
                rel.attrib.get("Id"): rel.attrib.get("Target", "")
                for rel in rels_xml.iter()
                if _local_name(rel.tag) == "Relationship"
            }
            worksheet_targets: list[str] = []
            for sheet in workbook_xml.iter():
                if _local_name(sheet.tag) != "sheet":
                    continue
                rel_id = sheet.attrib.get("{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id")
                if rel_id is None:
                    continue
                target = relationship_map.get(rel_id)
                if target:
                    worksheet_targets.append(f"xl/{target.lstrip('/')}")
            if not worksheet_targets:
                return ParseOutcome(False, "xlsx-stdlib", "XLSX workbook contains no worksheet relationships.")
            for target in worksheet_targets:
                sheet_xml = ET.fromstring(archive.read(target))
                if _non_empty_xml_text(sheet_xml, "v") or _non_empty_xml_text(sheet_xml, "t"):
                    return ParseOutcome(True, "xlsx-stdlib", f"XLSX workbook contains {len(worksheet_targets)} worksheet(s) and non-empty cells.")
            return ParseOutcome(False, "xlsx-stdlib", "XLSX workbook contains worksheets but no non-empty cells.")
    except KeyError as exc:
        return ParseOutcome(False, "xlsx-stdlib", f"XLSX workbook is missing a required internal XML part: {exc}.")
    except (BadZipFile, ET.ParseError) as exc:
        return ParseOutcome(False, "xlsx-stdlib", f"XLSX workbook parsing failed: {exc}.")


def _parse_xlsx(path: Path) -> ParseOutcome:
    if openpyxl is not None:
        outcome = _parse_xlsx_with_openpyxl(path)
        if outcome.ok:
            return outcome
    return _parse_xlsx_stdlib(path)


def _parse_dta(path: Path) -> ParseOutcome:
    raw = path.read_bytes()
    if not raw:
        return ParseOutcome(False, "dta", "DTA file is empty.")
    if raw.startswith(b"<stata_dta>") or b"<stata_dta>" in raw[:256]:
        return ParseOutcome(True, "dta", "DTA file contains the expected <stata_dta> header.")
    return ParseOutcome(
        True,
        "dta-fallback",
        "DTA file is non-empty but does not expose the XML header in the first bytes; validation fell back to non-empty file check.",
        degraded=True,
    )


def validate_artifact(path: Path) -> ParseOutcome:
    suffix = path.suffix.lower()
    if suffix == ".png":
        return _parse_png(path)
    if suffix == ".smcl":
        return _parse_smcl(path)
    if suffix == ".txt":
        return _parse_text(path)
    if suffix == ".xlsx":
        return _parse_xlsx(path)
    if suffix == ".xls":
        return _parse_xls(path)
    if suffix == ".dta":
        return _parse_dta(path)
    if path.stat().st_size <= 0:
        return ParseOutcome(False, "size-only", "Artifact is empty.")
    return ParseOutcome(True, "size-only", "Artifact passed non-empty fallback validation.", degraded=True)
