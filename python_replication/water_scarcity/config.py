from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ProjectPaths:
    repo_root: Path
    code_root: Path
    data_root: Path
    output_root: Path


def detect_repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def build_project_paths(
    data_root: Path | None = None,
    output_root: Path | None = None,
) -> ProjectPaths:
    repo_root = detect_repo_root()
    package_root = repo_root / "Reproducibility Package"
    return ProjectPaths(
        repo_root=repo_root,
        code_root=package_root / "Codes",
        data_root=data_root or package_root / "Data",
        output_root=output_root or package_root / "Outputs",
    )
