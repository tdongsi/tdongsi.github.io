---
layout: post
title: "Rabin-Miller primality test"
date: 2016-04-20 22:07:17 -0700
comments: true
categories: 
- Algorithm
- Python
- Math
---

In Qualification Round of Google Code Jam 2016, there is an interesting [Coin Jam problem](https://code.google.com/codejam/contest/6254486/dashboard#s=p2).
The summarized problem statement is as follows:

{% blockquote %}
A jamcoin is a string of N ≥ 2 digits with the following properties:

1) Every digit is either 0 or 1.
2) The first digit is 1 and the last digit is 1.
3) If you interpret the string in any base between 2 and 10, inclusive, the resulting number is not prime.

Can you produce J different jamcoins of length N, along with proof that they are legitimate?

For example, for the jamcoin 1001, a possible set of nontrivial divisors for the base 2 through 10 interpretations of the jamcoin would be: 3, 7, 5, 6, 31, 8, 27, 5, and 77, respectively.
{% endblockquote %}

The name "jamcoin" is probably a play on Bitcoin, since it deals with prime/composite numbers, a topic commonly found in cryptography.
In this problem, we apparently need to determine lots of large numbers (32 digits for Large dataset) if they are composite numbers.

The very first idea, building a sieve of primes for up to 10^16 for trial division, seems not feasible for this problem since it will take lots of time and space (e.g., $\mathcal{O}(n\log{}n \log{}\log{}n)$ and $\mathcal{O}(n)$ for [sieve of Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes), respectively).

Note that we don't need to find all but only J of those jamcoins.
Therefore, we can keep iterating over all possible "jam coins" to find the first J numbers that satisfy the conditions.
To quickly determine if a large number is a composite/prime number, we can use Rabin-Miller primality test.
For reference, the Rabin-Miller primality test is based on the following [theorem](http://mathworld.wolfram.com/Rabin-MillerStrongPseudoprimeTest.html): 

* If p is a prime, let s be such that $p-1 = 2^{s}d$ and $d$ is odd. Then for any $1 \leq n \leq p-1$, one of two things happens:

<p><span class="math display">\[\begin{align}
&amp; n^d = 1 \mod p \mbox{, or} \\
&amp; n^{2^j d} = -1 \mod p \mbox{ for some } 0 \leq j &lt; s.
\end{align}\]</span></p>

In Rabin-Miller test, we pick $k$ random samples of $n$ in the interval $1 \leq n \leq p-1$.
If p is not a prime, then it is at least a 3/4 chance that a randomly chosen $n$ will be a fail.
For large $k$ independent tests, the probability that it passes all trials is (1/4)^k ~ 0.

The test is very fast, with runtime complexity of $k \log{}^3 n$ where k is the trial number.
Since we looks for composite numbers, this algorithm is even better-suited: even if a number passes all Rabin-Miller trials, we are still NOT sure if it is a prime.
However, if a number fails one of Rabin-Miller trial, we are sure that it is a composite number.

Implementation of this algorithm in different languages can be found on the web, such as [here](https://en.wikibooks.org/wiki/Algorithm_Implementation/Mathematics/Primality_Testing).
I re-implemented this algorithm in Python (shown below) since 1) it is simple enough (just slightly more complex than Euclid's `gcd` algorithm), and 2) I want to avoid disqualification from Google Code Jam for plagiarism. 

{% codeblock lang:python My implementation of Rabin-Miller test %} 
import random

def decompose(num):
    """ Decompose num = 2**exp * d where d is odd.

    :param num: the input number.
    :return: (exp, d) where num = 2**exp * d
    """
    exp = 0
    while num & 1 == 0:  # check num % 2 == 0 but probably faster
        num >>= 1
        exp += 1
    return exp, num

def is_pseudo_prime(prime, trial=10):
    """ Rabin Miller test of primality.

    :param prime: the input number.
    :param trial: Number of Rabin-Miller trial.
    :return: True if all trials passed, False if not.
    """

    # small primes < 100
    SMALL_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
                    43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    def rabin_miller_trial(num):
        """ Check if prime pass the Rabin-Miller trial.

        :param num: a random "witness" of primality.

        :return: True if composite, False if probably prime.
        """
        num = pow(num, remainder, prime)

        # For first iteration, 1 or -1 remainder implies prime
        if num == 1 or num == prime - 1:
            return False

        # For next iterations, -1 implies prime, 1 implies composite
        for _ in xrange(exponent):
            num = pow(num, 2, prime)
            if num == prime - 1:
                return False

        return True

    # Labor saving steps
    if prime < 2:
        return False
    for p in SMALL_PRIMES:
        if p * p > prime:
            return True
        if prime % p == 0:
            return False

    # Starting Rabin-Miller algorithm
    exponent, remainder = decompose(prime - 1)

    for _ in xrange(trial):
        num = random.randint(2, prime - 2)
        if rabin_miller_trial(num):
            return False

    return True
{% endcodeblock %}

Some notes about this implementation:

* Because the function `rabin_miller_trial` is unlikely reused anywhere else, it is nested inside `is_pseudo_prime` to keep its function signature simple, intuitive.
* Use `pow(x, y, z)` in Python to compute more efficiently than `(x ** y % z)`.
* `random.randint(2, prime - 2)` is used since it is useless to pick `1` and `p-1` and trials would be wasted.
* Labor saving steps: we first test for divisibility by small primes that are less than 100 before starting Rabin-Miller trials.

Going back to the Coin Jam problem, note that the problem requires us not only to check if numbers are composite but also find any non-trivial factor for those numbers.
Fortunately, as explained in [Wikipedia](https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test), we can modify the Rabin-Miller test to add greatest common divisor `gcd` calculations to find a factor of p with minimal additional computational cost.
The modified Rabin-Miller for finding factor of composite numbers is shown below.

{% codeblock lang:python Modified Rabin-Miller test for finding a factor %}
import fractions
import random

def find_factor(prime, trial=100):
    """ Modify Rabin Miller test of primality to find factor of composite.

    :param prime: the input number.
    :param trial: Number of Rabin-Miller trials.
    :return: 1 if prime (all trials passed), > 1 if composite.
    """

    # small primes < 100
    SMALL_PRIMES = [ 2,   3,   5,   7,  11,  13,  17,  19,  23,  29,  31,  37,  41,
                  43,  47,  53,  59,  61,  67,  71,  73,  79,  83,  89,  97, 101]

    def rabin_miller_trial(num):
        """ Find factor based on the Rabin-Miller trial.

        :param num: a random "witness" of primality.

        :return: > 1 if composite, 1 if probably prime.
        """
        num = pow(num, remainder, prime)

        # For first iteration, 1 or -1 remainder implies prime
        if num == 1 or num == prime - 1:
            return 1
        else:
            gcd = fractions.gcd(num-1, prime)
            if gcd > 1:
                return gcd

        # For next iterations, -1 implies prime, 1 implies composite
        for _ in xrange(exponent):
            num = pow(num, 2, prime)
            if num == prime - 1:
                return 1
            else:
                gcd = fractions.gcd(num-1, prime)
                if gcd > 1:
                    return gcd

        # It is a composite, but could not find a factor
        return -1

    # Labor saving steps
    if prime < 2:
        raise ValueError("Unexpected input")
    for p in SMALL_PRIMES:
        if p * p > prime:
            return 1
        if prime % p == 0:
            return p

    # Starting Rabin-Miller algorithm
    exponent, remainder = decompose(prime - 1)

    for _ in xrange(trial):
        num = random.randint(2, prime - 2)
        factor = rabin_miller_trial(num)
        if factor > 1:
            return factor

    return 1
{% endcodeblock %}

The final solution to the problem, using the modified Rabin-Miller test above, can be found in this [file](https://github.com/tdongsi/python/blob/master/CodeJam/codejam/y2016/codejam.py) (search for CoinJam class).
Note that the [suggested solution](https://code.google.com/codejam/contest/6254486/dashboard#s=a&a=2) to this problem is even nicer by using a mathematical trick and the fact that J is pretty small (relative to 10^N).
If J is much larger and close to the number of all jamcoins with length N available, then using modified Rabin-Miller test is probably required.
