latex input:	mmd-article-header
Title:			Things to Notes about Programming
Author:		Ethan C. Petuchowski
Base Header Level:		1
latex mode:  memoir
Keywords:		general, databases, testing, unit testing, monads, personal interest, research, fundamentals
CSS:			http://fletcherpenney.net/css/document.css
xhtml header:	<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:	2014 Ethan Petuchowski
latex input:	mmd-natbib-plain
latex input:	mmd-article-begin-doc
latex footer:	mmd-memoir-footer

Local databases
---------------

After I ran `brew install mysql`, it told me

* to launch mysql, run `mysql.server start`
* to connect, run `mysql -uroot`

The Monad
---------

### From Wikipedia

**5/27/14**

#### Intro

* A structure used in functional programming to represent computations defined
  as sequences of steps
* Defining a monad *type* means defining how operations of that type can be
  chained or nested together
* Facilitates the construction of data processing pipelines
* The monad defines extra code that gets executed *between* statements in the
  pipeline
* Can be seen as a functional design pattern for building generic types
* Used in *"purely functional"* programs to allow sequenced operation including
  side effects like I/O, variable assignment, exception handling, concurrency,
  etc.

### What is it

* Consists of a type constructor *M* and two operations *bind* and
  *return/unit*
* These operations must fulfill several properties to allow proper composition
* *Return* takes puts a value of a plain type into the type constructor,
  creating a *monadic value*
* *Bind* does the reverse, extracting the original value from the container and
  passing it to the next function in the pipeline, possibly with additional
  checks and transformations

### Example (Option)

* We want a monadic type such that computations can be chained such that if one
  computation fails, the rest of the computations simply won't *do* anything.
* So we have a type `Option[T]` s.t. if a computation fails it returns `None`,
  and if it succeeds it returns `Some[T]`, and when we perform operations on
  two `Options`, we only actually compute a result if they are both `Somes`,
  but simply return `None` if at least one operand is a `None`.
  
The following is my Scala translation of their Haskell example for this. It
merits careful study.

    scala> def maybePlus(a: Option[Int], b: Option[Int]): Option[Int] = {
         |   for {
         |     ia <- a
         |     ib <- b
         |   } yield (ia + ib)
         | }
    maybePlus: (a: Option[Int], b: Option[Int])Option[Int]
    
    scala> maybePlus(Some(3), Some(4))
    res0: Option[Int] = Some(7)
    
    scala> maybePlus(Some(3), None)
    res1: Option[Int] = None

### Example Writer monad

My Scala translation of their Javascript example for this. Also merits study.

    // the bind() method from the example
    case class Writer[A](value: A, log: String) {
      def flatMap[B](f: (A) => Writer[B]): Writer[B] = {
        f(value) match {
          case Writer(newVal, newStr) =>
            Writer(newVal, log + newStr)
        }
      }
    }
    
    // the unit() method from the example
    object Writer {
      def apply[A](a: A): Writer[A] = Writer(a, "")
    }
    
    object Run extends App {
      println(
        Writer(2)
          .flatMap(x => Writer(x*x, "squared."))
          .flatMap(x => Writer(x + 3, "plus threed."))
      )
    }

### Monad laws

There is a small set laws that must be followed in order for a monad to behave
correctly, but I don't understand the Haskell used to identify them on the
Monad Wikipedia page.

The correct type to use for currency values
-------------------------------------------

Don't use `double`, use `java.math.BigDecimal`


Redis
-----

#### 3/23/14

[StackOverflow](http://stackoverflow.com/questions/7888880/what-is-redis-and-what-do-i-use-it-for)

* [***RE**mote **DI**ctionary **S**erver*](http://redis.io/topics/faq)
* **NoSQL** key-value data store
* Data structure server
* Similar to **Memcached**, but with built-in *persistence* and more datatypes
* **Persistence** -- *snapshotting*, or *journaling* to disk
* **Datatypes** -- *Dictionary*, *List*, *(Sorted) Set*
* **Pub/Sub** transactions (see glossary at bottom)
* **Optimistic locking** -- (see glossary at bottom)
* The entire data set is stored in-memory (like Memcached)

##### Use Cases:

* Highly scalable data store shared by multiple processes, applications, or
  servers
* Caching layer

Philosophy
----------

### When something is too slow

#### 5/30/14

**Cache it**

### On the Method of Understanding a Programme

#### 3/13/14

* Run the program in a debugger
* Put breakpoints everywhere
* When it catches the first one, walk up the stack
* Put a breakpoint at the top of that stack
* Now restart from that outermost function and watch the thing unfold


Reactive Applications
---------------------
#### 2/23/14

According to [Typesafe](http://typesafe.com/platform)

Reactive applications have one or more of the following **defining traits:**

* **Event driven** -- enables parallel, asynchronous processing of messages or
  events with ease.
* **Scalable** -- across nodes elastically
* **Resilient** -- recovers and repairs automatically
* **Responsive** -- single-page UIs that provide instant feedback

In particular, the **Typesafe Reactive Platform** consists of the following
**stack:**

* **Play!** -- Web Framework
* **Akka** -- Actor Model concurrency library
* **Scala** -- Programming Language
* **Typesafe Console** -- Console


#### 3/23/14

The best description of what it really means, I've found to be this
[lecture on Vimeo by Sadek Drobi](http://vimeo.com/48328895). He describes it
as being a pattern in which you do all your computations on `Promises`, and
then the whole string of events that will happen once you obtain your `Promise`
is computed and then the actual computation takes place whenever you do obtain
the `Promise`. But the point is that you're never waiting for the `Promise`,
you just "react" by computing it when you *do* receive it. Something like that,
anyway.


Regex --- Lookahead & Lookbehind = "Lookaround"
-----------------------------------------------
#### 2/17/14

From [Regular-Expresions.info](http://www.regular-expressions.info/lookaround.html)

### Lookahead
* **Negative lookahead** --- match something *not* followed by something else
    * E.g. `q` *not* followed by `u` --- `q(?!u)`
* **Positive lookahead** --- match something *only if* it's followed by
  something else
    * E.g. `q` followed by `u` --- `q(?=u)`
        * Recall that the `u` is not consumed in this case
* Any valid regular expression can be used inside the lookahead (even capture
  groups, which do require their own set of parentheses within the lookahead)

### Lookbehind
* **Negative lookbehind** --- match something *not* preceded by something else
    * E.g. `b` *not* preceded by `a` --- `(?<!a)b`
* **Positive lookbehind** --- match something *only if* it's preceded by
  something else
    * E.g. `:` preceded by `cite` --- `(?<=cite):`
* Lookbehinds are generally restricted to only allowing some subset of the
  normal regex vocabulary, but the specifics vary (quite a bit) by language

### Notes:
* **They do not consume characters** in the string, they only assert whether a
  match is possible or not
* Some regexes would be impossible without them

##Newlines
#### 2/16/14

* On **Windows**, they use carriage-return & line-feed (`"\r\n"`)
* On **UNIX/Mac**, they use new-line, which is represented by the same ascii
  code as line-feed (`'\n'`), but does both CR-LF in one go

## Character Encodings
#### 2/4/15

* **ASCII** --- 7-bit character set maps characters to the range [0,127]
    * Sufficient for American English, but that's about it
* **Latin-1** --- 8-bit strict superset of ASCII, adds a few more characters
* **Unicode** --- space for 1m characters, 100K are used so far
    * Since it's only a "character set" not a "character encoding", it
      specifies what character gets mapped to each number, but it doesn't say
      how many bytes to use or which endianness; that's why we have the
      *encodings* UTF-8/16/32
    * **UTF-32** --- each character is a 4-byte int
    * **UTF-16** --- most are 2-bytes, some less common chars are 4-bytes
    * **UTF-8** --- 1-byte for ASCII chars, 2-bytes for many other alphabets,
      3-4-bytes for chars from Asian languages
        * This is used by Java's `.class` files to store string literals
* Other --- always use someone *else*'s converter to deal with other encodings

### Reference
* Java I/O 2nd ed., Elliotte Rusty Harold, 2010, O'Reilly

FTP vs. HTTP
------------
#### 2/16/14

Mainly from [AlBlue's Blog](http://alblue.bandlem.com/2009/02/why-do-people-
still-use-ftp.html)

* FTP was created for transferring files
    * That's why it gives you options for binary or ASCII modes
* HTTP was created for transmitting HTML
    * The file type is guessed based on the extension, though it can be
      specified in the header
* Originally, FTP was better for file downloads because HTTP/1.0 didn't support
  resumable downloads (where client disconnects part-way through and needs to
  restart). However, this was made possible in HTTP/1.1 via headers `Accept-
  Ranges` and `Content-Range`.
* HTTP also supports automatic data-compression, querying data-type before
  downloading, proxy support, running over SSL with HTTPS
* **People only use FTP over HTTP out of ignorance**
* In particular, WebDAV -- an extension of HTTP -- allows collaborative editing
  and management of documents stored on Web servers.

Glossary
--------

* **Reentrant** -- 2/16/14 -- a function that can be interrupted in the middle
  of its execution and then safely called again ("re-entered") before its
  previous invocations complete execution. Once the reentered invocation
  completes, the previous invocations will resume correct execution.
* **[Partial Function](http://en.wikipedia.org/wiki/Partial_function)** --
  3/1/14 -- *normally* a function maps an *entire* domain to some range. In a
  **Partial Function**, however, not *every* element of the domain must be
  mapped. Some values in the domain may be *undefined* after passing * through
  the partial function.
* **[Optimistic Locking](http://en.wikipedia.org/wiki/Optimistic_locking)** --
  3/23/14 -- Before committing, each transaction verifies that no other
  transaction has modified the data it has read. If the check reveals
  conflicting modifications, the committing transaction rolls back and can be
  restarted.
* **[Messanging pattern](http://en.wikipedia.org/wiki/Messaging_pattern)** --
  3/23/14 -- describes how two different parts of a message passing system
  connect and communicate with each other.
    * E.g. HTTP is a *request-response* pattern, UDP is a *one-way* pattern.
    * **Request-response** -- requester sends request message, replier
      receives, processes, and responds.
    * **Publish-subscribe** -- *publishers* post to an *intermediary message
      broker*, and *subscribers* register subscriptions with the broker. The
      broker might perform a *store and forward* to route messages to their
      destinations, and may prioritize the orderings.
        * E.g. RSS feeds
        * Provides better scalability than *request-response*
* **[Referential Transparency](http://en.wikipedia.org/wiki/Referential_transpa
  rency_(computer_science))**
  -- when you can replace an expression with its value without changing the
     program.
* **[Dithering](http://en.wikipedia.org/wiki/Dither)** --- applying noise to
  randomize quantization error, used when compressing audio and video data
