#!/usr/bin/env bash
set -euo pipefail

log_dir="${1:-/var/log}"
days="${2:-7}"

find "$log_dir" -type f -name '*.log' -mtime "+$days" -print0 |
while IFS= read -r -d '' file; do
  archive="${file}.gz"
  temp_archive="${archive}.tmp.$$"
  gzip -c "$file" > "$temp_archive"
  if ln "$temp_archive" "$archive" 2>/dev/null; then
    rm -f "$temp_archive" "$file"
  else
    echo "Skipping $file because $archive already exists" >&2
    rm -f "$temp_archive"
  fi
done
