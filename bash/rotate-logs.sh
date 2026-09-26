#!/usr/bin/env bash
set -euo pipefail

log_dir="${1:-/var/log}"
days="${2:-7}"

find "$log_dir" -type f -name '*.log' -mtime "+$days" -print0 |
while IFS= read -r -d '' file; do
  archive="${file}.gz"
  if [ -e "$archive" ]; then
    echo "Skipping $file because $archive already exists" >&2
    continue
  fi
  gzip -c "$file" > "$archive"
  rm -f "$file"
done
