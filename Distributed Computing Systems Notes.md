latex input:		mmd-article-header
Title:		Distributed Computing Systems Notes
Author:		Ethan C. Petuchowski
Base Header Level:		1
latex mode:		memoir
Keywords:		big data, consistency
CSS:		http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:			2016 Ethan C. Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

## Consistency

### Order by strength

\\[strong > sequential > weak\\]

### Strong Consistency

* All accesses are seen by all parallel processes in the same order (sequence)
* Reads must return the value of the last write to that location

### Sequential Consistency

* The result of any execution is the same as if the operations of all the
  processors were executed in some sequential order, and the operations of each
  individual processor appear in this sequence in the order specified by its
  program -- Lamport
* Every process sees write operations to the same location in the same order
  (though not necessarily the global "real time order" [not sure what that is])
* Does _not_ require that reads return the value of the last write to that
  location

### Weak Consistency

* All accesses to synchronization variables are seen by all parallel processes
  in the same order (sequence)
* No other order guarantees are made about accesses between processes
    * However the _set_ of reads and writes seen between synchronization
      operations is the same across processes

### Eventual Consistency

__TODO__

### Linearizability

* Aka **atomic, indivisible, uninterruptible**
* Appears to the rest of the system to occur instantaneously
    * Obviously it doesn't _actually_ occur instantaneously, so this is
      achieved via synchronization variables and cache coherence protocols
* Guarantees "isolation" (a la ACID) from concurrent processes
* Also guarantees "atomicity" (a la ACID: either changes the state
  successfully, or has no apparent effect)
