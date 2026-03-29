# Writing Repository

## Purpose
This is a multi-book writing repository. All books live under the `books/` directory — each subdirectory there is a **book project**. Books are written in Markdown and compiled into professionally formatted PDFs via Pandoc + XeLaTeX.

## Repository Structure

```
books/
  Book Title/
    data.md            <- Book metadata (YAML frontmatter) + notes, arcs, TODOs
    characters.md      <- Character database (excluded from builds)
    outline.md         <- Detailed chapter-by-chapter synopsis (excluded from builds)
    notes.md           <- World-building, themes, style notes (excluded from builds)
    trello/            <- Raw Trello board export (excluded from builds)
      board.json
    01/                <- Chapter/section (sorted ascending by directory name)
      01 - part.md     <- Content files (sorted alphabetically, compiled in order)
      02 - part.md
    02/
      01 - part.md
```

Root-level directories `scripts/`, `templates/`, `.github/`, `node_modules/` are infrastructure. The `books/` directory is the only place book projects live.

## Rules

### Content Files
- Markdown files inside numbered chapter directories are compiled into the book
- Files named `data.md` and `characters.md` are **always excluded** from builds — they are metadata/notes only
- The `trello/` directory is excluded from builds — it stores raw Trello board exports for reference
- Files are sorted alphabetically within each chapter directory (use zero-padded prefixes: `01`, `02`, etc.)
- Chapter directories are sorted ascending (use zero-padded numbers)
- Each chapter's first file should start with a `# Chapter Title` heading — Pandoc uses these for the table of contents and chapter breaks

### data.md Format
Each book's `data.md` has YAML frontmatter for build metadata and markdown body for notes:
```yaml
---
title: "Book Title"
author: "Author Name"
date: "2026"
lang: en
---
## Chapter Names
- 01: Chapter One Title
## Story Arcs / TODOs / Notes
...
```

### Building
- `make pdf BOOK="Book Title"` — build PDF (resolves to `books/Book Title`)
- `make html BOOK="Book Title"` — build HTML
- `make dev BOOK="Book Title"` — local dev server with hot reload
- `make list` — list all books
- `make all` — build all books as PDF

### CI/CD
- Push to `main` that changes files under `books/` triggers GitHub Actions: detects changed books, builds PDFs, uploads artifacts, notifies Discord
- Discord webhook URL stored in GitHub secret `DISCORD_WEBHOOK_URL`

### Book-Level Data Files

All markdown files at the book root level are reference/planning documents and are **never compiled** into the book (only files inside numbered chapter subdirectories are compiled):

- **`data.md`** — YAML frontmatter (title, author, date) used by the PDF build + markdown body for notes, chapter names, story arcs, TODOs, themes
- **`characters.md`** — Character database with descriptions, motivations, relationships
- **`outline.md`** — Detailed chapter-by-chapter synopsis with events, character appearances, and narrative beats
- **`notes.md`** — World-building details, themes, tone/style guidance, plot twists, open questions
- **`trello/board.json`** — Raw export of the original Trello board (if the book was planned in Trello)

### Writing Guidelines
- These are mostly non-fiction books, but some may be fiction
- Keep content in Markdown — avoid raw LaTeX unless necessary for special formatting
- Images go in an `images/` subdirectory within the chapter directory that references them
- Use relative paths for images: `![alt](images/photo.jpg)`

### Trello CLI Usage
The `trello` CLI (trello-cli) is used to import book planning data from Trello boards. Rate limits apply:
- **API token limit**: ~100 requests per 10-second window per token
- **Per-IP limit**: ~300 requests per 10-second window
- If you hit `API_TOKEN_LIMIT_EXCEEDED`, wait 10 seconds before retrying
- Use `trello sync` to build the local name-to-ID cache (required for name-based lookups)
- The `--card` flag uses card **names** (not IDs) for most commands; use `card:get-by-id --id <id>` for ID-based lookups
- Always use `--format json` for programmatic access
- When bulk-reading cards, avoid parallel requests to the same board — run them sequentially or with small delays
