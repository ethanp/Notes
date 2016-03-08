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

## Automata

* __Finite-state machine (FSM)__ -- abstract machine that can be in one of a
  finite number of _states_
    * Can only be in one state at a time, but can _transition_ to other states
    * A _particular_ FSM is _defined_ by
        * A list of states
        * The triggering condition for each transation
* __Deterministic finite automaton (DFA)__ -- an FSM that _accepts/rejects_
  finite strings of symbols, and can only produce a _unique_ run for each input
  string, meaning:
    1. Each of its transitions is uniquely determined by its source state and
       input symbol
    2. Reading an input symbol is required for each state transition
* __Nondeterministic finite automaton (NFA)__ -- needn't obey the restriction
  (1 & 2) listed above for the _DFA_
    * I.e. upon receiving an input symbol in a particular state, there may be
      multiple possible states to which it could transition
    * It _accepts_ its input _iff_ there is _some_ set of transitions on that
      input which will lead it to end in an accepting state
    * Can be used as a formal model for __regular expressions__
    * The _empty-string_ is generally represented with a "\\(\varepsilon\\)"
* _Diagram representation_
    * __States__ are circles
    * __Start states__ are pointed to by an arrow with no source
    * __Transition triggers__ are labels on the arrows
    * __Accepting states__ are double-circles

## Language Theory

* A __regular language__ is a _formal language_ that can be expressed using a
  _regular expression_ (defined in the _Automata_ section above)
* The language classes of Chomsky's hierarchy are (in increasing generality)
    1. Regular
    2. Context-free
    3. Context-sensitive
    4. Recursively enumerable

## Turing Machines

> "A hypothetical device that manipulates symbols on an [infinite] strip of
> tape according to a table of rules. Despite its simplicity, a Turing machine
> can be adapted to simulate the logic of any computer algorithm, and is
> particularly useful in explaining the functions of a CPU inside a computer."
> -- Wikipedia

* At any moment there is only one "scanned symbol" from the tape "in the
  machine" or "under the **head**"
    * the machine can alter alters the tape based upon the value of this symbol
* Other symbols on the tape can_not_ affect the machine's behavior
* A **state register** stores which one of some finite number of states the
  Turing machine is in
* A finite **table** of instructions maps *(state, symbol)* pairs to performing
  some combination of the following actions
    * _Erase_ or _write_ a symbol; _then_
    * Move the head *k* values *left* or *right*; _then_
    * Assume a new state \\(q_i\\)
* The only symbol allowed to occur on the tape infinitely often at any step
  during the computation is the *blank symbol* \\(b\in\Gamma\\)
* If the machine meets a symbol at a state for which its transition function
  \\(\delta\\) has no operation defined, it *halts*
* There may be a set of *final* or *accepting* states \\(F\\), and if the
  machine ends up in one of thse, the contents were *accepted* by the given
  machine \\(M\\)

> Operation is fully determined by a finite set of elementary instructions such
> as "in state 42, if the symbol seen is 0, write a 1; if the symbol seen is 1,
> change into state 17; in state 17, if the symbol seen is 0, write a 1 and
> change to state 6;" etc. -- Wikipedia

* The "machine" was invented in 1936 by (24 year old) Alan Turing
* The symbols on the tape come from an arbitrary language (viz. not necessarily
  binary)
* Multi-tape and multi-track Turing machines are *equivalent*

### Universal Turing Machine

* **A Turing machine that is able to simulate any other Turing machine**
* It reads the description (transition function) of another machine \\(M\\) as
  input, then \\(M\\)'s input

## Algorithmic Complexity

Ref: [StOve](http://stackoverflow.com/questions/1857244/)

* **P** -- *decision* problem that can be *solved* in polynomial time
	* E.g. check whether a graph can be two colored -- greedy algorithm works
* **NP** -- *decision* problem where a "yes" result can be *verified* in polynomial time
	* E.g. prime factorization (do the prime factors multiply to the number?)
* **NP-Complete** -- NP problem `x` s.t. any NP problem `y` can be *reduced* to `x` in polynomial time
	* So if we can solve `x` quickly, we can also solve `y` quickly
	* Example: 3-SAT -- find a satisfying interpretation for a conjunction of 3-clause conjunctions
* **NP-Hard** -- *any* problem `x` s.t. any NP-complete problem `y` can be *reduced* to `x` in polynomial time
	* The halting problem: given a program `P` on input `I`, will it halt?

### The Master Theorem

> The master theorem provides a solution in asymptotic terms (using Big O
> notation) for recurrence relations of types that occur in the analysis of
> many divide and conquer algorithms. -- Wikipedia

The master theorem concerns recurrence relations of the form:

\\[T(n)=aT(\frac{n}{b})+f(n)\;\mathrm{where}\,a\leq1,b>1\\]

##### Wherein

* n -- size of the problem
* a -- number of subproblems in the recursion
* n/b -- size of each subproblem (all are assumed to be roughly the same size)
* f(n) -- the cost of the work done outside the recursive calls
    * Includes the cost of dividing the problem and merging the solutions

#### Case 1

\\[\mathrm{If}\;\;f(n)\in O(n^c)\;\mathrm{where}\;c\lt\log_{b}a\\]
\\[\mathrm{Then}\;\;T(n)\in\Theta(n^{\log_{b}a})\\]

#### Case 2

\\[\mathrm{If}\;\;\exists k\geq 0\;\mathrm{s.t.}\;f(n)=\Theta(n^{c}\log^{k}n)\;\mathrm{where}\;c=\log_{b}a\\]
\\[\mathrm{Then}\;\;T(n)=\Theta(n^{c}\log^{k+1}n)\\]

#### Case 3

\\[\mathrm{If}\;\;f(n)=\Omega(n^c)\;\mathrm{where}\;c>\log_{b}a\;\mathrm{and}\;\exists k\lt 1,n_{large}\;\mathrm{s.t.}\;af(\frac{n}{b})\leq kf(n)\\]
\\[\mathrm{Then}\;\;T(n)=\Theta(f(n))\\]


## Graphs

### Topological Sorting

A topological sorting of a DAG is a linear ordering of vertices such that for
every directed edge `uv`, vertex `u` comes before `v` in the ordering. This is
not possible for non-DAGs.

E.g. for the graph

```
6
6
5 2
5 0
4 0
4 1
2 3
3 1
```
Among the possible sortings, we have
```
5 4 2 3 1 0
4 5 2 3 1 0
```

The basic _algorithm_ looks very similar to DFS. 

DFS looks roughly like this (when there is not just one "root" node)

```python
class Graph(object):
    # ...
    def disconnectedDFS(self):
        self.visited = [False for node in self.nodes]
        for node in self.nodes:
            if not self.visited[node.id]:
                self.dfs(node)

    def dfs(self, node):
        if not self.visited[node.id]:
            self.visited[node.id] = True
            print node.data
            for a in node.adj_list:
                dfs(a)
```

In contrast, Topological Sorting looks like this

```python
class DAG(Graph):
    # ...
    def disconnectedTS(self):
        self.stack = []
        self.visited = [False for node in self.nodes]
        for node in self.nodes:
            if not self.visited[node.id]:
                self.tsUtil(node)
        while len(self.stack) > 0:
            print self.stack.pop()

    def tsUtil(self, node):
        self.visited[node.id] = True
        for adj in node.adj_list:
            if not self.visited[adj.id]:
                self.tsUtil(adj)
        self.stack.push(node)
```

##### Refs

1. [geeksforgeeks](http://www.geeksforgeeks.org/topological-sorting/)

#### Use Cases

I just thought of this use-case, which is for dependency-management for a
package manager. Say we want to download a particular package, but we don't
want to download the package until we've downloaded all of its dependencies
(wait...actually I don't see why that'd be a necessary requirement...) then we
need to download them in topologically sorted order. I guess the only reason
that'd be important is because if the depended-upon package was un-downloadable
for some reason than we would be able to cancel before travelling further down
the DAG of dependencies.

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

## Union Find
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

### String Search with KMP (Knuth Morris Pratt)

In this problem, we're looking for an instance of a string `needle` in a larger
string `haystack`. The key here, is that as we inch-worm along through the
`haystack`, we use a precomputed array to figure out how much to inch forward
whenever there's a mismatch.

The explanation in [this video][kmp vid] is excellent. _After_ watching that
and reading the pseudocode below, the explanation in "Compilers" made a lot of
sense (pg. 136-138). A proof-heavy explanation (that I haven't read) is also
available in CLRS.

[kmp vid]: https://www.youtube.com/watch?v=GTJr8OvyEVQ

#### Computing the table

* __Proper prefix__ -- a prefix that is _not_ the _entire_ string

The table tells us, for each position in the `needle`, the longest _proper
prefix_ that is also a suffix of the `needle` _up to this position_. It is
calculated in time \\(O(|needle|)\\)

```python
def computeTable(needle):
    T = [0] * len(needle)   # alloc table
    T[0] = -1   # fixed starting values
    T[1] = 0    # "     "        "
    pos = 2     # where we are in the needle
    ctr = 0     # number of prefix-matching letters seen so-far
    while pos < len(needle):
        if needle[pos-1] == needle[ctr]:
            # expand size of prefix-matching-suffix
            ctr += 1
            T[pos] = ctr
            pos += 1
        elif ctr > 0:
            # We _had_ a prefix-matching-suffix, now it broke.
            # Check if we can recover without starting all over.
            ctr = T[ctr]
        else:
            # no prefix matches any suffix
            T[pos] = 0
            pos += 1
    return T

>>> computeTable('asdf')
    # a  s  d  f
 => [-1, 0, 0, 0]
>>> computeTable('aaasdf')
    # a  a  a  s  d  f
 => [-1, 0, 1, 2, 0, 0]
>>> computeTable('abcdaababcabcdef')
    # a  b  c  d  a  a  b  a  b  c  a  b  c  d  e  f
 => [-1, 0, 0, 0, 0, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 0]
```

Basically the value in the table at the index *after* the match indicates *one
more* than the number of matches seen so far. Nah mean.

#### Performing the search

Let `m` be the location of the start of the possible match in `haystack`. Let
`i` be the index of the character in the `needle` against which we're currently
checking. As long as the needle is matching the haystack, we keep checking and
incrementing `i`, like the (brute force) _naïve algorithm_. However, when we
find a mismatch, we do the following maneuver

```python
if T[i] > -1:   
    # we've matched beyond the 1st character of 'needle'
    # so maybe we can scoot extra inches
    m += i - T[i]
    i = T[i]
else:
    # we're still looking to match the 1st character (i == 0)
    # so we just inch along
    m += 1
```

In other words, in the fast-case, we move to the next location for which we
know based on the shape of the `needle` that it repeats its initial substring,
so we can move to the next place where that much substring is matched.


## Hashing

### Checksums

* The goal is to provide __integrity__ against corruption or tampering
* Good algorithms produce very different outputs for slightly different inputs
* It's related to cryptographic hashing, but the goal is to be _fast_ to compute
* Simple schemes involve the _check digit_, like we saw in Intro CS for ISBN,
  and the _parity bit_ (which is similar) in which we determine whether the count of 1's in our binary string is even (0) or odd (1)
* __Error correcting codes__, aka forward error correcting, aka channel coding,
  is a similar technique, but not only provides integrity, but can _fix_ a
  small amount of corruption (with high probability?)
* Logically these tend to involve a rolling sum, a modulo, and some XORing
* In code, one tries to avoid using modulo so much because it is slow
* In reality, one doesn't implement these, one finds time-tested
  implementations

### Building a hash-table of strings

**4/27/15**

From *The Algorithm Design Manual*.

A reasonable hashing algorithms for strings is

\\[H(S)=(\sum_{i=1}^{|S|}{\alpha^{|S|-i} S_i}) \,\%\,v\\]

In which you map each string to a unique integer by treating each character as
a "digit" in a base-\\(\alpha\\) number system. Then you stick the string in
slot \\(H(S)\\) of the underlying array. \\(v\\) should be a large prime not
too close to \\(2^{n}-1\\) so that hash values are fairly uniformly
distributed. The [code][gfgrk] I looked at just uses 101 for \\(v\\).

### String Search with Rabin-Karp

To find a pattern \\(p\\) in a a text \\(t\\), where \\(n=|t|,m=|p|\\)

We calculate the hash of \\(p\\) with the simple base-conversion hashing
algorithm above ("with a random \\(v\\)" [not sure why *random* would be
beneficial, the [code][gfgrk] I looked at just uses 101]), then slide along
\\(t\\), hashing as we go. Calculating the hash of each new letter given the
previous hash can be done in \\(O(1)\\) time if we note that our hash algorithm
"rolls" in the following manner:

\\[H(S,j+1)=\alpha(H(S,j)-\alpha^{m-1}char(s_j))+char(s_j+m)\\]

So now we just have to worry about hash collisions (which can be resolved in
\\(O(m)\\) via actual `char` comparisons), but in sum we've solved the problem
in *expected-time* \\(O(m+n)\\).

[gfgrk]: http://www.geeksforgeeks.org/searching-for-patterns-set-3-rabin-karp-algorithm/

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

### Pros

1. **Stable**
2. **In-place**
3. Efficient for data sets already nearly sorted
4. Very efficient for small data sets
    * Ie. we can find some \\(k\\) s.t. for \\(i < k\\), insertion sort is
      *faster* than quicksort
5. Faster than other \\(O(n^2)\\) algorithms 
    * viz. selection & bubble sort

### Cons

1. It is still \\(O(n^2)\\)

### How to do

1. Take `elem[1]`, if it's smaller than `elem[0]`, swap them
2. Take `elem[2]`, if it's smaller than `elem[0]`, move `elem[0:1]` over
   to the right, and put it at the front
3. Continue in this manner, moving along the array, putting each
   element in its proper place in relation to those elements previously seen

## Selection sort
**5/27/14**

### Pros
1. __Simple__
2. **In-place**

### Cons

1. **Slow** (painfully so)

### How to

1. Scan the array for the smallest element, and put it in slot `0`
2. Scan the *rest* of the array for its smallest element, and put it in slot
   `1`
3. And so on.

#### Note

This algorithm is very similar to **insertion sort**, except that instead of
_inserting_ `a[i]` into `a[1:i]`, we _select_ the right `a[i]` from `a[i:n]`.

## Quicksort

### Pros

1. \\(O(n \log n )\\)
2. Very fast in the real world
3. __In-place__

### Cons

1. \\(O(n^2)\\) in the worst case
    * This happens when the pivot is the greatest or least element in each
      round of the partition
2. Extra stack frames from the recursion?
3. Not as fast as insertion sort for small number of elements

### How to

#### Partition

1. Select a `pivot`
    * There are many way we might do this
        1. The middle element -- better on (at-least) partially-sorted inputs?
        2. Randomly -- decreases chances of worst-case?
        3. Median of medians -- what does that mean?
2. Move it to the end
3. Make it so that all elements of `set1` containing those `e < pivot` are
   _before_ all elements of `set2` containing those `e ≥ pivot`
4. Recursively quicksort `set1` and `set2` separately

## Bubble sort
**5/27/14**

### Pros

1. Only requires one pass if the list is already sorted
2. **Stable**
3. **In-place**

### Cons

1. Really, really slow.

### How To

1. Repeatedly step through the list to be sorted, comparing each
  pair of adjacent items and swap them if they are in the wrong order
2. Keep repeating this until no swaps are needed

#### Note
The algorithm gets its name from the way smaller elements "bubble" to the top
of the list

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
* Incremental trie-based -- create a trie then do depth-first, in-order
  traversal

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

## Euclid's algorithm

(2.3+ kya!)

Computes the greatest common divisor of two nonnegative integers

```scala
@tailrec
def gcd(int p, int q): Int = {
    if (q == 0) p 
    else gcd(q, p % q)
}
```

# Vocab

* **Stable sort** -- preserves order of duplicate entries
