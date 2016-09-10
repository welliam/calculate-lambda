(define-library (lambda-calculator main)
  (import (scheme base))
  (export abstraction? calculate-lambda)
  (begin
    (define (abstraction? x)
      (and (pair? x)
           (eq? (car x) 'lambda)))

    (define (calculate-lambda x)
      x)))
