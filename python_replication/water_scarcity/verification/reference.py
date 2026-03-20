from __future__ import annotations

from pathlib import PurePosixPath

from .types import ArtifactSpec, ExhibitSpec


def _artifact(relative_path: str, description: str = "") -> ArtifactSpec:
    return ArtifactSpec(relative_path=relative_path, description=description)


EXHIBITS: tuple[ExhibitSpec, ...] = (
    ExhibitSpec(
        exhibit_id="figure_1",
        paper_label="Figure 1",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig1_water_pc.png"),),
        report_aliases=(),
        notes=("Final reviewer-facing figures are tracked as PNG files under Outputs/graphs.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_2",
        paper_label="Figure 2",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig2_daily_water_use_per_capita.png"),),
        report_aliases=(),
        notes=("The continent panel excludes the aggregate Americas bar and retains population-weighted regional averages.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_3",
        paper_label="Figure 3",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig3_WaterStress_SectorsSDG.png"),),
        report_aliases=(),
        notes=("The canonical Figure 3 removes the extra VC and BM observations from the relevant subregional panels.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_4",
        paper_label="Figure 4",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig4_WaterStress_WB.png"),),
        report_aliases=(),
        notes=("The canonical Figure 4 removes GD from the Caribbean panel and omits the aggregate Americas bar.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_5",
        paper_label="Figure 5",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig5_WaterStress_2000_2020_WB.png"),),
        report_aliases=(),
        notes=("Figure 5 is normalized into Outputs/graphs alongside the other tracked paper figures.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_6",
        paper_label="Figure 6",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from the checked-in OECD pricing CSV.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/Fig6_OECD_WaterPrices.png"),),
        report_aliases=(),
        notes=("Figure 6 and the water-pricing regressions share the same checked-in OECD reference source.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_1",
        paper_label="Table 1",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table1.tex"),),
        report_aliases=(),
        notes=("Panel B explicitly documents the UN median 2050 population projection and 2% annual real GDP per capita growth assumption.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_2",
        paper_label="Table 2",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table2.tex"),),
        report_aliases=(),
        notes=("Reviewer-facing tables are tracked as LaTeX files under Outputs/tables.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_3",
        paper_label="Table 3",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table3.tex"),),
        report_aliases=(),
        notes=(),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_4",
        paper_label="Table 4",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table4.tex"),),
        report_aliases=(),
        notes=(),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_5",
        paper_label="Table 5",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table5.tex"),),
        report_aliases=(),
        notes=(),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_6",
        paper_label="Table 6",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from structured machine output.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table6.tex"),),
        report_aliases=(),
        notes=("The canonical table is derived from structured one-standard-deviation effect exports rather than SMCL logs.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_7",
        paper_label="Table 7",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table7.tex"),),
        report_aliases=(),
        notes=("Only the paper-matching sector-share regressions are promoted into the canonical artifact set.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_8",
        paper_label="Table 8",
        section="main",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/Table8.tex"),),
        report_aliases=(),
        notes=("The canonical table combines the total-manufacturing and automotive regression panels.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_a1",
        paper_label="Figure A1",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/FigA1_USDm3.png"),),
        report_aliases=(),
        notes=("The appendix continent panel omits the aggregate Americas bar.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="figure_a2",
        paper_label="Figure A2",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("graphs/FigA2_USDm3_Sectors.png"),),
        report_aliases=(),
        notes=("The appendix continent panel omits the aggregate Americas bar.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a1",
        paper_label="Table A1",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA1.tex"),),
        report_aliases=(),
        notes=(),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a2",
        paper_label="Table A2",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA2.tex"),),
        report_aliases=(),
        notes=("The canonical appendix table is a LaTeX correlation matrix rather than an SMCL log.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a3",
        paper_label="Table A3",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA3.tex"),),
        report_aliases=(),
        notes=("The water-pricing regressions use the checked-in OECD 2008 reference CSV as their source of truth.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a4",
        paper_label="Table A4",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA4.tex"),),
        report_aliases=(),
        notes=("Canonical appendix numbering follows the paper-reviewed A1-A7 mapping.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a5",
        paper_label="Table A5",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA5.tex"),),
        report_aliases=(),
        notes=("Canonical appendix numbering follows the paper-reviewed A1-A7 mapping.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a6",
        paper_label="Table A6",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA6.tex"),),
        report_aliases=(),
        notes=("Canonical appendix numbering follows the paper-reviewed A1-A7 mapping.",),
        verification_mode="required",
    ),
    ExhibitSpec(
        exhibit_id="table_a7",
        paper_label="Table A7",
        section="annex",
        status_in_report="Canonical paper-ready artifact generated from code.",
        manual_changes_expected=False,
        actual_artifacts=(_artifact("tables/TableA7.tex"),),
        report_aliases=(),
        notes=("Canonical appendix numbering follows the paper-reviewed A1-A7 mapping.",),
        verification_mode="required",
    ),
)

KNOWN_ALIAS_ANOMALIES: dict[tuple[str, str], dict[str, object]] = {}

GENERAL_ANOMALIES: tuple[dict[str, object], ...] = (
    {
        "anomaly_id": "legacy-raw-table-artifacts",
        "severity": "info",
        "message": "Legacy .xls, .xlsx, .txt, and .smcl outputs are retained only as ignored scratch artifacts under Outputs/tables/raw and are no longer part of the canonical reviewer-facing artifact set.",
    },
    {
        "anomaly_id": "legacy-appendix-numbering",
        "severity": "info",
        "message": "Historical package materials referenced a stale appendix numbering scheme; the canonical verifier now follows the paper-reviewed A1-A7 mapping.",
    },
)


def canonical_artifact_paths() -> tuple[str, ...]:
    paths = [artifact.normalized_path for exhibit in EXHIBITS for artifact in exhibit.actual_artifacts]
    return tuple(paths)


def normalized_canonical_paths() -> tuple[str, ...]:
    return tuple(dict.fromkeys(canonical_artifact_paths()))


def get_known_alias_anomaly(exhibit_id: str, alias: str) -> dict[str, object] | None:
    return KNOWN_ALIAS_ANOMALIES.get((exhibit_id, PurePosixPath(alias).name))


def validate_reference_manifest(strict_doc_aliases: bool = False) -> tuple[str, ...]:
    issues: list[str] = []
    seen_paths: set[str] = set()
    for exhibit in EXHIBITS:
        if exhibit.verification_mode == "required" and not exhibit.actual_artifacts:
            issues.append(f"{exhibit.exhibit_id} is required but has no canonical artifacts.")
        canonical_basenames = {artifact.basename for artifact in exhibit.actual_artifacts}
        for artifact in exhibit.actual_artifacts:
            normalized = artifact.normalized_path
            if PurePosixPath(normalized).is_absolute():
                issues.append(f"{exhibit.exhibit_id} uses an absolute artifact path: {normalized}")
            if ".." in PurePosixPath(normalized).parts:
                issues.append(f"{exhibit.exhibit_id} uses a non-normalized artifact path: {normalized}")
            if normalized in seen_paths:
                issues.append(f"Duplicate canonical artifact path detected: {normalized}")
            seen_paths.add(normalized)
        for alias in exhibit.report_aliases:
            alias_name = PurePosixPath(alias).name
            if alias_name in canonical_basenames:
                continue
            if strict_doc_aliases:
                issues.append(
                    f"{exhibit.exhibit_id} alias {alias_name} does not match a canonical artifact under strict alias mode."
                )
                continue
            if get_known_alias_anomaly(exhibit.exhibit_id, alias_name) is None:
                issues.append(f"{exhibit.exhibit_id} alias {alias_name} is not covered by the anomaly catalog.")
    return tuple(issues)
