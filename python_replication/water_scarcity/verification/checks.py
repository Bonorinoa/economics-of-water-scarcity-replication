from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

from water_scarcity.config import ProjectPaths
from water_scarcity.oracle import check_stage_outputs
from water_scarcity.stages import ALL_STAGES

from .collect import build_stage_artifact_index, collect_output_inventory
from .parsers import validate_artifact
from .reference import EXHIBITS, GENERAL_ANOMALIES, get_known_alias_anomaly, validate_reference_manifest
from .types import ArtifactCheckResult, ExhibitCheckResult, VerificationFinding, VerificationReport


def _artifact_kind(relative_path: str) -> str:
    suffix = Path(relative_path).suffix.lower()
    return suffix.lstrip(".") or "no_extension"


def _finding_count(findings: list[VerificationFinding], severity: str) -> int:
    return sum(1 for finding in findings if finding.severity == severity)


def _status_from_findings(findings: list[VerificationFinding], *, not_applicable: bool = False) -> str:
    if not_applicable:
        return "not_applicable"
    if any(finding.severity == "failure" for finding in findings):
        return "failed"
    if any(finding.severity == "warning" for finding in findings):
        return "warning"
    return "passed"


def _build_artifact_results(
    output_root: Path,
    *,
    required_paths: set[str],
    supplementary_paths: set[str],
) -> dict[str, ArtifactCheckResult]:
    artifact_results: dict[str, ArtifactCheckResult] = {}
    for relative_path in sorted(required_paths | supplementary_paths):
        path = output_root / relative_path
        findings: list[VerificationFinding] = []
        exists = path.exists()
        parse_ok = None
        parser_name = None
        if exists:
            outcome = validate_artifact(path)
            parse_ok = outcome.ok
            parser_name = outcome.parser_name
            if not outcome.ok:
                findings.append(
                    VerificationFinding(
                        severity="failure",
                        code="artifact-parse-failed",
                        message=outcome.detail,
                        artifact_path=relative_path,
                    )
                )
            elif outcome.degraded:
                findings.append(
                    VerificationFinding(
                        severity="info",
                        code="artifact-parse-degraded",
                        message=outcome.detail,
                        artifact_path=relative_path,
                    )
                )
        elif relative_path in required_paths:
            findings.append(
                VerificationFinding(
                    severity="failure",
                    code="artifact-missing",
                    message=f"Required artifact is missing: {relative_path}",
                    artifact_path=relative_path,
                )
            )
        else:
            findings.append(
                VerificationFinding(
                    severity="warning",
                    code="supplementary-artifact-missing",
                    message=f"Supplementary artifact is absent on this machine: {relative_path}",
                    artifact_path=relative_path,
                )
            )
        artifact_results[relative_path] = ArtifactCheckResult(
            relative_path=relative_path,
            exists=exists,
            required=relative_path in required_paths,
            supplementary=relative_path in supplementary_paths,
            kind=_artifact_kind(relative_path),
            parse_ok=parse_ok,
            parser_name=parser_name,
            findings=tuple(findings),
        )
    return artifact_results


def _check_stage_results(output_root: Path) -> tuple[tuple[dict[str, object], ...], list[VerificationFinding], set[str], set[str]]:
    stage_results: list[dict[str, object]] = []
    findings: list[VerificationFinding] = []
    required_paths: set[str] = set()
    supplementary_paths: set[str] = set()
    for stage in ALL_STAGES:
        check = check_stage_outputs(stage, output_root)
        required_paths.update(stage.expected_outputs)
        supplementary_paths.update(stage.supplementary_outputs)
        stage_findings: list[VerificationFinding] = []
        for path in check.missing:
            relative_path = path.relative_to(output_root).as_posix()
            stage_findings.append(
                VerificationFinding(
                    severity="failure",
                    code="stage-required-output-missing",
                    message=f"{stage.display_name} is missing required output {relative_path}.",
                    artifact_path=relative_path,
                )
            )
        for path in check.supplementary_missing:
            relative_path = path.relative_to(output_root).as_posix()
            stage_findings.append(
                VerificationFinding(
                    severity="warning",
                    code="stage-supplementary-output-missing",
                    message=f"{stage.display_name} is missing supplementary output {relative_path}.",
                    artifact_path=relative_path,
                )
            )
        findings.extend(stage_findings)
        stage_results.append(
            {
                "stage_id": stage.stage_id,
                "display_name": stage.display_name,
                "status": _status_from_findings(stage_findings),
                "required_outputs": {
                    "present": len(check.existing),
                    "missing": len(check.missing),
                    "paths": list(stage.expected_outputs),
                },
                "supplementary_outputs": {
                    "present": len(check.supplementary_existing),
                    "missing": len(check.supplementary_missing),
                    "paths": list(stage.supplementary_outputs),
                },
                "findings": [finding.to_dict() for finding in stage_findings],
                "notes": list(stage.notes),
            }
        )
    return tuple(stage_results), findings, required_paths, supplementary_paths


def check_exhibits(
    artifact_results: dict[str, ArtifactCheckResult],
    *,
    strict_doc_aliases: bool,
) -> tuple[tuple[ExhibitCheckResult, ...], list[VerificationFinding]]:
    exhibit_results: list[ExhibitCheckResult] = []
    findings: list[VerificationFinding] = []
    for exhibit in EXHIBITS:
        exhibit_findings: list[VerificationFinding] = []
        if exhibit.verification_mode == "not_applicable":
            exhibit_findings.append(
                VerificationFinding(
                    severity="warning",
                    code="exhibit-not-applicable",
                    message="This exhibit is outside coded replication and is intentionally excluded from artifact parity.",
                    exhibit_id=exhibit.exhibit_id,
                )
            )
            result = ExhibitCheckResult(
                exhibit_id=exhibit.exhibit_id,
                paper_label=exhibit.paper_label,
                verification_mode=exhibit.verification_mode,
                status=_status_from_findings(exhibit_findings, not_applicable=True),
                actual_artifacts=tuple(),
                report_aliases=exhibit.report_aliases,
                findings=tuple(exhibit_findings),
                notes=exhibit.notes,
            )
            exhibit_results.append(result)
            findings.extend(exhibit_findings)
            continue

        canonical_basenames = {artifact.basename for artifact in exhibit.actual_artifacts}
        for artifact in exhibit.actual_artifacts:
            artifact_result = artifact_results[artifact.normalized_path]
            for finding in artifact_result.findings:
                exhibit_findings.append(
                    VerificationFinding(
                        severity=finding.severity,
                        code=finding.code,
                        message=finding.message,
                        exhibit_id=exhibit.exhibit_id,
                        artifact_path=finding.artifact_path,
                    )
                )
        for alias in exhibit.report_aliases:
            alias_name = Path(alias).name
            if alias_name in canonical_basenames:
                continue
            anomaly = get_known_alias_anomaly(exhibit.exhibit_id, alias_name)
            if anomaly is None:
                exhibit_findings.append(
                    VerificationFinding(
                        severity="failure",
                        code="unknown-report-alias",
                        message=f"Report alias {alias_name} is not covered by the anomaly catalog.",
                        exhibit_id=exhibit.exhibit_id,
                        alias=alias_name,
                    )
                )
                continue
            severity = "failure" if strict_doc_aliases else "warning"
            targets = ", ".join(anomaly["canonical_targets"])
            exhibit_findings.append(
                VerificationFinding(
                    severity=severity,
                    code="known-report-alias-anomaly",
                    message=f"{anomaly['message']} Canonical target(s): {targets}.",
                    exhibit_id=exhibit.exhibit_id,
                    alias=alias_name,
                )
            )
        if exhibit.manual_changes_expected:
            exhibit_findings.append(
                VerificationFinding(
                    severity="warning",
                    code="manual-paper-adjustment-expected",
                    message="The World Bank report says the published exhibit includes manual changes relative to raw code output.",
                    exhibit_id=exhibit.exhibit_id,
                )
            )
        findings.extend(exhibit_findings)
        exhibit_results.append(
            ExhibitCheckResult(
                exhibit_id=exhibit.exhibit_id,
                paper_label=exhibit.paper_label,
                verification_mode=exhibit.verification_mode,
                status=_status_from_findings(exhibit_findings),
                actual_artifacts=tuple(artifact.normalized_path for artifact in exhibit.actual_artifacts),
                report_aliases=exhibit.report_aliases,
                findings=tuple(exhibit_findings),
                notes=exhibit.notes,
            )
        )
    return tuple(exhibit_results), findings


def verify_documented_parity(
    paths: ProjectPaths,
    *,
    include_hashes: bool = True,
    fail_on_warning: bool = False,
    strict_doc_aliases: bool = False,
) -> VerificationReport:
    manifest_issues = validate_reference_manifest(strict_doc_aliases=strict_doc_aliases)
    if manifest_issues:
        raise ValueError("Reference manifest is invalid:\n- " + "\n- ".join(manifest_issues))

    inventory, hashes = collect_output_inventory(paths.output_root, ALL_STAGES, include_hashes=include_hashes)
    stage_results, stage_findings, required_stage_paths, supplementary_stage_paths = _check_stage_results(paths.output_root)

    exhibit_required_paths = {
        artifact.normalized_path
        for exhibit in EXHIBITS
        if exhibit.verification_mode == "required"
        for artifact in exhibit.actual_artifacts
    }
    artifact_results = _build_artifact_results(
        paths.output_root,
        required_paths=required_stage_paths | exhibit_required_paths,
        supplementary_paths=supplementary_stage_paths,
    )
    exhibit_results, exhibit_findings = check_exhibits(
        artifact_results,
        strict_doc_aliases=strict_doc_aliases,
    )

    all_findings = [*stage_findings, *exhibit_findings]
    failure_count = _finding_count(all_findings, "failure")
    warning_count = _finding_count(all_findings, "warning")

    overall_status = "passed"
    if failure_count:
        overall_status = "failed"
    elif warning_count:
        overall_status = "passed_with_warnings"
    if fail_on_warning and warning_count and overall_status != "failed":
        overall_status = "failed"

    stage_required_artifact_count = len(required_stage_paths | exhibit_required_paths)
    required_artifacts_passed = sum(
        1
        for relative_path in (required_stage_paths | exhibit_required_paths)
        if artifact_results[relative_path].exists and artifact_results[relative_path].parse_ok is not False
    )

    required_index, supplementary_index = build_stage_artifact_index(ALL_STAGES)
    inventory_map = {entry["relative_path"]: dict(entry) for entry in inventory}
    for relative_path, artifact_result in artifact_results.items():
        entry = inventory_map.setdefault(
            relative_path,
            {
                "relative_path": relative_path,
                "kind": artifact_result.kind,
                "size_bytes": None,
                "modified_at_utc": None,
                "required_by_stages": list(required_index.get(relative_path, ())),
                "supplementary_by_stages": list(supplementary_index.get(relative_path, ())),
                "sha256": hashes.get(relative_path),
            },
        )
        entry["exists"] = artifact_result.exists
        entry["parse_ok"] = artifact_result.parse_ok
        entry["parser_name"] = artifact_result.parser_name
        entry["status"] = artifact_result.status
        entry["findings"] = [finding.to_dict() for finding in artifact_result.findings]

    return VerificationReport(
        run_timestamp=datetime.now(timezone.utc).isoformat(),
        repo_root=str(paths.repo_root),
        output_root=str(paths.output_root),
        verification_standard="documented-parity",
        overall_status=overall_status,
        summary={
            "required_artifacts_checked": stage_required_artifact_count,
            "required_artifacts_passed": required_artifacts_passed,
            "warnings": warning_count,
            "failures": failure_count,
        },
        stage_results=stage_results,
        exhibit_results=exhibit_results,
        artifact_inventory=tuple(sorted(inventory_map.values(), key=lambda item: item["relative_path"])),
        known_anomalies=GENERAL_ANOMALIES,
        hashes=hashes if include_hashes else {},
    )
