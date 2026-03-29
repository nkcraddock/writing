# Writing

A multi-book writing repository. Each book lives under `books/` in its own directory, containing Markdown files organized by chapter. Books are compiled into professionally formatted PDFs using Pandoc and LaTeX, built automatically in CI, and delivered to Discord.

## Quick Start

```bash
# Install local dev tools (Node.js required)
make install

# Start writing with live preview in your browser
make dev BOOK="My Book"

# Build a PDF
make pdf BOOK="My Book"

# List all books
make list
```

## Book Structure

All books live under the `books/` directory. Inside each book, numbered subdirectories represent chapters or sections. Markdown files within each chapter are compiled in alphabetical order.

```
books/
├── My Book/
│   ├── data.md              # Book metadata + notes (never included in builds)
│   ├── 01/                  # Chapter 1
│   │   ├── 01 - opening.md
│   │   ├── 02 - main.md
│   │   └── 03 - closing.md
│   ├── 02/                  # Chapter 2
│   │   ├── 01 - intro.md
│   │   └── 02 - details.md
│   └── 03/                  # Chapter 3
│       └── 01 - content.md
└── Another Book/
    ├── data.md
    └── 01/
        └── 01 - intro.md
```

**Key rules:**
- **Chapter directories** are sorted ascending by name — use zero-padded numbers (`01`, `02`, ...).
- **Markdown files** within a chapter are sorted alphabetically — prefix with numbers for ordering.
- **`data.md`** is always excluded from builds. It holds book metadata and your working notes.
- Start each chapter's first file with a `# Chapter Title` heading for the table of contents.

## data.md

Each book has a `data.md` at its root for metadata and working notes. The YAML frontmatter is used by the build system for the PDF title page:

```yaml
---
title: "My Book Title"
author: "Your Name"
date: "2026"
lang: en
---

## Chapter Names
- 01: Introduction
- 02: The Main Idea

## Notes
- Key theme: ...
- TODO: finish chapter 3
```

The markdown body below the frontmatter is your scratchpad — story arcs, character details, TODOs, research notes, or anything else relevant to the book. It is never compiled into output.

## Commands

All commands use the book's directory name (not the full path — `books/` is implied):

| Command | Description |
|---------|-------------|
| `make dev BOOK="Title"` | Live-preview server at localhost:3000 with auto-reload |
| `make pdf BOOK="Title"` | Build a PDF in `books/<Title>/.build/` |
| `make html BOOK="Title"` | Build HTML in `books/<Title>/.build/` |
| `make all` | Build PDFs for every book |
| `make list` | List all books with chapter/file counts |
| `make clean` | Remove all `.build/` directories |
| `make install` | Install npm dev dependencies |

## Local Setup

### Prerequisites

**For live preview (HTML):**
- Node.js (18+)
- Run `make install` to get browser-sync, chokidar, and concurrently

**For PDF builds:**
- [Pandoc](https://pandoc.org/installing.html) (2.19+)
- TeX Live with XeLaTeX:
  ```bash
  sudo apt install pandoc texlive-xetex texlive-latex-extra texlive-fonts-recommended
  ```

### Live Preview

```bash
make dev BOOK="My Book"
```

This starts a local server at `http://localhost:3000` that renders your book as HTML. When you edit any `.md` file in the book directory, it automatically rebuilds and refreshes your browser.

### Building PDFs

```bash
make pdf BOOK="My Book"
```

Output lands in `books/My Book/.build/My Book.pdf`. The PDF includes:
- Title page (from `data.md` frontmatter)
- Auto-generated table of contents
- Numbered chapters and sections
- Professional book formatting (justified text, proper margins, serif font)

## CI/CD

Pushing to `main` with changes under `books/` automatically:
1. Detects which books have changed files
2. Builds PDFs for those books only
3. Uploads PDFs as GitHub Actions artifacts (retained 90 days)
4. Sends a Discord notification with build status and download link

You can also trigger a build manually from the Actions tab, specifying a book name.

### Discord Setup

1. In your Discord server: Server Settings → Integrations → Webhooks → New Webhook
2. Copy the webhook URL
3. In GitHub: repo Settings → Secrets → Actions → New secret
4. Name: `DISCORD_WEBHOOK_URL`, Value: the webhook URL

## Starting a New Book

1. Create a directory under `books/` with your book's title
2. Add a `data.md` with at least a title in the frontmatter
3. Create chapter directories (`01/`, `02/`, ...) with markdown files inside
4. Run `make dev BOOK="Your Book"` to start writing with live preview

```bash
mkdir -p "books/My New Book/01"
cat > "books/My New Book/data.md" << 'EOF'
---
title: "My New Book"
author: "Your Name"
date: "2026"
---

## Notes
- This book is about...
EOF

cat > "books/My New Book/01/01 - introduction.md" << 'EOF'
# Introduction

Start writing here.
EOF

make dev BOOK="My New Book"
```
