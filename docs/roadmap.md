# Roadmap

This document keeps track of the immediate next steps for tailoring the LuST
scenario toward corridor-focused studies with real signal plans.

## Phase 1 — Baseline extraction (current)

- [x] Automate retrieval of the LuST dataset.
- [x] Provide helper scripts to run the static timing plans in SUMO.
- [x] Offer a quick inspection utility for the published `tll.static.xml` file.

## Phase 2 — Corridor scoping (up next)

- Identify a handful of signalised intersections that form a coherent corridor
  (e.g., the Avenue de la Gare axis) using OpenStreetMap IDs and LuST TLS IDs.
- Reduce the demand to a shorter analysis window (morning or evening peak).
- Generate per-lane detection outputs (using `e1` or `e2` detectors) to validate
  queue spillback against reference data.

## Phase 3 — Experimentation

- Prototype new control strategies with TraCI while keeping the published plan
  as the baseline.
- Compare actuated vs. static programs under identical demand slices.
- Integrate additional data sources (e.g., floating vehicle traces) for
  calibration or validation.

