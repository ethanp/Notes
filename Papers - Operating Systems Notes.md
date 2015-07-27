latex input:    mmd-article-header
Title:          Operating Systems Papers Notes
Author:         Ethan C. Petuchowski
Base Header Level:      1
latex mode:     memoir
Keywords:       algorithms, computer science, theory, grammars
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:      2015 Ethan Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer

## Linux Kernel Development

> Robert Love; Linux Kernel Development, 3rd ed., 2010, Pearson

#### Forward by Andrew Morton

As the kernel gets more complex, it becomes harder for new developers to become
contributors. Code simplicity helps, code comments about intent help, but
written word for the point of essential high-level understanding is necessary
as well. That's where this book comes in.

#### Preface

* This book is about the Linux kernel's design and implementation
* Specifically version 2.6
* The goal of this book is to help you begin developing code in the kernel
* It balances theory and application, it covers API and internals

### Introduction to the Linux Kernel

* Unix-family operating systems all implement a similar API
* Unix development was started by Dennis Ritchie and Ken Thompson in 1969 after
  Multics failed to provide a multiuser operating system at Bell Labs
* It was rewritten in C in 1973
* UC Berkeley created variants of Unix (BSDs) 1977-1994 with added veatures
  like `csh`, `vi`, virtual memory, job control, demand paging, and TCP/IP.
* Workstation and server companies sold their own versions for their hardware
  as well

#### Key Successes of Unix

1. Only 100s of system calls (instead of 1,000s) with clear goals and design
2. Everything is a file (except a socket)
3. Kernel and utilities leverage C to make them portable
4. Fast process creation time via `fork()`
5. Simple IPC primitives allow piping simple programs into each other
6. Clean layering with strong separation of policy from mechanism

#### Key Features of Unix

1. Preemptive multitasking
2. Multithreading
3. Virtual memory
4. Demand paging
5. Shared libraries with demand loading
6. TCP/IP networking

#### Intro to Linux

* Linus developed first version of Linux in 1991 at school for the new and
  advanced Intel 80386 microprocessor
* It's based on Minix, but Minix did not have a permissive license
* It took off quickly, with new developers contributing
* Now it runs on watches and super-computer clusters
* It is not a commercial product
* If you distribute your changes you must make the source available
* A "Linux system" may include the kernel, C library, utilities, windowing
  system, desktop environment (e.g. GNOME), etc. Here Linux refers to just the
  kernel

#### What is a kernel

The kernel is software that

1. provides basic services
2. manages hardware
3. distributes system resources

Typical components include

1. Interrupt handlers
2. Scheduler
3. Memory management system
4. Networking
5. IPC

#### Some Linux kernel specifics

* It resides in *kernel-space*, where it has full access to the hardare and,
  apps execute in *user-space*, where they do not
* It runs in **process context** when an application uses the C library which
  calls system calls which instruct the kernel to do particular tasks
* It runs in an **interrupt context** when hardware interrupts the processor,
  which interrupts the kernel, which uses the interrupt number to index to an
  interrupt handler which does something. This all is not associated with any
  process.
* It is monolothic -- it is a single static binary executable image running in
  a single address space as a single process, which communicates with itself
  using simple method calls
    * However it still has a modular design, the ability to preempt tasks
      executing within the kernel, kernel threads, and can dynamically load
      kernel modules into the kernel image
* It does not differentiate between threads and normal processes

##### Versioning

* 2.6.4.2 -- major version, minor version, revision, stable version
* Even minor versions are stable releases (intended to work for a long time)
* Odd minor versions are development releases (in which new features are tried
  out)
* This versioning system is not set in stone and is itself under development


## The UNIX Time-Sharing System

> Ritchie, Dennis M., and Ken Thompson. "The UNIX time-sharing system."
> Communications of the ACM 17, no. 7 (1974): 365-375.

### Notes on notes provided by Emmett Witchel and Mike Dahlin

1. UNIX's most important role is to provide a filesystem
2. Unix's filesystem flavor includes a _hierarchical_ namespace
    1. This sacrifices some generality for the sake of simplicity
    2. It is a __DAG__
        1. This makes _search_ and _garbage collection_ easier
        1. Augmented with softlinks, which don't lead to cycles because
           they don't increment the "link" (reference) count; this means
           they can "dangle" if they're not cleaned up
3. File metadata is stored in an __inode__ (index-node) data structure -- I
   think the exact inode structure can vary between filesystems, but for the
   _Unix File System_ & `ext3`, it
    1. Is identified by an `inumber` -- shown via `ls -i` command
    2. Starts with a section containing metadata
        1. Size in bytes
        2. Number of hard-links pointing to the file
        3. Owner (a _user_, in a _group_)
        4. Permissions -- `owner | group | other`
        5. Timestamps (created, modified, accessed)
        6. __No filename__ -- this is stored in the file's parent-
           directory's data blocks (see below)
    2. Followed by a set of "direct" pointers to data blocks
    3. Folowed by a set of "indirect" pointers to direct pointers
    4. Followed by a set of "double indirect" pointers
4. "Everything is a file"
    1. Directories are files
        1. Their datablocks contain a set of lines
        2. Each line has a contained file's `inode` number (id) and its
           filename
    2. Devices are files -- this makes their API the same, so either can be
       passed as a parameter to a program
        1. They are "located" on the filesystem in the `/dev` directory
        2. The way this is handled has changed over time to deal with
           various issues
5. Hard-links vs Symbolic/Soft-links
    1. __Hard-link__ -- an entry in a directory's data-block to an `inode`
       as described above
    2. __Symbolic-link__ -- an entry in a directory's data-block with an
       absolute path-name
6. Unix gained success & elegance via "ruthless simplification"
7. Unix's breakthrough besides the filesystem was in process-management
8. They provide process-mgmt primitives, not "solutions"
    1. `fork` -- spawn a new process with parent's open files
    2. `exec` -- load a new program image into this process
    3. `wait` -- wait for a child process to finish executing
    4. `stdin|stdout` -- enables redirection and pipelines
9. A process is an executing program, and is just a bunch of bytes divided by
   virtual-memory location into the _code, heap, and stack_ "segments"
    1. By contrast, Multix had _N_ segments, and previous systems had all kinds
       of really crazy complicated stuff which differed between programs
10. How do you teach/learn elgance?
    1. Study case studies, try to learn lessons
    2. When you build a system, ask yourself "What would Ritchie and Thompson
       say about my design?"
