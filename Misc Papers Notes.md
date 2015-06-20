latex input:    mmd-article-header
Title:          Misc Papers Notes
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

# Databases

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

#### Tablet Location

Not done yet

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
4. Read-only transactions are implemented to include high availability and
   snapshot isolation
5. It is shown to be __substantially faster__ than popular commercial products
6. In most DBMSs, attributes for a record ("tuple") are placed contiguously in
   storage
    * This makes writing new records to disk easy
7. However data warehouses are optimized for ad-hoc queriyng, ie. _"read-
   optimized"_, like CRM systems, card catalogs, etc.
    * For this, the *column store* architecture---in which values for a single
      column ("attribute") are stored contiguously---are more efficient
8. Column storage means irrelevant attributes needn't be brought into memory
9. With modern speed-tradeoffs, we should trade CPU ineffiency for disk
   efficiency because disk bandwidth is so low compared to CPU speeds
10. We can do this by encoding abbreviations of the set of values, and storing
    the encoded form of our attribute values
    * Also we can forget about byte/word-aligning values on disk
11. B-trees are good for a write-, but not a read-optimized world
    * For read-optimization, we prefere bit-map, cross-table, and materialized-
      view index structures, with _no_ B-tree at all.
12. So here, each column is stored separately, each sorted in its own way
    * Or the same column may be stored multiple times, sorted in different ways
        * This redundancy also happens to increase data availability
12. Projection --- groups of columns sorted on the same attribute
13. A "grid" environment is assumed, where each node has private disk and
    memory
14. Data is horizontally partitioned across various nodes
    * This facilitates _intra-query parallelism_
15. Data structures are allocated to grid nodes automatically
16. Want transactional, on-line updates, with delay to data visibility
17. One writes to the write-optimized Writeable Store (WS) component, then the
    _tuple mover_ batches writes into the Read-optimized Store (RS)
    * Both are column-oriented
18. Deletes go to RS, inserts to WS, and updates are implemented as an insert
    and a delete

End of intro. Rest is work in progress.

# Networking

## The Akamai Network: A Platform for High-Performance Internet Applications

> Nygren, Erik, Ramesh K. Sitaraman, and Jennifer Sun. "The akamai network: a
> platform for high-performance internet applications." ACM SIGOPS Operating
> Systems Review 44.3 (2010): 2-19.

### Introduction

1. The Internet is too slow to conduct global business
2. Akamai invented Content Delivery Networks in the 1990s
3. 2010, Akamai delivers 15-20% of global Web traffic, as well as DNS,
   analytics, live streaming HD video, etc.
4. They believe a *highly distributed network* is the most effective
   architecture for these purposes

### Internet Application Requirements

1. End-to-end system quality --- *any* outages are *very* costly
2. Sheer website performance is important for maintaining customer loyalty
3. Increasing website performance makes customers more likely to purchase
4. The Internet itself provides no end-to-end reliability or performance
   guarantees

### Internet Delivery Challenges

1. The Internet is composed of 1000s of networks
2. The largest has only 5% of Internet access traffic
3. It takes 650 networks to get to 90% of all access traffic
4. So centrally-hosted content must travel through multiple networks to reach
   end-users
5. No money is made on the "middle-mile" *peering points* where one network
   connects to a competitor's, thus creating bottlenecks/congestion causing
   packet loss and increased latency
6. **BGP (Border Gateway Protocol)** --- used for exchanging routing
   information between ISPs. Layer 4, sits atop TCP.
7. BGP is inefficient and subject to business agreements, misconfiguration,
   foul play, hijacking, etc. and can cause route flapping, bloated paths, and
   broad connectivity outages
8. Internet outages and partitions happen all the time
9. TCP carries significant overhead, and is a bottleneck for video because
   every window of packets must be ACKd, which means throughput is inversely
   related to round trip time (RTT/network latency)
10. Origin server capacity needs to scale quickly with demand
11. People's continued use of IE6 and other old technology means algorithm
    improvements can't break their ability to access content

### Delivery Network Overview

1. CDNs originally just cached static site content at the "edge" of the
   Internet, close to end users to avoid middle-mile bottlenecks
2. Now they accelerate entire web apps and provide HD live streaming media
3. They provide security, logging, diagnostics, reporting, and management tools

#### Delivery Networks as Virtual Networks

1. **Delivery network** --- *virtual network* built as a software layer over
   the actual Internet
2. Provides reliability, performance, scalability, and security
3. Works over the existing Internet as-is, requiring no client software and no
   changes to the underlying networks

#### Anatomy of a Delivery Network

1. Akamai's network has 10k's of globally deployed servers running
   sophisticated algorithms to enable faster content delivery
2. Different servers are running different algorithms for optimize for
   different things (e.g. dynamic content vs streaming media)
3. User enters URL into browser, URL is translated by the **mapping
   system** into the IP address of an **edge server** using historical and
   current data with machine learning
4. The *edge server* sends the requested data to the user
5. If the *edge server* needs to request data from the **origin server**,
   it uses the highly reliable and performant **transport system**
6. *Communications and control system* --- disseminates control messages
   and configuration updates
7. *Data collection and analysis system* --- monitoring, analytics, billing
8. *Management portal* --- configuration management platform for customers
   with analytics about customer usage and demographics

#### System Design Principles

1. Delivery networks were designed with the philosophy that failures are normal
   and everything must operate seamlessly despite them, so there are no single
   points of failure
2. Also, highly automated, scalable, performant

### High-Performance Streaming and Content Delivery Networks

1. Instead of dozens of massive datacenters of servers, there are 1000s of
   locations with server clusters

#### Video-grade Scalability

1. In the next 2--5 years, throughput requirements will grow by an order of
   magnitude
2. The bottleneck will no longer be just the origin data center, but it could
   be the peering point or network backhaul capacity
3. Thus CDNs will be even *more* of a necessity
4. Software multicast implementations have been far more practical than IP-
   layer multicast

#### Streaming Performance

1. Akamai optimizes stream availability, startup time, frequency and duration
   of playback interruptions, and effective bandwidth
2. They built a global monitoring infrastructure that simulates users to test
   quality and collect data

#### A transport System for Content and Streaming Media Delivery

1. Recall from above, the **transport system** connects the *edge servers* with
   the *origin servers*
2. Edge servers use excellent caching strategies
3. *Tiered distribution* involves a cache pyramid with "parent" clusters
   holding more content
4. When new content is made available for streaming, it is sent to multiple
   *entrypoints* and then there's an intermediate layer of *reflectors* which
   relay streams (according to their own software routing algorithms) to *edge
   clusters*

### High-Performance Application Delivery Networks

#### A Transport System for Application Acceleration

1. Akamai has highly optimized inter-edge-server communication which reduces
   packet loss
    1. path optimization --- instead of BGP's chosen path
    2. protocol enhancements (because they're not constrained by client
       software adoption rates) --- including persistent connection pools,
       dynamic TCP window sizing, overriding standard TCP timeout and
       retransmission protocols
2. Application-wise, **edge-servers can prefetch content** before the user's
   browser requests it, **so dynamic content *appears* to be cached**.
   Customers can decide the specifics of how this is done
3. Content compression is useful for end users with slow connections
4. Having a great overlay network makes for good long-distance performance---
   for large files, for example, **origin server downloads that go over the
   high performance overlay can perform nearly as well as files delivered from
   cache because the overlay is able to deliver the file from origin to edge
   server as quickly as the edge server can deliver to the end user**.

#### Distributing Applications to the Edge

1. Akamai EdgeComputing takes cloud computing to a new level of performance,
   reliability, and scalability by distributing the application *itself* to the
   "edge", so application resources are allocated not only on-demand but also
   near the end user.
2. Applications relying heavily on large transactional databases still require
   significant communication with the origin server
3. However there are use cases, like content aggregation and reformatting,
   static databases (product catalogs), data validation and data input
   batching, and static pieces of dynamic content

### Platform Components

#### Edge Server Platform
1. Customers can tune exactly how the edge servers are to be used

#### Mapping System

1. The scoring system first creates a current topological map capturing the
   state of connectivity across the entire Internet. This requires collecting
   and processing tremendous amounts of historic and real-time data—including
   pings, traceroutes, BGP data, logs, and IP data, collected cumulatively over
   the years and refreshed on a continual basis.
2. This is used by the Akamai platform to direct end users to the best edge
   servers and to select intermediates for tiered distribution and the overlay
   network.
3. This system is all highly distributed and fault-tolerant

#### Communications and Control System

1. For small status and control messages, they use public/subscribe with multi-
   path tiered fan-out
2. Configuration updates are published to storage servers with quorum-based
   replication

#### Data Collection and Analysis System

1. Collect 100TB of logs per day, compressed and aggregated to a set of
   clusters with dedicated processing pipelines, then passed to systems for
   analytics, storage, and delivery to customers
2. Real-time monitoring of status information of just about every software
   component can be done through a standard SQL interface to their Query system

#### Additional Systems and Services

1. DNS, network and website performance monitoring agents, medium-term storage,
   management portal with analytics, etc.

### Example: Multi-Level Failover

1. DNS resolution first goes to generic Top Level Domain servers, then Akamai's
   Top Level Name Servers, then Akamai Low Level Name Servers, which returns an
   edge server IP address based on the mapping system from above. Then the
   browser makes an HTTP request to the edge server.
2. If a machine fails, another machine will start responding to that IP address
   and the low level map is updated
3. If a cluster fails it will be removed from the map
4. If a connection degrades, the path optimization will no longer use it

### Customer Benefits and Results

#### Customer Examples for Content and Streaming Delivery

1. Improved performance, reliability, infrastructure cost savings, protection
   from DDoS, ability to handle flash crowds

#### Customer Examples for Application Delivery

1. Performance, reliability, less latency for international traffic, large file
   transfers using Akamai's overlay network, avoid building out regional data
   centers

# Distributed Computing

## Spark: Resilient Distributed Datasets, In-Memory Cluster Computing

> Zaharia, Matei, Mosharaf Chowdhury, Tathagata Das, Ankur Dave, Justin Ma,
> Murphy McCauley, Michael J. Franklin, Scott Shenker, and Ion Stoica.
> **"Resilient distributed datasets: A fault-tolerant abstraction for in-memory
> cluster computing."** In Proceedings of the 9th USENIX conference on
> Networked Systems Design and Implementation, pp. 2-2. USENIX Association,
> 2012.

### Abstract / Intro

1. They've invented the concept of "Resilient Distributed Datasets" (RDDs) and
   released the primary implementation of them in Apache Spark
2. It's a *distributed memory abstraction* that facilitates writing fault-
   tolerant in-memory computations on large clusters
3. Only allow coarse-grained transformations/updates to shared state
4. Addresses the fact that MapReduce lacks the ability to leverage distrubuted
   RAM, making it inefficient for
    1. applications that reuse intermediate results across multiple
       computations
        * e.g. iterative machine learning and graph algorithms
            * e.g. PageRank, K-means, logistic regression
    2. Running interactive, ad-hoc queries on the same subset of the data
5. Existing abstractions for in-memory cluster storage can only provide fault
   tolerance by replicating the data, or logging updates across machines
    * This is because those systems allow fine-grained updates to mutable state
    * This is expensive for data-intensive workloads because of all the network
      bandwidth used for copying data around
    * In contrast, an RDD only logs the *transformations* used in its creation
      (i.e. its *"lineage"*)
6. Spark can also be used to interactively query big datasets from the Scala
   interpreter

### Resilient Distributed Datasets (RDDs) 

1. An RDD is a read-only, partitioned collection of records
2. Can only be created through deterministic operations on (1) data in stable
   storage or (2) other RDDs
3. An operation that creates an RDD is called a "transformation" and includes
   `map`, `filter`, and `join`.
4. You are allowed to define the data partitioning scheme across machines for
   optimizing joins to co-locate the data
5. As opposed to *transformations*, **actions** return a value to the
   application, or export data to a storage system
    * e.g. `count`, `collect` (returns the elements), `save`
6. RDDs aren't actually computed until they're used in an action, allowing
   transformations to be pipelined
7. Calling `persist` on an RDD means you want to save an RDDs transformed data
   after it has been computed for further transformations or other actions,
   etc.
8. The system mitigate "stragglers" by running backup copies (a la *MapReduce*)
9. Partitions that don't fit in RAM will basically devolve to MapReduce jobs
10. Note that this "coarse-update-only" model is *only* good for batch
    analytics

### Spark Programming Interface

1. Scala was chosen because it is concise and efficient
2. Developers write a *driver program* that connects to a cluster of *workers*
3. Note that `flatMap` in Scala/Spark corresponds to the `map` in "map-reduce"

More about this is best left to a Spark programming tutorial.

### Representing RDDs

1. All RDDs are represented through an common `interface` to simplify the
   scheduler and overall system design. This interface includes
    * Set of *partitions* -- pieces of the dataset
    * Set of *dependencies* on parent RDDs, which can be either
        * *narrow* -- ≤ 1 child has it, e.g. `map`; allows pipelining
          transformations on a single cluster node, and simple recovery
        * *wide* -- otw, e.g. `join`; requires "shuffling" data across nodes, a
          la MapReduce
    * A *function* for computing RDD from parents
    * And *metadata* about partitioning scheme and preferred (node) locations
      for getting easy access to the data

### Implementation

1. 14,000 lines of Scala
2. System runs over the Mesos cluster manager
3. Scala itself was unmodified (though you have to use *their* modified
   interpreter to do the interactive ad-hoc querying stuff)
4. Failed tasks are re-run on another node
5. Scheduler chooses the best node to run each task based on data-locality
6. The data in persistent RDDs can be stored
    * In the JVM heap as deserialized Java objects
    * serialized in-memory data, or
    * on-disk
7. The user can choose to checkpoint RDDs at will via API (`persist`)

### Evaluation

1. Big speedup over Hadoop (20-100x) by avoiding I/O and deserialization by
   leaving data in the Java heap
2. Queried 1TB in 5-7 seconds (100 `m2.4xlarge` EC2s with 8 cores, 68 GB RAM)
    * Querying on disk to 170s
3. Much faster to store RDD data in Java objects rather than in-memory local
   files (this seems to relate to Tachyon [which I don't think was out yet])
4. Performance degrades gracefully with decreasing memory to data ratio

### Discussion

1. RDDs' immutability & limited API of coarse-grained transformations is still
   suitable for a wide class of applications
2. RDDs allow efficient expression existing programming models including
   MapReduce, DryadLINQ, SQL, Pregel (Google's graph processing), iterative
   MapReduce (e.g. HaLoop, Twister), batched stream processing (e.g. 15 min
   latency on ad-click data)
3. RDDs' immutability and coarse-grained nature makes them highly-debuggable

Fin.

## Kafka: a Distributed Messaging System for Log Processing

> Kreps, Jay, Neha Narkhede, and Jun Rao. "Kafka: A distributed messaging
> system for log processing." In Proceedings of the NetDB, pp. 1-7. __2011__.
> All (were) employees of LinkedIn Corp.

**Most of these notes may be direct quotes from the paper**

### Abstract
1. a distributed messaging system for collecting and delivering high volumes of
  log data with low latency.
2. suitable for both offline and online message consumption
3. unconventional design choices to optimize efficiency and *scalability*

### Introduction

Internet companies generate *terabytes* of log data *daily* for

1. __User activity events__ --- logins, clicks, likes, comments, and queries
2. __Operational metrics__ --- service call stack, latency, and utilization

These can then be used for

1. __Analytics__ --- tracking engagement, and utilization
2. __Features__ --- search, recommendations, ad targeting, security, newsfeed

Facebook and Yahoo have their own systems for loading data into Hadoop for
offline consumption, but LinkedIn wants to use this data for real- time (order
of seconds) application delays.

Their Kafka implementation is __open source__, and greatly simplifies their
architecture for both online and offline data processing.

### Related Work
Traditional enterprise messaging systems have existed for a long time and often
play a critical role as an event bus for processing asynchronous data flows.

Those systems have the following feature mismatches:

1. Focus on rich delivery guarantees (overkill for log data) over throughput
2. Don't provide easy way to partition messages across multiple machines.
3. Assume near immediate consumption of messages
    * Performance degrades significantly if messages are allowed to accumulate

"At LinkedIn, we find the _“pull”_ model more suitable for our applications
since each consumer can retrieve the messages at the maximum rate it can
sustain and _avoid being flooded_ by messages pushed faster than it can handle.
The pull model also makes it _easy to rewind_ a consumer."

### Kafka Architecture and Design Principles

#### High-level
* __Topic__ --- a __stream__ of messages of a particular type
* __Producer__ --- publishes messages to a _topic_
* __Broker__ --- where published messages are stored by a _producer_
    * A single producer may store [messages from the *same* topic] at multiple
      brokers (for load balancing)
* __Consumer__ --- __subscribes__ to one or more _topics_ from the _brokers_
    * Consume _subscribed_ messages by _pulling_ data from _brokers_.
* __Subscription__ --- provides the _consumer_ an _iterator interface_ over the
  messages being produced, so it may process them
    * The iterator _blocks_ when it's empty until new messages are published to
      the _topic_.

##### Sample producer code

    producer = new Producer(...);
    message = new Message(“test message str”.getBytes());
    set = new MessageSet(message);
    producer.send(“topic1”, set);

##### Sample consumer code

    streams[] = Consumer.createMessageStreams(“topic1”, 1);
    for (message : streams[0]) {
        bytes = message.payload();
        // do something with the bytes
    }

#### Efficiency on a Single Partition
1. Producer _publishes_ to a partition _by simply appending_ the message to the
   last _segment file_ (e.g. 1 GB)
    * The message is consumable only after it is flushed
2. No "message ID", each message only has a _logical offset_ in log (in bytes)
    1. Removes overhead of maintaining auxiliary index mapping
    2. The broker keeps the sorted list of offsets in memory
    3. The consumer calculates the offset of the next message it wants on its
       own
3. Consumer only consumes sequentially
4. Consumer acknowledges message offset, implying it has received all prior
   messages in that partition
5. They have numerous optimizations which they list, mainly ways of allowing
   themselves to rely on caching provided by the OS
6. Experiments show that "production and the consumption have _consistent
   performance linear to the data size_, up to many terabytes of data."
7. They use the "`sendfile` API" that Witchel talked about
    1. this is where you directly transfer bytes from an OS file channel to a
       socket channel, without having to go through an application buffer
    2. this reduces 4 data copies and 2 syscalls into 2 copies and 1 "sendfile"
       syscall
8. Messages are (only, automatically) deleted after a defined time-period
   (typically 7 days)
    1. This is a much simpler mechanism than one might initially dream up, but
       is useful in practice
    2. It allows consumers to *rewind* and re-consume data
        * E.g. to re-play messages after fixing an error
9. Broker doesn't maintain offsets of consumers ("stateless")

#### Distributed Coordination
1. __Consumer group__ --- "one or more consumers that jointly consume a set of
   subscribed topics, i.e. each message is delivered to only one of the consumers within each group"
    1. Consumers within groups could be on different machines (or not)
2. Each partition is consumed by only one consumer in the group  
3. Coordination of consumers is tasked to the "highly available consensus
   service Zookeeper" which has a "file system like API"
    1. Detecting addition and removal of brokers and consumers, and at those
       times triggering a rebalance process (see algorithm 1 in the paper)
        * Done by storing broker and consumer *registries* mapping
          `hostname:port` to set of subscribed topics & partitions (broker) or
          topics & consumer groups (consumer)
    2. Tracking consumption offset of each partition

#### Delivery Guarantees
1. Kafka only **guarantees at-least-once delivery**
    1. Guaranteeing *exactly-once* would require 2PC and is not necessary 
    2. In practice, exactly-once is what happens
        * Duplicates occur whan a consumer crashes at the wrong time
        * You can efficiently de-dup if you google-it
2. Kafka guarantees that **messages from a single partition** are delivered to
   a consumer **in order**. However, there is **no guarantee** on the ordering
   of messages coming from **different partitions**.
3. [At the time of writing,] if the storage system on a broker is permanently
   damaged, any unconsumed message is *lost forever*.

### Kafka Usage at LinkedIn

1. Frontend servers batch-publish log data to Kafka brokers in the same data
   center, and online consumers run within the same datacenter
2. Another Kafka cluster in a separate datacenter for offline analysis pulls
   from the cluster described in (1) above, from which consumers pull into a
   Hadoop infrastructure
3. They can run ad-hoc queries against live event streams on the cluster in (2)
4. End-to-end latency of ~10 seconds
5. Avro is used as serialization protocol
    1. Efficient and supports schema evolution
    2. Each message stores Avro schema id
    3. Schema allows producer/consumer compatibility enforcement
    4. Schemas can be retrieved from a registry
    5. Schemas are immutable

### Experimental Results

1. Compared with Apache ActiveMQ (JMS), and RabbitMQ
2. Much *faster*, but *less features* provided compared to those services

#### Producer Test
1. Kafka is *much* faster when you *batch* messages (e.g. 50 at a time)
2. Kafka is **way frikin faster**
3. Why?
    1. Producer doesn't wait for acknowledgements (this may be an option in the
       future though)
    2. Producer sends messages as fast as the broker can handle
        * A single producer almost saturated the 1Gb link to the broker
    3. More efficient storage format (less space devoted to metadata)
    4. Batching amortizes RPC overhead

#### Consumer Test
1. 4X ActiveMQ and RabbitMQ
2. More efficient storage format
3. No maintenance of delivery state of every message
4. Use of the Linux `sendfile` API

### Conclusion and Future Works

#### Conclusion
1. Pull-based consumption model
2. Much higher throughput
3. 'Distributed' support for "scaling out"

#### Future work
1. Built-in message replication across multiple brokers
    * for durability and availability (both synchronous and asynchronously)
2. Support for stream processing
    * To provide the foundation for processing distributed streams across a
      cluster of consumer machines.
    * Bonus library of helpful stream utilities
