# numberfolders.py - utility for sorting and grouping folders into numbered
# groups
#
# * recursively collects all files in the given folder
# * sorts them lexicographically
# * creates new subfolders for each subgroup (default: 100 files per folder)
# * moves the files into the new subfolders, updating in place
#
#
# by default, the script performs only a 'dry run' and prints the files that
# would be moved:
# $ python numberfolders.py /path/to/folder
#
# to update a folder in place without a dry
# $ python numberfolders.py /path/to/folder -x
#
# or, to not modify the original folder, use -o/--output-folder:
# $ python numberfolders.py /path/to/folder -x -o /path/to/output/folder
#
from __future__ import annotations

import argparse
import math
import os
import shutil
from pathlib import Path

GROUP_DIR_MIN_WIDTH = 3
METADATA_FILES = {".DS_Store"}
METADATA_DIRS = {".AppleDouble"}


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Group files from a folder into numbered subfolders. "
            "By default this is a dry run."
        )
    )
    parser.add_argument("folder", help="Input folder to scan recursively.")
    parser.add_argument(
        "-x",
        "--execute",
        action="store_true",
        help="Apply changes (move or copy files).",
    )
    parser.add_argument(
        "-o",
        "--output-folder",
        help="Output folder (copies files instead of moving).",
    )
    parser.add_argument(
        "-n",
        "--group-size",
        type=int,
        default=100,
        help="Number of files per group folder (default: 100).",
    )
    parser.add_argument(
        "-p",
        "--group-prefix-len",
        type=int,
        default=0,
        help=(
            "Append the first N letters of the first file in each group to "
            "the group folder name (default: 0)."
        ),
    )
    parser.add_argument(
        "-c",
        "--clean",
        action="store_true",
        help="Remove empty directories after moving.",
    )
    return parser.parse_args()


def _validate_args(args: argparse.Namespace) -> tuple[Path, Path, int, bool]:
    input_folder = Path(args.folder).expanduser().resolve()
    if not input_folder.exists() or not input_folder.is_dir():
        raise SystemExit(
            "Input folder does not exist or is not a directory: "
            f"{input_folder}"
        )

    if args.group_size <= 0:
        raise SystemExit("--group-size must be a positive integer.")

    if args.group_prefix_len < 0:
        raise SystemExit("--group-prefix-len must be zero or positive.")

    if args.output_folder:
        output_folder = Path(args.output_folder).expanduser().resolve()
    else:
        output_folder = input_folder

    copy_mode = output_folder != input_folder
    return input_folder, output_folder, args.group_size, copy_mode


def _should_skip_output_root(
    input_folder: Path, output_folder: Path, root_path: Path, dirs: list[str]
) -> bool:
    if output_folder == input_folder:
        return False

    try:
        rel_to_root = output_folder.relative_to(root_path)
    except ValueError:
        return False

    if not rel_to_root.parts:
        dirs[:] = []
        return True

    skip_dir = rel_to_root.parts[0]
    dirs[:] = [d for d in dirs if d != skip_dir]
    return False


def _collect_files(input_folder: Path, output_folder: Path) -> list[Path]:
    files: list[Path] = []
    for root, dirs, filenames in os.walk(input_folder):
        root_path = Path(root)
        if _should_skip_output_root(
            input_folder, output_folder, root_path, dirs
        ):
            continue

        for filename in filenames:
            file_path = root_path / filename
            if file_path.is_file():
                files.append(file_path)
    return files


def _group_name(index: int, total_groups: int, label: str | None) -> str:
    if total_groups > 0:
        width = max(GROUP_DIR_MIN_WIDTH, len(str(total_groups - 1)))
    else:
        width = GROUP_DIR_MIN_WIDTH
    base = f"{index:0{width}d}"
    if label:
        return f"{base}-{label}"
    return base


def _is_group_dir(name: str) -> bool:
    return name.isdigit() and len(name) >= GROUP_DIR_MIN_WIDTH


def _group_label_from_name(filename: str, length: int) -> str:
    if length <= 0:
        return ""

    base = Path(filename).stem
    letters = [ch.lower() for ch in base if ch.isalnum()]
    label = "".join(letters[:length])
    return label or "misc"


def _split_name(filename: str) -> tuple[str, str]:
    suffixes = Path(filename).suffixes
    if not suffixes:
        return filename, ""
    suffix = "".join(suffixes)
    base = filename[: -len(suffix)]
    return base, suffix


def _unique_name(filename: str, used_names: set[str]) -> str:
    if filename not in used_names:
        used_names.add(filename)
        return filename

    base, suffix = _split_name(filename)
    counter = 2
    while True:
        candidate = f"{base}_{counter}{suffix}"
        if candidate not in used_names:
            used_names.add(candidate)
            return candidate
        counter += 1


def _plan_moves(
    files: list[Path],
    input_folder: Path,
    output_folder: Path,
    group_size: int,
    prefix_len: int,
) -> list[tuple[Path, Path]]:
    files_sorted = sorted(
        files, key=lambda p: str(p.relative_to(input_folder))
    )
    total_groups = (
        math.ceil(len(files_sorted) / group_size) if files_sorted else 0
    )
    moves: list[tuple[Path, Path]] = []

    used_names_by_group: dict[Path, set[str]] = {}
    group_labels: dict[int, str] = {}

    for idx, file_path in enumerate(files_sorted):
        group_index = idx // group_size
        if group_index not in group_labels and prefix_len > 0:
            group_labels[group_index] = _group_label_from_name(
                file_path.name, prefix_len
            )
        group_folder = output_folder / _group_name(
            group_index, total_groups, group_labels.get(group_index)
        )
        used_names = used_names_by_group.setdefault(group_folder, set())
        filename = _unique_name(file_path.name, used_names)
        dest_path = group_folder / filename
        moves.append((file_path, dest_path))

    return moves


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def _apply_moves(moves: list[tuple[Path, Path]], copy_mode: bool) -> None:
    for src, dest in moves:
        if src.resolve() == dest.resolve():
            continue
        if dest.exists():
            raise FileExistsError(f"Destination already exists: {dest}")
        _ensure_parent(dest)
        if copy_mode:
            shutil.copy2(src, dest)
        else:
            shutil.move(src, dest)


def _cleanup_empty_dirs(root: Path) -> None:
    for current_root, dirnames, _ in os.walk(root, topdown=False):
        current_path = Path(current_root)
        if current_path == root:
            continue
        entries = list(current_path.iterdir())
        for entry in entries:
            if entry.is_dir() and entry.name in METADATA_DIRS:
                for meta in entry.iterdir():
                    if meta.is_file():
                        meta.unlink()
                try:
                    entry.rmdir()
                except OSError:
                    pass
            elif entry.is_file() and (
                entry.name in METADATA_FILES or entry.name.startswith("._")
            ):
                entry.unlink()

        try:
            remaining = [
                entry
                for entry in current_path.iterdir()
                if not (
                    entry.is_file()
                    and (
                        entry.name in METADATA_FILES
                        or entry.name.startswith("._")
                    )
                )
                and not (entry.is_dir() and entry.name in METADATA_DIRS)
            ]
            if not remaining:
                current_path.rmdir()
        except OSError:
            continue


def main() -> None:
    args = _parse_args()
    input_folder, output_folder, group_size, copy_mode = _validate_args(args)

    files = _collect_files(input_folder, output_folder)
    moves = _plan_moves(
        files,
        input_folder,
        output_folder,
        group_size,
        args.group_prefix_len,
    )

    action = "Copy" if copy_mode else "Move"
    if not moves:
        print("No files found to process.")
        return

    if args.execute:
        _apply_moves(moves, copy_mode)
        if not copy_mode and args.clean:
            _cleanup_empty_dirs(input_folder)
        print(f"{action}d {len(moves)} files into numbered groups.")
    else:
        print("Dry run (no changes applied).")
        for src, dest in moves:
            print(f"{action}: {src} -> {dest}")
        print(f"{action}d {len(moves)} files (dry run).")


if __name__ == "__main__":
    main()
