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
