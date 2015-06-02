## "The Art of Capacity Planning: Scaling Web Resources"

### The key components
1. CPU
2. RAM
3. disk utilization
4. I/O wait
    * network
    * disk

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
    * When will I run out of disk space?
    * For this we want to track storage _consumption_ over time
* I'm 30% through.
