latex input:        mmd-article-header
Title:              Zookeeper Notes
Author:             Ethan C. Petuchowski
Base Header Level:  1
latex mode:         memoir
Keywords:           distributed computing, apache, distributed coordination
CSS:                http://fletcherpenney.net/css/document.css
xhtml header:       <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
Copyright:          2016 Ethan Petuchowski
latex input:        mmd-natbib-plain
latex input:        mmd-article-begin-doc
latex footer:       mmd-memoir-footer

## What is it good for?

* Determining which servers
    * are alive
    * are currently running your program
    * have (e.g. compute) resources available to process a query
* It is reliable in the face of distributed computing
    * network failures -- packets lost
    * bandwidth limitations -- packets too slow
    * variable latency connections -- some packets slow
    * security concerns -- packets being eaten by third-party
    * inter-data-center connections -- packets have a long way to go
* It aims to be a
    * fast
        * Low latency of responses to API requests
    * highly available
        * (not sure) Still able to answer queries in the presence of failures
    * fault tolerant
        * (not sure) Able to recover after crashes without corrupting anything
    * __distributed coordination service__
* It allows you to build _reliable, distributed data structures_ for 
    * group membership
        * Which servers are on my team right now?
    * leader election
        * Which server on my team is in charge right now?
    * coordinated workflow
        * Who has done which tasks so far?
    * configuration services
        * _I think_ what this is for, is that some configuration must be
          dynamically changed, so we need a highly-available place where can a
          server in the group get _and modify_ the latest config info
    * generalized distributed data structures like 
        * locks
            * Only allow one server to access a shared resource at a time
        * queues
            * I'm guessing this is a mechanism to allow only one server to
              produce and consume each item, but have the queue as a whole
              never fail or get messed up, even if individual producers and
              consumers fail
            * There's not enough info in the word "queues" to really know what
              is possible here
        * barriers
            * I think this is when you say, "Once enough servers say they are
              ready to move to step two, we tell them all it's OK to proceed"
        * latches
            * I think this is similar to a barrier

### Caveats

> "ZooKeeper cannot help with network problems or partial failures...[but]
> ZooKeeper provides certain guarantees regarding data consistency and
> atomicity that can aid you when building systems" -- Leberknight

### Projects using it include
* HBase
* Hadoop 2.0
* Neo4J
* Apache Kafka


## Zookeeper's provided abstractions

* The abstraction it provides is a __distributed, hierarchical file system__
* It provides its "loosely coupled" clients an __eventually consistent
  view of its "znodes" (files & directories)__
    * I think loosely coupled here means: they are associated in-that they are connected to the same Zookeeper "ensemble", but clients can individually decide how to handle each other's failures
* Clients can "watch" (subscribe to notifications) for changes to specific
  znodes
    * E.g. new child added

## Architecture

* __Ensemble__ -- a group of servers collectively running a distributed
  instance of the Zookeeper software
* _One_ server is the _elected_ __leader__, _all_ others are __followers__
    * When the leader fails, a (_single_) follower will be elected
* _Every_ member of an ensemble holds the entire file system in-memory and on-
  disk
* _Any_ member is allowed to just use its own copy of the file system to
  service client __read__ requests
* _Only_ the leader is allowed to service client __write__ requests
    * It then "broadcasts" changes to its followers
        * I think this is where the "Zab reliable broadcast protocol" comes in
          or whatever that thing is that the research paper is about
* Once a "quorum" (majority, \\(\lceil \frac{n}{2} \rceil\\)) of followers
  "successfully commit" (??) the change, the write has "succeeded" and the
  write will now survive the leader's failure
* This makes Zookeeper only __"eventually consistent"__, because it allows
  followers to respond to clients with data that is already out-of-date
  according to the leader
* When a client boots up, it is configured with a list of servers in the
  ensemble (could be just one of them), and tries one at a time at random until
  it is able to establish a connection on its protocol built on TCP
* A new client connection causes Zookeeper to create a "session" with a client-
  specified timeout
    * The client maintains this session by sending periodic heartbeats to its
      server
        * If the server stops responding, the client starts trying other
          servers in the ensemble
        * In this case the client session can be retained
        * But even still, individual ongoing operations within the session
          may fail
            * This will generally yield errors or exceptions through the
              Zookeeper client API

## References

* ["Distributed Coordination With ZooKeeper Part 1: Introduction"ssdsdfsf][nofluff1]

[nofluff1]: https://nofluffjuststuff.com/blog/scott_leberknight/2013/06/distributed_coordination_with_zookeeper_part_1_introduction
