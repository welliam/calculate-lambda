(define-library (lambda-calculator main)
  (import (scheme base) (scheme write))
  (export abstraction? application? calculate-lambda substitute abstraction-var)
  (begin
    (define (abstraction? x)
      (and (list? x)
           (eq? (car x) 'lambda)
           (= (length x) 3)
           (list? (car (cdr x)))))

    (define (application? x)
      (and (list? x)
           (= (length x) 2)))

    (define (abstraction-var abs)
      (car (car (cdr abs))))

    (define (calculate-lambda x)
      x)

    (define (substitute looking with in)
      (cond
       ((application? in)
        (list (substitute looking with (car in))
              (substitute looking with (car (cdr in)))))
       ((abstraction? in)
        (let ((var (abstraction-var in)))
          (if (eq? var looking)
              in
              (list 'lambda
                    (car (cdr in))
                    (substitute looking with (car (cdr (cdr in))))))))
       ((eq? looking in) with)
       (else in)))))
