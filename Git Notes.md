latex input:    mmd-article-header
Title:          Git Notes
Author:         Ethan C. Petuchowski
Base Header Level:  1
latex mode:     memoir
Keywords:       Git, Version Control, Command Line, Terminal, Syntax
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:      2014 Ethan C. Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer

Many of these notes are from O'Reilly's *Git Pocket Guide,* by Richard E. Silverman.

## Basic Commands
#### 11/12/14

```bash

# git fetch && git merge
$ git pull

# read `man` file for git command
$ git --help rm

# Show current branch
$ git branch
* master

# Checkout a tagged commit
$ git checkout mytag
You are in 'detached HEAD' state...

# Show `diff`erence between your working tree and the *index* (staging area)
$ git diff

# Show `diff`erence between your *index* (staging area)
# and the most recent ("current") commit
$ git diff --staged

# Make the *index* (staging area) *become* the newest commit
# Physically, this just adds a pointer from it to the previous commit
$ git commit

# Merge branch `refactor` into `master`.
#   1. applies the diffs
#   2. asks you to resolve conflicts
#   3. commits the result
$ git checkout master   # switch to master branch
$ git merge refactor

# Add only *some* of the changes you've made
#    Starts an interactive loop that lets you select
#    which "hunks" of (all) changes you want to index.
# Use "`?`" during the interactive session to see the commands
$ git add -p

# Remove file from your index/"staging" **and from the working tree**
#       WARNING: removal from "working tree" means this
#                file disappears from your file-system!
$ git rm [filename]

# Reset (empty) the staging area
#   Nonobviously: Your changes will still be there on your local filesystem
$ git reset
```