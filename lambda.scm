(define-library (lambda-calculator main)
  (import (scheme base) (scheme write))
  (export abstraction? application?
          abstraction-var abstraction-body
          calculate-lambda
          substitute substitute-abstraction)
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

    (define (abstraction-body abs)
      (car (cdr (cdr abs))))

    (define (calculate-lambda x)
      (if (application? x)
          (let ((op (calculate-lambda (car x)))
                (arg (calculate-lambda (car (cdr x)))))
            (if (abstraction? op)
                (substitute (abstraction-var op)
                            arg
                            (abstraction-body op))
                (list op arg)))
          x))

    (define (substitute-abstraction looking with var body)
      (list 'lambda
            (list var)
            (if (eq? looking var)
                body
                (substitute looking with body))))

    (define (substitute looking with in)
      (cond
       ((application? in)
        (list (substitute looking with (car in))
              (substitute looking with (car (cdr in)))))
       ((abstraction? in)
        (substitute-abstraction looking
                                with
                                (abstraction-var in)
                                (car (cdr (cdr in)))))
       ((eq? looking in) with)
       (else in)))))
