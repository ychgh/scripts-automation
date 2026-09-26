#!/usr/bin/env bash
set -euo pipefail

log_dir="${1:-/var/log}"
days="${2:-7}"

find "$log_dir" -type f -name '*.log' -mtime "+$days" -print0 |
while IFS= read -r -d '' file; do
  archive="${file}.gz"
  temp_archive="${archive}.tmp.$$"
  lock_dir="${archive}.lock"
  gzip -c "$file" > "$temp_archive"
  if mkdir "$lock_dir" 2>/dev/null; then
    if [ -e "$archive" ]; then
      echo "Skipping $file because $archive already exists" >&2
      rm -f "$temp_archive"
    else
      mv "$temp_archive" "$archive"
      rm -f "$file"
    fi
    rmdir "$lock_dir"
  else
    echo "Skipping $file because $archive is locked by another process" >&2
    rm -f "$temp_archive"
  fi
done
