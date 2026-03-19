from __future__ import annotations

import json
import os
from pathlib import Path

from water_scarcity.config import build_project_paths
from water_scarcity.verification.checks import check_exhibits
from water_scarcity.verification.types import ArtifactCheckResult, ArtifactSpec, ExhibitSpec, VerificationFinding
from water_scarcity.verify import main
import water_scarcity.verification.checks as checks_module


def _mirror_output_root(src: Path, dst: Path) -> Path:
    dst.mkdir(parents=True, exist_ok=True)
    for path in src.rglob("*"):
        relative = path.relative_to(src)
        target = dst / relative
        if path.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        os.symlink(path, target)
    return dst


def test_verifier_passes_on_current_outputs(tmp_path):
    json_path = tmp_path / "report.json"
    md_path = tmp_path / "report.md"

    exit_code = main(
        [
            "--standard",
            "documented-parity",
            "--json-out",
            str(json_path),
            "--md-out",
            str(md_path),
        ]
    )

    payload = json.loads(json_path.read_text(encoding="utf-8"))

    assert exit_code == 0
    assert md_path.exists()
    assert payload["overall_status"] == "passed_with_warnings"
    assert payload["summary"]["failures"] == 0
    figure_6 = next(item for item in payload["exhibit_results"] if item["exhibit_id"] == "figure_6")
    assert figure_6["status"] == "not_applicable"
    figure_3 = next(item for item in payload["exhibit_results"] if item["exhibit_id"] == "figure_3")
    assert any(finding["code"] == "known-report-alias-anomaly" for finding in figure_3["findings"])


def test_verifier_fails_when_required_output_is_missing(tmp_path):
    paths = build_project_paths()
    mirrored_root = _mirror_output_root(paths.output_root, tmp_path / "Outputs")
    (mirrored_root / "tables" / "Table3_GDPgr.xls").unlink()

    exit_code = main(
        [
            "--standard",
            "documented-parity",
            "--output-root",
            str(mirrored_root),
        ]
    )

    assert exit_code == 1


def test_verifier_fails_when_png_is_corrupted(tmp_path):
    paths = build_project_paths()
    mirrored_root = _mirror_output_root(paths.output_root, tmp_path / "Outputs")
    target = mirrored_root / "graphs" / "Fig1_water_pc.png"
    target.unlink()
    target.write_bytes(b"")

    exit_code = main(
        [
            "--standard",
            "documented-parity",
            "--output-root",
            str(mirrored_root),
        ]
    )

    assert exit_code == 1


def test_check_exhibits_fails_for_uncataloged_alias():
    custom_exhibit = ExhibitSpec(
        exhibit_id="custom",
        paper_label="Custom Exhibit",
        section="main",
        status_in_report="Custom",
        manual_changes_expected=False,
        actual_artifacts=(ArtifactSpec("graphs/Fig1_water_pc.png"),),
        report_aliases=("mystery_alias.png",),
        notes=(),
        verification_mode="required",
    )
    artifact_results = {
        "graphs/Fig1_water_pc.png": ArtifactCheckResult(
            relative_path="graphs/Fig1_water_pc.png",
            exists=True,
            required=True,
            supplementary=False,
            kind="png",
            parse_ok=True,
            parser_name="png",
            findings=(),
        )
    }
    original = checks_module.EXHIBITS
    checks_module.EXHIBITS = (custom_exhibit,)
    try:
        results, findings = check_exhibits(artifact_results, strict_doc_aliases=False)
    finally:
        checks_module.EXHIBITS = original

    assert results[0].status == "failed"
    assert any(finding.code == "unknown-report-alias" for finding in findings)
