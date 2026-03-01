#! /usr/bin/bash

# xlsx
apt-get install -y python3-openpyxl
# docx
apt-get install -y python3-python-docx
# pptx
pipx install --global --system-site-packages python-pptx


# rss
apt-get install -y python3-feedparser

# xml
apt-get install -y python3-lxml

# LaTeX/PDF
apt install -y texlive-full python3-pypdf

# pandoc
apt-get install -y \
    pandoc \
    pandoc-citeproc-preamble \
    context \
    weasyprint \
    librsvg2-bin \
    groff \
    ghc \
    r-base-core \
    libjs-mathjax \
    libjs-katex \
    citation-style-language-styles

# YAML
apt-get install -y yq