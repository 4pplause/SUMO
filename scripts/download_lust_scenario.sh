#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/lcodeca/LuSTScenario/archive/refs/heads/master.zip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${PROJECT_ROOT}/data/LuSTScenario"
DOWNLOAD_DIR="${PROJECT_ROOT}/data/.downloads"
FORCE=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--force]

Downloads the Luxembourg SUMO Traffic (LuST) scenario into data/LuSTScenario.
Existing files are left untouched unless --force is provided.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -d "${TARGET_ROOT}" && ${FORCE} -eq 0 ]]; then
  echo "LuST scenario already present at ${TARGET_ROOT}. Use --force to re-download."
  exit 0
fi

mkdir -p "${DOWNLOAD_DIR}"
TMP_DIR="$(mktemp -d)"
ZIP_PATH="${DOWNLOAD_DIR}/LuSTScenario-master.zip"

if [[ ${FORCE} -eq 1 || ! -f "${ZIP_PATH}" ]]; then
  echo "Downloading LuST scenario archive from ${REPO_URL}..."
  curl -L --fail --progress-bar "${REPO_URL}" -o "${ZIP_PATH}"
else
  echo "Re-using cached archive at ${ZIP_PATH}."
fi

echo "Extracting archive..."
unzip -q -o "${ZIP_PATH}" -d "${TMP_DIR}"
SRC_DIR="$(find "${TMP_DIR}" -mindepth 1 -maxdepth 1 -type d -name 'LuSTScenario*' -print -quit)"

if [[ -z "${SRC_DIR}" ]]; then
  echo "Could not locate extracted LuSTScenario directory." >&2
  exit 2
fi

rm -rf "${TARGET_ROOT}"
mkdir -p "${TARGET_ROOT}"

# Copy only the relevant parts of the upstream repository.
cp -R "${SRC_DIR}/scenario" "${TARGET_ROOT}/"
cp -R "${SRC_DIR}/docs" "${TARGET_ROOT}/"
cp "${SRC_DIR}/README.md" "${TARGET_ROOT}/"
cp "${SRC_DIR}/CHANGELOG.md" "${TARGET_ROOT}/" 2>/dev/null || true
cp "${SRC_DIR}/LICENSE.md" "${TARGET_ROOT}/"

rm -rf "${TMP_DIR}"

echo "LuST scenario extracted to ${TARGET_ROOT}."
