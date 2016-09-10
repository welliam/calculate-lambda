(define-library (lambda-calculator main)
  (import (scheme base))
  (export abstraction? application? calculate-lambda)
  (begin
    (define (abstraction? x)
      (and (list? x)
           (eq? (car x) 'lambda)
           (= (length x) 3)
           (list? (car (cdr x)))))

    (define (application? x)
      (list? x))

    (define (calculate-lambda x)
      x)))
