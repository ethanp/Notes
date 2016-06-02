latex input:		mmd-article-header
Title:		Math Notes
Author:		Ethan C. Petuchowski
Base Header Level:		1
latex mode:		memoir
Keywords:		Math, DSP, Digital Signal Processing, Fourier Transform
CSS:		http://fletcherpenney.net/css/document.css
xhtml header:		<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:			2014 Ethan C. Petuchowski
latex input:		mmd-natbib-plain
latex input:		mmd-article-begin-doc
latex footer:		mmd-memoir-footer

This document requires MathJax (and possibly
[`MultiMarkdown`](http://fletcherpenney.net)) to be viewed properly.

# Basics to know and tell #

### Common approximations ###

These work for small \\(x\\), they come from the Taylor series expansion.

\\[\frac{1}{1+x}=1-x+x^2-x^3+...\approx 1-x\\]

\\[\frac{1}{1-x}=1+x+x^2+x^3+...\approx 1+x\\]

# Probability & Statistics #

## Probability ##

### Introductory Vocabulary ###

* **Population** -- the complete set of items under consideration by a
  statistical analysis
* **Sample space** -- the set of possible outcomes
* **Simple random sample** -- each individual has the same probability of being
  chosen at any stage during the sampling process
  * Provides an *unbiased estimate* of the true population characteristics
* **Probability distribution** -- assigns a probability to each possible
  outcome of a random procedure
  * *Discrete* random variables -- **probability mass function**
  * *Continuous* random variables -- **probability density function**
  * ***Categorical* distribution**
* **Estimator** -- a rule for calculating an estimate of a given quantity based
  on observed data
  * There are *point* and *interval* estimators that yield a scalar and range
    respectively
  * Notation
    * \\(\theta\\) -- *parameter* being estimated
    * \\(\hat{\theta}\\) -- *estimator*
  * *Error* -- \\(e(x)=\hat{\theta}(x)-\theta\\)
  * **Bias** -- the difference between the estimator's *expected value* and the
    true value of the parameter being investigated, i.e.
    \\(E_\theta[\hat{\theta}]-\theta\\)
    * Sometimes a biased estimator is used *because* no unbiased estimator is
      known unless more assumptions are made about the population, or the
      relevant unbiased estimator may be too expensive to compute
    * An **unbiased** estimator's bias is *zero* for *all* values of parameter
      \\(\theta\\)
* **Stochastic|Random Process** -- a collection of *random variables*
  representing the evolution of a system of random values over time
  * Even if the initial condition is known, there are several directions in
    which the process may evolve
  * E.g. stock market, blood pressure, random walks, speech signals
* **Point process** -- a *random process* for which a realization of the
  process consists of a *set* of isolated *points* in time and/or space
  * For example, the occurrence of lightning strikes
  * **Poisson [point] process** -- the simplest and most common example of a
    point process
    * Important for *queueing theory*
      * E.g. model arrival times of customers to a store
    * Also can be used to model the locations of trees in a forrest
    * Each point is *[stochastically] independent* to all the other points
      * This means it is not a good fit for some modeling scenarios
		* Also, see the *Poisson distribution* section below

### Combinations (*n* choose *k*) ##

\\[{n\choose k}=\frac{n!}{k!(n-k)!}\\]

####Explanation ###

1. We know that \\(n!\\) is the number of *permutations* of *n* items
    1. I.e. the total number of unique *orderings*
    2. Because there are \\(n\\) options for the first slot, \\(n-1\\) for the
       second, and so on.
2. But if we are only "choosing" \\(k\\) items, so we can stop the factorial
   after computing the permutations of the first \\(k\\) items. This leaves us
   with \\(n\cdot(n-1)\cdot(n-2)\cdots (n-k+1)=\frac{n!}{(n-k)!}\\).
3. Now among these \\(k\\) items, we don't actually care about all the
   different permutations, so we can cancel them out by dividing by
   \\(k!\\), leaving us with the final formula.

### Distributions ###
 
#### Binomial Distribution ####

* Describes the probability of the sum of *n Bernoulli trials* with probability
  *p*
#### Poisson Distribution ####

* The probability that N = n is given by --
  \\(P\{N=n\}=\frac{\lambda^n}{n!}e^{-\lambda}\\), where \\(\lambda\\) is the
  single *Poisson parameter* defining this Poisson distribution
* It is the limiting case of the *binomial distribution*, such that
  \\(\lambda=np\\)

#### Exponential Distribution ####

* Describes the time between events in a _Poisson process_
* The PDF is \\(f(x;\lambda)=\lambda e^{-\lambda x}\\) for nonnegative \\(x\\),
  and zero otherwise
* The CDF is \\(F(x;\lambda)=1-e^{-\lambda x}\\) for nonnegative \\(x\\), and
  zero otherwise
* The mean and variance are \\(\frac{1}{\lambda},\frac{1}{\lambda^{2}}\\)

#### Log-Normal Distribution

These notes are from the Wikipedia article

A continuous probability distribution of a random variable whose logarithm is
normally distributed. Thus, if the random variable X is log-normally
distributed, then \\(Y = \ln(X)\\) has a normal distribution. Likewise, if Y
has a normal distribution, then \\(X = \exp(Y)\\) has a log-normal
distribution.

Many natural growth processes are driven by the accumulation of many small
percentage changes. These become additive on a log scale.

A few examples

* Length of internet discussion comments
* Length of time people spend reading online articles
* Time to repair a "maintainable system"

## Statistics #


### Markov Models

#### Mathematical Monk Chapter 14

1. **Markov models -- "the future is independent of the past, given the
   present"**
    1. This is *true* in the Newtonian physics view of the world if you think
       about it
    2. *Except* that we can't expect to perfectly understand the current state
       of the system -- i.e. there is "hidden" information
2. The canonical probabilistic model for temporal or sequential data
3. Comes from Russian mathematician Andrey Markov's work in "stochastic
   processes" through the start of the 1900s
4. Useful for weather, finance, language, music, etc.
    1. Useful when the data has *periodicity* (e.g. yearly cycles)
    2. Useful for finding a robot given noisy sensor data
    3. Good for "fill in the blank" when a sentence is missing a word
5. We assume discrete time and space
6. We can't say the data points are iid because nearby points are clearly more
   closely related
7. Our "first order" singly-linked simple "Markov Chain" can be also written
   \\(p(x_t | x_1,...,x_{t-1}) = p(x_t | x_{t-1})\\)
8. This means \\(p(x_1,...,x_n)=p(x_1)p(x_2|x_1)\cdots p(x_n|x_{n-1})\\)
9. In the graphical model for a "second order" Markov chain, each node is
   pointed to by the previous *two* nodes
10. A continuous-time MC is "Brownian motion" or a "Poisson process"
11. **Hidden Markov Models** model the fact that the current state of the world
    contains information hiden to our understanding of the state
12. HMMs are popular because they work well because they are simple enough
    that you can accurately generate parameters, but complex enough to handle
    real world applications
13. It's based on the "Trellis diagram" (graphical model for HMM), in which
    you observe X's, which are each pointed to by corresponding Z's, and Z's
    form a first-order Markov chain
14. The video series itself is much better than my notes of course...
15. We must specify parameters for the HMM
    1. Transition probabilities between hidden states
    2. Emission probabilities -- *pdf*'s or *pmf*'s on *X* given each hidden
       state value *Z*
    3. Initial distribution -- probability of having each *Z* as the initial
       state
16. The *Forward-Backward Algorithm* will compute \\(p(z_k|x_{1:n})\\); it is
    composed of:
    1. Forward algorithm computes \\(p(z_k,x_{1:k})\\)
    2. Backward algorithm computes \\(p(x_{(k+1):n}|z_k)\\)
17. *Viterbi Algorithm* computes \\(z^*=argmax_{z} p(z|x)\\)
18. These algorithms are efficient because they are examples of Dynamic
    Programming, meaning each level of the recursive computation relies on
    cmputations already performed for preceding levels


### Bayesian Inference ###

Use **Bayes' Rule** to update the probability for a hypothesis as evidence is
acquired.

\\[P[H|E]=\frac{P[E|H]\cdot P[H]}{P[E]}\\]

In my own words: > The *posterior probability* that the *hypothesis* \\(H\\) is
*true* *given* the *evidence* \\(E\\), is *equal* to the *probability* of the
*evidence* *given* the *hypothesis* is *true* *w.r.t.* seeing that *evidence*
under *all* circumstances, multiplied by the *prior* ("overall") probability of
the *hypothesis* being *true* in general.

Particularly important in the *dynamic analysis* of a *sequence* of data.

### Markov Chain Monte Carlo ###

A *class* of *algorithms* for *sampling* from a *probability distribution*
based on constructing a *Markov chain* that has the desired distribution as its
*equilibrium distribution*. We can then use the *state* of the chain after a
number of *steps* as a *sample* from the desired distribution. The point is
generally to calculate a *numerical approximation* of a *multi-dimensional
integral*.

Examples include *Gibbs sampling*, which requires all the *conditional
distributions* of the target distribution to be sampled exactly.

### Covariance Matrix ##
#### How to Compute It ###

\\[X^TX\\]

#### Why It Matters ###

Used in **Principal Component Analysis** (PCA), a technique described in Andrew
Ng's *Machine Learning* course on Coursera, for reducing the *dimensionality*
of a *dataset*. One might want to do this for 2 reasons:

1. As a form of *lossy compression*
2. To produce *visualizations* of the data in 1, 2, or 3D
3. To *reduce computation time*

#### Covariance ###

"A measure of how much two random variables change together."
[[Wikipedia][WCov]]

\\[\sigma_{XY}=cov(X,Y)=E[(X-\mu_X)(Y-\mu_Y)]\\]
\\[=E[XY]-\mu_X\mu_Y\\]
\\[=E[XY]-E[X]E[Y]\\]
\\[=\sum_{i=1}^{N}{\frac{(x_i-\bar{x})(y_i-\bar{y})}{N}}\\]

Note
\\[cov(X,X)=E[X^2]-E[X]^2=\sigma_x^2\\]
At first glance, it behaves like the slope line of a linear regression: two
positively correlated variables have a positive covariance, and same for
negative. However, the *magnitude* of the covariance is different, "Notably,
correlation is dimensionless while covariance is in units obtained by
multiplying the units of the two variables" (Wiki).

**TODO...heh**

[WCov]: http://en.wikipedia.org/wiki/Covariance

### Ordinary Least Squares ##

#### Finding the Intercept and the Slope ###

[On Wikipedia](http://en.wikipedia.org/wiki/Simple_linear_regression)

We're trying to find the equation of the straight line

\\[y = \alpha + \beta x \\]

which would provide a line that minimizes the sum of squared residuals of the
linear regression model.

We can use

\\[\hat{\beta} = \frac{\mathrm{Cov}[x, y]}{\mathrm{Var}[x]} = r_{xy} \frac{s_y}{s_x}\\]

\\[\hat{\alpha} = \bar{y} - \hat{\beta} \bar{x}\\]

* The line always passes through \\((\bar{x},\bar{y})\\)
* If you normalize the data, the slope is \\(Cor(Y,X)\\)

##### Without the Intercept Term ####

\\[y = \beta x \\]
\\[\hat{\beta} = \frac{\bar{xy}}{x^2}\\]

### Similarity Measures ##
Sources:

* [Random blog on Collaborative Filtering with Mahout](http://blog.comsysto.com/2013/04/03/background-of-collaborative-filtering-with-mahout/)

#### Real Valued Attributes

##### Pearson Similarity ####

* [Wikipedia](http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient)

\\[\rho_{X,Y}=\frac{\mathrm{cov}(X,Y)}{\sigma_X \sigma_Y}=\frac{E[(X-\mu_X)(Y-\mu_Y)]}{\sigma_X \sigma_Y}\\]

##### Euclidean Distance ####

* [Wikipedia: Norm](http://en.wikipedia.org/wiki/Norm_(mathematics)#Euclidean_norm)

\\[ ||\textbf{x}|| := \sqrt{x^2_1 + \cdots + x^2_n} \\]

Or more generally, the *p*-norm is

\\[ ||\textbf{x}|| := (\sum_{i=1}^{n}|x_i|^p)^{1/p} \\]

Which means the Euclidean norm \\(\equiv\\) the \\(l_2\\) norm.

#### Binary Attributes ###

* [Wikipedia](http://en.wikipedia.org/wiki/Tanimoto_coefficient#Tanimoto_coefficient_.28extended_Jaccard_coefficient.29)

##### Jaccard index/similarity coefficient ####

\\[J(A,B)=\frac{|A\cap{B}|}{|A\cup{B}|}\\]


Now, letting \\(M_{AB}\\) be the number of data points where binary attribute
a=A and b=B, we compute the **Jaccard similarity coefficient** as

\\[J=\frac{M_{11}}{M_{01}+M_{10}+M_{11}}\\]

And the **Jaccard distance** as

\\[d_J=\frac{M_{01}+M_{10}}{M_{01}+M_{10}+M_{11}}\\]


# Digital Signal Processing

## Total Harmonic Distortion ##

#### 4/17/14

[Wikipedia](http://en.wikipedia.org/wiki/Total_harmonic_distortion)

The total harmonic distortion, or THD, of a signal is a measurement of the
harmonic distortion present and is defined as **the ratio of the sum of the
powers of all harmonic components to the power of the fundamental frequency**.
In audio systems, lower THD means the components in a loudspeaker, amplifier or
microphone or other equipment produce a more accurate reproduction by reducing
harmonics added by electronics and audio media.

## Fourier Transform ##

Notes from Brian Douglas's Khan Academy-style  YouTube Videos:

* [Part 1](https://www.youtube.com/watch?v=1JnayXHhjlg)
* [Part 2](https://www.youtube.com/watch?v=kKu6JDqNma8)

#### Turns a function of *time* into a function of *frequency.* ####

Any function in the time-domain, can be represented as a sum of sinusoids,
where each has a different amplitude, frequency, and phase. This is that thing
from Diff. EQ class. So that's all we're doing.

 \\[\mathrm{Frequency}\;\; \nu_{Hz} := \frac{\omega}{2\pi}[Hz]  \\]

So a Fourier Transform maps you from the Time domain \\(T\\), to the Frequency
domain \\(N\\):

\\[FT:\; f(t) \rightarrow f(\nu) \\]

Here it is:

\\[FT\{f(x)\}:=\frac{1}{\sqrt{2\pi}}\int_{-\infty}^{\infty}\!f(x)e^{-iwx}dx\\]

And the inverse:

\\[FT^{-1}\{FT\{f(x)\}\} := \frac{1}{\sqrt{2\pi}}\int_{-\infty}^{\infty}\!FT\{f(x)\}e^{iwx}dx\\]



### Useful Tidbits

#### A bit of Nomenclature

* A **signal** and a **function** are the *same thing*
* **Analysis** -- break a signal into simpler component parts
* **Synthesis** -- reassemble a signal from its constituent parts
* **Complex Sinusoids** -- Phase and amplitude can be described by a single
  complex number. Plotting that point on a real-imaginary plane, the amplitude
  is the distance of the point from the origin. The phase is the angle of that
  line off the positive real line, so a frequency with no phase shift is on the
  real line, where the value *is* the amplitude. Otherwise we have to do some
  trigonometry to go convert between the number and the phase & amplitude.
* **Frequency spectrum** -- representation of a signal in the *frequency
  domain*

#### Euler's Formula(s) ####


\\[e^{ix} = \cos x + i \sin x\\]
\\[e^{-ix} = \cos x - i \sin x\\]


### [Discrete Fourier Transform](http://en.wikipedia.org/wiki/Discrete_Fourier_transform) ##

The following summary is brilliant:

> Converts a finite list of equally spaced samples of a function into the list
> of coefficients of a finite combination of *complex sinusoids* [see
> definition above], ordered by their frequencies, that has those same sample
> values. It can be said to convert the sampled function from its original
> domain (often time or position along a line) to the frequency domain.

### [Fast Fourier Transform](Http://en.wikipedia.org/Wiki/Fast_Fourier_Transform) ###

Using the definition of a DFT, the computation takes \\(O(n^2)\\) operations.
An FFT can compute the same DFT in only \\(O(n\log n)\\) operations. It is an
approximation.

# Set Theory
##### References
* Wikipedia

## Vocab

### Binary Relation
Wikipedia:

A **binary relation** on a set \\(A\\) is a collection of *ordered pairs* of
elements of \\(A\\). In other words it is a *subset* of the *Cartesian product*
\\(A^2=A\times A\\). More generally, a binary relation between two sets \\(A\\)
and \\(B\\) is a subset of \\(A\times B\\).

A binary relation is the special case \\(n = 2\\) of an \\(n\\)-ary relation
\\(R \subseteq A_1 \times \cdots \times A_n\\), that is, a set of
\\(n\\)-tuples where the \\(j^{th}\\) component of each \\(n\\)-tuple is taken
from the \\(j^{th}\\) domain \\(A_j\\) of the relation.

### Transitive Closure

Wikipedia (this is surprisingly clear and succint):

In mathematics, the **transitive closure** of a *binary relation* \\(R\\) on a
set \\(X\\) is the *transitive relation* \\(R^+\\) on set \\(X\\) such that
\\(R^+\\) contains \\(R\\) and \\(R^+\\) is minimal (Lidl and Pilz 1998:337).
If the binary relation *itself* is *transitive*, then the transitive closure is
that same binary relation (i.e. \\(R^+ := R\\)); otherwise, the transitive
closure is a different relation.

For example, if \\(X\\) is a set of airports and \\(x R y\\) means "there is a
direct flight from airport \\(x\\) to airport \\(y\\)", then the transitive
closure of \\(R\\) on \\(X\\) is the relation \\(R^+\\): "it is possible to fly
from \\(x\\) to \\(y\\) in one or more flights." [Or perhaps, "\\(y\\) is
*reachable* from \\(x\\) by plane."]
