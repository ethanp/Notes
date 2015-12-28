latex input:    mmd-article-header
Title:          Operating Systems Notes (Old)
Author:         Ethan C. Petuchowski
Base Header Level:  1
latex mode:     memoir
Keywords:       C, Programming Language, Syntax
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:      2014 Ethan C. Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer

## x86-64

* A.k.a. x64, x86_64, AMD64
* Spec released by AMD in 2000
    * First implemented in AMD K8 in 2003
* This is the 64-bit version of the x86 instruction set
* Fully backward compatible with 16- and 32-bit x86 code
    * With no performance penalties
* Has 64-bit (8 bytes) virtual addresses
    * only 48 bits are in use today (2015)
* Has 16 (instead of 8) general-purpose registers
    * rax, rbx, rcx, rdx 
        * note: abcd
    * rbp, rsp 
        * base and stack pointer
    * rsi, rdi
        * source and destination (no longer meaningful)
    * r8, r9, r10, r11, r12, r13, r14, r15
        * These weren't available in the 32-bit x86
    * Using the same register name
        * but with 'e' in place of 'r', means the lower 32-bits of that
          register
        * without the first letter, means the lower 16-bits of that register
* Has 16 (instead of 8) _single instruction, multiple data_ (SIMD, "parallel")

### Linux-specific usage
* It used to be that arguments to function-calls were passed on the stack
* Now that there are so many general-purpose registers, Linux uses 8 registers to pass the first 8 arguments
    * Viz. rbx, rsp, rbp, r12, r13, r14, r15
    * For some reason, these _same_ values must be in those registers when the
      called-function returns
    * Similarly, the argument registers for _system calls_ are rdi, rsi, rdx,
      r10, r8, r9

#### Reference
* [null program](http://nullprogram.com/blog/2015/05/15/)

## Buffer Cache

1. This is the thing you always here them clearing in systems papers' benchmarks.
2. It is the memory used by the operating system to cache information from disk
3. It is used for reads as well as writes (eg. to batch writes, optimize
   location, and complete asynchronously)
    * This is why you're not supposed to rip your floppy drive out (lol),
      because some data might *seem* like it has been written, but lo and
      behold it is still in the buffer cache
4. The `sync` command *flushes* the buffer to disk
5. Specifically, the buffer cache holds file *blocks*, the smallest units of
   disk I/O
6. The cache may hold directories, super blocks, etc. too [cached `ls`]
7. Linux automatically uses all free RAM for buffer cache, and takes some space
   back when programs need it for memory
8. The cache data is shared between processes


# Most of these Notes are from *before* I actually took the course. So maybe
they're wrong.

## Unix System Calls

### Making a system call (at least for Linux) in NASM

C prototype for `write()` syscall

    ssize_t write(int fd, const void *buf, size_t count);

Recall from above the argument registers for _system calls_ are rdi, rsi, rdx,
r10, r8, r9. So we load the arguments in that order.

Then we must load `rax` with the integer identifying the system call we want to
make. For Linux, `write` has ID `1`.

    mov rdi, 1        ; fd
    mov rsi, buffer
    mov rdx, 10       ; 10 bytes
    mov rax, 1        ; SYS_write
    syscall

### clone (Linux only)

* Used by Linux to implement _threads_ of execution
* Similar to the regular UNIX `fork()`, except that you can pass flags saying
  which parts of the execution context should be shared between this process
  and its new child
    * E.g. for threads, the the only thing that's new is the _stack_, i.e.
        
            CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND \
            | CLONE_PARENT | CLONE_THREAD | CLONE_IO |

#### Reference
* [null program](http://nullprogram.com/blog/2015/05/15/)

### mmap

    void* mmap(
        void*  addr, // "suggestion" of where mapping should be placed
        size_t len, 
        int    prot, 
        int    flags, 
        int    fildes, 
        off_t  off
    ); 

3/16/15

1. Implements *demand paging* (lazy page loading) --- OS copies a disk page
   into physical memory only if an attempt to access it page-faults
    * This is achieved using *page tables*
2. Implements *memory-mapped file I/O* --- assigns a segment of virtual memory
   a direct byte-for-byte correlation with some portion of a file-like resource
   (something accessible through a *file-descriptor*), allowing applications to
   treat the mapped portion as though it were RAM.
3. mmaps are always aligned to the page size (usually 4KB)
4. Giving `addr = 0` means the OS gets full authority to decide where to
   allocate the memory
5. Returns a pointer to the top of the address space allocated

#### Some flags

1. Use `PROT_[READ|WRITE|EXEC|NONE]` to set this range's `rwx` options
2. Use `MAP_FIXED` to _demand_ that the given `addr` be used as the start-
   address


#### Why use it?

1. mmap uses the the kernel's **page/disk cache**, a "transparent" cache of
   disk-backed pages kept in RAM by the OS for quicker access
    * The OS generally allocates *all* available RAM not used by applications
      for this purpose because it would otherwise be idle and can be easily
      reclaimed for use by applications
    * Here, we can buffer updates, only updating the block on disk after
      performing all updates in RAM
2. Updating mmap'd data doesn't require a system call, saving time

#### How to use it?

1. In C, you just call it directly. Look up its man page
2. In Java, you can use `nio.channels.FileChannel`
    * `force` --- force updates to the channel's file to be written to the
      storage device; this happens *synchronously* if the device is *local*
    * `read`, `write`, set `position(long pos)`, `truncate(long size)`, `lock`
    * `map(mode, pos, size)` -- creates a `nio.MappedByteBuffer`
        * `force` data to disk
        * `put`, `get` (these are what write/read are called here [why?])
        * `mode` can be `READ_ONLY`, `READ_WRITE`, `PRIVATE` (COW)
3. In Ruby and Python there are associated importable libraries

### Distributed Transactions

#### 7/23/14

The scenario, is we'd like to have multiple databases storing the same data in
such a way that no matter who we ask, we're guaranteed to get the exact same
data.

* You can *prove* that no system can be free of deadlocks *and* guarantee
  consistency

#### Two-phase commit
1. Coordinator sends data to everyone
2. Everyone writes the data to save to a local log
    * This log can be retrieved if the unit crashes
3. Everyone tells the coordinator whether they were successful
4. If anyone fails, the coordinator addresses the issue in some way
5. If everyone succeeds, the coordinator tells all to update their data to
   match the log

#### Paxos
1. Instead of having a coordinator, there is a democracy
2. This is a very successful and widespread scheme by Leslie Lamport
3. Hard to guarantee high-performance/low-latency response times
4. Can lead to deadlock
5. "Although no deterministic fault-tolerant consensus protocol can guarantee
   progress in an asynchronous network, Paxos guarantees safety (freedom from
   inconsistency), and the conditions that could prevent it from making
   progress are difficult to provoke."
6. Paxos is normally used in situations requiring durability (for example, to
   replicate a file or a database), in which the amount of durable state could
   be large.
7. The protocol attempts to make progress even during periods when some
   bounded number of replicas are unresponsive.
8. Here are a few youtube videos that might explain the algorithm itself
    1. [Lec 10 U1](https://www.youtube.com/watch?v=s66GsKmU7kg&list=PL700757A5D4B3F368&index=57)
    1. [Lec 10 U2](https://www.youtube.com/watch?v=5scBtoyz8HU&list=PL700757A5D4B3F368&index=58)
    1. [Lec 10 U3](https://www.youtube.com/watch?v=s66GsKmU7kg&list=PL700757A5D4B3F368&index=59)
    1. [Demo](https://www.youtube.com/watch?v=jyel-iADuUU)
9. [This tutorial](http://the-paper-trail.org/blog/consensus-protocols-paxos/)
   looks decently brisk & well-written

#### Eventual consistency
1. Definition: In the absence of updates, all replicas will *eventually*
   converge towards identical copies
2. What the application sees in the meantime is difficult to predict
3. E.g. MongoDB

#### Record-level consistency
1. Some DB systems (e.g. Hbase & CouchDB) support "record level transactions"
2. This means that updates to fields of individual records are either all
   applied or not applied

#### CAP Theorem
**Choose 2**

1. **Consistency** --- do all applications see the same data
2. **Availability** --- can I interact with the system in the presence of
   failures
3. **Partitioning** --- if two sections of the system can't talk to each
   other, can they still make forward progress
    * For instance, if you have a master node, you will not be able to make
      progress if someone can't communicate with the master?
        * If you do allow that, you are sacrificing *Availability*
        * If you don't allow that, you are sacrificing *Consistency*
        * If you need both of those, then don't use *Partitioning*

#### Byzantine fault tolerance
1. **Byzantine failure** --- an arbitrary fault that occurs during the
   execution of an algorithm by a distributed system
    1. stopping
    2. crashing
    7. failing to receive a request
    3. processing requests incorrectly
    4. corrupting their local state
    5. producing incorrect
    8. failing to send a response
    6. producing inconsistent outputs
2. A **Byzantine fault tolerant system** will be able to correctly provide the
   system's service assuming there are not too many Byzantine faulty
   components

#### Two generals' problem
[Wikipedia page](http://en.wikipedia.org/wiki/Two_Generals%27_Problem)

1. A thought experiment meant to illustrate the pitfalls and design challenges
   of attempting to coordinate an action by communicating over an unreliable
   link.
2. There is a red army, then a hill, then a blue army, then a hill, then a red
   army again
3. The two red armies want to agree on a time to attack the blue army
4. They can't guarantee that any messages from one red army get to the other
   one because the messenger may be captured by the blue army, and the message
   could be lost or altered

**There's no algorithm that they can use (e.g. attack if more than four
messages are received) which will be certain to prevent one from attacking
without the other.**

##### Proofs of nonexistence
*I copied these in because I liked them.*

###### For deterministic protocols with a fixed number of messages

Suppose there is any fixed-length sequence of messages, some successfully
delivered and some not, that suffice to meet the requirement of shared
certainty for both generals to attack. In that case there must be some minimal
non-empty subset of the successfully delivered messages that suffices (at
least one message with the time/plan must be delivered). Consider the last
such message that was successfully delivered in such a minimal sequence. If
that last message had not been successfully delivered then the requirement
wouldn't have been met, and one general at least (presumably the receiver)
would decide not to attack. From the viewpoint of the sender of that last
message, however, the sequence of messages sent and delivered is exactly the
same as it would have been, had that message been delivered. Therefore the
general sending that last message will still decide to attack (since the
protocol is deterministic). We've now constructed a circumstance where the
purported protocol leads one general to attack and the other not to attack -
contradicting the assumption that the protocol was a solution to the problem.

###### Daryl's proof (not sure if this works)

Every message could just fail

##### One nice solution
1. Send 100 messages and hope one gets through

### Kernel

#### 3/19/14

[Wikipedia](http://en.wikipedia.org/wiki/Operating_system_kernel)

* A program that turns I/O requests from software into instructions for the
  CPU/memory/devices
* Programs (read *"processes"*) make *system calls*
    * **System call** -- request for resources or for operations to be
      performed by OS
        * It is the operating system's API
* Schedules which processes run when
* Decides which process has access to what memory locations when (via *virtual
  addressing*)
* Relays I/O requests from applications to the appropriate device (via *device
  drivers*)
    * **Device driver** -- provides an API for hardware devices
        * Hardware dependent, and operating system specific
        * Apple's open-source framework for developing OS X drivers is `I/O
          Kit`
* Methods for *synchronization* and *inter-process communication*
* Certain kernel functions can be delegated to special-purpose hardware (e.g.
  Memory Management Unit for checking access-rights for memory access)

#### Monolithic Kernel

* One single program that contains all of the code necessary to perform every
  kernel related task
* Traditionally used by *nix systems
* Allows the whole system to be much smaller
* More difficult development environment
* More difficult to maintain

#### Microkernel

* OS functionality is moved to a set of *servers* that comminicate with
  eachother via a "minimal kernel"
* First one designs a set of primitives (e.g. system calls for memory mgmt,
  scheduling, and IPC)
* Then higher low-level system implementations (e.g. networking) are user-
  space processes, called *servers*
* Easier to maintain and debug
* More context switches can slow down the system
* Bugs are less likely to bring the system down

### Concurrent Programming

Edsger Dijkstra proved ("Cooperating Sequential Processes", 1965) that from a
logical point of view, atomic lock and unlock operations operating on binary
semaphores are sufficient primitives to express any functionality of process
cooperation. [Wikipedia](http://en.wikipedia.org/wiki/Operating_system_kernel)

But that is such a painful method of programming, that we're still looking for
good abstractions and alternatives.

### Inter-Process Communication

**TODO**

[Wikipedia](http://en.wikipedia.org/wiki/Inter-process_communication)

Some Options:

* File
* Signal
* Socket
* Message queue
* Pipe
* Named pipe
* Semaphore
* Shared memory
* Message passing ("shared nothing")
* Memory-mapped file

