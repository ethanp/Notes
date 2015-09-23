#!/usr/bin/env bash
# Ethan Petuchowski
# 11/11/14


LATEX_DIR=~/Desktop/Latex

function mtx_dont_open {
    TEX_NAME=$(basename "$1" | sed s'|.md|.tex|')
    PDF_NAME=$(basename "$1" | sed s'|.md|.pdf|')
    TEX_LOC=$LATEX_DIR/"$TEX_NAME"

    # use mmd to do .md => .tex
    multimarkdown -t latex "$1" > "$TEX_LOC"

    # use latex to do .tex => .pdf
    pdflatex --output-directory "$LATEX_DIR" \
        "$TEX_LOC" > /dev/null
}

# xfm every .md in this directory
ls *.md | while read line; do
    echo making "$line"
    (mtx_dont_open "$line" || echo "$line didn't work")&
done

# subshell to retain interactivity in fg shell while waiting
(
    sleep 15  # MAGIC NUMBER, I can't get it to wait() properly
    cd $LATEX_DIR

    # delete the temp files produced by this process
    rm -f *.aux *.idx *.glo *.ist *.out *.log *.tex
)&
