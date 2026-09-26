#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-/tmp}"
days="${2:-14}"

find "$target_dir" -type f \( -name '*.tmp' -o -name '*.temp' \) -mtime "+$days" -delete
