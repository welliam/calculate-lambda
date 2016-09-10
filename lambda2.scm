(define-library (lambda-calculator main)
  (import (scheme base))
  (export abstraction? calculate-lambda)
  (begin
    (define (abstraction? x)
      (and (list? x)
           (eq? (car x) 'lambda)
           (= (length x) 3)
           (list? (car (cdr x)))))

    (define (calculate-lambda x)
      x)))
