(define-library (lambda-calculator main)
  (import (scheme base))
  (export abstraction? application? calculate-lambda substitute)
  (begin
    (define (abstraction? x)
      (and (list? x)
           (eq? (car x) 'lambda)
           (= (length x) 3)
           (list? (car (cdr x)))))

    (define (application? x)
      (and (list? x)
           (= (length x) 2)))

    (define (calculate-lambda x)
      x)

    (define (substitute looking with in)
      (if (eq? looking in)
          with
          in))))


