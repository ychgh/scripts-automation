#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from pathlib import Path
import os
import shutil
import sys


def unique_destination(path: Path, attempt: int = 0) -> Path:
    if attempt == 0:
        return path
    stamp = datetime.now().strftime("%H%M%S%f")
    return path.with_name(f"{path.stem}-{stamp}-{attempt}{path.suffix}")


def move_without_overwrite(source: Path, destination: Path) -> Path:
    attempt = 0
    while True:
        candidate = unique_destination(destination, attempt)
        attempt += 1
        try:
            fd = os.open(candidate, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o644)
        except FileExistsError:
            continue

        try:
            with source.open("rb") as src_stream, os.fdopen(fd, "wb") as dst_stream:
                shutil.copyfileobj(src_stream, dst_stream)
            source.unlink()
            return candidate
        except Exception:
            candidate.unlink(missing_ok=True)
            raise


def main() -> int:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "./reports")
    dst_root = Path(sys.argv[2] if len(sys.argv) > 2 else "./archive")
    stamp = datetime.now().strftime("%Y-%m-%d")
    dst = dst_root / stamp
    dst.mkdir(parents=True, exist_ok=True)
    for file in src.rglob("*.report"):
        move_without_overwrite(file, dst / file.name)

    print(f"Archived reports to {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
