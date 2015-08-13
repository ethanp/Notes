latex input:		mmd-article-header
Title:		Bash Notes
Author:		Ethan C. Petuchowski
Base Header Level:		1
latex mode:		memoir
Keywords:		Bash, Unix, Linux, Shell, Command Line, Terminal, Syntax
CSS:		http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:			2014 Ethan C. Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

## Things that come in handy

Delete all non-pdf files recursively from directory

    find . ! -name '*.pdf' -delete

## Syntax

### The Environment

Essentially the shell's *global state*, inherited by every child process of
this shell.

To change the environment for a *single command*, prefix the command with your
settings

    CLASSPATH=/bin:/usr/bin java MyProgram

### Variables

Assign a value to a variable

    my_var=24

Make an existing variable **read-only**

    readonly my_var

Add existing variable to the *environment*

    export my_var

Print the environment

    env
    # or
    export -p

Remove varaible from shell

    unset my_var
    unset -f my_fctn    # for functions

#### Expansion operators

| **Operator** | **Meaning** |
| ---------------------: | :------------------------------------------------------- |
| `${#my_var}`           | Return number of characters in the value of `my_var`     |
| `${my_var:-default}`   | Return default value if variable is undefined            |
| `${my_var:=default}`   | Set variable *and* return it if it is undefined          |
| `${my_var:?"message"}` | If variable is *null* or *undefined*, exit and print message |
| `${my_var:+value}`     | Return `value` if `my_var` *is* defined                  |
| `${variable#pattern}`  | Delete *shortest* match from *beginning* (only) of var's value, and return the rest |
| `${variable##pattern}` | Delete *longest* match, otherwise like above             |
| `${variable%pattern}`  | Delete *shortest* match from *end* (only)                |
| `${variable%%pattern}` | Delete *longest* match from *end*                        |

##### e.g.s
    vble=/my/long/path_to.thing
    echo ${vble#/*/} # => long/path_to.thing
    echo ${vble##/*/} # => path_to.thing

### Script/Function Parameters

#### Special variables

Try `echo`ing these.

| **Variable** | **Meaning** |
| -----: | :------ |
| `$!` | PID of the most recent background command |
| `$$` | PID of the (current) script file or bash terminal |
| `$?` | Most recent foreground pipeline **exit status** |
| `$#` | Number of arguments passed to shell script/function |
| `$*`/`$@` | All command-line arguments (no quoting applied) |
| `"$*"` | All command-line arguments as a *single* string |
| `"$@"` | All cmd-line args, each wrapped in quotes |

#### Functions for manipulating parameters

Replace supplied positional parameters with your own set of parameters

    set first and third arguments

Shift all arguments *left*, replacing `$1` with `$2` and so on

    shift [#args to shift]

### Arithmetic

The shell evaluates the arithmetic expressions inside and places the result
back into the text of the command.

This is done as you'd expect, and it has *everything* you're used to, like
`|`, `||`, `<<`, `+=`, `++`, etc.

    echo $((2 + 3))    # => 5

**Booleans** are `1 = true` and `0 = false`

    echo $((2 && 3))   # => 1

**Exponentiation** is done with `**`, like in Python

    echo $((2 ** 3))   # => 8

### If

General form (based on Algol 68)

    if cond
    then
        # what to do
    elif cond
        # something
    else
        # otherwise
    fi

`test expr` is a synonym for `[ expr ]` (spaces required)

Test if `$file` is a directory

    if [ -d "$file" ]

String comparison

    if [ "$file" = "myfilename" ]

Multiple boolean checks

    if [ "$file" = "myfilename" ] || [ "$file" = "another/name" ]

### Case

* Check if a variable is one of many values.
* Patterns for catching the variable *can* contain wildcard characters.

Syntax

    case $1 in
    -f)
        # code
        ;;  # like "break"
    -d | --directory)  # multiple options
        # code
        ;;
    *)                 # catch-all (not required)
        ;;  # not required here
    esac

### Looping

#### For

    for i in *.[ch]
    do
        # something
    done

Loop over command-line arguments

    for i
    do
        case $1 in
        -f)
            # etc.
            ;;
        # etc.
        esac
    done

#### While and Until

    while condition
    do
        stuff   # *break* and *continue* are allowed
    done

    until condition
    do
        stuff
    done

#### POSIX-Style Command-Line Arguments

Use `getopts` to allow getting CLAs like

    grep -vnf --long-one=24

Here's how you'd implement something like that

    file=
    verbose=
    quiet=
    long=

    while getopts "$@" opt
    do
        case $opt in
        f)
            file=$OPTARG
            ;;
        v)
            verbose=true
            quiet=
            ;;
        esac
    done

### Functions

    my_func() {
        my code
        return 2  # set exit-status to 2 (failing)
    }

Note that if you modify a global variable in a function, this modification is
actually modifying that variable for real.

### `$(c)` vs `backtick(c)` vs `eval c`

* `$(c)` and `backtick(c)` are (at least practically) the same, they **capture the output**.
* `eval c` **interprets the text** you give it as a bash command.

### Subshells and Code Blocks

**Subshell** commands are wrapped in parentheses and are run in a separate
process. The main advantage is that state changes in the subshell (e.g. via
`cd`) don't affect the parent.

    tar -cf - . | (cd /newdir; tar -xpf -)

A **code block** is like a subshell, but runs in the shell's current process,
and state changes *do* affect the shell's state. These don't seem all that
useful.

## Jobs

    $ vim

    # you type
    ^z  # stop (pause) process

    [1]+ Stopped    vim

    $ jobs
    [1]+ Stopped    vim

    $ fg  # back to vim
    ^z

    $ less somefile.txt
    ^z
    [2]+ Stopped    less somefile.txt

    $ jobs
    [1]- Stopped    vim
    [2]+ Stopped    less somefile.txt

    $ fg    # back to less
    ^z

    $ fg %1 (or) fg 1  # back to vim
    ^z

    $ kill 2  # raw number means pid, but pid:2 is not a child
    bash: kill: (2) - No such process

    $ kill %2
    [2]- Terminated: 15   less somefile.txt

    $ fg    # vim is only job left
    ^z

If you have a job that's taking too long and you want to **move it to the
background**, you can do `CTRL-Z` to `STOP` it, then do

    $ bg %JOB_NO

and the shell will run it as a background jobs, as though you had run it with

    $ command for background execution &

## File Descriptors

* **0** -- `stdin`
* **1** -- `stdout`
* **2** -- `stderr`

##### Examples

    make check 2>&1 | tee make-check.log

* We can think of **`2>&1`** as "point `STDERR` to where `STDOUT` points"
* `| tee afile` means "and also print it to the log-file"

## POSIX Regex Character Classes

* These things can help you be international/multicultural
* They are only recognized *inside* a square-bracket sub-expression. So if you
  are using one of these standalone, you must wrap it in square-brackets

        [[:alnum:]]
* They only count for a single character, so for e.g. multiple spaces, you'd
  have to do

        [[:space:]]+
* What follows is likely not a complete list for *your* system because GNU
  added more, etc.

#### But here are the basics

| **Class**   | **Matches**   |
|  -------:   | :----------   |
| `[:alnum:]` | alphanumeric  |
| `[:alpha:]` | alphabetic    |
| `[:blank:]` | space & tab   |
| `[:cntrl:]` | control chars |
| `[:digit:]` | numeric       |
| `[:graph:]` | non-space     |
| `[:lower:]` | lowercase     |
| `[:print:]` | printable     |
| `[:punct:]` | punctuation   |
| `[:space:]` | whitespace    |
| `[:upper:]` | uppercase     |
| `[:xdigit:]`| hexadecimal   |

## Things one may want to do

### Repeat a command *N* times

cleaner syntax

    for i in {1..10}; do command; done

more flexible because you can go by 3's etc. (see `seq` command below)

    for i in `seq 10`; do command; done

### Iterate through files

    find . -name '*.csv' | while read line; do
        echo "$line"
    done

## Commands to Command

### netstat -anp --- list all stocket usages

* `-a`, `--all` --- show both listening and non-listening sockets
* `-n`, `--numeric` --- Show numerical addresses instead of trying
  to determine symbolic host, port or user names
* `-p`, `--program` --- Show the PID and name of the program to which
  each socket belongs.

### apropos --- pertaining too ...

    $ apropos database
    $ man -k database

Find all man-pages containing the word "database".

### printf --- basically like you'd expect

    $ printf "hello %s, that's $%.2f please for %d hamburglers\n" Jann 2.32 3
    hello Jann, that's $2.32 please for 3 hamburglers

### lynx --- run the text-based browser

This is *just* too cool.

### diff --- print differences between text files

* -y --- view differences *side-by-side* (mind-blowing)
* -u --- use the +/- format (it's honestly not as nice)

### cut --- extract column of text

    cut -(b|c|f)range [optns] [files]

* -c5 --- extract the 5th character of each line
* -b3-5 --- extract the 3rd, 4th, and 5th byte of each line
* -f2,4 -d, --- extract the 2nd and 4th **fields** of each line, where a field
  delimiter is a comma
* by default, the *delimiter* (`-d`) is a `TAB`
    * to make it a space, try `-d' '`
* --output-delimiter=C --- when you're printing multiple fields, use this
  delimiter (default is `TAB`)
* -s --- suppress (don't print) lines not containing the delimiter character

### paste --- make multiple text files into a csv-type-thing

    $ cat D1
    A
    B
    C

    $ cat D2
    1
    2
    3

    $ paste D1 D2
    A   1
    B   2
    C   3

    $ paste -d, D1 D2
    A,1
    B,2
    C,3

    # we can transpose too!!
    $ paste -s D1 D2
    A   B   C
    1   2   3

### sort

* You can sort by columns
* You can use offsets within columns
* You can use multiple columns, each with its own offset

Check this out

    $ cat D3
    B,2
    A,1
    E,4
    D,5
    C,3

    # sort by column two, with separator=,
    $ sort --key=2 --field-separator=, D3
    $ sort -k2 -t, D3
    A,1
    B,2
    C,3
    E,4
    D,5

### tail --- print the end of the file

    tail [optns] [files]

* **-N** --- show last `N` lines
* **+N** --- show all but first `N` lines
* **-f** --- (*watch file*) keep file open, and when new content gets
  appended, print it too (super useful)


### ln --- create a file that is a link to this file

    ln [-sif] source target

* **i** --- ask before doing anything
* **f** --- don't ask for permission
* **s** --- make a symbolic/soft link instead of a hard link

#### Hard vs. Soft Links

* **Hard** --- create a new name for a pointer to the `source`-file's
               `inode` on disk
* **Soft** --- create a new file on disk whose contents hold the
               `source`-file's *name*
    *  if the source file disappears this symbolic link will be broken

### seq -- create a sequence of numbers

    seq [first [incr]] last

* Numbers are floating point
* `first` and `incr` both default to 1
* **-s** --- set the separator
    * `$ seq -s \\t 3  =>    1\t2\t3`
* **-f** --- use printf style formatters
    * `$ seq -f %.2f -s ' ' 1 .5 3`
    * `=>  1.00 1.50 2.00 2.50 3.00`
* **-t** --- add a terminator to the sequence
* **-w** --- set width by padding with zeros

### jot --- print sequential or random data

* *Very* similar to `seq`
* **-r** --- use random data
* **-b** --- just print a given word repeatedly
* Print some random ascii (this could be improved...)
    * `jot -s '' -r -c 100 A`

### pkg-config -- determine C compiler flags

#### Examples

    $ pkg-config fuse --cflags

    -D_FILE_OFFSET_BITS=64 -D_DARWIN_USE_64_BIT_INODE -I/usr/local/Cellar/osxfuse/2.7.1/include/osxfuse/fuse

says to use pkg-config to determine what C compiler flags are necessary to
compile a source file that makes use of FUSE.

    $ pkg-config fuse --libs

    -L/usr/local/Cellar/osxfuse/2.7.1/lib -losxfuse -pthread -liconv

does the same for the libs to link with.

You can use it in a Makefile like this

    bbfs : bbfs.o log.o
            gcc -g -o bbfs bbfs.o log.o `pkg-config fuse --libs`

    bbfs.o : bbfs.c log.h params.h
            gcc -g -Wall `pkg-config fuse --cflags` -c bbfs.c

    log.o : log.c log.h params.h
            gcc -g -Wall `pkg-config fuse --cflags` -c log.c


### tail -- last part of file

#### Options

* **-F** --- if a log file is currently getting written to, `tail` will
  keep the connection to `stdout` open so that all live input into the
  log file gets written out to the terminal

### locate -- find file on file system

It's just like `find` only *way* faster and less thorough and has less
features. For simple things it ought to suffice.

### ack -- better than grep

Basic:

    ack pattern
    ack --[no]language pattern

Specify output format

    ack '^([^:]+)if:(.*)$' --output='$1 and $2 too!'

Options:

* **-w** --- match only whole words
* **-i** --- ignore case
* **-h** --- don't print filename
* **-l** --- only print filenames
* **-c** --- show count of matching lines in *all* files
* **-lc** --- show count of matching lines in *files with matches*
* **-C** --- specify lines of context (default: `2`)
* **--pager=LESS** --- pipe it into less (same as `ack ... | less`), except
  that it can be added (not sure yet if I want this) to the `~/.ackrc`
* **--[no]smart-case** --- Ignore case distinctions in `PATTERN`, only if
  `PATTERN` contains no upper case. Ignored if **-i** is specified.

### tr -- translate characters

**I think you *have* to pipe or carrat stuff into this thing, there's no place
for an input file**

To map all uppercase characters to their corresponding lowercase variants:

	tr A-Z a-z


* **-d** --- **delete** all specified characters

		tr -d ' '   # removes all spaces

* **-c** --- set **complement**

        tr -cd ' '  # removes *everything but* the spaces

* **-s** --- **squeeze** multiple repetitions into a single instance

        tr -s ' ' '\t'  # convert spaces to tabs

* **-cs** --- convert and squeeze (used by Doug McIlroy)

        tr -cs A-Za-z '\n' < /tmp/a.txt  # convert multiple non-letters into a newline

### `uniq`

*Remove lines that are duplicates of the previous line*

`uniq -c --count` --- prefix lines by the number of consecutive occurrences

    $ sort < a.txt | uniq -c
    4 a
    2 b

### ps -- Process Status

##### Description:

Prints information about running processes (and threads with option).

You can do things like

* List processes by memory usage
* List them by CPU usage
* List processes by other users
* List them by user

### Sort

con`cat`enate the contents of the given files, and sort that list of lines.

##### Useful-looking Options

* `-o FILE, --output=FILE` -- write to file
* `-r, --reverse` -- reverse the output
* `-f, --ignore-case` -- ignore case
* `-u` -- deduplicate lines

### dirname

**returns path to the input file, not including the file itself in that path**

this is the **opposite of [`basename`](#basename)**

    $ dirname a/b/myfile
    a/b

    $ dirname a/myfile
    a

    $ dirname myfile
    .


### basename

**given a filepath, return the part after the last slash**

This is the **opposite of [`dirname`](#dirname)**

    $ basename "./dir space/other dir/file.txt"
    file.txt

    # DON'T do this by accident (viz. ALWAYS quote the filename)
    $ basename ./dir space/other dir/file.txt
    dir
    other
    file.txt

You can get it to strip off the file suffix, though this doesn't seem to work
well with globbing.

    $ basename args.h .h
    args

### find

**recursive listing of all the files underneath given file**

    $ find .
    ./.DS_STORE
    ./file.txt
    ./a
    ./a/anotherFile.txt
    ./a space b
    ./a space b/file.txt

#### Useful-looking options

* `-(max|min)depth n`
* `-newer FILE` -- only files newer than `FILE`

### read

**Read user input into local variable**

##### Example

    echo -n "Enter some text > "
    read text
    echo "You entered: $text"

    Enter some text > this is some text
    You entered: this is some text

You can read *multiple* variables at once, splitting the input string using
`$IFS`. Recall that you can set `IFS` for the duration of a single command.

    echo "thing1:thing2:thing3" | IFS=: read vA vB vC
    echo $vB    # => thing2

### exec

With *no arguments*, change the current shell's *file descriptors*.

    exec 2> /tmp/mylog  # redirect shell's stderr
    exec 3< /file       # open new file descriptor
    read var1 var2 <&3  # read from fd 3
    exec 5>&2           # save sterr loc in fd 5
    exec 2> /otherfile  # new stderr loc
    ...
    exec 2>&5           # copy back saved stderr loc
    exec 5>&-           # close fd 5

*With* arguments, `exec` starts a new program in its current process and
control *never* returns to the shell.

    exec java MyApp

### fmt

Reformat paragraphs by changing line breaks to not exceed a given width. Think
of `cmd-opt-q` in my Sublime.

    $ fmt -w 20 << END
    > this line is going to broken up into 20 char chunks
    > END
    this line is going
    to broken up into 20
    char chunks

### wait

Wait for all background jobs to finish

### . (dot)

Read and execute commands contained in a separate file.

## Some crazed bash commands

### Coursera Lecture Time Aggregator

In a folder containing a bunch of videos with titles of the format *"Compilers
3.0 04-01 Lexical Specification (14m30s).mp4"*, I'd like to count the total
number of hours of video.

Algo

1. Morph list of filenames into just the time-pieces, e.g. 6m29
2. Split those strings on `m`
3. Add up the hours and minutes separately
4. Add up the total number of minutes and divide it into hours
5. Print it out

```bash
$ ls \
  | sed 's/[^(]*(\([^s]*\)s).*/\1/' \
  | awk -Fm '{s+=$1;t+=$2} END {printf "%.2f hrs\n", (t/60+s)/60}'

#=> 19.50 hrs
```

### Bootleg Spellchecker

August 11, 2015

Look for spelling errors in some crappy Mac-provided dictionary file. Based on
the UNIX command given in the [AT&T Archives Video][arch], but many of the
commands have disappeared since then and new ones have been introduced.

[arch]: https://www.youtube.com/watch?v=tc4ROCJYbm0

```bash
$ echo "The quick brown Fox jumped over." \
  | tr ' ' '\n' \                     # replace spaces with newlines
  | tr '[:upper:]' '[:lower:]' \      # convert to lowercase
  | sed 's|[^[:alpha:]\n]||g' \       # only keep letters
  | sort -u \                         # sort and dedup
  | comm -23 - /usr/share/dict/words  # keep only words not found in dictionary

=> jumped
```
