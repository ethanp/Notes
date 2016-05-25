latex input:    mmd-article-header
Title:		      Distributed Computing Systems Notes
Author:         Ethan C. Petuchowski
Base Header Level:		1
latex mode:     memoir
Keywords:       big data, consistency
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:			2016 Ethan C. Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

## Introduction

We'd generally like to have as few constraints as possible on the ways we are
allowed to interact with our system while preserving the guarantees about
correctness. Rigorous correctness guarantees are always reducible to a set of
__safety__ constraints about what our system will _not_ do, and a set of
__liveness__ constraints about what our system _will_ do.

## Consensus

### Vague Definition

__All correct processes agree on the same proposed value.__

### Why we care

We want to achieve overall system reliability within a distributed (multi-
agent) system in the presence of (some) number of faulty processes.

### Precisely

* __Termination__ -- every correct process decides _some_ value
* __Integrity__ -- every correct process decides _at most one_ value, and it
  can decide \\(v\\) _only if_ some process proposes \\(v\\)
* __Agreement__ -- every correct process decides the _same_ value
* __Validity__ -- if all processes _propose_ \\(v\\), then all correct
  processes _decide_ \\(v\\)

### Uh-oh: FLP

__In a fully asynchronous system there is no algorithm that can be tolerate one
or more crash failures and still be guaranteed to achieve consensus in a
bounded time.__

## State machine replication

A general method for implementing a fault-tolerant system by replicating
servers and coordinating client interactions with server replicas.

Consider the case of having a _single_ replica. Now our system is pretty simple
for the client to reason about, but if that replica fails, the system will
become _unavailable_ which is often not desirable.

Consider the case of having _multiple_ replicas. Now if one replica is
_updated_, and the other replica is _read_, e.g. is the reader guaranteed to
read the _updated_ value?

## Consistency Models

* If the programmer follows the specified constraints, he is provided a way to
  reason about the results of operations on "memory" (aka. "a register") even
  if that "memory" is actually "shared" (used concurrently by multiple
  processes) or distributed (i.e. replicated)

### Order by strength

\\[strong > linearizability > sequential > causal weak\\]

One consistency model is considered _stronger_ than another if it requires all the same conditions/constraints and more.

### Strong Consistency

* All accesses are seen by all parallel processes in the same order (sequence)
* Reads must return the value of the last write to that location
* If one is reading from a replica, it means the the replica has received the
  new data from wherever it was written, which will take time (at least the
  speed of light...), so this thing is _slow_

### Linearizability

* Aka **atomic, indivisible, uninterruptible**
* Appears to the rest of the system to occur instantaneously
    * Obviously it doesn't _actually_ occur instantaneously, so this is
      achieved via synchronization variables and cache coherence protocols
* Guarantees "isolation" (a la ACID) from concurrent processes
* Also guarantees "atomicity" (a la ACID: either changes the state
  successfully, or has no apparent effect)
* Can be seen as _sequential consistency_ with a _real-time constraint_
    * (Not sure what that means)

### Sequential Consistency

* The result of any execution is the same as if the operations of all the
  processors were executed in some sequential order, and the operations of each
  individual processor appear in this sequence in the order specified by its
  program -- Lamport
* Every process sees write operations to the same location in the same order
  (though not necessarily the global "real time order" [not sure what that is])
* Does _not_ require that reads return the value of the last write to that
  location

### Causal Consistency

* Write operations should be seen in (Lamport's) _causal order_ by all
  processes

### Weak Consistency

* All accesses to synchronization variables are seen by all parallel processes
  in the same order (sequence)
* No other order guarantees are made about accesses between processes
    * However the _set_ of reads and writes seen between synchronization
      operations is the same across processes

### Eventual Consistency

__TODO__

## Bibliography

* Wikipedia
