## "The Art of Capacity Planning: Scaling Web Resources"

### Linux Commands
1. `iostat`

### The key components
1. CPU
2. RAM
3. disk utilization
4. I/O wait
    * network
    * disk

#### Useful Disk Metrics
1. How much you're reading
2. How much you're writing
3. How long your CPU is waiting on reading or writing to finish
4. track (rate of) storage _consumption_ over time

##### Derived
1. Plot 1 & 2 vs 3 to see whether IO speed is a bottleneck

#### Useful Database Metrics
1. Queries per second
    * Broken down by SELECT, INSERT, UPDATE, and DELETE
2. Connections currently open
3. Lag time between master and slave during replication
4. Cache hit rates

##### Derived
1. E.g: plot disk-io-util & disk-io-wait vs replication lag time to determine
   which is the cause of major lag spikes

#### Useful Cache Metrics
1. Cache hit ratio
2. Total request size
3. Average object size
4. LRU reference age (if you use LRU)

### The Book
* If you don't have a way to measure your current capacity, you can't conduct
  capacity planning --- you'll only be guessing
* When will each part of your infrastructure fail? Find capacity ceilings.
* Taking into account the specific hardware configuration, how many queries per
  second (QPS) can the database server manage?
* How many QPC can it serve before performance degradation affects end user
  experience?
* Then you can set thresholds for alerts accordingly.
* And figure out what to expect when adding/removing similar database servers
  to the backend
* The point is to be able to justify expensive hardware and software requests
    * It's best to be able to tie that into specific business metrics
        * For example knowing *what* types of requests are causing the most
          load
            * So that you can say, "if we bought these resources, we could
              handle this many more of this type of request, which is popular
              among our users and an important part of our business
              blahdeblah."
* Get a good picture of *the key components* above
* During peak loads, **which one is the bottleneck?**
* It's like how you always have a fuel guage of your car in plain sight
* Are the numbers here due to web server or database usage?
    * Most likely server uses CPU, database other two
* How does an increase in database queries-per-second affect each?
* How about web server requests per second
* Performance tuning optimizes your existing system for better performance;
  Capacity planning determines what your system needs and when it needs it,
  using your current performance as a baseline.
* The best predictions for capacity planning come from *empirical* observations
  of the site's usage, not benchmarks from artificial environments
* It would be good to know database queries per second
* How much CPU, cache, bus bandwidth, and so on does each component of the
  system need?
* If everything ends up being disk-bound, don't buy amazing CPUs!
* __Once you plot load vs throughput, use it to find the performance ceilings
  for each of the key components above__
* It is a great idea to collect application-level metrics
    * E.g. 'photos uploaded' (daily, cumulative, per hour)
    * This will help you uncover the monetary value of the health of your
      server capacity as it relates to *the key components* above
* Storage is like a glass of water
    * It has a finite limit (the size of the glass)
    * And a variable (the amount of water inside it at any moment)
        * And this rate of change in this variable is capped
* For storage consumption, the central question is
    * __When will I run out of disk space?__
    * The stats listed above help you to answer this question
* Capacity planning for CPU on servers (unlike storage) is *peak driven*
    * The capacity trajectory is driven by the periodic peaks you will discover
    * When you find the peaks, drill down into what's actually going on during
      those cycles
* If you identify that CPU is the key component which is the bottleneck for
  your system, increase the load on it with real traffic by altering the load
  balancer, to determine whether CPU is still the bottleneck, meaning that the
  system will scale well with more clients, and that you are truly CPU bound
* Running fake requests (even replays) in practice isn't a great way to test
  the capacity of your system. Messing with your load balancer is a good way.
* Database capacity ceilings are hard to predict because there are hidden
  cliffs revealed only in certain edge cases
* Database performance often depends more on your schemas and queries than on
  the speed of your hardware
* Figure out when you're expected to run out of hardware resources *relative to
  traffic*
    * Determine whether your database speeds are bound by CPU, network, or disk
      I/O
* When doing capacity planning, don't get bogged down in figuring out what
  specifically caused the spike
    * The goal is to be able to _handle_ spikes that are inevitably produced by
      everyone else
    * Find cause the _after_ your capacity plan is in-hand
* Measuring and recording your cache's hit ratio is "imperative" to
  understanding how efficient it is
* The *working set of cacheable files* is the number of unique objects
  requested over a given time period
* Servers doing multiple tasks are harder to figure out
    * Maybe you can hold other tasks' resource-usage constant to isolate
      the last
* Predictions require two essential bits of information, your ceilings and
  your historical data
* Don't fit a curve using a higher-than-2nd-order polynomial, that would be
  based on bizarre assumptions that you don't have a basis to make
