from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


@dataclass(frozen=True)
class StageDefinition:
    stage_id: str
    display_name: str
    category: str
    stata_script: str
    description: str
    expected_outputs: tuple[str, ...] = ()
    supplementary_outputs: tuple[str, ...] = ()
    dependencies: tuple[str, ...] = ()
    notes: tuple[str, ...] = ()
    port_status: str = "scaffold"

    def stata_script_path(self, code_root: Path) -> Path:
        return code_root / self.stata_script

    def output_paths(self, output_root: Path) -> tuple[Path, ...]:
        return tuple(output_root / relative for relative in self.expected_outputs)

    def supplementary_output_paths(self, output_root: Path) -> tuple[Path, ...]:
        return tuple(output_root / relative for relative in self.supplementary_outputs)

    def to_dict(self, code_root: Path, output_root: Path) -> dict[str, Any]:
        return {
            "stage_id": self.stage_id,
            "display_name": self.display_name,
            "category": self.category,
            "stata_script": str(self.stata_script_path(code_root)),
            "description": self.description,
            "expected_outputs": [str(path) for path in self.output_paths(output_root)],
            "supplementary_outputs": [str(path) for path in self.supplementary_output_paths(output_root)],
            "dependencies": list(self.dependencies),
            "notes": list(self.notes),
            "port_status": self.port_status,
        }


def make_stage(
    *,
    stage_id: str,
    display_name: str,
    category: str,
    stata_script: str,
    description: str,
    expected_outputs: Iterable[str] = (),
    supplementary_outputs: Iterable[str] = (),
    dependencies: Iterable[str] = (),
    notes: Iterable[str] = (),
) -> StageDefinition:
    return StageDefinition(
        stage_id=stage_id,
        display_name=display_name,
        category=category,
        stata_script=stata_script,
        description=description,
        expected_outputs=tuple(expected_outputs),
        supplementary_outputs=tuple(supplementary_outputs),
        dependencies=tuple(dependencies),
        notes=tuple(notes),
    )
