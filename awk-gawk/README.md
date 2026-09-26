# awk/gawk task: summarize disk usage

## Goal
Summarize the total size used by top-level directories from `du` output.

## Implementation
- Script: [`summarize-disk.awk`](./summarize-disk.awk)

## Usage
```bash
du -sk --max-depth=1 . | awk -f ./summarize-disk.awk
```
