#lang racket
;; The Most Beautiful Program Ever Written
;; An environment passing call by value lambda calculus interpreter
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


