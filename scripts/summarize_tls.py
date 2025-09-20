#!/usr/bin/env python3
"""Summarize traffic light programs from the LuST scenario."""

from __future__ import annotations

import argparse
import signal
import sys
import textwrap
from pathlib import Path
import xml.etree.ElementTree as ET


def load_tl_logics(tll_path: Path) -> list[ET.Element]:
    tree = ET.parse(tll_path)
    root = tree.getroot()
    return list(root.findall(".//tlLogic"))


def format_phase(phase: ET.Element) -> str:
    state = phase.attrib.get("state", "")
    duration = float(phase.attrib.get("duration", "0"))
    min_dur = phase.attrib.get("minDur")
    max_dur = phase.attrib.get("maxDur")
    extras = []
    if min_dur is not None or max_dur is not None:
        extras.append("adaptive duration")
        if min_dur is not None:
            extras.append(f"min={min_dur}")
        if max_dur is not None:
            extras.append(f"max={max_dur}")
    extras_str = f" ({', '.join(extras)})" if extras else ""
    return f"duration={duration:>5.1f}s state={state}{extras_str}"


def summarize(tll_path: Path, ids: set[str], show_phases: bool) -> int:
    tl_logics = load_tl_logics(tll_path)
    matched = 0
    for tl in tl_logics:
        tl_id = tl.attrib["id"]
        if ids and tl_id not in ids:
            continue
        matched += 1
        program_id = tl.attrib.get("programID", "")
        offset = tl.attrib.get("offset", "0")
        controller_type = tl.attrib.get("type", "static")
        print(f"TLS {tl_id} | program={program_id} | type={controller_type} | offset={offset}s")
        if show_phases:
            for idx, phase in enumerate(tl.findall("phase")):
                formatted = format_phase(phase)
                print(f"  Phase {idx:02d}: {formatted}")
        print()

    if ids and matched != len(ids):
        missing = ids - {tl.attrib["id"] for tl in tl_logics}
        if missing:
            print(f"Warning: {', '.join(sorted(missing))} not found in {tll_path.name}", file=sys.stderr)
            return 1
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inspect real-world TLS plans included with the LuST scenario.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """Examples:\n"
            "  %(prog)s\n"
            "  %(prog)s --id -10130 --id -10156 --phases\n"
            """
        ),
    )
    parser.add_argument(
        "--id",
        dest="ids",
        action="append",
        default=[],
        help="Filter by specific traffic light IDs (may be repeated).",
    )
    parser.add_argument(
        "--phases",
        dest="phases",
        action="store_true",
        help="Print full phase definitions for each matching controller.",
    )
    parser.add_argument(
        "--tll",
        dest="tll_path",
        type=Path,
        default=None,
        help="Override path to tll.static.xml (defaults to data/LuSTScenario/scenario/tll.static.xml).",
    )

    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[1]
    tll_default = project_root / "data" / "LuSTScenario" / "scenario" / "tll.static.xml"
    tll_path = args.tll_path or tll_default

    if not tll_path.exists():
        parser.error(f"Traffic light definition not found at {tll_path}. Run download_lust_scenario.sh first.")

    ids = set(args.ids)
    return summarize(tll_path, ids, args.phases)


if __name__ == "__main__":
    if hasattr(signal, "SIGPIPE"):
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    sys.exit(main())
