from __future__ import annotations

from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Any


@dataclass(frozen=True)
class ArtifactSpec:
    relative_path: str
    description: str = ""

    @property
    def normalized_path(self) -> str:
        return PurePosixPath(self.relative_path).as_posix()

    @property
    def basename(self) -> str:
        return PurePosixPath(self.relative_path).name

    def to_dict(self) -> dict[str, Any]:
        return {
            "relative_path": self.normalized_path,
            "basename": self.basename,
            "description": self.description,
        }


@dataclass(frozen=True)
class ExhibitSpec:
    exhibit_id: str
    paper_label: str
    section: str
    status_in_report: str
    manual_changes_expected: bool
    actual_artifacts: tuple[ArtifactSpec, ...]
    report_aliases: tuple[str, ...]
    notes: tuple[str, ...]
    verification_mode: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "exhibit_id": self.exhibit_id,
            "paper_label": self.paper_label,
            "section": self.section,
            "status_in_report": self.status_in_report,
            "manual_changes_expected": self.manual_changes_expected,
            "actual_artifacts": [artifact.to_dict() for artifact in self.actual_artifacts],
            "report_aliases": list(self.report_aliases),
            "notes": list(self.notes),
            "verification_mode": self.verification_mode,
        }


@dataclass(frozen=True)
class VerificationFinding:
    severity: str
    code: str
    message: str
    exhibit_id: str | None = None
    artifact_path: str | None = None
    alias: str | None = None

    def to_dict(self) -> dict[str, Any]:
        payload = {
            "severity": self.severity,
            "code": self.code,
            "message": self.message,
        }
        if self.exhibit_id is not None:
            payload["exhibit_id"] = self.exhibit_id
        if self.artifact_path is not None:
            payload["artifact_path"] = self.artifact_path
        if self.alias is not None:
            payload["alias"] = self.alias
        return payload


@dataclass(frozen=True)
class ArtifactCheckResult:
    relative_path: str
    exists: bool
    required: bool
    supplementary: bool
    kind: str
    parse_ok: bool | None
    parser_name: str | None
    findings: tuple[VerificationFinding, ...]

    @property
    def status(self) -> str:
        if any(finding.severity == "failure" for finding in self.findings):
            return "failed"
        if any(finding.severity == "warning" for finding in self.findings):
            return "warning"
        if not self.exists:
            return "missing"
        return "passed"

    def to_dict(self) -> dict[str, Any]:
        return {
            "relative_path": self.relative_path,
            "exists": self.exists,
            "required": self.required,
            "supplementary": self.supplementary,
            "kind": self.kind,
            "parse_ok": self.parse_ok,
            "parser_name": self.parser_name,
            "status": self.status,
            "findings": [finding.to_dict() for finding in self.findings],
        }


@dataclass(frozen=True)
class ExhibitCheckResult:
    exhibit_id: str
    paper_label: str
    verification_mode: str
    status: str
    actual_artifacts: tuple[str, ...]
    report_aliases: tuple[str, ...]
    findings: tuple[VerificationFinding, ...]
    notes: tuple[str, ...]

    def to_dict(self) -> dict[str, Any]:
        return {
            "exhibit_id": self.exhibit_id,
            "paper_label": self.paper_label,
            "verification_mode": self.verification_mode,
            "status": self.status,
            "actual_artifacts": list(self.actual_artifacts),
            "report_aliases": list(self.report_aliases),
            "findings": [finding.to_dict() for finding in self.findings],
            "notes": list(self.notes),
        }


@dataclass(frozen=True)
class VerificationReport:
    run_timestamp: str
    repo_root: str
    output_root: str
    verification_standard: str
    overall_status: str
    summary: dict[str, Any]
    stage_results: tuple[dict[str, Any], ...]
    exhibit_results: tuple[ExhibitCheckResult, ...]
    artifact_inventory: tuple[dict[str, Any], ...]
    known_anomalies: tuple[dict[str, Any], ...]
    hashes: dict[str, str]

    def to_dict(self) -> dict[str, Any]:
        return {
            "run_timestamp": self.run_timestamp,
            "repo_root": self.repo_root,
            "output_root": self.output_root,
            "verification_standard": self.verification_standard,
            "overall_status": self.overall_status,
            "summary": self.summary,
            "stage_results": list(self.stage_results),
            "exhibit_results": [result.to_dict() for result in self.exhibit_results],
            "artifact_inventory": list(self.artifact_inventory),
            "known_anomalies": list(self.known_anomalies),
            "hashes": self.hashes,
        }
