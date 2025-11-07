#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SOURCE_IMAGE="${1:-${REPO_ROOT}/assets/images/waves.png}"

python3 "${REPO_ROOT}/tool/generate_app_icons.py" "${SOURCE_IMAGE}"
