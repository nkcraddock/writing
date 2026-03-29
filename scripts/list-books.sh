#!/usr/bin/env bash
# Lists all book directories in the repository (excludes infrastructure dirs)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXCLUDE_DIRS=("scripts" "templates" "node_modules" ".github" ".git")

for dir in "$REPO_ROOT"/*/; do
    [[ ! -d "$dir" ]] && continue
    name=$(basename "$dir")
    skip=false
    for exclude in "${EXCLUDE_DIRS[@]}"; do
        [[ "$name" == "$exclude" ]] && skip=true && break
    done
    [[ "$skip" == true ]] && continue

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
