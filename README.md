# The Most Beautiful Program Ever Written (in Racket)

### Inspired by William Byrd's talk ["The Most Beautiful Program Ever Written"](https://www.youtube.com/watch?v=OyfBQmvr2Hc)

The most beautiful program ever written is a (essentially) 3 line program that encapsulates all the behavior of call by value lambda calculus with an environment.

It is turing complete (lambda calculus came first!), which means it has been proven that any program or computable problem can be expressed in this language.

This fact is amazing, considering that our language contains no numbers, no strings, no symbols, just an environment and functions.

All of those convieninces are of course helpful and simple to add, but they are not needed. Numbers can be expressed with Church encoding. Conditionals can also be encoded. Other data types can be expressed with numbers. Let that sink in. Any program you have ever written can be condensed into a language that whose core logic lies in 3 branches of a match expression.

For these reasons, this is the most beautiful program ever written.

```racket
(define eval-expr
  (lambda (expr env)
    (match expr
      [(? symbol?) (env expr)]
      [`(lambda (,x) ,body)
       (lambda (arg)
         (eval-expr body (lambda (y)
                           (if (eq? x y)
                               arg
                               (env y)))))]
      [`(,rator ,rand)
       ((eval-expr rator env)
        (eval-expr rand env))])))
```

### Explanation

For any of you who are absolutely confused about the program (like I was at first), here is a mini explanation on what this is. Will Byrd does a way better job in his [talk](https://www.youtube.com/watch?v=OyfBQmvr2Hc), which all of this is taken from, but heres my go at it.

Recall define binds a symbol to an expression. We are defining `eval-expr` which is a function (see the lambda) that takes in two arguments: an expression `expr` and something called `env`.

We use `match`, which pattern matches against `expr`, its just a utility and we could totally express this functionality with a `cond` and some creativity, but as you will see `match` makes things a lot more concise.

The first branch guards by matching if `expr` is a symbol? `(? symbol?)` is just how Racket expresses this guard. i.e. "If `expr` is a symbol, then `(env expr)`.

`(env expr)` looks up the expression in the environment. We know that `expr` is a symbol, and in our language symbols resprent a variable. Since we clearly dont know the value of the variable, we need to look it up in our environment. Our environment is just a name for the data structure that holds the values of our variables. We will get into the implementation of our environment in a second.

To recap, this line says "If this is a symbol, it must be a variable so look up its definition in the environment!"

Now onto branch 2: `match` will execute this branch if the incoming expression matches a list of symbols of the form `(lambda (x) body)`. We use appropiate quasiquotes and unquotes to express that we want to match the value of whatever is in the position of `x` and `body`, not the literal symbols `'x` and `'body`.

The incoming symbols represent the creation of a lambda, so we just return a lambda! This lambda takes in some argument `arg`. Remember that `x` is the name of our variable being bound and the value of `arg` is the value `x` is being bound to. When this function is called we also need to evaluate the `body` so we just `(eval-expr body ...)` which is simple enough, but we need to remember the value of `x` and `arg` as we will likely need to use it when evaluating the body! In other words, we need to *extend the environment*.

To do this, we say `env` is a function that takes in some `y`. Note that we dont know what `y` is! We just know that if someone passed in `y`, they are "looking up" the value of `y` in the `env`". Now, we say that if `x` equals `y` (we use `eq` for equality here) then that means they are "looking up the value of `x` in the `env`". But hey, we know what `x` is bound to: `arg`! So we return `arg`. Otherwise we continue to recursively call `(env y)`, as we want to keep looking up the value.

This implementation is essentially just a stack, implemented with lambdas. Every time we descend further into the scope of a function we bind the argument and push it onto `env`. If we ever need to get the value of a variable (see line 1) then we recursively search `env` which will have the most recently bound identifiers first (a FILO data structure). As we linearly search through the `env` we will hopefully find a binding, until we hit the empty environment (see notes at the end for the empty environment).

Finally the last of the 3 lines deals with function application. In LISP-like languages a function is called in the from `(function argument)`. For example `(+ 1 1) -> 2`. We simply extract the function or oper*rator*, and then the argument or oper*rand*, then apply them in the form Racket is familiar with. We must first evaluate both the `rator` and the `rand` before actually applying. Note that this ensures that the `arg` coming into `(lambda (arg)...` on branch 2 is always some literal value. Equally we might easily imagine that we could bind a function to some variable to be the `rator` of a function call, so of course we need to evaluate that as well.

And thats it! Lets take a birds eye view and recap what these 3 lines accomplish:

1. If we find a symbol, we look it up in the environment

2. When we get an expression in the form of a lambda, we evaluate the body and extend the environment by binding `x` to `arg` for future lookups.

3. When we get a function application we evaluate the operator and operand, then call the operator on the operand.

Thats it! If my explanation was boring or unhelpful please do watch the [talk](https://www.youtube.com/watch?v=OyfBQmvr2Hc). You'll probably understand it from that. Also, if youre interested in more things like this I reccomend you read up on Programming Languages. I reccomend *Structure and Interpretation of Computer Programs*, or [*Programming and Programming Languages*](https://papl.cs.brown.edu/2019/) which is totally free and online (plus its co-authored by one of my favorite professors at Northeastern: Ben Lerner).

Notes:

In the current form the empty environment is kind of left up to whoever called `eval-expr` first. In the talk its shown that you probably want to have it be some lambda with an error message. That way if the environment look up burnt through all possible bindings and gets to the empty environment it can error saying that no binding was found:

```racket
(define empty-env (lambda (x) (error 'lookup "unbound identifer")))
(eval-expr ... empty-env)
```


------------------------------------------------------------------

Some might say that writing a barely functional language in a functional language is kind of pretentious and shows nothing.

For one, wow you're a real party pooper people can enjoy what they want. Secondly, you try implementing a turing complete language that is as readable as this in Java or Python or C++ or (name your favorite industrial imperative language here). If all you got is janky LISP clones and Brainfuck then take another look at this program and you might just glimpse at some of that beauty I was talking about.

The point of this is that its a simple and readable exercise that can help us understand how programming languages work. All you need is a little background a LISP-like language and you can create your own turing complete language in a few lines. Its cool, its educational, and its fun. There doesn't need to be more justification than that.


------------------------------------------------------------------

If you programmed a bit in Scheme or Racket before you are probably familar with `=` and `equal?` but you may not know what `eq?` is. `eq?` is just a special variant of equality that check if two things *refer to the same object*. That is, pointer equality. In paticular we know that we are comparing symbols, and two symbols are only ever pointer equivalent if they are the same symbol. To be honest I'm not 100% sure why exactly we *need* to use `eq?` here, but it is used in the talk.

------------------------------------------------------------------
