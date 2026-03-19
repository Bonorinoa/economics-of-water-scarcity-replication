from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from pathlib import Path

from water_scarcity.stages.base import StageDefinition


def _sha256sum(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_stage_artifact_index(
    stages: tuple[StageDefinition, ...] | list[StageDefinition],
) -> tuple[dict[str, tuple[str, ...]], dict[str, tuple[str, ...]]]:
    required_index: dict[str, list[str]] = {}
    supplementary_index: dict[str, list[str]] = {}
    for stage in stages:
        for relative_path in stage.expected_outputs:
            required_index.setdefault(relative_path, []).append(stage.stage_id)
        for relative_path in stage.supplementary_outputs:
            supplementary_index.setdefault(relative_path, []).append(stage.stage_id)
    return (
        {key: tuple(sorted(value)) for key, value in required_index.items()},
        {key: tuple(sorted(value)) for key, value in supplementary_index.items()},
    )


def collect_output_inventory(
    output_root: Path,
    stages: tuple[StageDefinition, ...] | list[StageDefinition],
    *,
    include_hashes: bool,
) -> tuple[tuple[dict[str, object], ...], dict[str, str]]:
    required_index, supplementary_index = build_stage_artifact_index(stages)
    inventory: list[dict[str, object]] = []
    hashes: dict[str, str] = {}
    for path in sorted(output_root.rglob("*")):
        if not path.is_file():
            continue
        if any(part.startswith(".") for part in path.relative_to(output_root).parts):
            continue
        relative_path = path.relative_to(output_root).as_posix()
        stat = path.stat()
        sha256sum = _sha256sum(path) if include_hashes else None
        if sha256sum is not None:
            hashes[relative_path] = sha256sum
        inventory.append(
            {
                "relative_path": relative_path,
                "kind": path.suffix.lower().lstrip(".") or "no_extension",
                "size_bytes": stat.st_size,
                "modified_at_utc": datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).isoformat(),
                "required_by_stages": list(required_index.get(relative_path, ())),
                "supplementary_by_stages": list(supplementary_index.get(relative_path, ())),
                "sha256": sha256sum,
            }
        )
    return tuple(inventory), hashes
