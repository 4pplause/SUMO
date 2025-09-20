#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCENARIO_ROOT="${PROJECT_ROOT}/data/LuSTScenario"
CONFIG_PATH="${SCENARIO_ROOT}/scenario/dua.static.sumocfg"
SUMO_BIN=${SUMO_BIN:-sumo}
SUMO_GUI_BIN=${SUMO_GUI_BIN:-sumo-gui}
GUI=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--gui] [-- <additional SUMO args>]

Runs the LuST scenario using the static signal programs, preserving real-world TLS plans.
SUMO binary defaults to 'sumo'. Override with SUMO_BIN or use --gui to launch 'sumo-gui'.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gui)
      GUI=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ ! -d "${SCENARIO_ROOT}" ]]; then
  echo "LuST scenario not found at ${SCENARIO_ROOT}. Run scripts/download_lust_scenario.sh first." >&2
  exit 1
fi

if [[ ! -f "${CONFIG_PATH}" ]]; then
  echo "Cannot locate configuration file ${CONFIG_PATH}." >&2
  exit 2
fi

if [[ ${GUI} -eq 1 ]]; then
  SUMO_CMD="${SUMO_GUI_BIN}"
else
  SUMO_CMD="${SUMO_BIN}"
fi

echo "Running LuST static configuration using ${SUMO_CMD}..."
exec "${SUMO_CMD}" -c "${CONFIG_PATH}" "$@"
