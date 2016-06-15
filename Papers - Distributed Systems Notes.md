latex input:    mmd-article-header
Title:          Distributed Systems Papers Notes
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

## Event Sourcing, Martin Fowler

**7/3/15**

> "Capture all changes to an application state as a sequence of events."
> [Link](http://martinfowler.com/eaaDev/EventSourcing.html)

1. Normally for a given application, you can query its current state
2. For this pattern, we also store the state changes applied to reach the
   current state as a "sequence of events"
3. We can query the event log, use it to reconstruct past states, and cope with
   retroactive changes
4. Why not store each item's history in the instance?
    * Because this way, the log persisting the Event objects is the source of
      truth of state changes, and we can build independent services over this
      log (replication, query back-in-time, undo and recompute using new code)
5. Code-structure-wise, the event contains model-selection logic which helps
   the event processor object decide which models to update. The processor
   calls the right method on those model objects, which contains the processing
   domain logic.
6. We can make events reversable by including reversal logic in the object
    * This isn't strictly necessary because we can *also* just revert to a
      snapshot and play the relevant events onto that
7. It's problematic if your events "fire the missiles" because they will try to
   re-fire them on replay, when the target has already been demolished.
    * To handle this wrap missile-firing with the "Gateway" pattern [details
      ommitted]
    * You should replay past events "in replay mode" so the event processor
      knows what to tell the gateway
8. If your events rely on non-deterministic external response data, you have to
   store them and re-apply those stored responses on replay
    * *"This all sounds strangely familiar..."* -- Lorenzo Alvisi
9. You can backfill data from
    1. New features by adding it to past events
    2. After a bug-fix (which is great)
    3. As always, the problem is dealing with the Gateways
10. This log is great for debugging
    * You can create a test environment and replay events into there
11. If you have a system with lots of readers and few wriers, Event Sourcing is
    great because you stream events to a cluster of systems with in-memory
    databases, and route updates to a single message queue to a persisted
    database
    * *"This all sounds strangely familiar..."* -- Pat K


## Spark: Resilient Distributed Datasets, In-Memory Cluster Computing

**6/9/15**

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

## Spark SQL: Relational Data Processing in Spark

> Armbrust, Michael, Reynold S. Xin, Cheng Lian, Yin Huai, Davies Liu, Joseph
> K. Bradley, Xiangrui Meng et al. "Spark SQL: Relational data processing in
> Spark." In Proceedings of the 2015 ACM SIGMOD International Conference on
> Management of Data, pp. 1383-1394. ACM, __2015__. There are in total _11_
> authors on this paper, all are part of Databricks Inc. Matei Zaharia himself
> is the _last_ author.

7/12/15

### Abstract & Introduction

1. Spark SQL makes two main additions
    1. tighter integration between relational and procedural processing
    2. highly extensible optimizer, "Catalyst"
2. Spark SQL is officially, like, the coolest thing ever.
3. It is "a new module in Apache Spark that integrates relational processing
   with Spark's functional programming API"
4. Built on their experience with Shark (the old relational processing module
   for Spark)
5. "Offers richer APIs and optimizations, while keeping the benefits of the
   Spark programming model."
6. Raw MapReduce was too low level, that's why we got Pig, Hive, Dremel, and
   Shark -- to allow decarative queries over Big Data
7. But declarative queries don't work on semi- or unstructured data
8. Declarative queries don't allow one to easily express machine learning or
   graph processing algorithms
9. Data pipelines normally force the user to segregate their relational queries
   from their procedural algorithms
10. Spark SQL is designed to change that through
    1. The DataFrame API -- based on `R`'s `dataframe` object, but performs
       operations lazily, like RDDs; allows relational operations on both
       external data sources and Spark's built-in distributed collections
    2. The extensible optimizer, "Catalyst"
11. The DataFrame API makes it easy to compute multiple aggregates in one pass,
    via a SQL statement
    * This would be hard to express using the functional RDD API
12. DataFrames store data in a columnar format that is significantly more
    compact than Java/Python objects
13. Spark SQL is already deployed by a large Internet company on an 8000-node
    cluster with over 100 PB of data.
14. Spark SQL is up to 10x faster and more memory-efficient than naive Spark
    code in computations expressible in SQL
15. They see Spark SQL as an evolution of the core Spark API; making it both
    more accessible to new users, and faster for existing users

### Background and Goals

1. RDD optimizations are limited because the engine doesn't understand the
   structure of data in RDDs (arbitrary Java/Python objects) or the semantics
   of arbitrary user functions passed to the higher-order-function API
2. The first attempt at building a relational interface was Shark, which
   modified Hive to run on Spark
    1. It could only query data stored in the Hive catalog, not data _inside_ a
       spark program
    2. It only worked on (error-prone) SQL strings crafted by the user
    3. It was hard to extend for new features and data types
3. The Spark SQL system is meant to fix the limitations listed above

### Programming Interface

1. Spark SQL is a library atop Spark itself, which exposes SQL interfaces,
   accessible through JDBC, the console, and the DataFrame API
2. A __DataFrame__ is a distributed collection of `Row`s with the same `Schema`
3. It can be _viewed_ as an RDD of Row objects, allowing calls to the
   procedural Spark API
4. Uses a "nested data model" based on Hive
5. Supports all major SQL data types, complex data types like structs, arrays,
   maps, and unions (also nestable), and user-defined types
6. Logical plans are evaluated _eagerly_, and query results computed _lazily_.
   This means errors are reported often by the IDE, and more often once the
   program has started, but data processing has barely begun.
7. They built a bunch of optimizations for the case of converting RDDs into
   DataFrames via the `.toDF` function
8. "Cached" (aka. "materialized") DataFrames use columnar storage, as opposed
   to RDDs which use JVM objects, reducing memory by 10x by applying columnar
   compression schemes like dictionary encoding and run-length encoding
    * Use it by calling `.cache()` on the DataFrame
9. Spark allows inline definition of UDFs without the complicated packeging and
   registration normally used

### Catalyst Optimizer

1. Based on functional programming constructs in SCala
2. A goal was to make it easy to extend by external developer
3. Supports both rule- and cost-based optimizations
    * __Cost-based optimization__ -- performed by generating multiple _plans_
      using _rules_ and then computing and comparing their _costs_
4. It is the fist production-quality optimizer built in a functional language
5. The __logical analyzer__ runs transformations defined as partial functions
   over the input tree in batches until the tree stops changing
    * At time of writing, it's rules 1000 lines of code
6. The __logical optimizer__ has rules to e.g. rewrites SQL "`like`" into
   equivalent fast Scala `.startWith` or `.contains`
    * It's rules are 800 lines of code
7. The __phyiscal planner__ generates one or more physical plans out of the
   logical plan produced by the _logical optimizer_
    * It's currently only implemented to select join algorithms in certain
      cases, but it will be extended
    * It also does rule-based physical optimizations like pipelineing
      projections and filters into one `map` operation
    * It's rules are 500 lines of code
8. The __code generator__ uses Scala's "quasiquotes" which are Scala strings
   fed to the Scala compiler at runtime to generate bytecode
    * Plus the Scala compiler can apply its own expression-level optimizations
    * It is 700 lines of code
9. You implement a new _data source_ by implementing `createRelation`
    * For optimization, you can write code to return an RDD of `Row` objects,
      implement ("advisory", i.e. doesn't have to always work) pushdowns of
      projections and filters, and enable data locality optimizations
    * This was used to implement the CSV, Avro, Parquet, and JDBC data sources
10. Users can register they're own types by providing a mapping to Catalyst's
    built-in types, as well as UDFs that operate on their own types

### Advanced Analytics Features

1. They made a schema inference algorithm for JSON
    * In practice it works over Twitter's firehose, and multiple other sources
2. Spark's machine learning library is incorporating Spark SQL
3. They support "federated queries" from disparate data sources

### Evaluation (performance)

1. Spark SQL is faster than Shark and the native Spark API
    * For Python, the speedup over the native API is particularly pronounced,
      but there is even a speedup over hand-written Scala code
2. Applications combining Spark SQL with RDDs are faster than running separate
   parallel jobs
3. Spark SQL is about the same speed as (C++ & LLVM-based) Impala -- some
   queries are faster, others slower

### Research Applications

1. Researchers have extended Catalyst for use in their own big data projects to
   speed up computation times for their specialized needs with small amounts of
   code

### Related Work

1. Shark is an earlier, more primitive version of the same thing
2. DryadLINQ compiles queries written in a C# API into a distributed DAG
   execution engine, but doesn't have such a nice interface or support for
   iterative algorithms
3. Hive, Pig and verious lesser-known frameworks are relational query languages
   with UDF interfaces, but don't integrate with Spark to allow mixing
   procedural with relational code
4. Previous extensible optimizer frameworks require the use of a DSL to write
   rules in, and an "optimizer compiler" to make the DSL code executable

### Conclusion

1. Spark SQL is open source at [`http://spark.apache.org`]()


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

### Implementation

#### How Kafka uses Zookeeper

##### For Creating a High-Level Consumer

See the doc-string at the top of `ZookeeperConsumerConnector.scala`. However I
will summarize.

* A new consumer within a group assigns itself the group-unique `id` defined in
  its configuration, and registers this `id` as an "ephemeral znode" in
  Zookeeper.
* IIRC, this means that if this node were to become disconnected from
  Zookeeper, that znode would _disappear_, and notify anyone listening for that
  event.
* The "value" of the znode (a.k.a. the contents of the _"small"_ file at the
  hierarchical name identified by the znode) is a list of the topics this
  consumer "owns" within this consumer-group
* The consumer asks Zookeeper which brokers own the respective partititons it
  wants to get (subject to a consumption load-balancing effort being done by
  Kafka), and subscribes to changes in these brokers' partition-ownerships
* The assignment of Consumer to Partition is _also_ saved in Zookeeper
* There is also a map in Zookeeper tracking offsets in brokers' partitions for
  each topic for each group id

