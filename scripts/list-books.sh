#!/usr/bin/env bash
# Lists all book directories under books/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOKS_DIR="$REPO_ROOT/books"

if [[ ! -d "$BOOKS_DIR" ]]; then
    echo "No books/ directory found."
    exit 0
fi

for dir in "$BOOKS_DIR"/*/; do
    [[ ! -d "$dir" ]] && continue
    name=$(basename "$dir")

    # Count chapters and files
    chapters=0
    files=0
    for ch in "$dir"/*/; do
        [[ ! -d "$ch" ]] && continue
        [[ "$(basename "$ch")" == ".build" ]] && continue
        ((chapters++))
        for f in "$ch"*.md; do
            [[ -f "$f" ]] && [[ "$(basename "$f")" != "data.md" ]] && ((files++))
        done
    done

    echo "$name — $chapters chapters, $files files"
done
