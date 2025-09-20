# LuST Scenario Notes

The Luxembourg SUMO Traffic (LuST) scenario is a 24-hour microscopic simulation
based on real data collected by Luxembourg's traffic management authorities.
Key traits relevant to traffic-signal replication:

- **Static programs** (`dua.static.sumocfg` + `tll.static.xml`): time-of-day
  plans that mirror the controller schedules deployed on-street. Each `tlLogic`
  entry includes explicit phase orders, durations, offsets, and yellow durations
  needed to reproduce the municipal coordination strategy.
- **Actuated programs** (`dua.actuated.sumocfg` + `tll.actuated.xml`): the same
  network with vehicle-actuated phases, providing min/max durations that match
  detector-actuated logic.
- **Detector placements** (`e1detectors.add.xml`): loops positioned to match the
  real sensor network, enabling validation of queue and flow metrics.

### Mapping intersections

The `tll.static.xml` file references controllers using IDs derived from
OpenStreetMap node identifiers (transformed during network conversion). Typical
examples include identifiers such as `-10130`, `-10156`, or `-10438`.

Use `scripts/summarize_tls.py --id <TLS_ID> --phases` to inspect detailed phase
plans before implementing control logic changes. Omit `--id` to list every
controller defined in the scenario and identify the ones relevant to your
corridor.

### Recommended workflow

1. Download the scenario with `scripts/download_lust_scenario.sh`.
2. Visualise the network via `sumo-gui` to verify geometry and detector
   placement.
3. Export baseline metrics (travel time, waiting time) for the corridor of
   interest.
4. Iterate on controller logic via TraCI or by editing the relevant `tlLogic`
   entries while keeping backups of the original real-world plans for reference.

