#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <book_directory> [pdf|html]"
    echo "  Assembles markdown files from a book directory and builds output."
    exit 1
}

[[ $# -lt 1 ]] && usage

BOOK_DIR="$1"
FORMAT="${2:-pdf}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$BOOK_DIR" ]]; then
    echo "Error: Book directory '$BOOK_DIR' not found."
    exit 1
fi

BOOK_NAME=$(basename "$BOOK_DIR")
BUILD_DIR="$BOOK_DIR/.build"
mkdir -p "$BUILD_DIR"

# --- Extract metadata from data.md frontmatter ---
METADATA_ARGS=()
TEMP_META=$(mktemp /tmp/book-meta-XXXXXX.yaml)
trap 'rm -f "$TEMP_META" "$ASSEMBLED"' EXIT

if [[ -f "$BOOK_DIR/data.md" ]]; then
    # Extract YAML between --- delimiters
    sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$BOOK_DIR/data.md" > "$TEMP_META"
    if [[ -s "$TEMP_META" ]]; then
        METADATA_ARGS+=(--metadata-file="$TEMP_META")
    fi
fi

# Add title from directory name if not in metadata
if ! grep -q '^title:' "$TEMP_META" 2>/dev/null; then
    METADATA_ARGS+=(--metadata "title=$BOOK_NAME")
fi

# --- Assemble chapter markdown files in order ---
ASSEMBLED=$(mktemp /tmp/book-assembled-XXXXXX.md)
FILE_COUNT=0

for chapter_dir in "$BOOK_DIR"/*/; do
    [[ ! -d "$chapter_dir" ]] && continue
    dir_name=$(basename "$chapter_dir")
    # Skip non-chapter directories
    [[ "$dir_name" == ".build" ]] && continue
    [[ "$dir_name" == "images" ]] && continue
    [[ "$dir_name" == "trello" ]] && continue

    for md_file in "$chapter_dir"*.md; do
        [[ ! -f "$md_file" ]] && continue
        [[ "$(basename "$md_file")" == "data.md" ]] && continue

        if [[ $FILE_COUNT -gt 0 ]]; then
            printf '\n\n' >> "$ASSEMBLED"
        fi
        cat "$md_file" >> "$ASSEMBLED"
        ((FILE_COUNT++))
    done
done

if [[ $FILE_COUNT -eq 0 ]]; then
    echo "Warning: No markdown files found in '$BOOK_DIR'. Nothing to build."
    exit 0
fi

echo "Assembling $FILE_COUNT files from '$BOOK_NAME'..."

# --- Build output ---
case "$FORMAT" in
    pdf)
        pandoc "$ASSEMBLED" \
            "${METADATA_ARGS[@]}" \
            --from markdown+smart+yaml_metadata_block \
            --pdf-engine=xelatex \
            --toc --toc-depth=3 \
            --number-sections \
            --top-level-division=chapter \
            --variable geometry:margin=1in \
            --variable fontsize=11pt \
            --variable documentclass=book \
            --variable classoption=openright \
            --variable linkcolor=blue \
            --variable urlcolor=blue \
            --variable toccolor=black \
            -o "$BUILD_DIR/$BOOK_NAME.pdf"
        echo "PDF built: $BUILD_DIR/$BOOK_NAME.pdf"
        ;;
    html)
        # Copy CSS to build dir
        if [[ -f "$REPO_ROOT/templates/style.css" ]]; then
            cp "$REPO_ROOT/templates/style.css" "$BUILD_DIR/style.css"
        fi
        pandoc "$ASSEMBLED" \
            "${METADATA_ARGS[@]}" \
            --from markdown+smart+yaml_metadata_block \
            --to html5 \
            --standalone \
            --toc --toc-depth=3 \
            --css style.css \
            -o "$BUILD_DIR/index.html"
        echo "HTML built: $BUILD_DIR/index.html"
        ;;
    *)
        echo "Error: Unknown format '$FORMAT'. Use 'pdf' or 'html'."
        exit 1
        ;;
esac
