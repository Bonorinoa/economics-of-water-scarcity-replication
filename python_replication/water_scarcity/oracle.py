from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .stages.base import StageDefinition


@dataclass(frozen=True)
class OutputCheck:
    stage_id: str
    existing: tuple[Path, ...]
    missing: tuple[Path, ...]
    supplementary_existing: tuple[Path, ...]
    supplementary_missing: tuple[Path, ...]

    @property
    def ok(self) -> bool:
        return not self.missing


def check_stage_outputs(stage: StageDefinition, output_root: Path) -> OutputCheck:
    existing: list[Path] = []
    missing: list[Path] = []
    supplementary_existing: list[Path] = []
    supplementary_missing: list[Path] = []
    for candidate in stage.output_paths(output_root):
        if candidate.exists():
            existing.append(candidate)
        else:
            missing.append(candidate)
    for candidate in stage.supplementary_output_paths(output_root):
        if candidate.exists():
            supplementary_existing.append(candidate)
        else:
            supplementary_missing.append(candidate)
    return OutputCheck(
        stage_id=stage.stage_id,
        existing=tuple(existing),
        missing=tuple(missing),
        supplementary_existing=tuple(supplementary_existing),
        supplementary_missing=tuple(supplementary_missing),
    )
