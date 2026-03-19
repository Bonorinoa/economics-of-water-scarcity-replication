from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

from .config import build_project_paths
from .verification.checks import verify_documented_parity
from .verification.report import render_console_summary, render_json, render_markdown


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Verify documented parity for the Frost et al. Stata outputs.")
    parser.add_argument("--standard", choices=["documented-parity"], default="documented-parity")
    parser.add_argument("--output-root", type=Path, default=None)
    parser.add_argument("--json-out", type=Path, default=None)
    parser.add_argument("--md-out", type=Path, default=None)
    parser.set_defaults(include_hashes=True)
    parser.add_argument("--include-hashes", dest="include_hashes", action="store_true")
    parser.add_argument("--no-hashes", dest="include_hashes", action="store_false")
    parser.add_argument("--fail-on-warning", action="store_true")
    parser.add_argument("--strict-doc-aliases", action="store_true")
    return parser


def _write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    paths = build_project_paths(output_root=args.output_root)
    if not paths.output_root.exists():
        print(f"Output root does not exist: {paths.output_root}")
        return 2

    try:
        report = verify_documented_parity(
            paths,
            include_hashes=args.include_hashes,
            fail_on_warning=args.fail_on_warning,
            strict_doc_aliases=args.strict_doc_aliases,
        )
    except ValueError as exc:
        print(str(exc))
        return 2

    if args.json_out is not None:
        _write_text(args.json_out, render_json(report))
    if args.md_out is not None:
        _write_text(args.md_out, render_markdown(report))

    print(render_console_summary(report))
    if report.overall_status == "failed":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
