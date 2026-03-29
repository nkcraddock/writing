# Writing Repository

## Purpose
This is a multi-book writing repository. All books live under the `books/` directory — each subdirectory there is a **book project**. Books are written in Markdown and compiled into professionally formatted PDFs via Pandoc + XeLaTeX.

## Repository Structure

```
books/
  Book Title/
    data.md          <- Book metadata (YAML frontmatter) + notes, arcs, TODOs, character details
    01/              <- Chapter/section (sorted ascending by directory name)
      01 - part.md   <- Content files (sorted alphabetically, compiled in order)
      02 - part.md
    02/
      01 - part.md
```

Root-level directories `scripts/`, `templates/`, `.github/`, `node_modules/` are infrastructure. The `books/` directory is the only place book projects live.

## Rules

### Content Files
- Markdown files inside numbered chapter directories are compiled into the book
- Files named `data.md` are **always excluded** from builds — they are metadata/notes only
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

### Writing Guidelines
- These are mostly non-fiction books
- Keep content in Markdown — avoid raw LaTeX unless necessary for special formatting
- Images go in an `images/` subdirectory within the chapter directory that references them
- Use relative paths for images: `![alt](images/photo.jpg)`
