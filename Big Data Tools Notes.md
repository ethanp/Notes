## Parquet

1. *"Parquetry"* is a geometric mosaic of wood pieces used for decorative effect.
2. The goal is to compress data for use with processing tools like Spark and Hadoop, so that it takes less time to scan the data from disk
3. It interoperates with "object models" like Avro, Thrift, ProtoBuff, Pig, Hive SerDe, and Impala (what's that?) via specific "converters"
4. The striping and encoding is model-agnostic
5. The files are stored in the language-agnostic, formally specified, Parquet file format
6. Instead of storing (a,b,c) tuples as [(a1,b1,c1),(a2,b2,c2),...], Parquet stores them as [Encoded(chunk of a's),...,Encoded(chunk of c's)].
    * This (compressed) columnar storage at work
    * This helps us only read the data we need
7. Parquet's "nested representation" is "borrowed from the Google Dremel paper" ([tutorial][twdrm]).
    * Each cell is encoded as a triplet: repetition level, definition level, value, enabling small footprint, and fast de/serialization
8. Their code is implemented to optimize for the processor pipeline
    * Replacing common constructs with unrolled loops, bitwise operations etc. to minimize CPU cache misses
9. They use the right encodings in the right situations
    * **Delta encoding** -- avoids branching, store differences between items instead of their values (eg. for timestamps, ids, metrics)
    * **Prefix coding** -- delta encoding for strings
    * **Dictionary encoding** -- replace values with dictionary mapping shorter values to real values
        * Useful when there are < 50K distinct values
        * Faster and more compression than eg. gzip, lzo, snappy
    * **Run length encoding** -- good for repetitive data
    * *User-defined encoding* -- supported
10. For each chunk, they find the total number of values contained, and use the minimum number of bits to hold them, pack decompression info in the chunk header, and cram all the bits into the payload.
11. For Twitter it helps them handle 100TB+/day of compressed data (whoa) for use with multiple 1K+ node Hadoop clusters (whoa)
    * Using Parquet saves them terabytes in "data scanning" per day
12. It's among the best at compressing, and by far the fastest for querying (according to the creators' benchmarks)
13. What is stored is a block containing a "row group" (50MB to 1GB), inside which there are chunks of individual columns, inside which there are "pages" of the column chunks (8KB to 1MB), inside which there is a header containing metadata, and the values
14. Stores metadata statistics relevant for query planners and predicate pushdown
15. Main contributors are from Twitter, Cloudera, Criteo, Stripe, UC-Berkeley, and LinkedIn

[twdrm]: https://blog.twitter.com/2013/dremel-made-simple-with-parquet

## Spark

### Overall
* Gracefully degrades wrt how much of working set fits in cache
* **Shuffle** --- triggered by certain Spark operations (e.g. `reduceByKey`)
    * Re-distributes data across partitions
    * involves copying data across executors and machines
* Don’t spill to disk unless the functions that computed your datasets
  are expensive, or they filter a large amount of the data
    * Otherwise, recomputing a partition may be as fast as reading it from disk
* Spark automatically monitors cache usage on each node and drops out old data
  partitions in a least-recently-used (LRU) fashion

#### Testing

From the [programming guide](http://spark.apache.org/docs/latest/programming-guide.html)

Spark is friendly to unit testing with any popular unit test framework. Simply
create a `SparkContext` in your test with the master URL set to `"local"`, run your
operations, and then call `SparkContext.stop()` to tear it down. Make sure you
stop the context within a `finally` block or the test framework’s `tearDown` method,
as Spark does *not* support two contexts running concurrently in the same program.

### Examples

To start the terminal in Scala it's

    ./bin/spark-shell

For python, it'd be

    ./bin/pyspark

He recommends Continuum's python package mgmt capabilities

#### WordCount

`sc` is the "spark context" given for free in the spark REPL

    val f = sc.textFile("README.md")
    val wc = f.flatmap(_ split " ").map( (_, 1) ).reduceByKey(_ + _) //_

    // nothing has 'happened' yet because we haven't taken an "action"!
    // we've just defined an RDD with the "transforms" we will want

    wc.saveAsTextFile("wc_out.txt")

### API

* `reduceByKey` performs better than `groupByKey` because it attemps
  to apply the reduce function *locally* before the shuffle/reduce phase.
  `groupByKey` will force a shuffle of all elements *before* grouping.

### Debugging

On any RDD you can call `.toDebugString` and it will show you a nice graph of
what's contained in the RDD.

### History
* MapReduce
    * invented in 2002, and SSDs didn't count as "commodity hardware".
    * hard to "think in terms of", and only works well for large batches
* So for Spark, want to leverage the memory, and generalize possible
  computational graphs and do lazy evaluation on it
* Spark has less than 50% as much code as Hadoop (60- vs 120k)

### How it works

The **Master**

1. Connects to a *cluster manager* which allocates resources across
   applications
2. Acquires **executors** on cluster nodes --- worker processes to run
   computations and store data
3. Sends *app code* to the executors
4. Sends *tasks* for the executors to run

**RDD** --- Resilient Distributed Dataset

* Primary abstraction of fault-tolerant collections that can be operated
  on in parallel
* Two types of RDD
    * Parallelized Scala collections
    * Hadoop datasets --- functions on each record of a file in HDFS
        * Could also be S3, Cassandra, MySQL (through JDBC), local file, etc.
* Two types of operations (API listing here is *incomplete*)
    * Transformations --- lazy
        * map, filter, flapMap, sample(withReplc, fraction, seed),
          union(otherDataset), distinct
        * groupByKey, reduceByKey, sortByKey, join, cogroup/groupWith,
          cartesian
        * To evaluate immediately, use the action `collect()`
    * Actions --- eager
        * reduce, collect, count, first, take(n), takeSample(w,f,s)
        * saveAsTextFile, saveAsSequenceFile, countByKey, foreach(func)
* Accumulators --- variables upon which only *associative* operators may
  be applied (e.g. counters)
* Broadcast --- send an immutable datastructure to all nodes (I think)
* Persistence --- you can choose what Spark does when an object doesn't
  fit in memory
    * By default, the parts that don't fit will be recomputed each time
      they're needed
    * But you may want that instead you store parts that don't fit *on disk*

### Main Classes

#### SparkConf
* Configuration for a Spark application
* Used to set various Spark parameters as key-value pairs
* Calling the constructor also loads values from any `spark.*` Java
  system properties
* Parameters set directly on the object take priority over system properties
* Spark configuration can never be modified once it is past to Spark itself

##### What you might want to set
1. `setAppName(name: String)`
2. `setMaster` --- Set url of `Master`
    * Number of cores to use (e.g. "local[4]" for 4 cores)

#### SparkContext
* Main entry point for Spark functionality
* Represents the connection to a Spark cluster
* Used to create RDDs, accumulators, and broadcast variables on that cluster
* Only one can be active per JVM
    * You must `stop()` the active `SparkContext` before creating a new one

Creating one

    val conf = new SparkConf().setAppName("Simple Application").setMaster("local")
    val sc = new SparkContext(conf)

##### Useful looking methods

1. `addFile(path: String, recursive: Boolean)` --- add a file to be downloaded
   with this Spark job on every node
2. `cancelAllJobs()` --- cancel all jobs that have been scheduled or are running
3. `hadoopFile` --- get an RDD for a hadoop file
4. `makeRDD` --- distribute a local Scala collection to form an RDD
    * It looks like `parallelize` does the *exact same thing* (?)
5. `runJob` --- run a job on all partitions in an RDD
    * Pass results to handler function
    * Return the results in an array
6. `stop()` --- shut down the `SparkContext`
7. `submitJob` --- submit a job for execution, return `FutureJob` holding result
8. `textFile(path: String)` --- return a textfile as an RDD of `String`s
    * The `path` may correspond toa directory, compressed file, or
      wildcard (`"dir/*.txt"`)
9. `union(rdds)` --- build the union of a list of rdds
10. `wholeTextFiles(path): RDD[(String, String)]` --- read a *directory*
   of text files, returning each one as a `(name, content)` pair, instead of
   a record-per-line of each file.

### Side Notes

* There's this thing called Tachyon which is a distributed file-system
  like HDFS, but it lives *in memory*
    * You can use this to share RDDs between applications
* Also Ooyala has an open source REST end-point called "Spark Job Server"
  which manages sharing RDDs used by multiple services

### spark.sql.DataFrame

7/10/15

1. First announced 2/17/15
2. API inspired by R and Python's "Pandas"
3. Scales to petabytes on a large cluster
4. State-of-the-art optimization and code generation
5. A `DataFrame` is a distributed collection of data organized into named columns, conceptually equivalent to a table in a relational database.
