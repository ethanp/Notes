latex input:    mmd-article-header
Title:          Networking and Network Programming Notes
Author:			Ethan C. Petuchowski
Base Header Level:		1
latex mode:     memoir
Keywords:       REST protocol, protocols, sockets, TCP/IP
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:      2015 Ethan C. Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer

## Protocol Buffers

**Protocol buffers provide a syntax for defining datatypes that are able to be
_serialized_, either for network transfer or storage.**

* Definitions are written in the _interface description language_ (e.g.
  `message_type.proto`), and source code for generating and parsing byte-
  streams for those objects is generated for your language by the protobuf free
  and open source compiler.
* Design emphasis was on being simpler to use and more performant than XML.
* It is used at Google to implement an RPC system.
* Unlike Apache Thrift (used by Facebook), the implementation does not include
  or rely upon any particular RPC protocol stack.
* The binary wire format is compact, forward and backward compatible, but not
  self-describing except in a special ASCII-format debug mode
    * i.e. we normally separately need the schema to understand what the data's
      fields are/mean).
* Each protobuf _message_ (type) can have _required_, _optional_, and
  _repeated_ (ordered dynamic array) fields.
    * Some Google engineers don't use `required` because if they then stop
      using that field, it must still be included in every serialized object
      stream, which is inefficient
* In addition to _messages_ we can define _enum_ types
* We can also define a _service_ which is a set of named mappings between
  _request_ messages and _response_ messages
    * In Java, this will produce an `interface` with the given abstract methods
* Each field is associated with a unique _tag_ (integer field- number), which
  doesn't change between releases to provide compatibility.
* Protobufs can contain _nested messages_ of different (or perhaps the same)
  type
* "You should never add behaviour to the generated classes by inheriting from
  them. This will break internal mechanisms and is not good object- oriented
  practice anyway." -- Google.com
* A key feature is that you can use (e.g. Java) _reflection_ to iterate of a
  message's fields and manipulate its values without knowing the specific
  message type. E.g. by calling `Message#getAllFields(void)`

## Network Principles

### The End-to-End Principle

#### From Wikipedia

* Classic __design principle__ in computer networking
* First articulated in a __1981__ paper by Saltzer, Reed, and Clark.

> * In a general-purpose network, __application-specific functions ought to
>  reside in the end hosts__ of a network rather than in intermediary nodes
>     * Provided end hosts can implement them "completely and correctly".

* Payoffs from adding functions to a simple network quickly diminish,
  especially when end hosts have to re-implement those functions themselves
  anyway.
* The *canonical* case is TCP/IP
    * IP *only* provides *unreliable* data[gram] transfer
        * because many clients don't need reliability.
    * TCP is a layer *on top* of IP, that requires no special-purpose IP code
      to be implemented
        * It provides connection-oriented, _reliable_ transmission.

#### From [Quora Question][e2e-lay]

* According to Google employee *Soheil Hassas Yeganeh*
* If a network function can be implemented correctly and completely using the
  functionalities available on the end-hosts, that function should be
  implemented on the end-hosts without delegating any task to the network (ie,
  intermediary nodes in between the end-hosts).
* This way the new networking functions can be developed without changing the
  existing network infrastructure. For example, there are many different ways
  to implement something like HTTP but, you should prefer design alternatives
  that use solely the functions available on the both ends to the designs that
  demand new functionalities from routers and switches.
* Intermediary nodes, on the other hands, can intercept such network functions
  for optimization, security, and scalability purposes. For instance,
  firewalls, load balancers, and proxies intercept HTTP flows for security,
  scalability and optimization. Note that those features are auxiliary and
  HTTP does not depend on them.

[e2e-lay]: http://www.quora.com/How-does-one-explain-end-to-end-principle-in-
laymans-terms

### The Internet is an Onion of Networking Layers

* TCP/IP doesn't actually strictly follow that **7-layer OSI Model**
    * Physical, Data Link, Network, Transport, Session, Presentation,
      Application
* It follows a **4-layer abbreviation**
    * **Link, Internet, Transport, Application**
* **"The Internet"** is the world's largest IP-based network
    * No one owns or controls it, it's just a bunch of nodes that know how to
      communicate with each other.

#### TCP/IP Layers

1. **Link** -- (OSI 1,2) -- connects hardware to higher-layer abstractions
    * **Ethernet**
    * **Wifi**
    * __ARP__ (Address Resolution Protocol) -- resolves network layer
      addresses (e.g. IPv4 address) into link layer addresses (i.e. MAC
      address)
        * __NDP__ (Neighbor Discovery Protocol) does this for IPv6
2. **Internet** -- (OSI 3) -- congestion control and routing global unique IP
   addresses and IP packets
    * **IP** (Internet Protocol) -- addresses hosts and routes packets across
      1+ IP networks
3. **Transport** -- (OSI 4) -- error control, segmentation, congestion
   control, application addresssing
    * **TCP** (Transmission Control Protocol) -- creates *reliable* connection
      between 2 computers
    * **UDP** (User Datagram Protocol) -- *broadcasts* messages over a network
    * **ICMP** (Internet Control Message Protocol) -- provides error messages
        * Part of the Internet Protocol Suite (aka. TCP/IP)
        * Transport protocol like TCP/UDP but not used for exchanging data
        * Examples
            * "Requested service is not available"
            * "Host or router could not be reached"
            * TTL = 0 => "time to live exceeded in transit"
        * Useful for the following user-level programs
            * Traceroute*
            * *Ping*
4. **Application** -- (OSI 5,6,7) -- protocols used by applications
    * **FTP** -- for transmitting files, (somewhat replaced by HTTP)
    * **SMTP** (Simple Mail Transfer Protocol) -- for sending mail between
      mail servers
    * **HTTP** -- used by the WWW
        * **SOAP** [or old-school XML-RPC]
        * **REST API**
    * **POP3** (Post Office Protocol Version 3) and **IMAP** (Internet Message
      Access Protocol) -- both are for retrieving email from a mail server
    * **DNS** (Domain Name System) -- for translating name to an IP address
      (uses UDP)
        * More about this in its own section below

## Networking Concepts & Vocabulary

* **Address** -- a sequence of bytes uniquely identifying a *node*
    * In IPv4 these are 4 full unsigned bytes (0-255), e.g. 199.1.32.90
        * This allows for 4 billion *total*, not enough to have one per
          person...
        * Asia, Australia, and Europe ran out by 2013
    * In IPv6 these are 16 bytes, e.g.
      `FEDC:BA98:7654:3210:FEDC:BA98:7654:3210`, which allows for 3.4E38
* __Broadcast address__ -- messages sent to `255.255.255.255` are *broadcast*
  to everyone attached to the local network
    * This mechanism is used to find the local DHCP server
    * To do this with IPv6, instead of a broadcast address, use a _multicast_
      address with the _all-hosts_ multicast group
* **DNS** (Domain Name Service) -- translates *hostnames* into IP addresses
* **Firewall** -- hardware or software that inspects, modifies, and/or drops
  specified packet traffic flowing through it
    * Configured with rules about which packets to allow in and out
        * Eg. may look at the IP addresses and/or transport protocols
    * If it implements "stateful inspection", the drop rules may involve
      analyzing the header information from a *sequence* of packets (a la
      FSM), which may e.g. be doing a _port scan_ of your network
    * A **proxy gateway** aka. **bastion host** is a firewall that pretends to
      be the application but it's actually a proxy that is filtering
      improperly formatted commands from getting to the true application
      server
* **Host** -- an endpoint for networked communication
* **Latency** -- request's *round-trip time* (RTT)
* __Local loopback address__ -- `127.0.0.1` -- always points to the local
  computer (*hostname* `localhost`)
    * For IPv6 it's `0:0:...:0:1`, which can be abbreviated to `::1`
    * __TODO__ there should be more here about DNS. E.g. check out the
      associated Eli the Comp Guy video
* **NAT** (Network Address Translation) -- your internal IP address within
  your LAN is different from your external IP address to The Internet, and
  this translation is done/managed by your router
    * In this way, generally, your router is only using up a single "real" IP
      address for connecting all devices in your house to the Internet
* **Node** -- a machine on a network
* **Packet-switched network** -- data is sent in small chunks
    * This scheme (as opposed to a __circuit-switched network__) allows for
        * efficient shared-use of network
        * integrity checks
* **Peer-to-peer** -- an alternative to the *client/server* model, where any
  node can initiate a connection with any other
* **Protocol** -- a precise set of rules defining how computers communicate
* **Proxy server** -- you connect to the outside world through this server
    * It has a different IP address, so that the outside world never learns
      about your real IP address
    * It can do more thorough inspection of packets being sent by and to you
    * It can be used to implement local area caching
* **Tunneling** -- wherein a packet is wrapped inside the payload of another
  packet

## Transport Layer

### TCP (Transmission Control Protocol)
**9/5/14**, **6/19/15**

* This is the **transport layer** of the **TCP/IP suite**
* Intermediary between the application and Internet Protocol (IP)
    * An app simply issues a *single* TCP request with the data it wants to
      transmit, and TCP handles the packet breakup and IP requests etc.
* **IP packets can be lost, duplicated, corrupted, or delivered out of order**
    * **TCP handles all this; specifically, it *guarantees* that all bytes are
      perfectly received in the correct order**
* TCP uses **positive acknowledgement with retransmission** as the basis of
  its algorithm
    * Input data is split into *segments*, and each segment is passed to the
      IP layer wherein it will be put into a packet and actually
      sent/delivered
        * Segment described below
    * Sender keeps a record of each packet it sends
    * Sender maintains a timer from when each packet was sent
        * Sender retransmits if no `ACK` is received before a [configurable,
          but standardized] *timeout* (due to loss, corruption, etc.)
    * Receiver responds with an `ACK` message as it receives the packet
    * The actual algorithm is not in these notes at this time.
* A **TCP Connection** consists of 2 *sockets* (one on each end) (*sockets
  defined below*)
* Relied upon by e.g. WWW, email, file transfer, SSH, etc.
* Use **User Datagram Protocol (UDP)** instead if you don't require reliable
  data transfer and want reduced *latency* (e.g. for multiplayer video games)
* First published in a 1974 IEEE paper by Vint Cerf and Bob Kahn
* **TCP Header** C pseudocode

        struct tcp_header {
            uint16_t src_port,
            uint16_t dest_port,
            uint32_t seq_num,
            uint32_t ack_num,
            uint4_t data_offset, // specifies size of TCP header in 32b words
            uint12_t reserved_and_flags, // control bits for options
            uint16_t window_size,
            uint16_t checksum, // for error-checking header & data
            uint16_t urgent_pointer,
            variable_length options,
            padding zeros // to make sure header ends on 32 bit boundary
        }
    * Side note: if you use `int16_t` from `<stdint.h>`, your compiler will
      have the appropriate e.g. `typedef short int16_t` to make that variable
      actually by 16 bits long. There is no better way to do it.
        - Ref: [StOve](http://stackoverflow.com/questions/9813247)

#### Protocol Operation

The protocol is defined by a *state machine* with *Three Phases*

1. Connection establishment --- multistep handshake
2. Data transfer
3. Connection termination --- closes established virtual circuits and releases
   allocated resources

##### Connection Establishment

1. Client sends `SYN` message to the server and sets the segment's sequence
   number to a random value `A`
    * I guess it is random to protect from "TCP sequence prediction attacks"
2. Server replies with `SYN-ACK` message, acknowledgement number is `A+1`, but
   this packet's number is random value `B`
3. Client sends `ACK` to server, sequence number is `A+1`, ack number is `B+1`
4. Now both are in the `ESTABLISHED` state

##### Connection Termination

Similar to connection establishment, but slightly different.

##### Bandwidth Delay Product (BDP)

This is a figure representing the number of bytes _in flight_. It is

\\[linkCapacity \bullet RTT = \frac{\#bits}{sec}\bullet sec = \#bits\\]

The point is we want to design an effective algorithm for setting this value
in such a way that it maximizes use of the network without leading to
congestion. And that is what TCP is for.

### Sockets

* **Network Socket** --- endpt of interprocess communication across a network
* **Internet Socket** --- unique combination of

        localSocketAddress + remoteSocketAddress + protocol
* **Socket Address** --- `ipAddress + port`
* **Socket descriptor** --- `int` that references the socket within the OS
    * The OS uses this to strip the routing info and forward the data to the
      stream-reader object within the application
* The normal **socket API** is based on the **Berkeley sockets** standard
    * This is the origin of such actions as
        * `socket()` --- construct socket and allocate OS resources to it
          (e.g. slot in descriptor table)
        * `bind()` (server side) --- associate socket with IP addr + port
        * `listen()` (server side) --- TCP socket enters "listening" state
        * `connect()` (client side) --- associate socket to local port number;
          and for TCP, attempt to establish TCP connection
        * `accept()` (server side) --- accept attempt to create a new TCP
          connection, and create a new socket for it
        * `send() recv() write() read()` etc. --- self-explanatory
        * `close()` --- release resources allocated to socket; for TCP close
          connection
        * `gethostbyname() gethostbyaddr()` --- resolve host names and
          addresses
        * `select()` --- wait for one or more provided sockets to be ready to
          read or write or retrieve errors from
        * `poll()` --- test if socket can be read from, written to, or if
          there are errors to retrieve
        * `get`/`setsockopt()` --- get/set socket options

#### Ports

* Ports have a number between 1 and 65,535 (2 bytes)
* Ports up to 1023 are reserved for *well-known services*
* Each connection between a client and server requires its own unique socket.
* You can send a message to a server by sending to it's **IP adress**,
* You append a **port number** to make sure your message gets "demultiplexed"
  to the correct **process** on that server,

### SSL (Secure Sockets Layer) / TLS (Transport Layer Security)

* TCP & UDP do not provide encryption on their own
* **SSL provides an encrypted TCP connection**, yielding improved
    * data __encryption__
    * data __integrity__
    * endpoint __authentication__
        * _Client_ can authenticate _server_, and (optionally) _vice-versa_
    * Without requiring modification of application layer protocols above it
* TLS has beeen adapted to run over UDP, in a protocol called "DTLS"
* TLS provides its own message framing mechanism
    * Which signs each message with a MAC (one-way hash, i.e. checksum)
        * Only the endpoints know the cryptographic hash function
        * This provides _integrity_ and _authenticity_
* A third-party observer can still infer
    * Connection endpoints
    * Type of encryption
    * Data transaction frequency
    * Approximate data throughput
* SSL was Netscape's propriatary protocol
    * TLS 1.0 is the IETF standardization of SSL (RFC 2246, 1999)
    * Then we have TLS 1.1: 2006; then TLS 1.2: 2008
* In addition to encrypting data over the wire (like SSL), TLS authenticates a
  server with a certificate to prevent spoofing.
*  Uses long-term public and secret keys to exchange a short term session key
   to encrypt the data flow between client and server
* This creates a *stateful* connection
* There are numerous known attacks on each version of SSL & TLS
* __Forward secrecy__ -- if an attacker gets a server's private key, they
  still cannot decrypt the current or any previously recorded sessions
    * We must use [Eliptic Curve] _Diffie-Hellman_ (ECDH) instead of _RSA_
      handshake to achieve this

#### In very basic terms
* First an X.509 certificate (asymmetric) authenticates the counterparty
* The two parties negotiate a symmetric key to be used to encrypt data
    * They start by finding a cipher and hash function that both support
    * The client encrypts a random number with the server's public key, and
      sends it
        * From this they negotiate a session key
    * Importantly, this symmetric key cannot be derived from the X.509

#### TLS handshake protocol
1. TCP handshake ("3-way")
    1. SYN
    2. SYN ACK
    3. ACK
2. TLS Handshake (2 extra roundtrips)
    1. ClientHello (bundled with TCP ACK above)
    2. ServerHello, Certificate, ServerHelloDone (optnly request client cert)
    3. ClientKeyExchange, ChangeCipherSpec, Finished
    4. ChangeCipherSpec, Finished
3. Application Data can be sent through "TLS tunnel"

##### Abbreviated Handshake
* If the client has previously communicated with the server, we can reuse
  negotiated parameters, and employ an "abbreviated handshake", which requires
  only _one_ roundtrip
* TLS False Start allows application to be sent before the server acknowledges
  the ChangeCipherSpec, to reduce new handshake latency-overhead to one
  roundtrip
* Ideally, we should use _both_

#### Application Layer Protocol Negotiation (ALPN)
* To easily enable custom application layer protocols without assiging a new
  well-known port to each one, we can
    1. initiate the connection over the HTTPS port 443
    2. Append supported protocols in a `ProtocolNameList` to the `ClientHello`
       message
    3. Server appends selected `ProtocolName` to `ServerHello` message
* This removes need for using the HTTP Upgrade mechanism, which would require
  more round-trips before the final application protocol can actually be used

 #### References
1. High Performance Browser Networking [Chapter 4][ch4]

[ch4]: http://chimera.labs.oreilly.com/books/1230000000545/ch04.html

## Transport Layer

### Simple Authentication and Security Layer (SASL) 

HDFS allows the use of the __Simple Authentication and Security Layer (SASL)__,
"a framework for providing authentication and data security services in
connection-oriented protocols via replaceable mechanisms". It provides a "data
security layer" which in-turn "can provide data integrity, data
confidentiality, and other services". Basically, it seems like what happens is,
while implementing _your_ algorithm, you can call methods provided by SASL to
make use of its security services. Underneath, those methods might use
passwords, Kerberos, certificates, etc.

### TCP (Transmission Control Protocol)

### UDP (User Datagram Protocol)

### SCTP (Stream Control Transmission Protocol)

* Message-oriented like UDP
* Reliable, unicast, full duplex, sessioned, and ordered, with congestion
  control, like TCP
* More performant than TCP and more reliable than UDP
* Originally created for telephony signaling support [*what's that?*]
* Allows multiple-streams to be multiplexed over a connection, each is
  individually ordered, with no global order, which allows mitigation of the
  formiddable *head-of-line blocking* problem
* Supports "multi-homing", meaning a single endpoint is identified by a list
  of IP addresses, so that if one becomes unavailable, another can be tried
* Can be tunneled over UDP
* One can tunnel TCP over SCTP
* Defined and accepted as an IETF standard in 2000
* Looks like the Max OS X 10.11 (El Capitan) kernel does not support SCTP, but
  there is a "Network Kernel Extension" (NKE) available for it on Github.


## Network Layer
### IP (Internet Protocol)

* Exchanges **packets** --- which have a **header** and a **body**
    * **Header** -- source, destination, control info
    * **Payload** -- the *data*
    * **Trailer** -- *checksum* (sometimes inside the header)
        * Only for detecting corruption in header itself, *not* the data
* Packets can get lost, reordered, duplicated, or corrupted

## HTTP

### Status codes

* `100s` --- informational response
* `200s` --- request succeeded
* `300s` --- redirection
* `400s` --- client error
* `500s` --- server error

### Methods

#### Main ones
* `GET` --- retrieve, idempotent, side-effect free
* `POST` --- upload reseource without specifying a any action, not idempotent
* `PUT` --- idempotent, upload representation of resource to server
* `DELETE` --- remove resource from specified URL, idempotent

#### Other ones
* `HEAD` --- only download resource header
    * e.g. to check `mtime` to see if cache is valid
* `OPTIONS` --- ask server what can be done with specified resource
* `TRACE` --- echo back client request

#### Non-standard ones
* `COPY`
* `MOVE`

### Request

This is from *Harold, Elliotte Rusty (2013-10-04). Java Network Programming.
O'Reilly Media. Kindle Edition.* It may contain typos.


    GET /index.html HTTP/1.1
    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv: 20.0)
    Host: en.wikipedia.org
    Connection: keep-alive
    Accept-Language: en-US,en;q=0.5
    Accept-Encoding: gzip, deflate
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8

### Response

This is from Wikipedia's page on HTTP.

    HTTP/1.1 200 OK
    Date: Mon, 23 May 2005 22:38:34 GMT
    Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
    Last-Modified: Wed, 08 Jan 2003 23:11:55 GMT
    ETag: "3f80f-1b6-3e1cb03b"
    Content-Type: text/html; charset=UTF-8
    Content-Length: 131
    Accept-Ranges: bytes
    Connection: close

    <html>
    <head>
      <title>An Example Page</title>
    </head>
    <body>
      Hello World, this is a very simple HTML document.
    </body>
    </html>

### HTTP/0.9

* Name was "back-assigned" from when HTTP/1.0 was released
* e.g.
    ```html

    <!-- request -->
    GET /the-site-i-want \r\n

    <!-- response -->
    <html>
      <head><title>All the htmls!</title></head>
      <body><p> HTTP/0.9 does not have headers and assumes HTML <p></body>
    </html>
    ```
* Opens a new TCP connection per request/response cycle
    * This means we have to wait an extra round-trip for the 3-way TCP
      handshake
* Request: {method}{path}{CLRF}
* Response: {html}{close-TCP-conn}

### HTTP/1.0
* Released in 1996
* Adds `HEAD`, `POST`, and **headers**
* Use `Content-Length` header field to denote size of entity body instead of
  closing the connection
* Request: {method}{path}{"HTTP/1.0"}{CLRF}
* Response: {"HTTP/1.0"}{status code}{status
  English}{CLRF}{headers}{CLRFx2}{body}{close-TCP-conn}

### HTTP/1.1
* Request & Response: same except "HTTP/1.1", and _not_ closing TCP at the end
* Persistent connections
    * TCP connections "persist" by _default_ between requests
    * improves _latency_, but not really _bandwidth_ (except perhaps window
      increasal)
    * Helps when pages feature _linked resources_ (e.g. images)
* Typically, browsers will use multiple connections to download the linked
  resources in parallel
    * Typically up to 8 per domain to reduce thread-usage overhead on the
      server
* __HTTP pipelining__ -- specifies that the next request can be sent before
  the previous request's response has been received
    * Not great because due to being a simple text protocol, the server must
      still send responses in request-order, meaning big responses (e.g.
      images) will get in the way of other responses (e.g. client-side
      javascript)

### HTTP/2
* __Optimizes transport__, while __preserving high-level compatibility with
  HTTP/1.1__
    * Methods, status codes, header fields, URI schemes, port numbers, etc.
      are unchanged
* It's a __binary, multiplexed__ network protocol
    * This means you can't use `telnet` for debugging, but _can_ use `curl`
      which has integrated deserialization for the console
* Sends data in __frame__s, such as `HEADERS`, `DATA`, `SETTINGS`, `GOAWAY`
* Upgrades from HTTP/1.1
    * Use the `Upgrade` header
        ```html
        <!-- request -->
        GET /index.html HTTP/1.1
        Host: server.example.com
        Connection: Upgrade, HTTP2-Settings
        Upgrade: h2c
        HTTP2-Settings: <base64url encoding of HTTP/2 SETTINGS payload>

        <!-- response -->
        HTTP/1.1 101 Switching Protocols
        Connection: Upgrade
        Upgrade: h2c
        {empty line}
        {server sends HTTP/2 frames}
        ```
    * Use __Application-Layer Protocol Negotiation (ALPN)__ (IETF [RFC 7301][alpn-spec],
      July 2014)
        * This means you're using the TLS handshake protocol to ask to run
          HTTP/2 over the [encrypted] TLS connection
        * Java 8 does not support ALPN, but Jetty does and __Java 9 will__
* __Header compression__ -- client and server each maintain a `headers` table
  storing previous headers. These headers don't need to be resent.
    * This cuts a _lot_ of overhead out of transmissions
    * This removes the need to combine all assets into a single giant asset
* __Multiplexing and Streams__
    * Individual req-res exchanges each get a __stream__ id
    * The `HEADERS` frame is what initializes a stream
    * Different streams may be _interleaved_ through the same socket
    * Streams can be assigned a __priority__ in the `HEADERS` frame
        * Priorities are only "advice" and "SHOULD" be followed
    * This removes the need for domain sharding
* __Push__ -- server can proactively send as-yet-unrequested resources to the
  client's cache for future use, as soon as a stream has been established
    * This is useful for sending linked assets that would otherwise require
      the client to download the referencing html, parse it, and explicitly
      request those assets
    * This is neither the same-as or a replacement-for server-sent events (??)
      or WebSockets, both introduced with HTML5
    * Server sends a `PUSH_PROMISE` frame, includes the supposed request's
      URI, followed by `HEADER` then `DATA` frames containing the pushed
      response message

#### Frame Types

* `DATA` -- arbitrary, variable-length byte-sequences associated with a stream
    * one or more are used, for instance, to carry HTTP request or response
      payloads.
    * Set `END_STREAM` flag to `0` to indicate this is the last frame for this
      stream
* `HEADERS` -- opens a stream, may declare dependency on another stream,
  assigns a priority ["weight"], may end the stream, may have a "header block
  fragment" (subject to compression)
* `PRIORITY` -- specifies stream dependency and priority
* `RST_STREAM` -- request's cancellation of a stream with an error code
* `SETTINGS` -- specifies the sender's characteristics to the receiver; sent
  by client and/or server
    * Header table size, enable push, max concurrent streams, initial window
      size, max frame size, max header list size
* `PUSH_PROMISE` -- notify peer of the stream-id of a stream the sender
  intends to initiate
* `PING` -- mechanism for measuring minimal round-trip time from the sender,
  as well as determining whether an idle connection is still functional
    * MUST contain 8 bytes of whatever you want
    * If you receive a PING with ACK flag not set, you MUST send a PING _with_
      the ACK flag set in response, with an identical payload
    * PINGs have _higher priority_ than _anything_ else
* `GOAWAY` -- initiate shutdown of a connection or signal serious error
  conditions
    * allows an endpoint to gracefully stop accepting new streams while still
      finishing processing of previously established streams
    * Receivers of a GOAWAY frame MUST NOT open additional streams on the
      connection, although a new connection can be established for new
      streams.
    * Endpoints SHOULD always send a GOAWAY frame before closing a connection
      so that the remote peer can know whether a stream has been partially
      processed or not
* `WINDOW_UPDATE` -- used to implement _flow control_
    * The sender MUST NOT send a flow-controlled frame (viz. `DATA`) with a
      length that exceeds the space available in either the connection or the
      stream flow-control windows advertised by the receiver
    * The receiver of a frame sends a WINDOW_UPDATE frame as it consumes data
      and frees up space in flow-control windows, one for each of the 2
      relevant windows
    * Flow-controlled frames from the sender and WINDOW_UPDATE frames from the
      receiver are completely asynchronous with respect to each other
* `CONTINUATION` -- contains more of a `header block fragment` under
  transmission


#### Sources
* [JavaWorld Jetty & HTTP/2][jwj]
* [http2-spec][]

[alpn-spec]: https://tools.ietf.org/html/rfc7301
[jwj]: http://www.javaworld.com/article/2916548/java-web-development/http-2-for-java-developers.html
[http2-spec]: https://http2.github.io/http2-spec

### REST

#### Summary

* An architectural style for developing distributed, networked systems such as
  the World Wide Web and its applications. *Application components* (e.g.
  `users` and `tweets`) are *resources* that can be *created, read, updated,
  and deleted* [CRUD], corresponding to the four fundamental `HTTP` request
  methods: `POST`, `GET`, `PATCH`, and `DELETE`.
* HTML forms (up to and including HTML 5) can only send `GET` and `POST`.

#### POST

* **Providing a block of data** to a handling process
    * Fields from an HTML form
    * A message for a bulletin board
    * A new resource
    * Appending data to a resource

#### If your action is not *idempotent*, then you *MUST* use `POST`

**`GET`, `PUT` and `DELETE` methods are required to be idempotent.** The client
should be able to pre-fetch every possible `GET` request for your service
without it causing visible side-effects.

##### The format

	POST /index.html HTTP/1.1
	Host: www.example.com
	Content-Type: application/x-www-form-urlencoded
	Content-Length: length

	licenseID=string&content=string&paramsXML=string

###### Key-Value pair encoding

For example, the key-value pairs

	Name: Jonathan Doe
	Age: 23
	Formula: a + b == 13%!

are encoded as

	Name=Jonathan+Doe&Age=23&Formula=a+%2B+b+%3D%3D+13%25%21

#### PUT

Create a resource, or overwrite it at the specified new URL.

A successful `PUT` of a given representation would suggest that a subsequent
`GET` on that same target resource will result in an equivalent representation
being sent in a `200 (OK)` response. `PUT` is **idempotent**, so duplicate
attempts after a successful one have no effect.

#### PUT vs. POST

* `POST` means "create new" as in "Here is the input for creating a user,
  create it for me".
* `PUT` means "insert, replace if already exists" as in "Here is the data for
  user 5".
* `PATCH` to a URL updates part of the resource at that client defined URL.

#### PUT vs. PATCH

`PUT` must take a full new resource representation as the request entity.
`PATCH` also updates a resource, but unlike PUT, it *applies a delta* rather
than replacing the entire resource. Many APIs simply implement PUT as a
synonym for PATCH.

## Application Layer Protocols

For plain-old HTTP, it's in its own Chapter.

### HTTPS (HTTP Secure)

* Provides **authentication** of the website and associated web server that
  one is communicating with, which protects against *man-in-the-middle*
  attacks
* Also provides **bidirectional encryption** of communications between a
  client and server, which protects against *eavesdropping* and *tampering*
  with or *forging* the communication's contents
* Everything in the HTTPS message is encrypted, including the headers, and the
  request/response load.
* Technically, not a protocol in and of itself, but the result of layering
  `HTTP` on `SSL`/`TLS`
* Relies on *certificate authorities* to verify the owner of the certificate
    * Snowden's documents revealed that this *still* allows *man-in-the-
      middle* attacks
* Note: a site *must* be *completely* hosted over HTTPS (without having some
  of its contents loaded over HTTP) or the user will be vulnerable to some
  attacks and surveillance.
* Uses `port 443` by default (not `80`)
* To serve over HTTPS without the client's browser showing a warning, one must
  create a public key certificate signed by a certificate authority. This may
  cost $8 -- $70 per year.

### SOAP (Simple Object Access Protocol)

* A *protocol specification* for exchanging *structured information* in the
  implementation of a *Web service*
* Uses XML for its message format,
* Relies on e.g. HTTP or SMTP for message transmission
* Can form the foundation layer of a web services protocol stack
* Has 3 parts
    1. An envelope, i.e. **message structure** and how to process it
    2. Encoding rules for application-defined **datatypes**
    3. A convention for representing *procedure calls* and *responses*
* Has 3 characteristics
    1. Extensible (not sure what this means)
    2. Neutral (doesn't care what transport protocol is used)
    3. Independent (of programming language etc.)
* Evolved as successor of `XML-RPC`
* Designed in 1998 for Microsoft, became W3C recommendation (with
  specification) in 2003

#### Wikepedia's example message

    POST /InStock HTTP/1.1
    Host: www.example.org
    Content-Type: application/soap+xml; charset=utf-8
    Content-Length: 299
    SOAPAction: "http://www.w3.org/2003/05/soap-envelope"

    <?xml version="1.0"?>
    <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
      <soap:Header>
      </soap:Header>
      <soap:Body>
        <m:GetStockPrice xmlns:m="http://www.example.org/stock">
          <m:StockName>IBM</m:StockName>
        </m:GetStockPrice>
      </soap:Body>
    </soap:Envelope>

### XMPP (Extensible Messaging and Presence Protocol aka "Jabber") -- 1999

* Message-oriented middleware based on XML
* Open standard, many free and open source software implementations
* Instant messaging (IM) (including multi-user), VoIP, video, file transfer,
  gaming, Internet of Things, smart grid, social networking
* Transport over TCP, or HTTP, or WebSocket; optionally uses TLS
* No central master server, but it's neither anonymous nor peer-to-peer
* Client-server architecture, clients don't talk directly to each other

### Telnet

From 1968, an unencrypted-but-otherwise-SSH-like protocol

### SIP (Session Initiation Protocol)

* A text-based *session (application) layer* *signaling* *communications
  protocol* from 1996 for controlling e.g. Voice/Video Over IP for two-party
  ("unicast") or multiparty ("multicast") *sessions*, as well as file transfer
  and online games; runs over over TCP, UDP, or SCTP
    * Defines messages for establishment, termination, and other essential
      elements of a call like changing addresses or ports, inviting more
      participants, and adding or deleting media streams
    * The media itself is transmitted over another application protocol,
      RTP/RTP (Real-time Transport Protocol) *(see below)*
    * Like HTTP, each transaction consists of a client request invoking a
      particular method/function on the server, and at least one response;
      most devices can perform both the client and server roles, where caller
      is recipient and callee is server
    * Request methods include REGISTER, `INVITE`, `ACK`, `CANCEL`, `BYE`, and
      `OPTIONS`
    * Response codees include Provisional (`1xx`), Success (`2xx`),
      Redirection (`3xx`), Client Error (`4xx`), Server Error (`5xx`), and
      Global Failure (`6xx`)
    * Reuses most of the header fields, encoding rules, and status codes of
      HTTP
    * Each resource in a SIP network as a URI with the format
      `sip:username:password@host:port`, or `sips:` for secure transmission
      via TLS
* **Signaling** --- message to inform receiver of a message to be sent
    * E.g. to establish a telecommunication circuit
* **Communications Protocol** --- system of digital rules for data exchange
  within or between computers.
    * Well-defined message formats with exact meaning provided by a specified
      syntax, semantics, and synchronization of communication
* **Communication session** --- "semi-permanent interactive information
  interchange between 2+ devices" (lol). *Established* and *terminated* at
  specific points in time.

### RTP (Real-time Transfer Protocol)

* Defines a standardized packet format for delivering audio and video over IP
* Often uses RTCP (RTP Control Protocol) for monitoring quality of service
  (QoS) and SIP (Session Initiation Protocol) *(see above)* for setting up
  connections across the network
* Designed for end-to-end, *real-time* transfer of *stream* data, provides
  *jitter* compensation and detection of out of sequence data arrival. Allows
  use of IP *multicast*.
    * **Jitter** --- deviation from true periodicity of a presumed periodic
      signal (e.g. variation of packet latency). Dejitterizers use a buffer.
    * **Real-time** programs *must guarantee* response within strict time
      constraints aka "deadlinees"
    * **Streaming media** --- bresented to end-user *while* being delivered by
      provider
* Tolerates some packet loss to achieve goal of real-time multimedia streaming
* Generally uses UDP and not TCP

### FTP -- File Transfer Protocol

* _Stateful_ client-server protocol; e.g. "current directory" state is
  maintained per session on the server
* This protocol is so old (1971), it predates TCP (originally used "NCP")
* Client connects over TCP to FTP server listening on port 21
* This becomes the "control" channel
* Now we must also establish a separate "data" channel
* How the "data" channel is established depends on whether we do it in
  "active" or "passive" mode
* Using "passive" mode allows us to bypass firewalls and NAT issues
* For "passive" mode, the server sends a data port to connect to over the
  control channel, and the client initiates a connection to that port
* For "active" mode, the client listens on a port that the server connects to
* To get access to files, the client must supply a username and password
* If the username is "anonymous", the server may still make some files
  available, e.g. software patches
* FTP is from before protocols cared about security, because only rich
  academics had access to compoopers
* Everything is transmitted in plain text (lol), including usernames,
  passwords, and data.
* There is a securified protocol _extension_ called FTPS
* There is also a related protocol with similar commands called SFTP which
  runs over SSH, and over which everything is encrypted
* One can also use an SSH tunnel or VPN, but that is difficult because
  multiple TCP connections are required
* Commands include things like abort, append, change directory, delete file,
  disconnect, rename, retrieve file, store file
* Servers send reply codes similar to HTTP status codes

### SFTP -- SSH File Transfer Protocol

* More like a remote file system protocol them just file transfer
* Allows resuming transfers, listing remote directories, and remote file
  removal
* Does not provide authentication or security itself, it expects that from the
  transfer layer, generally via SSH-2
* It is still only a "Draft" of the IETF, because it does so many things, and
  standardization has been stalled since roughly 2006 (interesting)

### SSH -- Secure Shell

* Provides encrypted remote-login channel over unsecured network
* Client-server architecture; 20+ separate server and client implementations
* Can be used to provide a secure channel for other network services (i.e.
  services implemented as a network protocol)
* Two major versions SSH-1 and SSH-2
* Designed to replace the insecure virtual terminal protocol Telnet, which
  sends passwords in plaintext
* Snowden's leaks indicate that the NSA can sometimes decrypt and read the
  contents of SSH sessions*
* Authentication of the server is always done with public-key cryptography
* Authentication of the user can either be done with a public-key, or with a
  password
    * To do it by key, put your public key in the server's
      `~/.ssh/authorized_keys` file
* The network connection is encrypted via generated public-private key pairs
* If the two sides have never authenticated before, a man-in-the-middle could
  pretend to be the server and obtain the user's password
* Supports remote command execution, tunneling, TCP port forwarding, X11,
  SFTP, and SCP
    * In this case, tunneling refers to the fact that SSH can provide a secure
      channel to protocols that transmit plaintext. As all traffic through SSH
      is encrypted end-to-end, the protocol running through it does not need
      to secure itself.
* TCP port 22 is assigned for SSH servers
* Created as freeware by Finish guy in Helsinki in 1995 to replace Telnet, and
  had instant success
* SSH-2, incompatible with SSH-1, created by IETF working group, and adopted
  by them as an Internet standard in 2006
* SSH-2 supports concurrent shell sessions over one SSH connection
* Internally it has its own stack of layers
* Transport layer sets does server authentication (every hour), sets up
  encryption, and exposes an interface for sending plaintext packets. This
  layer alone is similar to TLS. Optionally provides compression.
* User authentication layer does user authentication, and runs over the
  transport layer.
* Connection layer provides the "channel" abstraction. Channels are
  multiplexed through the single SSH connection (this is an advantage over
  TLS). Either side may open a channel.
    * This layer runs over the user authentication layer.
    * Standard channel types include "shell" for terminal shells, and "tcpip"
      for forwarding connections
        * When one side requests to open a channel, it specifies the type, and
          if the recipient doesn't know that type, the request will be
          rejected
    * Each end may refer to the same channel with a different identifier. The
      _recipient's_ identifier is used to label packets in that channel.
    * *Channels are flow-controlled* using a receiver-advertised window (like
      TCP), where *both sides* have a window
        * "The window size specifies how many bytes the other party can send
          before it must wait for the window to be adjusted" with a special
          window-adjustment message
* Communication is done with an ssh2 binary packet, which contains the length
  (encrypted!), payload (encrypted, possibly compressed), random padding, and
  a MAC; the sequence number is an "implicit" `uint32` (it is not sent over
  the wire)

#### Example: remote command execution

* the client opens a "session" channel
* then requests allocation of a pseudo-terminal (with given dimensions)
* then sends its overriden environment variables
* then requests startup of a shell program
* then sends commands to execute
* then may send signals e.g. `SIGINT` to the server
* then on termination server sends "exit-status" or "exit-signal" (due to
  violent termination)
* Client-side window-size updates can be sent too.

## Miscellaneous

### Packet Sniffing Promiscuous Mode

* __Promiscuous mode__ -- a mode of the network interface controller (NIC), in
  which it passes _all received traffic_ to the CPU, rather than only those
  frames addressed to this NIC (viz. via MAC address)
    * Used for _packet sniffing_
* __Packet sniffing__ -- intercepting and logging traffic, then passing it to
  a _packet analyzer_
    * Can be used to become a bad guy, _or_ to catch bad guys
    * Useful for monitoring your network

### Overlay Network

* A network built on top another network
* A link between 2 nodes in the overlay may require multiple links in the
  underlying network
* The Internet was originally an overlay upon the telephone network.  Today,
  VoIP is the vice-versa.
* Distributed systems such as peer-to-peer networks and client-server
  applications are overlays over the Internet

### Router vs. Switch

* **Routers** join together multiple **LAN**s with a **WAN**
* Intermediate destinations, forwarding packets toward their destinations
* Your home router connects your house's LAN to the Internet WAN
* **Switches** just forward packets *within one LAN*
    * They can inspect the messages, and forward data only to the intended
      device

### Apple's general Network Programming Tips

* Higher-level APIs solve many networking problems for you -- caching,
  proxies, choosing from among multiple IP addresses for a host, and so on
* Be wary of all incoming data. Carefully inspect incoming data and
  immediately discard anything that looks suspicious
* Bad networking code can cause poor battery life, performance, and so on
* Batch your transfers, and idle whenever possible
    * If you keep their radio on, you're wasting their battery life
* Cache resources locally, only redownload if you know it changed

## Web Hosting

* **VPS (Virtual Private Server)** --- you're sharing the hardware with
  someone else, but you're running in a VM so you may pay less than you would
  have for a minimal website that's not tying up the resources of an entire
  server.

### Rails Web Hosting Companies

* Directly on Amazon AWS EC2
* Digital Ocean (VPS)
* Heroku
