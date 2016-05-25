latex input:        mmd-article-header
Title:              Messaging Notes
Author:             Ethan C. Petuchowski
Base Header Level:  1
latex mode:         memoir
Keywords:           distributed computing, messaging
CSS:                http://fletcherpenney.net/css/document.css
xhtml header:       <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
Copyright:          2016 Ethan Petuchowski
latex input:        mmd-natbib-plain
latex input:        mmd-article-begin-doc
latex footer:       mmd-memoir-footer

## AMQP 

* AMQP is a binary, application layer protocol, designed to efficiently support
  a wide variety of messaging applications and communication patterns
* It provides flow controlled, message-oriented communication with various
  optional message- delivery guarantees
* It assumes an underlying reliable transport layer protocol such as TCP
* AMQP was originated in 2003 by John O'Hara at JPMorgan Chase in London, UK
* The working group grew to 23 companies by 2011
* Transfers are subject to a credit based flow control scheme, managed using
  "flow" frames. This allows a process to protect itself from being overwhelmed
  by too large a volume of messages
* Each transferred message must eventually be settled. Settlement ensures that
  the sender and receiver agree on the state of the transfer, providing
  reliability guarantees
* Changes in state and settlement for a transfer (or set of transfers) are
  communicated between the peers using the disposition frame
* The various standard reliability guarantees e.g. "at X once" can be enforced
  this way
* A session is a bidirectional, sequential conversation between two peers that
  is initiated with a begin frame and terminated with an end frame
* A connection between two peers can have multiple sessions multiplexed over
  it, each logically independent
* Connections are initiated with an open frame in which the sending peer's
  capabilities are expressed, and terminated with a close frame
* Message headers may include time to live, durability, and priority info

### Basic architectural components

* __Publisher/producer__ -- publishes messages to _brokers_
* __Broker__ -- contains an _exchange_ and the _queues_
* __Exchange__ -- decides how to put messages received into _queues_ using _bindings_
* __Binding__ -- a rule about how messages should be added to a queue
* __Queue__ -- a buffer from which consumers consume
* __Consumer__ -- may *either* __pull *or* get pushed__ messages from _queues_

### References

* [Wikipedia: AMQP][wikiqp]
* [Rabbit tutorial][rabbitamqp]

[wikiqp]: https://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol?oldformat=true
[rabbitamqp]: https://www.rabbitmq.com/blog/2014/01/23/preventing-unbounded-buffers-with-rabbitmq/

### RabbitMQ vs Kafka

* Use Rabbit if you have messages (20k+/sec) that need to be routed in complex
  ways to consumers, you want per-message delivery guarantees, you don't care
  about ordered delivery, and/or you need HA at the cluster-node level now
* RabbitMQ is broker-centric, focused around delivery guarantees between
  producers and consumers, with transient preferred over durable messages
* RabbitMQ uses the broker itself to maintain state of what's consumed (via
  message acknowledgements) - it uses Erlang's Mnesia to maintain delivery
  state around the broker cluster
* Unlike Kafka, RabbitMQ presumes that consumers are mostly online, and any
  messages "in wait" (persistent or not) are held opaquely (i.e. no cursor)
*  RabbitMQ pre-2.0 (2010) would even fall over if your consumers were too
   slow, but now it's robust for online and batch consumers - but clearly large
   amounts of persistent messages sitting in the broker was not the main design
   case for AMQP in general
* The AMQP 0.9.1 model says "one producer channel, one exchange, one queue, one
  consumer channel" is required for in-order delivery
* The whole job of Kafka is to provide the "shock absorber" between the flood
  of events and those who want to consume them in their own way
* Kafka currently blows away RabbitMQ in terms of performance on synthetic
  benchmarks
* Kafka is an early Apache incubator project
* It doesn't necessarily have all the hard-learned aspects in RabbitMQ
* The AMQP standard is 'a mess'
* RabbitMQ offers optional durability and persistence (two separate features)
* The persistence uses an optimized logging format that provides the fastest
  possible write throughput (similar to things that Redis and Riak are doing)
* You never have to touch the persistent message store, and in the majority of
  cases, RabbitMQ will never read the persistent store
* It is just there for insurance in the case of server crash or a low memory
  situation

### References

* [Quora: What are the differences between Apache Kafka and RabbitMQ][qramq]

[qramq]: https://www.quora.com/What-are-the-differences-between-Apache-Kafka-and-RabbitMQ
