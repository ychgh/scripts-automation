#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from pathlib import Path
import shutil
import sys


def unique_destination(path: Path) -> Path:
    if not path.exists():
        return path
    stamp = datetime.now().strftime("%H%M%S%f")
    return path.with_name(f"{path.stem}-{stamp}{path.suffix}")


def main() -> int:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "./reports")
    dst_root = Path(sys.argv[2] if len(sys.argv) > 2 else "./archive")
    stamp = datetime.now().strftime("%Y-%m-%d")
    dst = dst_root / stamp
    dst.mkdir(parents=True, exist_ok=True)

    for file in src.glob("*.report"):
        destination = unique_destination(dst / file.name)
        shutil.move(str(file), str(destination))

    print(f"Archived reports to {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
