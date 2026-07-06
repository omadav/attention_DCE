#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: scripts/convert_docx_to_latex.sh path/to/draft.docx" >&2
  exit 1
fi

input_docx="$1"

if [ ! -f "$input_docx" ]; then
  echo "File not found: $input_docx" >&2
  exit 1
fi

mkdir -p sections fig/word_media

pandoc "$input_docx" \
  --from=docx \
  --to=latex \
  --extract-media=fig/word_media \
  --wrap=none \
  --output=sections/00_converted_from_word.tex

echo "Converted Word draft to sections/00_converted_from_word.tex"
echo "Extracted embedded media, if any, to fig/word_media/"
echo "Review the converted section, then split it into the numbered section files."
