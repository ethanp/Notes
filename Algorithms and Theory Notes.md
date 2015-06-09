latex input:    mmd-article-header
Title:				  Algorithms and Theory Notes
Author:			    Ethan C. Petuchowski
Base Header Level:		1
latex mode:     memoir
Keywords:       algorithms, computer science, theory, grammars
CSS:				    http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:		  2015 Ethan Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

# Interview-type Questions

## Find the \\(k^{th}\\) largest element of array `arr`

[Reference](http://courses.csail.mit.edu/iap/interview/Hacking_a_Google_Interview_Handout_2.pdf).
It's also near the beginning of *The Algorithm Design Manual*.

Use *random-pivot quicksort*, but always only recurse into the half containing
desired index (e.g. \\(n/2\\) to __find the median__). If the pivot goes in
that index, we're done. The complexity is
\\(O(n)+O(n/2)+O(n/4)+\cdots\rightarrow O(2n)=O(n)\\).

# CS Theory

## Graphs

### Minimum spanning tree
Tree with all nodes of graph (i.e. spanning tree) such that the some of the
weights of the edges is less or equal to any other spanning tree of this graph.

#### Prim's algorithm
Greedy algorithm that finds a minimum spanning tree for connected weighted
undirected graph.

1. Initialize tree with arbitrary vertex of graph
2. Continually the add minimum weight edge that adds a new vertex to the tree

#### Kruskal's algorithm
(Another) greedy algorithm that finds a minimum spanning tree for connected
weighted undirected graph.

1. Initialize a set F of trees, where each vertex in the graph is its own tree
2. Initialize a set S with all edges of the graph, sorted by length
   (\\(O(m \log m)\\))
3. Continually use the smallest edge from S to combines two trees in F

To implement this efficiently, we need to use Union Find (below) to combine
trees in F.

### Union Find
The goal of this **data structure** is to handle the following situation:

We have a set of sets of elements, where are elements are globally distinct.
We would like to be able to quickly:

1. determine whether two elements are in the same [inner] set
2. merge two [inner] sets with each other
3. know the size of the outer set

So we give each element an id, and put all ids in an array, and organize each
inner set as a tree, defined by the array in the following manner:

* `elem`'s *parent* is the value in `array[elem_id]`.

So we can find the root of the set containing an element by traversing until we
reach an element such that `array[elem_id] == elem_id`. This will be guaranteed
\\(O(\log n)\\) if the tree is kept balanced. To ensure this, whenever
combining two trees, we make the root of the *smaller* tree point to the root
of the *bigger* one, rather than any other method of combining the trees. To
facilitate this, we have a `sizeArray[num_elems]` that says how many nodes
(including itself) are contained in the (sub-)tree defined by this node down.

That's really all there is to it.

## Strings
### String Search with Rabin-Karp
See hashing section below

## Hashing

### Building a hash-table of strings

**4/27/15**

From *The Algorithm Design Manual*.

A reasonable hashing algorithms for strings is

\\[H(S)=(\sum_{i=1}^{|S|}{\alpha^{|S|-i} S_i}) \,\%\,m\\]

In which you map each string to a unique integer by treating each character as
a "digit" in a base-\\(\alpha\\) number system. Then you stick the string in
slot \\(m\\) of the underlying array. \\(m\\) should be a large prime not too
close to \\(2^{i}-1\\) so that hash values are fairly uniformly distributed

### String Search with Rabin-Karp

To find a pattern \\(p\\) in a a text \\(t\\), where \\(n=|t|,m=|p|\\)

We calculate the hash of \\(p\\) with the simple base-conversion hashing
algorithm above ("with a random \\(m\\)" [not sure why]), then slide along
\\(t\\), hashing as we go. Calculating the hash of each new letter given the
previous hash can be done in *constant* if we note that our hash algorithm is a
"rolling-hash" in the following manner:

\\[H(S,j+1)=\alpha(H(S,j)-\alpha^{m-1}char(s_j))+char(s_j+m)\\]

So now we just have to worry about hash collisions (NBD), but otherwise we've
solved the problem in *expected-time* \\(O(m+n)\\).

## Finite State Machines

**9/13/14**

### Definition

[Source: i-programmer][ip fsm]

1. Finite number of states
2. When a *symbol* (a character from some *alphabet*) is input to the
   machine, it changes state
3. The next state depends *only* on the current state and the input symbol


### In General
1. Don't let the lack of historical memory deceive you: all you need
   is a state for each of the possible past histories and then the state
   that you find the machine in is an indication of not only its current
   state but how it arrived in that state.
2. The Markov chain is a sort of probabilistic version of the finite state
   machine.
3. All you have to do is draw a circle for every state and arrows that
   show which state follows for each input symbol.
4. Many communications protocols, such as USB can be defined by a finite
   state machine’s diagram showing what happens as different pieces of
   information are input.
5. You can even write or obtain a compiler that will take a finite state
   machine’s specification and produce code that behaves correctly.

### Finite Grammars
1. If you define *two* of the machine’s states as special –-- a *starting* and
   a *finishing* state –-- then you can ask what sequence of *symbols* will move
   it from the starting to the finishing state.
    * Any sequence that does this is said to be *accepted* by the machine.
2. Or, you can think of the finite state machine as generating the
   sequence by outputting the symbols as it moves from state to state.
3. A finite state machine cannot recognise whether an arbitrary sequence
   is *palindromic*.
    1. Any finite state machine that you build will have a limit on the
       number of repeats it can recognize and so you can always find a
       palindromic sequence that it can't recognize.
4. A finite state machine cannot count; well it can up to a fixed *maximum*.
5. The type of sequence that can be recognised by a finite state machine is
   called a *regular sequence*.
    1. Yes, this is connected to the *regular expressions* available in
       so many programming languages.
6. It has rules of the form
    1. \\( [nonTerminal_1] \; \rightarrow \; symbol \; [nonTerminal_2] \\)
    2. \\( [nonTerminal_1] \; \rightarrow \; symbol \\)
7. One step more powerful on the *Chomsky hierarchy* is the *Push Down Machine*
    1. This is a FSM with a LIFO stack
    2. On each transition the machine can pop/push a symbol on/off its stack
    3. Now it can detect palindromes
    4. A language corresponding to a *Push Down Machine* is a *Context Free
       Grammar*
8. The next step is *Context Sensitive* grammars
    9. Instead of a *stack*, this machine has a *tape* on which it stores
       the input symbols
    2. It can read/write the tape and move it left/right
    3. This is a *Turing Machine*

[ip fsm]: http://www.i-programmer.info/babbages-bag/223-finite-state-machines.html

# Sorting algorithms

## Insertion sort
**5/27/14**

### Properties

* A **stable** sort
* Efficient for *very* small data sets
* Faster than other O(n^2) algorithms (**selection** & **bubble** sort)
* **In-place**
* Efficient for data sets already nearly sorted

### How to do

1. Take `elem[1]`, if it's smaller than `elem[0]`, swap them
2. Take `elem[2]`, if it's smaller than `elem[0]`, move `elem[0:1]` over
   to the right, and put it at the front
3. Continue in this manner, moving along the array, putting each
   element in its proper place in relation to those elements previously seen

## Selection sort
**5/27/14**

### Properties

* Painfully **slow**, comfortingly **simple**
* Similar to **insertion sort**, but slower
* **In-place**

### How to

1. Scan the array for the smallest element, and put it in slot `0`
2. Scan the *rest* of the array for its smallest element, and put it in slot `1`
3. And so on.

## Bubble sort
**5/27/14**

* Repeatedly step through the list to be sorted, comparing each
  pair of adjacent items and swap them if they are in the wrong order
* Keep repeating this until no swaps are needed
* The algorithm gets its name from the way smaller elements "bubble"
  to the top of the list
* The *only* thing good about it is that it only requires one pass
  if the list is already sorted
* It is a **stable** sort and **in-place**


## Radix Sort
**5/27/14** [Radix sort on Wikipedia](http://en.wikipedia.org/wiki/Radix_sort)

* Sorts data with integer keys by grouping keys by the individual digits
  which share the same significant position and value.
* **In English**:
    1. Clump/group/bucket given integers by least/most significant digit
    2. Clump/group/bucket each of those by next least/most significant digit
    3. Repeat for a number of times equal to the length of the longest key
* Dates back to 1887
* Can be used for strings (because those can be rewritten as integers)
* Most significant digit (MSD) / Least significant digit (LSD) varieties

### Implementations

Gazillions of options

* Iterative version with Queues (3 pass)
* Recurse into the different buckets (can be done in parallel)
* In-place
* Stable version (with size *n* buffer)
* Hybrids -- e.g. switch to **insertion sort** when the buckets get small
* Incremental trie-based -- create a trie then do depth-first, in-order traversal

## Spaghetti Sort
**5/27/14** [Found on Wikipedia](http://en.wikipedia.org/wiki/Spaghetti_sort)

1. Gather all the spaghetti into a bundle
2. Put it vertically on the table and let all strands rest on the table
3. While (there is more spaghetti)
    1. Lower your hand slowly onto the spaghetti
    2. Pull out the first strand your hand touches

# Dynamic Programming

## Intro

1. It means *solving a problem via an **inductive step** (recursion)*
2. It is applicable to problems exhibiting
    1. **Overlapping subproblems** --- subproblems can be nested recursively
       into the entire problem; and when you recurse into another branch, you
       see the same subproblems you've already solved (e.g. Fibonacci)
        1. If there is no overlapping-ness of the subproblems, it's called
           **Divide & Conquer** and is *not Dynamic Programming*. This
           includes `mergesort` and `quicksort`.
    2. **Optimal substructure** --- when optimal solutions to subproblems can
       be combined into an optimal solution of the entire problem
3. Reduces complexity vs solving with naïve methods, e.g. depth-first-search
    1. Naive methods may solve the subproblems over-and-over, we want to
       prevent that
    2. Sometimes all that is required is **memo-ization** of the basic
       recursive solution, sometimes finding a dynamic programming algorithm
       for the problem is not so simple
4. Solve the subproblems, then combine them to reach the overall solution
5. *Greedy algorithms* (at each decision, pick the locally optimal choice) are
   faster, but not always optimal
6. Two general approaches
    1. **Top-down** --- direct implementation of the induction rule and
       memoization
    2. **Bottom-up** --- after finding induction rule, reformulate into a
       means of solving the subproblems *first* and combining them to solve
       bigger subproblems
        1. Often done by filling in a table

# Other algorithms

## Bloom Filter
See `Data Structures Notes.md`


# Vocab

* **Stable sort** -- preserves order of duplicate entries
