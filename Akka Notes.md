latex input:    mmd-article-header
Title:          Akka Notes
Author:         Ethan C. Petuchowski
Base Header Level:  1
latex mode:     memoir
Keywords:       Akka, Scala, Concurrency
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:      2014 Ethan C. Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer

## Again from the Akka Docs
4/8/15

Actors each have independent state and behavior, so it may be helpful to think
of them as *people* that you assign tasks to.

Actor systems are hierarchies, a *parent* "supervises" its *children*. Each
actor has at most *one* parent.

* So e.g. I may want the master to be a parent and all the nodes to be
  children?
* Or I could have the master have 2 children `serverSupervisor` and
  `clientSupervisor`

The hierarchical structure helps us to clearly structure our task in the mind
and in the code.

"Watching" another actor for whether it terminates is different from
"supervising" it. When we "watch", we (under the hood) register to receive
heartbeats, using a smarter mechanism than I would ever bother to implement on
my own.

Communication between actors is "transparent", whether it is within-JVM,
across-JVM, across network, across world, etc.

Akka itself has no shared global state; we can have multiple actor systems
coexisting in one JVM.

Do not pass mutable objects or closures between actors.

The goal of an `ActorRef` is to support sending messages to the referenced
actor.

An `Actor` can get an `ActorRef` to

* *itself* via its `self` field
* the currently received msg *sender* via the `sender` field

There are different types of `ActorRef`s, here are a few

* Purely local, doesn't work across network
* Local with remoting enabled -- represents nodes with this JVM, but includes
  networking info
* Remote actor references represent nodes reachable only through the network
    * If you send one a msg, Akka will serialize that msg for you

Each actor goes by a unique slash-separated path name, like a directory tree,
where the older ancestors are the earlier entries in the path.
 
You *can* create an actor *path* without creating an actor, but *cannot* create
an actor *reference* without creating the corresponding actor.


## Akka for PlayFramework

3/1/14

From the [Play Docs](http://www.playframework.com/documentation/2.0/ScalaAkka)

Play apps have their own default actor system. Use it as a Factory via

    import play.libs.concurrent.Akka
    val myActor = Akka.system.actorOf(Props[MyActor], name = "myactor")

Add these lines to `conf/application.conf`

    akka.default-dispatcher.core-pool-size-max = 64
    akka.debug.receive = on


A "Hello Akka" set of notes, Written by Me
------------------------------------------

3/1/14

### Based on `HelloAkkaScala.scala`

    case object Greet
    case class Greeting(msg: String)
    class Greetor extends Actor {
      def receive = {
        case Greet => 
          sender ! Greeting("good day to you too!")
      }
    }

* Use the `tell` method explicitly when you want to specify the `sender
  ActorRef` to pass to the receiver
    * E.g. to get the `Actor` to `receive` the `msg` with *no* sender
      `ActorRef`, use

            toActor.tell(
              msg = MyCaseObj,
              sender = ActorRef.noSender
            )

#### ActorSystem

* Creates and manages the actors
* Has a `name` parameter in the constructor, *probably* for logging,
  configuring in a `.conf` file, and creating a good path-name.

Constructor usage example:

    val system = ActorSystem(name="Hello_Akka")

Now we can use the ActorSystem's 'factory' to create an instance of a class
that `extends Actor` (e.g. `Greeter`)

    val greeter: ActorRef = system.actorOf(props=Props[Greeter], name="greeter")

Again, `name` is *probably* for logging, configuring in a `.conf` file, and
creating a good path-name.

#### Inbox

* An actor created along with the system with no specific implementation
  details
* Useful when writing code outside of actors which shall communicate with
  actors
* It can `send` a message to an `Actor`

        inbox.send(target=greeter, msg=greet)

* It can `receive` the reply from that `Actor` with a *timeout*

        val Greeting(message1: String) = inbox.receive(max=5.seconds)



#### Scheduler

* Use this to repeatedly send a message to an actor every so often

        system.scheduler.schedule(
          initialDelay=0.seconds,
          interval=1.second,
          receiver=greeter,
          message=Greet)(
          executor=system.dispatcher,
          sender=greetPrinter
        )

[Akka Scala Documentation](http://doc.akka.io/docs/akka/2.2.1/scala.html)
--------------------------

3/1/14

### [Akka Actors Docs](http://doc.akka.io/docs/akka/2.2.1/scala/actors.html)

####Send messages

Messages are sent to an Actor through one of the following methods.

1. `!` means **“fire-and-forget”**, e.g. send a message asynchronously and
   return immediately. **Also known as `tell`**.
2. `?` sends a message asynchronously and **returns a Future representing a
   possible reply**. **Also known as `ask`**.

Message ordering is guaranteed on a per-sender basis ("FIFO delivery").


Scala In Depth, Chp. 9: Actors
------------------------------

2/23/14

* An actor will process received messages sequentially in the order they are
  received, and only handle one message at a time.
* A small set of threads can support a large number of actors, given the right
  behavior.
* If the application needs to farm many similar tasks out for processing, this
  requires a large pool of actors to see any concurrency benefits.
* **Using an actor to perform blocking I/O is asking for trouble. That actor
  can starve other actors during this processing.**

Akka can be used with Spray
--------------------------

2/23/14

This tutorial application will:

* Receive HTTP requests with JSON payloads
* Unmarshal the JSON into `case classes`
* Send these instances to `Actor`s for processing
* Marshal the `Actor`'s responses into JSON
* Use that to construct HTTP responses

It will also use the "Cake" pattern, which enable us to separate out parts of
the system so that I can "assemble" the parts of the cake into the components
that I ultimately run or test.

### [Spray](http://spray.io/) (an interesting aside)

* An open-source toolkit for building REST/HTTP-based integration layers on top
  of Scala and Akka.
* Comes with a small, embedded and super-fast HTTP server (called spray-can)
  that is a great alternative to servlet containers. spray-can is fully
  asynchronous and can handle thousands of concurrent connections. It also
  supports request and response streaming, HTTP pipelining and SSL. And: there
  is an HTTP client to go with it.
* Elegant DSL for API construction promotes RESTful style as well as a clean
  separation of the various application layers.
* All APIs are fully asynchronous, blocking code is avoided wherever at all
  possible.
* Akka Actors and Futures are key constructs of its APIs.
* Being *modular*, your application only needs to depend onto the parts that
  are actually used.

##### Spray's Philosophy

* Regards itself as a suite of libraries rather than a framework, e.g. you just
  need a REST/HTTP interface, not browser-interaction
* `spray` is made for building integration layers based on HTTP and as such
  tries to “stay on the sidelines”. Therefore you normally don’t build your
  application “on top of” `spray`, but you build your application on top of
  whatever makes sense and use `spray` merely for the HTTP integration needs.

Notes from the Hello-Akka Tutorial
----------------------------------

2/23/14

### Notes from the Tutorial itself

##### Akka is a toolkit and runtime for building highly concurrent, distributed, and fault-tolerant event-driven applications on the JVM.
* Messages can be of arbitrary type
* Define messages with good names and rich semantic and domain specific
  meaning, even if it's just wrapping your data type. This will make it easier
  to use, understand and debug.
* It is very important that the messages we create are immutable to avoid
  sharing state between two Actors
* Scala `case classes` and `case objects` make excellent messages since they
  are immutable and we can use *pattern matching* to locate messages it has
  received.
    * Another advantage case classes has is that they are marked as
      *serializable* by default.
* Actors are object-oriented in the sense that they encapsulate state and
  behavior, but they have much stronger isolation than regular objects
* **The only way to observe another actor's state is by sending it a message
  asking for it.**
* Actors are extremely lightweight, *you can easily create millions of
  concurrent Actors in a single application*.
* To create an Actor, you `extend Actor` trait, and implement the `receive`
  method, where you define how the Actor responds to different messages it can
  receive
* **Mutating an Actors internal state in `receive` is thread safe**, being
  protected by the Actor model
* In the (Scala only) `receive` method, you don't need to define a *default*
  case because that is passed to the `unhandled()` method for you by Akka
* You instantiate Actors using a factory
* The factory returns an `ActorRef` *pointing* to the Actor instance
    * The indirection here adds power and flexibility to
        * have the actor in-process or on a remote machine without changing
          anything.
        * And you can change where it is while it's running.
        * And it enables *"let it crash"*, in which the system heals itself and
          restarts faulty Actors.
* The Actor factory -- `ActorSystem` -- is also the Actor container, managing
  their life-cycles.
* `Props` is a *configuration object*, and you parameterize it with the Type of
  the Actor you want.
* Every hard problem in Actor programming can be solved by adding more Actors;
  by breaking down the problem into subtasks and delegate by handing them to
  new Actors.
* The sample unit tests use `ScalaTest`, using the Akka `TestKit` module, which
  makes it so much easier to test and verify concurrent code.
