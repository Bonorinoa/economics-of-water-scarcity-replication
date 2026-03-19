from __future__ import annotations

from pathlib import Path
from zipfile import ZipFile

from water_scarcity.verification.parsers import validate_artifact


MINIMAL_PNG = (
    b"\x89PNG\r\n\x1a\n"
    b"\x00\x00\x00\rIHDR"
    b"\x00\x00\x00\x01\x00\x00\x00\x01"
    b"\x08\x02\x00\x00\x00"
    b"\x90wS\xde"
    b"\x00\x00\x00\x0cIDAT"
    b"\x08\xd7c\xf8\x0f\x00\x01\x01\x01\x00"
    b"\x18\xdd\x8d\xb1"
    b"\x00\x00\x00\x00IEND\xaeB`\x82"
)


def _write_xml_xls(path: Path) -> None:
    path.write_text(
        (
            '<?xml version="1.0"?>'
            '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet">'
            '<Worksheet ss:Name="Sheet1" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'
            "<Table><Row><Cell><Data ss:Type=\"String\">ok</Data></Cell></Row></Table>"
            "</Worksheet></Workbook>"
        ),
        encoding="utf-8",
    )


def _write_xlsx(path: Path) -> None:
    with ZipFile(path, "w") as archive:
        archive.writestr(
            "[Content_Types].xml",
            (
                '<?xml version="1.0" encoding="UTF-8"?>'
                '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                '<Default Extension="xml" ContentType="application/xml"/>'
                '<Override PartName="/xl/workbook.xml" '
                'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
                '<Override PartName="/xl/worksheets/sheet1.xml" '
                'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
                "</Types>"
            ),
        )
        archive.writestr(
            "_rels/.rels",
            (
                '<?xml version="1.0" encoding="UTF-8"?>'
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                '<Relationship Id="rId1" '
                'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
                'Target="xl/workbook.xml"/>'
                "</Relationships>"
            ),
        )
        archive.writestr(
            "xl/workbook.xml",
            (
                '<?xml version="1.0" encoding="UTF-8"?>'
                '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
                'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
                "<sheets><sheet name=\"Sheet1\" sheetId=\"1\" r:id=\"rId1\"/></sheets>"
                "</workbook>"
            ),
        )
        archive.writestr(
            "xl/_rels/workbook.xml.rels",
            (
                '<?xml version="1.0" encoding="UTF-8"?>'
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                '<Relationship Id="rId1" '
                'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
                'Target="worksheets/sheet1.xml"/>'
                "</Relationships>"
            ),
        )
        archive.writestr(
            "xl/worksheets/sheet1.xml",
            (
                '<?xml version="1.0" encoding="UTF-8"?>'
                '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
                '<sheetData><row r="1"><c r="A1" t="str"><v>ok</v></c></row></sheetData>'
                "</worksheet>"
            ),
        )


def test_png_parser_accepts_valid_png(tmp_path):
    path = tmp_path / "figure.png"
    path.write_bytes(MINIMAL_PNG)

    result = validate_artifact(path)

    assert result.ok
    assert result.parser_name == "png"


def test_png_parser_rejects_invalid_png(tmp_path):
    path = tmp_path / "broken.png"
    path.write_bytes(b"not-a-png")

    result = validate_artifact(path)

    assert not result.ok


def test_xls_parser_accepts_xml_spreadsheet(tmp_path):
    path = tmp_path / "table.xls"
    _write_xml_xls(path)

    result = validate_artifact(path)

    assert result.ok
    assert result.parser_name == "xml-xls"


def test_xlsx_parser_accepts_minimal_workbook(tmp_path):
    path = tmp_path / "table.xlsx"
    _write_xlsx(path)

    result = validate_artifact(path)

    assert result.ok
    assert result.parser_name in {"openpyxl", "xlsx-stdlib"}


def test_text_and_smcl_reject_empty_files(tmp_path):
    txt = tmp_path / "empty.txt"
    smcl = tmp_path / "empty.smcl"
    txt.write_text("", encoding="utf-8")
    smcl.write_text("", encoding="utf-8")

    txt_result = validate_artifact(txt)
    smcl_result = validate_artifact(smcl)

    assert not txt_result.ok
    assert not smcl_result.ok
