#!/usr/bin/env bash
set -euo pipefail

log_dir="${1:-/var/log}"
days="${2:-7}"

find "$log_dir" -type f -name '*.log' -mtime "+$days" -print0 |
while IFS= read -r -d '' file; do
  archive="${file}.gz"
  lock_dir="${archive}.lock"
  if mkdir "$lock_dir" 2>/dev/null; then
    (
      temp_archive=""
      trap '[ -n "$temp_archive" ] && rm -f "$temp_archive"; rmdir "$lock_dir" 2>/dev/null || true' EXIT
      if [ -e "$archive" ]; then
        echo "Skipping $file because $archive already exists" >&2
        exit 0
      fi
      if [ ! -e "$file" ]; then
        echo "Skipping $file because source disappeared during compression" >&2
        exit 0
      fi
      before_size="$(stat -c '%s' "$file")"
      before_mtime="$(stat -c '%Y' "$file")"
      archive_dir="$(dirname -- "$archive")"
      archive_base="$(basename -- "$archive")"
      temp_archive="$(mktemp -p "$archive_dir" ".${archive_base}.tmp.XXXXXX")"
      gzip -c "$file" > "$temp_archive"
      after_size="$(stat -c '%s' "$file")"
      after_mtime="$(stat -c '%Y' "$file")"
      if [ "$before_size" != "$after_size" ] || [ "$before_mtime" != "$after_mtime" ]; then
        echo "Skipping $file because source changed during compression" >&2
        exit 0
      fi
      mv -n "$temp_archive" "$archive"
      if [ -e "$temp_archive" ]; then
        echo "Skipping $file because $archive appeared during processing" >&2
        exit 0
      fi
      temp_archive=""
      rm -f "$file"
    )
  else
    echo "Skipping $file because $archive is locked by another process" >&2
  fi
done
