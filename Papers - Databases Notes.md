latex input:    mmd-article-header
Title:          Databases Papers Notes
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

## Bigtable: A Distributed Storage System for Structured Data

**Notes from 6/20/15**

> Chang, Fay, Jeffrey Dean, Sanjay Ghemawat, Wilson C. Hsieh, Deborah A.
> Wallach, Mike Burrows, Tushar Chandra, Andrew Fikes, and Robert E. Gruber.
> "Bigtable: A distributed storage system for structured data." ACM
> Transactions on Computer Systems (TOCS) 26, no. 2 (**2008**): 4. **Google,
> Inc.**

Note that this is old now, and Google has (at least in large part) moved on
from using Bigtable itself. At some point I'll probably take notes on *Spanner*
which addresses some problems raised while using Bigtable. In reading the
paper, I'm assuming there is still something to be learnt from it after all
this time.

### Abstract & Introduction

* Designed to scale to *petabytes* across 1,000s of commodity servers
* Stores data for web indexing, Google Earth, and Google Finance, personalized
  search, Google Analytics
* This includes both backend bulk processing, and real-time data serving
* Bigtables data model gives clients dynamic control over data layout and
  format
* Doesn't support full relational data model
* Data indexed using row and column names (arbitrary strings)
* Data treated as uninterpreted strings (clients can serialize their objects
  into this)
* Clients dynamically control whether to serve data from memory or disk

### Data Model

* "A Bigtable is a sparse, distributed, persistent multi-dimensional sorted
  map, indexed by a row key, column key, and timestamp; each value
  in the map is an uninterpreted array of bytes." 
  \\((row:string, column:string, time:int64) → string\\)
    * E.g. for a *Webtable*, *row-keys* are URLs, columns include contents, as
      well as each in-reference from another page, then each \\((row, col)\\)
      has a set of values, each associted with a *timestamp*.
* A read or write of a row is atomic, and may affect multiple columns
* Data is ordered lexicographic by row key
* Row ranges are dynamically partitioned into **tablets**, the unit of
  distribution and load balancing
    * Due to this, one should choose row names that match your access pattern
* Column keys are grouped into **column families**, the basic unit of *access
  control*
    * Access control is necessary because multiple applications may read or
      write the same bigtable
* "Different versions of a cell are stored in decreasing timestamp order, so
  that the most recent versions can be read first."

### API

* (Create & delete) (tables & column families), change metadata (e.g. access
  control rights)
* Write or delete values, look up values from individual row, or iterate over
  subset
* Single-row transactions (atomic read-modify-write)
* Bigtables can be inputs and outputs for MapReduce jobs

### Building Blocks

* Stores log and data files in Google File System (GFS)
* Runs on a cluster of machines that are also running other applications
* Relies on a cluster management system for scheduling jobs, resource
  management, dealing with failures, and monitoring machine status
* Data is stored in the Google SSTable file format, providing a persistent
  `immutable.OrderedMap[String, String]`
* SSTables are a sequence of indexed blocks
    * index is loaded into memory on application launch
    * blocks themselves can optionally be loaded into memory
* Relies on Chubby, a distributed lock service & file system (just like
  ZooKeeper)
    * Ensuring the cluster has a single active *master* node, tablet server
      discovery, finalizing server deaths, storing schema info, and storing
      access control lists

### Implementation

* Tablet servers can be dynamically added and removed from a cluster
* Master assigns tablets to tablet servers, load balances, garbage collects
  (using client-chosen expiry algorithm [e.g. 3 days, or 10 versions])
* Tablet servers handle read & write requests to any of their ~100s of tablets,
  and split tablets that have grown too large
* Client data doesn't go through master, clients don't find tablets using
  master, most clients never talk to master, master is only lightly loaded
* Tablet's are roughly 100-200 MB in size by default
* Chubby holds *root tablet* containing location of metadata tablets which hold
  locations of tables
* Tablet locations are cached by the client library
* Tablets are assigned to one tablet server at a time
    * This is handled by the *master*, by monitoring Chubby, who keeps track of
      which servers are alive
    * There are plenty of complications with this that I will not repeat herein
* Tablet updates are committed to a commit log that stores redo records
    * This facilitates tablet recovery
* Tablet state is stored in GFS
* Recent commits are stored in a *memtable* buffer, which takes part in
  handling read requests
    * When it hits a size threshold, it's converted to a SSTable and written to
      GFS
* *Merging compactions* happen in the background, and merges multiple SSTables
  with the current memtable to produce a compacted SSTable

### Refinements

* Here they describe optimizations to make the above design more performant,
  reliable, and available
* Column families can be combined into *locality groups* which are accessed
  together, and hence are pulled together into memory and held there for a
  while
* SSTables for a locality group may optionally be compressed by a supplied
  algorithm
* Tablet servers cache SSTables by either row or block
* Bloom filters can optionally be used to check whether an SSTable has data for
  a specified row/column pair to reduce the number of disk seeks for reads
* Commit logs don't fit well with the GFS model, so they did some stuff
* The immutability of SSTables means access needn't be synchronized across
  reads
* Memtable is copy-on-write to allow simultaneous reads and writes

### Performance Evaluation

* Performance scaling is roughly 100x as #servers goes from 1-500

### Real Applications

* Stores raw click data (~200 TB) and summary tables (~20 TB) for Google
  Analytics
* Google Earth uses MapReduce over Bigtable to transform from compressed raw
  satelite imagery to geographic segments
* Personalized Search stores each user's data and actions (e.g. web queries) in
  Bigtable

### Lessons

* Learned that distributed systems don't just have network partitions and fail-
  stop failures; they have memory corruption, clock skew, hung machines,
  asymmetric network partitions, bugs in other services (e.g. Chubby), planned
  and unplanned hardware maintenance, etc.
* Addressed these issues by changing protocols and adding checksumming
* Importance of system-level monitoring (e.g. Bigtable itself and its client
  processes) for detecting and fixing bugs and performance issues
* Don't use obscure Chubby features because they don't work properly

### Related Work

* "The manner in which Bigtable uses memtables and SSTables to store updates to
  tablets is analogous to the way that the Log-Structured Merge Tree stores
  updates to index data"
* C-Store and Bigtable share many characteristics

### Conclusions

* "Our users like the performance and high availability provided by the
  Bigtable implementation, and that they can scale the capacity of their
  clusters by simply adding more machines to the system as their resource
  demands change over time."
* "An interesting question is how difficult it has been for our users to adapt
  to using it. New users are sometimes uncertain of how to best use the
  Bigtable interface, particularly if they are accustomed to using relational
  databases that support general-purpose transactions."

## C-Store: A Column-oriented DBMS

> M. Stonebraker, D. J. Abadi, A. Batkin, X. Chen, M. Cherniack, M. Ferreira,
> E. Lau, A. Lin, S. R. Madden, E. J. O'Neil, P. E. O'Neil, A. Rasin, N. Tran,
> and S. B. Zdonik. C-Store: A Column-Oriented DBMS. In VLDB, pages 553–564,
> 2005. MIT, Brandeis, UMass Boston, Brown (i.e. it's diversely *Bostonian*.)

### Abstract & Introduction

1. C-Store is a __relational database management system__ (DBMS)
2. It is __read-optimized__
    * Whereas most systems are write-optimized
    * C-Store gets reasonable write speed as well
    * Reduces the number of disk-accesses per query
3. __Data is stored by column__ rather than by row
4. Read-only transactions include high availability and snapshot isolation
5. Shown to be __substantially faster__ than popular commercial products
6. In most DBMSs, attributes for a record ("tuple") are placed contiguously in
   storage to make writing new records to disk easy
7. However data warehouses are optimized for ad-hoc queriyng, ie. _"read-
   optimized"_, like CRM systems, card catalogs, etc.
    * For this, the *column store* architecture---in which values for a single
      column ("attribute") are stored contiguously---are more efficient
8. Now, irrelevant attributes needn't be brought into memory
9. Modern speed-tradeoffs imply we should trade CPU ineffiency for disk
   efficiency; disk bandwidth is low compared to CPU speeds
10. Do this by encoding abbreviations of the set of values, and storing the
    encoded form of our attribute values
    * Also, forget about byte/word-aligning values on disk
11. B-trees are good for a write-, but not a read-optimized world
    * For read-optimization, we prefer bit-map, cross-table, and materialized-
      view index structures, with _no_ B-tree at all.
12. So here, each column is stored separately, each sorted in its own way
    * Or the same column may be stored multiple times, sorted in different ways
        * This redundancy also happens to increase data availability
12. Projection --- groups of columns sorted on the same attribute
13. We assume "grid" environment, where each node has private disk and memory
14. Horizontally partition data across nodes for _intra-query parallelism_
15. Allocate data structures to grid nodes automatically
16. Want transactional, on-line updates; minimize delay to data visibility
17. One writes to the write-optimized Writeable Store (WS) component, then the
    _tuple mover_ batches writes into the Read-optimized Store (RS)
    * Both are column-oriented
18. Deletes go to RS, inserts to WS, and updates are implemented as an insert
    and a delete

### Data Model

* Relational logical data model, but physically only store projections

Hmm

* Reading this would probably be much more profitable *after* having read more
  about typical relational database internals because this is all about what
  they did *w.r.t.* what is normally done.
