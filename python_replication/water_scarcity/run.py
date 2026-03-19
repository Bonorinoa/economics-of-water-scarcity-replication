from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

from .config import build_project_paths
from .oracle import check_stage_outputs
from .stages import ALL_STAGES, STAGE_REGISTRY, select_stages


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Water scarcity replication stage registry")
    parser.add_argument("--stage", default="all", choices=["all", *STAGE_REGISTRY.keys()])
    parser.add_argument("--data-root", type=Path, default=None)
    parser.add_argument("--output-root", type=Path, default=None)
    parser.add_argument("--manifest", type=Path, default=None)
    parser.add_argument("--json", action="store_true", help="Emit the selected stage manifest to stdout.")
    parser.add_argument(
        "--check-existing-outputs",
        action="store_true",
        help="Check whether the declared Stata output artifacts already exist.",
    )
    return parser


def _manifest(stage_names: Sequence[str], data_root: Path | None, output_root: Path | None) -> dict[str, object]:
    paths = build_project_paths(data_root=data_root, output_root=output_root)
    stages = select_stages(stage_names[0]) if len(stage_names) == 1 else [STAGE_REGISTRY[name] for name in stage_names]
    return {
        "repo_root": str(paths.repo_root),
        "data_root": str(paths.data_root),
        "output_root": str(paths.output_root),
        "stages": [stage.to_dict(paths.code_root, paths.output_root) for stage in stages],
    }


def _print_human_summary(manifest: dict[str, object]) -> None:
    print(f"Repo root: {manifest['repo_root']}")
    print(f"Data root: {manifest['data_root']}")
    print(f"Output root: {manifest['output_root']}")
    print("Stages:")
    for stage in manifest["stages"]:
        print(
            f"- {stage['stage_id']}: {stage['display_name']} "
            f"[{stage['category']}] -> {stage['stata_script']}"
        )


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    manifest = _manifest([args.stage], args.data_root, args.output_root)

    if args.manifest is not None:
        args.manifest.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    if args.json:
        print(json.dumps(manifest, indent=2))
    else:
        _print_human_summary(manifest)

    if not args.check_existing_outputs:
        return 0

    output_root = Path(manifest["output_root"])
    failures = 0
    for stage in select_stages(args.stage):
        check = check_stage_outputs(stage, output_root)
        if check.ok:
            print(f"[ok] {stage.stage_id}: {len(check.existing)} expected artifacts present")
        else:
            failures += 1
            print(f"[missing] {stage.stage_id}: {len(check.missing)} expected artifacts absent")
            for missing in check.missing:
                print(f"  - {missing}")
        if check.supplementary_missing:
            print(f"[info] {stage.stage_id}: {len(check.supplementary_missing)} supplementary artifacts absent")
            for missing in check.supplementary_missing:
                print(f"  - optional: {missing}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
