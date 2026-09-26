#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from pathlib import Path
import errno
import os
import shutil
import sys


def unique_destination(path: Path, attempt: int = 0) -> Path:
    if attempt == 0:
        return path
    stamp = datetime.now().strftime("%H%M%S%f")
    return path.with_name(f"{path.stem}-{stamp}-{attempt}{path.suffix}")


def move_without_overwrite(source: Path, destination: Path) -> Path:
    same_filesystem = source.stat().st_dev == destination.parent.stat().st_dev
    attempt = 0
    while True:
        candidate = unique_destination(destination, attempt)
        attempt += 1

        if same_filesystem:
            try:
                os.link(source, candidate)
                source.unlink()
                return candidate
            except FileExistsError:
                continue
            except FileNotFoundError as exc:
                raise RuntimeError(f"Source disappeared while archiving: {source}") from exc

        before = source.stat()
        fd: int | None = None
        try:
            fd = os.open(candidate, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o644)
        except FileExistsError:
            continue

        try:
            with source.open("rb") as src_stream, os.fdopen(fd, "wb") as dst_stream:
                fd = None
                shutil.copyfileobj(src_stream, dst_stream)
            after = source.stat()
            if before.st_size != after.st_size or before.st_mtime_ns != after.st_mtime_ns:
                candidate.unlink(missing_ok=True)
                raise RuntimeError(f"Source changed while archiving: {source}")
            source.unlink()
            return candidate
        except OSError as exc:
            if fd is not None:
                os.close(fd)
            candidate.unlink(missing_ok=True)
            if exc.errno == errno.ENOENT:
                raise RuntimeError(f"Source disappeared while archiving: {source}") from exc
            raise


def main() -> int:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "./reports")
    dst_root = Path(sys.argv[2] if len(sys.argv) > 2 else "./archive")
    src_resolved = src.resolve()
    stamp = datetime.now().strftime("%Y-%m-%d")
    dst = dst_root / stamp
    if dst.exists():
        dst_resolved = dst.resolve()
    else:
        dst_resolved = dst.parent.resolve() / dst.name
    try:
        dst_resolved.relative_to(src_resolved)
    except ValueError:
        pass
    else:
        print(f"Destination must not be inside source: {dst}", file=sys.stderr)
        return 1
    try:
        src_resolved.relative_to(dst_resolved)
    except ValueError:
        pass
    else:
        print(f"Source must not be inside destination: {src}", file=sys.stderr)
        return 1

    dst.mkdir(parents=True, exist_ok=True)
    for file in src.rglob("*.report"):
        relative_path = file.relative_to(src)
        destination = dst / relative_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        move_without_overwrite(file, destination)

    print(f"Archived reports to {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
