# Real-world Traffic Signal Workspace for SUMO

This repository bootstraps a Simulation of Urban Mobility (SUMO) workspace that
reuses the **Luxembourg SUMO Traffic (LuST)** scenario, whose signal timing
plans are derived from field deployments. The goal is to quickly obtain a
simulation configuration in which traffic light logic mirrors a real European
city so that additional experiments (e.g., corridor studies, new control
strategies) can start from a validated baseline.

## Why LuST?

The LuST scenario ships with:

- an OpenStreetMap-derived network covering Luxembourg City,
- calibrated 24-hour travel demand, and
- both static and actuated traffic signal programs that follow real-world
  controller parameters.

By default we load the static (time-of-day) programs to guarantee deterministic
replays of the published signal plans.

## Repository layout

```
.
├── scripts/                   # Utility scripts to download and inspect the scenario
├── scenarios/lust/            # Notes and references that contextualize LuST
├── docs/                      # Additional documentation and planning notes
└── data/                      # Populated after downloading LuST (ignored by git)
```

## Getting started

1. **Download the LuST data package**

   ```bash
   ./scripts/download_lust_scenario.sh
   ```

   This retrieves the upstream LuST repository (≈80 MB), extracts the published
   `scenario/` directory, and places it under `data/LuSTScenario/`.

2. **Inspect traffic light logic (optional but recommended)**

   ```bash
    ./scripts/summarize_tls.py --id -10130 --id -10156 --phases
   ```

   Replace the IDs with intersections of interest; omit `--id` to list all
   controllers contained in `tll.static.xml`.

3. **Run the static-plan simulation**

   ```bash
   ./scripts/run_lust_static.sh
   ```

   Use `--gui` to launch `sumo-gui` or pass extra SUMO CLI options after `--`.

## Next steps

- Lock the simulation to specific time windows (e.g., AM/PM peaks) by trimming
  the demand files or applying departure time filters.
- Export per-intersection measurements (waiting time, delay, queue lengths)
  using SUMO detectors or TraCI scripts.
- Compare the provided actuated plans (`dua.actuated.sumocfg`) with the static
  baseline to study adaptive behaviors.

## Requirements

- SUMO ≥ 1.10.0 (any recent release should work even though LuST was validated
  on 0.26).
- `curl`, `unzip`, and standard Unix utilities for the helper scripts.
- Python ≥ 3.10 (for `scripts/summarize_tls.py`).

