latex input:        mmd-article-header
Title:              Notes on Cloud Computing
Author:             Ethan C. Petuchowski
Base Header Level:  1
latex mode:         memoir
Keywords:           Modern Technology, Cloud, Buzzwords
CSS:                http://fletcherpenney.net/css/document.css
xhtml header:       <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:          2015 Ethan C. Petuchowski
latex input:        mmd-natbib-plain
latex input:        mmd-article-begin-doc
latex footer:       mmd-memoir-footer

## Platform as a Service
#### September 23, 2015

From [Wikipedia](http://www.wikiwand.com/en/Platform_as_a_service)

* Allows customers to develop, run, and manage Web applications without the
  complexity of building and maintaining the infrastructure
* It can either be
	* A 'public cloud' service on the provider's hardware
	* Software installed in private data centers
* For example, it might provide an application API containing some Node
  functionality, a NoSQL object store and message queue services
* The original term was "Framework as a Service" (2006)
* Google launched App Engine in 2008
* PaaS simplifies code-writing, hosting, and deploying for developers, and
  handles the infrastructure and operations side of things, such as networking,
  security, scalability, persistence, instrumentation, and monitoring
	* This lets the developer focus on business value
* One may typically pay for storage used, network traffic, and CPU usage
* The main downside is some amount of vendor lock-in
* PaaS Sits between SaaS and IaaS
	* SaaS is software hosted in the cloud
	* IaaS is virtualized hardware
* Some PaaS vendors (2015) are Apprenda, Microsoft (Azure), Red Hat, Pivotal,
  Oracle, Salesforce, and Cloud Foundry

# Distributed Systems

Some notes from *"From P2P and Grids to Services on the Web: Evolving
Distributed Communities"*, Taylor & Harrison, 2nd Ed. Springer: Computer
Communications and Networks, 2009.

These notes don't necessarily belong here, I just don't really have a better
place to put them right now.

## What is a "Service"

> A service is a software entity that can be used to represent *resources*, and
therefore capabilities, on a network. Services receive a reqest, and
(optionally) return a response; similar to a function call. --- Taylor &
Harrison, pg. 8

### Web service

Some from [Wikipedia: *Web service*][wws] and other Wikipedia pages

1. **a method of communication between two electronic devices**
over a network.
2. It is **a software function provided at a network address** over the Web
   with the service always on as in the concept of *utility computing*.
    * **Utility computing** --- the packaging of computing resources, such as
      computation, storage and services, as a metered service
3. The W3C defines a Web service generally as: *a software system designed to
   support **interoperable** machine-to-machine interaction over a network.*
    * **Interoperability**
        * **Syntactic interoperability** --- when two or more systems are
          capable of communicating and *exchanging data*. Relies on specified
          data formats & communication protocols such as XML or SQL.
        * **Semantic interoperability** --- the ability to automatically
          *interpret* the information exchanged meaningfully and accurately.
          The content of the information exchange requests are unambiguously
          defined.
4. **REST-compliant Web services** --- manipulate XML representations of Web
   resources using a uniform set of stateless operations
5. **Web Services Description Language** (**WSDL**: "wiz'-dul") --- an XML-
   based interface definition language that is used for describing the
   functionality offered by a web service.
    * Filename extension `.wsdl`
    * Provides a machine-readable description of how the service can be called,
      what parameters it expects, and what data structures it returns,
      basically like method signatures.

[wws]: http://en.wikipedia.org/wiki/Web_service

### Service Oriented Architecture (SOA)

* A collection of loosely-coupled services on a network that communicate with
  each other over well-defined interfaces.
* Capabilities are dynamically discoverable
* It is possible to quickly assemble impromptu computing communities without
  human intervention
* An SOA does *not* require using Web Services and obviously vice-versa too

## Distributed Objects

* E.g. in CORBA (Java, Python, C++, etc.), you instantiate an object which gets
  serialized with its entire class hierarchy and you receive a handle to it (a
  URI). You don't know where it actually exists on the network.
* *Mobile agents* are little bundles of code that can travel to different hosts
  and execute or even replicate themselves. E.g. a MapReduce program, in which
  the algorithm travels *to* the data and returns the results to the invoker.

## Grid Computing

* The term is from an analogy with the electrical power grid: users can tap
  into resources off the internet like plugging into a power outlet
* At this time there is no one Grid, but many different types that are possibly
  evolving, private, public, regional, global, specific in goal, generic in
  goals, etc.
* Condor is one example: you send the code you want to run to a resource
  manager, who dynamically locates available processing and storage resources
  and submits jobs to them and retrieves results which are returned to you

## P2P Application Architectures

### Gnutella

1. No single entity can be isolated to bring down the entire network
2. The information providers are not indexed in a central place
3. **Servent** (peer) = **serv**er + cli**ent**
4. Each servent only sees the (roughly 4) other servents it is directly
   connected to
5. **To search for a file**, a peer asks its neighbors, which is forwarded to
   further neighbors until something is found
    1. Done naively, this will congest the network without leaving room for
       file transfer
6. Requests that have already been seen are because of loops in the semi-random
   overlay topology and are dropped (by remembering request IDs)
7. TTL ("Gnutella horizon") for requests is 7 hops (up to 10,000 reachable
   nodes)
8. **To join the network and discover peers**
    1. **Out-of-band methods** --- ask on IRC, check a handful of Web pages,
       try ones that have worked before
    2. **GnuCache** --- a permanent server users can connect to to find peers
    3. **Internal Peer Discovery** --- once a single peer is known, you can
       send it a *ping* which it forwards to its neighbors, and so on until
       some peers send you a *pong* which means they can become your new direct
       neighbors

#### Gnutella Protocol

1. Comprises of a set of descriptors (packets) and rules of exchange

##### Descriptors for finding a file

1. __Header__ --- descriptor ID (16-bytes), payload type, TTL, hops, payload
   length
2. __Payload__ --- one of the following types
    1. __Ping__ (announce) --- empty
    2. __Pong__ (reply to Ping) --- port, IP Addr, # files shared, # KB shared
    3. __Query__ (search the network) --- minimum speed, search criteria (a
       null-terminated string)
    4. __QueryHit__ (reply to search) --- # of hits, port, IP Addr, speed,
       result set (variable length), servent ID
        1. __Result set entry__ --- file index (file ID), file size, file name
    5. __Push__ (traverse firewalls) --- servent ID, file index, IP Addr, port

##### Downloading a file

Requesting servent issues an `HTTP GET` request

    GET /get/<fileIndex>/<fileName> HTTP/1.0]\\r\\n
    Connection: Keep-Alive\\r\\n
    Range: bytes=0-\\r\\n
    User-Agent: Gnutella \\r\\n
    \\r\\n

Receiving servent replies `HTTP OK`

    HTTP 200 OK\\r\\n
    Server: Gnutella\\r\\n
    Content-type: application/binary\\r\\n
    Content-length: 567890\\r\\n
    \\r\\n

Then the file is sent.

### Super peers

1. Edge peers connect to a super peer who acts as a little directory, and super
   peers connect to each other and can query each other. This makes the system
   more scalable, because 1/4th of Gnutella's bandwidth is consumed by
   *searches*, because everyone only knows the files that *they* themself owns
   (bad English). So they generally have to forward requests to all their
   friends.
2. In the whole de/centralization feud, this is a compromise: very fault
   tolerant, but requires less effort to locate a resource
3. This is similar to how (empirically) social networks are organized, with
   *bridge* people being the central connector of *lots* of normal-folk
4. This organization is (was?) used by KaZaA and Morpheus with great success

### Distributed Hash Tables / "Structured" P2P Architecture

1. Map peers and resources to a hash key space
    * E.g. \\(node.id := sha1(IpAddress)\\)
2. **(The goal:)** The peer owning a resource corresponding to a particular
   hash key can be located deterministically by the algorithm
3. Peers maintain state about their neighbors
    * *Who* their "neighbors" are differs by DHT algorithm
4. Now nodes can be organized into a network overlay topology (e.g. a tree) for
   allowing (e.g.) \\(O(\log n)\\) search algorithms to be used, drastically
   improving scalability
5. Downsides:
    1. The *exact name* of a key must be known by the requester (which can be
       fixed at application level)
    2. It's harder to handle joining/leaving peers (than say the Napster model
       with a central server)
7. They use **consistent hashing** for **keyspace partitioning** so that only
   one's neighbors' assigned keyspaces are affected when someone joins/leaves
    * So that *any* incoming request can be forwarded *towards* the host node
8. A node chooses neighbors according to the DHT's connectivity policy, but for
   all keyspace regions it is not responsible for, it should be connected to a
   peer who is *closer* (fewer hops) to a node responsible for those keys
9. Higher connectivity means fewer hops but greater maintenance overhead of who
   is pointing to whom

#### Chord
* Created in 2001 by Ion Stoica, *Robert Morris*, David Karger, Frans Kaashoek,
  and Hari Balakrishnan, at MIT
* **Chord ring** --- circlular overlay network
    * Each node points to its *successor* and *predecessor*
    * This (without the finger table below) is enough for overall correctness,
      but only allows lookup cost \\(O(n)\\)
* Nodes are assigned an ID by taking the first *m* bits of `sha1(IpAddress)`
    * This gives our overlay network \\(2^m\\) slots
* Each node has a **finger table** with *m* entries
    * Makes lookup cost \\(O(\log n)\\) because each query forwarding gets us
      at least halfway toward the target node
    * \\(node.fingerTable[i] := succNodeForKey(n + 2^{i-1})\\)
* **Key assignment** --- each node stores data for keys \\(\{x : succ(node).id
  < x ≤ node.id \}\\)
* To make sure pointers stay up to date with all the "Peer churn" (coming &
  going) each node periodically runs a **stabilization protocol** to update
  both circle and finger pointers
* Can be made more robust if each node maintains a list of the next (say)
  log(*n*) nodes as a list of successors, so that if the true successor leaves,
  an alternative is already known and the network doesn't lose reachability
  when a node leaves

##### References
1. [Slideshare 1](http://www.slideshare.net/GertThijs/chord-presentation)
2. [Slideshare 2](http://www.slideshare.net/did2/introduction-to-dht-with-chord?related=1)
3. [Wikipedia](http://en.wikipedia.org/wiki/Chord_(peer-to-peer))
