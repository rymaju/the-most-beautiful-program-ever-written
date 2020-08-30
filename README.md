# The Most Beautiful Program Ever Written (in Racket)

## Inspired by William Byrd's talk ["The Most Beautiful Program Ever Written"](https://www.youtube.com/watch?v=OyfBQmvr2Hc)

The most beautiful program ever written is a (essentially) 3 line program that encapsulates all the behavior of call by value lambda calculus with an environment.

It is turing complete (lambda calculus came first!), which means it has been proven that any program or computable problem can be expressed in this language.

This fact is amazing, considering that our language contains no numbers, no strings, no symbols, just an environment and functions.

All of those convieninces are of course helpful and simple to add, but they are not needed. Numbers can be expressed with Church encoding. Conditionals can also be encoded. Other data types can be expressed with numbers. Let that sink in. Any program you have ever written can be condensed into a language that whose core logic lies in 3 branches of a match expression.

For these reasons, this is the most beautiful program ever written.
