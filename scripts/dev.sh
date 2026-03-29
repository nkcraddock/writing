#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <book_directory>"
    echo "  Starts a local dev server with hot-reload preview for a book."
    echo "  Opens in browser automatically. Rebuilds on any .md file change."
    exit 1
}

[[ $# -lt 1 ]] && usage

BOOK_DIR="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$BOOK_DIR" ]]; then
    echo "Error: Book directory '$BOOK_DIR' not found."
    exit 1
fi

BOOK_NAME=$(basename "$BOOK_DIR")
BUILD_DIR="$BOOK_DIR/.build"

echo "Starting dev server for '$BOOK_NAME'..."
echo "Building initial HTML..."

# Initial build
"$REPO_ROOT/scripts/build.sh" "$BOOK_DIR" html

echo ""
echo "Watching for changes in '$BOOK_DIR'..."
echo "Preview: http://localhost:3000"
echo "Press Ctrl+C to stop."
echo ""

# Run file watcher (rebuild on change) and browser-sync (serve + reload) concurrently
npx concurrently --kill-others \
    --names "watch,serve" \
    --prefix-colors "yellow,cyan" \
    "npx chokidar-cli '$BOOK_DIR/**/*.md' --ignore '$BUILD_DIR' -c '$REPO_ROOT/scripts/build.sh \"$BOOK_DIR\" html'" \
    "npx browser-sync start --server '$BUILD_DIR' --files '$BUILD_DIR/**/*' --no-open --port 3000 --ui-port 3001"
