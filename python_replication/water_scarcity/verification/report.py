from __future__ import annotations

import json

from .types import VerificationReport


def render_console_summary(report: VerificationReport) -> str:
    return "\n".join(
        [
            f"Verification standard: {report.verification_standard}",
            f"Overall status: {report.overall_status}",
            f"Output root: {report.output_root}",
            (
                "Required artifacts: "
                f"{report.summary['required_artifacts_passed']}/{report.summary['required_artifacts_checked']} passed"
            ),
            f"Warnings: {report.summary['warnings']}",
            f"Failures: {report.summary['failures']}",
        ]
    )


def render_markdown(report: VerificationReport) -> str:
    lines: list[str] = []
    lines.append("# Documented-Parity Verification Report")
    lines.append("")
    lines.append("## Verification Standard")
    lines.append("")
    lines.append(f"- Standard: `{report.verification_standard}`")
    lines.append(f"- Overall status: `{report.overall_status}`")
    lines.append(f"- Repo root: `{report.repo_root}`")
    lines.append(f"- Output root: `{report.output_root}`")
    lines.append(f"- Run timestamp (UTC): `{report.run_timestamp}`")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Required artifacts checked: `{report.summary['required_artifacts_checked']}`")
    lines.append(f"- Required artifacts passed: `{report.summary['required_artifacts_passed']}`")
    lines.append(f"- Warnings: `{report.summary['warnings']}`")
    lines.append(f"- Failures: `{report.summary['failures']}`")
    lines.append("")
    lines.append("## Stage Results")
    lines.append("")
    lines.append("| Stage | Status | Required | Supplementary |")
    lines.append("| --- | --- | --- | --- |")
    for stage in report.stage_results:
        lines.append(
            "| "
            f"{stage['display_name']} "
            f"| {stage['status']} "
            f"| {stage['required_outputs']['present']}/{stage['required_outputs']['present'] + stage['required_outputs']['missing']} "
            f"| {stage['supplementary_outputs']['present']}/{stage['supplementary_outputs']['present'] + stage['supplementary_outputs']['missing']} |"
        )
    lines.append("")
    lines.append("## Exhibit Results")
    lines.append("")
    lines.append("| Exhibit | Status | Canonical Artifacts | Report Aliases |")
    lines.append("| --- | --- | --- | --- |")
    for exhibit in report.exhibit_results:
        artifacts = ", ".join(exhibit.actual_artifacts) if exhibit.actual_artifacts else "n/a"
        aliases = ", ".join(exhibit.report_aliases) if exhibit.report_aliases else "n/a"
        lines.append(f"| {exhibit.paper_label} | {exhibit.status} | {artifacts} | {aliases} |")
    lines.append("")
    lines.append("## Known Documentation Anomalies")
    lines.append("")
    for anomaly in report.known_anomalies:
        lines.append(f"- `{anomaly['anomaly_id']}`: {anomaly['message']}")
    lines.append("")
    lines.append("## Artifact Hash Manifest")
    lines.append("")
    if report.hashes:
        lines.append("```text")
        for relative_path, sha256sum in sorted(report.hashes.items()):
            lines.append(f"{sha256sum}  {relative_path}")
        lines.append("```")
    else:
        lines.append("_Hashes were disabled for this run._")
    lines.append("")
    lines.append("## Conclusion")
    lines.append("")
    if report.overall_status == "failed":
        lines.append("documented parity failed")
    else:
        lines.append("documented parity passed")
    lines.append("")
    return "\n".join(lines)


def render_json(report: VerificationReport) -> str:
    return json.dumps(report.to_dict(), indent=2) + "\n"
