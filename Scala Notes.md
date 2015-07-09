latex input:    mmd-article-header
Title:				  Scala Notes
Author:			    Ethan C. Petuchowski
Base Header Level:		1
latex mode:     memoir
Keywords:			  Scala, programming language, syntax, fundamentals
CSS:				    http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:		  2014 Ethan Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

# Language Features

## self =>
**3/24/15**

I first came across this in the definition of the `Option` class:

    sealed abstract class Option[+A] extends Product with Serializable {
        self =>
        ...
        class WithFilter(p: A => Boolean) {
            def map[B](f: A => B): Option[B] = self filter p map f
            ...
        }
    }

As pointed out [here][spl self], if we didn't have the "`self =>`", then it
would be more difficult to access the `Option`'s `this` *inside* its inner-
class `WithFilter`.

[spl self]: http://scala-programming-language.1934581.n4.nabble.com/Beginner-question-Confused-by-self-type-syntax-td1940909.html

## Traits
**7/15/14**

> From *Programming in Scala* by Martin Odersky, Lex Spoon, and Bill Venners;
> Chapter 12 "Traits", beginning on pg 258.

Traits are a fundamental unit of code reuse in Scala. **A trait encapsulates
method and field definitions, which can then be reused by mixing them into
classes.** Unlike class inheritance, in which each class must inherit from just
one superclass, **a class can mix in any number of traits.**

You can do anything in a trait definition that you can do in a class
definition, and the syntax looks exactly the same, with **two differences**.

1. A trait cannot have 'class parameters' passed to the primary constructor of
   a class.

        trait NoPoint(x: Int, y: Int) // Does not compile

2. Whereas in `classes`, `super` calls are statically bound, in `traits`, they
   are dynamically bound, because the method implementation to invoke for the
   `super` call is undefined when you define the `trait`. It gets determined
   when the `trait` is mixed into a concrete `class`. This is key to allowing
   traits to work as *stackable modifications*.

Sealed classes
--------------
**7/15/14**

From *Programming in Scala* by Martin Odersky, Lex Spoon, and Bill Venners; pgs
326-7.

Whenever you write a pattern match, you need to make sure you have covered all
of the possible cases. Sometimes you can do this by adding a default case at
the end of the match, but you'd only do that if there is a sensible default
behavior. What if there isn't? In general, the Scala compiler can't tell what
all the cases are, because new case classes can be defined in arbitrary
compilation units.

The alternative is to make the superclass of your case classes sealed. A sealed
class cannot have any new subclasses added except the ones in the same file. If
you match against case classes that inherit from a sealed class, the compiler
will flag missing combinations of patterns with a warning message.

**Therefore, if you write a hierarchy of classes intended to be pattern matched, you should consider sealing them. Simply put the sealed keyword in front of the class at the top of the hierarchy.** The sealed keyword is to be treated like a "license to pattern match". 

    sealed abstract class Expr
    case class Var(name: String) extends Expr
    case class Number(num: Double) extends Expr
    case class UnOp(operator: String, arg: Expr) extends Expr
    case class BinOp(operator: String, left: Expr, right: Expr) extends Expr

    Listing 15.16 · A sealed hierarchy of case classes.

Now define a pattern match where some of the possible cases are left out:

    def describe(e: Expr): String = e match {
      case Number(_) => "a number"
      case Var(_)    => "a variable"
    }

You will get a compiler warning like the following:

    warning: match is not exhaustive!
    missing combination           UnOp
    missing combination          BinOp


Nested for-yield statements
---------------------------
**5/27/14**

* I've adapted Wikipedia's Haskell example to Scala.
* Note that this example is also in the `Things to Notes about Programming.md`
  under `The Monad`.

##### Example

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

What's Haapnin

* First we unwrap the options containing the ints
    * If they *both* exist, we add them
    * Otherwise we return `None`.
* The `None` case comes from the *definition of the **bind** operator on
  `Option[T]`*
    * But note [the entire *point* of the `Option` monad is that] we didn't
      have to do anything special here to take care of that

*Vector* Seq
--------------------
**6/10/14**

* According to [Stack Overflow](http://stackoverflow.com/questions/20612729/how-does-scalas-vector-work),
  the `Vector` data type uses a *32-ary* **tree**
* Each '32-way node' has a 32-element `Array` that **either** holds
  *references* **or** *data*
* The tree is "balanced" such that levels `1` to `n-1` hold 100% references,
  and level `n` contains 100% data
* Sounds quite like a B-Tree


Accessibility specifiers in class definitions
---------------------------------------------

**5/14/14**

Ref: [SO](http://stackoverflow.com/questions/14694712/do-scala-constructor-parameters-default-to-private-val)

To be clear, I'm talking about

    class Foo(** THIS SPOT HERE **)

#### bar: Int

If the variable isn't used anywhere besides the constructor, no
field is generated. Otherwise, `private val bar` is created, with
no getter.

#### private val bar: Int

Creates a `private val bar` field with a private getter.
No longer matters whether the variables is used anywhere besides
the constructor.

#### val bar: Int

Same as above, but with a public getter.

#### bar: Int (in a case class)

Same as above



Private instance variables
--------------------------

[SO](http://stackoverflow.com/questions/9698677/privatethis-vs-private)

#### private var a = b
Make the variable unavailable to other classes, but available to other
instances of the same class

#### private[this] var a = b    
Make the variable unavailable to *anyone* including other instances of this
class. Now it will be *only* available to *this specific instance* (and won't
work in subclass instances).

#### protected[this] var a = b
Make the variable *visible to only this specific instance, and subclass
instances*.

Override Keyword
----------------

**3/8/14**

* The `override` keyword **must be used** when overriding a **concrete
  implementation** of a member
* If you override an **abstract** member, the `override` keyword is
  **optional**
* If a declaration (whether a *class*, a *trait*, or a *member*) includes the
  `final` keyword then it may not be overridden

Futures and Promises
--------------------

**3/1/14**

From the [Scala Docs](http://docs.scala-lang.org/overviews/core/futures.html)

### Intro

* **A placeholder object for a result that does not yet exist**.
* Generally, the result is computed *concurrently* and can be later collected.
* Uses callbacks instead of blocking operations
* *Can* be blocked on when absolutely necessary
* Can only be assigned *once*

### Basics

Create a `Future[T]` with the `future` method

    import scala.concurrent._
    import ExecutionContext.Implicits.global
    
    val f: Future[List[Friend]] = future {
        session.getFriends()
    }
    
We import the `global ExecutionContext` to give us access to the global thread-
pool

We may also want to use a `Future` for tasks involving I/O

    val firstOccurrence: Future[Int] = future {
      val source = scala.io.Source.fromFile("myText.txt")
      source.toSeq.indexOfSlice("myKeyword")
    }

* **We can wait** for the `Future` to arrive and then use it
* **Or we can register for a callback** to be performed asynchronously when the
  `Future` arrives

E.g. you can call `onComplete(Try[T] => U)`, and you pass in the function to
call when the operation completes. The parameter `Try[T]` is similar to
is a monad (like `Option[T]`) that can either hold

* a *value* or
* an *exception*, where the exception is of type `Throwable`

##### For example
    f onComplete {
      case Success(posts) => for (post <- posts) println(post)
      case Failure(t) => println("An error has occurred: " + t.getMessage)
    }


The more specific callbacks you can register for are

* `onSuccess` only handles *successful* results
* `onFailure` only handles *failed* results

##### For example
    f onSuccess {
      case posts => for (post <- posts) println(post)
    }

#### Registering multiple callbacks

* Multiple callbacks registered on the same `Future` are *unordered*, they may
  even execute concurrently
* The callback is not necessarily called by the thread that completed the
  `Future` *or* the thread which created the callback
* In the event that some of the callbacks `throw` an `Exception`, the other
  callbacks are executed regardless
* Once executed, the callbacks are removed from the future object, thus being
  eligible for garbage collection

### For Comprehensions / Combinators

* `Futures` can be chained with the standard "combinators": `map, flatMap,
  filter, foreach, collect`
* The exceptions work nicely in this situation: whichever chained `Future`
  `throws` gets to declare the `Exception` type
* These combinators allow you to use *for-comprehensions*

In the following example, the `purchase` `Future` is only computed both
required `Futures` have completed.

    val usdQuote = future { connection.getCurrentValue(USD) }
    val chfQuote = future { connection.getCurrentValue(CHF) }
    
    val purchase = for {
      usd <- usdQuote
      chf <- chfQuote
      if isProfitable(usd, chf)
    } yield connection.buy(amount, chf)
    
    purchase onSuccess {
      case _ => println("Purchased " + amount + " CHF")
    }
    
If we want our `Future` to contain `0` instead of the `Exception`, we use the
`recover` combinator:

    val purchase: Future[Int] = rateQuote map {
      quote => connection.buy(amount, quote)
    } recover {
      case QuoteChangedException() => 0
    }

Combinator `fallbackTo` creates a new `Future` which holds the result of *this*
`Future` if it was completed successfully, or otherwise the successful result
of the *argument* `Future`. In the event that both this `Future` and the
argument `Future` fail, the new `Future` is completed with the `Exception` from
*this* `Future`.

    val usdQuote = future {
      connection.getCurrentValue(USD)
    } map {
      usd => "Value: " + usd + "$"
    }
    
    val chfQuote = future {
      connection.getCurrentValue(CHF)
    } map {
      chf => "Value: " + chf + "CHF"
    }
    
    val anyQuote = usdQuote fallbackTo chfQuote
    
    anyQuote onSuccess { println(_) }
    
The `andThen` combinator is used purely for side-effecting purposes. Multiple
`andThen` calls are *ordered*.

    val allposts = mutable.Set[String]()
    future {
      session.getRecentPosts
    } andThen {
      posts => allposts ++= posts
    } andThen {
      posts =>
      clearAll()
      for (post <- allposts) render(post)
    }


### The "Failed" projection

If the original `Future` *fails*, the `failed` projection returns a `Future`
containing a value of type `Throwable`. If the original future succeeds, the
`failed` projection fails with a `NoSuchElementException`. The following is an
example which prints the exception to the screen:

    val f = future {
      2 / 0
    }
    for (exc <- f.failed) println(exc)
    
The following example does not print anything to the screen:

    val f = future {
      4 / 2
    }
    for (exc <- f.failed) println(exc)


### Intentionally Blocking

Here is an example of how to *block* on the result of a `Future`:

    import scala.concurrent._
    import scala.concurrent.duration._
    
    def main(args: Array[String]) {
      val rateQuote = future {
        connection.getCurrentValue(USD)
      }
      
      val purchase = rateQuote map { quote =>
        if (isProfitable(quote)) connection.buy(amount, quote)
        else throw new Exception("not profitable")
      }
      
      Await.result(purchase, 0 nanos)
    }

In the case that the future fails, the caller is forwarded the exception that
the future is failed with.

Alternatively, calling `Await.ready` waits until the `Future` becomes
*completed*, but does not retrieve its result. In the same way, calling
`Await.ready` will not throw an `Exception` if the `Future` fails.

The `Future` trait implements the `Awaitable` trait with methods method
`ready()` and `result()`. These methods **cannot** be called directly by the
clients– they can only be called by the execution context.

To allow clients to call 3rd party code which is potentially blocking and avoid
implementing the `Awaitable` trait, the same `blocking` primitive can also be
used in the following form:

    blocking {
      potentiallyBlockingCall()
    }

The blocking code may also throw an exception. In this case, the exception is
forwarded to the caller.


### Promises

* A `Promise` can be used to successfully complete a `Future` with a value (by
  “completing” the promise) using the `success` method.
* Conversely, a `Promise` can also be used to complete a `Future` with an
  exception, using the `failure` method.

Read my comments to understand what's going on

    import scala.concurrent.{ Future, Promise }
    import scala.concurrent.ExecutionContext.Implicits.global

    val p = Promise[T]
    val f = p.future                      // get the future from *inside* of promise p

    val producer = future {
      val r = produceSomething()
      p success r                         // assign f the value r
      continueDoingSomethingUnrelated()   // f has already been assigned and can
    }                                     //     be used while this completes

    val consumer = future {
      startDoingSomething()
      f onSuccess {
        case r => doSomethingWithResult() // consumer notes that f was assigned,
      }                                   //   and can proceed to "do something"
    }

To `fail` the `promise` instead, use `p failure (new MyExceptionException)`
instead of `p success r`.

> One nice property of programs written using `Promises` with operations
> described so far and `Futures` which are composed through monadic operations
> without side-effects is that these programs are *deterministic*.
> Deterministic here means that, *given* that no `Exception` is thrown in the
> program, the result of the program (values observed in the `Futures`) will
> always be the same, regardless of the execution schedule of the parallel
> program.

The method `completeWith` completes the `Promise` with another `Future`. After
the `Future` is completed, the `Promise` gets completed with the result of that
`Future` as well. The following program prints `1`:

    val f = future { 1 }
    val p = promise[Int]    // sic, lowercase

    p completeWith f

    p.future onSuccess {
      case x => println(x)
    }


Case Class vs. Regular Class
----------------------------

**2/23/14**

From [Stack Overflow](http://stackoverflow.com/questions/5270752/difference-between-case-object-and-object)

Case classes just add to classes, they don't take away. They give you:

1. **pattern matching support**
2. default implementations of `equals` and `hashCode`
3. default implementations of *serialization*
4. a prettier default implementation of `toString`, and
5. the small amount of functionality that they get from automatically
   inheriting from `scala.Product`.

Implicit Variables and Parameters
---------------------------------

**2/2/14**

* Defining an implicit val makes it available to future uses of implicit
  parameters
* Must be last argument to function's last set of arguments

[This](http://www.drmaciver.com/2008/03/an-introduction-to-implicit-arguments/)
article spells them out quite simply, and the following example is based on
theirs.

##### E.g.

    scala> def foo(s: String)(implicit t: String) = s"$s $t"

    scala> foo("a")("b")
    res0: String = a b

    scala> implicit val w = "it's scary!"
    
    scala> foo("Implicit variables:")
    res1: String = Implicit variables: it's scary!

# Some functions worth knowing

## Functions on Collections

### Iterator.collect[B]\(pf: PartialFunction[A,B])

**1/18/14**

#### A convenient way to **simultaneously map and filter**.

* You can use a *pattern matching anonymous function* as the argument
* **If none of your `cases` match an element, that element gets filtered**

##### E.g.
  
    scala> (1 to 10) collect { 
        case x if x % 2 == 0 => -x
        case 1 => 11 
    }
    res0: Vector(11, -2, -4, -6, -8, -10)

### (xs groupBy f)

**7/15/14**

Partitions `xs` into a `Map` of collections according to a discriminator function `f`.

E.g. getting word count via MapReduce type algorithm

    scala> val wordString = "asdf qwer asdf asdf rtyu rtyu"    
    scala> val words = wordString.split(" ")

    // Oops!
    scala> val wordsGrouped = words.groupBy(_)
    error: missing parameter type for function ((x$1) => words.groupBy(x$1))
           val wordsGrouped = words.groupBy(_)
                                            ^
    // If you insist
    scala> val wordsGrouped = words.groupBy(identity)
    wordsGrouped: immutable.Map[String,Array[String]] = 
        Map(
          qwer -> Array(qwer), 
          rtyu -> Array(rtyu, rtyu), 
          asdf -> Array(asdf, asdf, asdf)
        )
    
    scala> val wordCounts = wordsGrouped.map { case (k, v) => k -> v.length }
    wordCounts: immutable.Map[String,Int] = Map(qwer->1, rtyu->2, asdf-> 3)


### Appending List to List with `++` & `:::`

**5/25/14**

Ref: [SO](http://stackoverflow.com/questions/6559996/scala-list-concatenation-vs)

It looks like one should generally use `++` instead of `:::` to
concatenate lists, because that works with *any* two `Collections`,
even `Iterators`. The same goes for using `+:` over `::`, **except
when pattern matching**, which you *cannot do with* `+:`.

        
### updated() on SeqLike
**6/15/14**

**A *functional* way to mutate *immutable* sequences.**

From the [source code][SeqLike.scala]:

    def updated[B >: A, That](index: Int, elem: B)(implicit bf: CanBuildFrom[Repr, B, That]): That = {
      val b = bf(repr)
      val (prefix, rest) = this.splitAt(index)
      b ++= toCollection(prefix)
      b += elem
      b ++= toCollection(rest).view.tail
      b.result
    }

E.g. for a `List[A]`, this will *copy* the first `index` elements to a
*new* `List`, then append the new element, then stick that onto the the
*existing* rest of the `List`. The implementation would be different for
an `Array[A]` or a `Vector[A]`.

[SeqLike.scala]: https://lampsvn.epfl.ch/trac/scala/browser/scala/trunk/src//library/scala/collection/SeqLike.scala


### Span on Collections

**5/4/14**

It's like `partition`, only it stops looking as soon as it finds
the first value in the collection for whom the predicate is `false`.

    scala> val a = List(1, 2, 3, 45, 56, 1, 2, 3)
    
    scala> val (b,c) = a.span(_ < 5)
    b: List[Int] = List(1, 2, 3)
    c: List[Int] = List(45, 56, 1, 2, 3)
    
    scala> val (d,e) = a.partition(_ < 5)
    d: List[Int] = List(1, 2, 3, 1, 2, 3)
    e: List[Int] = List(45, 56)
    
Example from **P09** in 
[Ninety-Nine Scala Problems](http://aperiodic.net/phil/scala/s-99/p09.scala)

    // P09 (**) Pack consecutive duplicates of list elements into sublists. 
    // If a list contains repeated elements they should be placed in separate 
    // sublists.
    //     Example:
    //     scala> pack(List('a,'a,'a,'a,'b,'c,'c,'a,'a,'d,'e,'e))
    //     res0: List[List[Symbol]] = List(
    //                List('a, 'a, 'a, 'a), 
    //                List('b), List('c, 'c), List('a, 'a), 
    //                List('d), List('e, 'e)
    //           )
    
    object P09 {
      def pack[A](ls: List[A]): List[List[A]] = {
        if (ls.isEmpty) List(List())
        else {
          val (packed, next) = ls span { _ == ls.head }
          if (next == Nil) List(packed)
          else packed :: pack(next)
        }
      }
    }
    

My Guide to a crazy function
----------------------------

Check out the following function from a nice [tutorial on Iteratees](http://blog.higher-order.com/blog/2010/10/14/scalaz-tutorial-enumeration-based-io-with-iteratees/)

    def enumerate[E,A]: (List[E], IterV[E,A]) => IterV[E,A] = {
      case (Nil, i) => i
      case (_, i@Done(_, _)) => i
      case (x :: xs, Cont(k)) => enumerate(xs, k(El(x)))
    }

### Now we translate:

#### First line

    def enumerate[E,A]: (List[E], IterV[E,A]) => IterV[E,A] = {

* The **function** `enumerate` has an **input** type `E`, and a **result** type
  `A`.
* It **returns** a *function* that
    * **takes**
         * `List` of *inputs*
         * `Iteratee` parameterized by the same input/result types as this
           function
    * **returns** another `Iteratee`

#### Case 1

    case (Nil, i) => i

* If the `List` passed in is empty, return the `Iteratee` as-is

#### Case 2

      case (_, i@Done(_, _)) => i

* If the `Iteratee` is in the `Done` state (I think it means
  `isInstanceOf[Done]`), return it as-is

#### Case 3

      case (x :: xs, Cont(k)) => enumerate(xs, k(El(x)))

* If the `Iteratee` is in the `Cont` state, recurse on this method
    * Pass the `tail` of this `List` as the new `List`
    * For the `Iteratee`, pass that `Iteratee` obtained by creating an
      **input** element from the `head` of the `List`, and (I think) appending
      it to the `Iteratee` using the function `k()`


# SBT

### Keys

Your `build.sbt` file defines a `Project` which holds a list of Scala
expressions called `settings`

    version := "0.1.0"

    scalaVersion := "2.11.4"

On the left-side of a `Setting` is a *key*. There are 3 types of keys

1. `SettingKey[T]` -- computed once, when project is loaded
2. `TaskKey[T]` -- key for a value which is a *task*, potentially with side
   effects (e.g. `compile` or `package`)
3. `InputKey[T]` -- key for a task which takes command line args as input


`version`, `name` and, `scalaVersion` are examples of keys which are 
*implicitly imported* into your `build.sbt` file.

To create a command line task, you first associate the key name with what type
of task it is.

    lazy val hello = taskKey[Unit]("An example task")

And then you associate the key with code to execute when it is called

    hello := { println("Hello!") }

Keys have *scopes* which might be subprojects, test sources, `.class` files,
etc. Often the scope is implied or has a default, but you can always set it
explicitly.


