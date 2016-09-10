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
                            (abstraction-body in)))
   ((eq? looking in) with)
   (else in)))

(define (build-var n)
  (string->symbol (string-append "var" (number->string n))))

(define (assq-default x lst)
  (let ((search (assq x lst)))
    (if search (cdr search) x)))

(define (alpha-rename-application op arg env n)
  (let*-values (((op-body op-env op-n) (alpha-rename-rec op env n))
                ((arg-body arg-env arg-n) (alpha-rename-rec arg env op-n)))
    (values (list op-body arg-body) env op-n)))

(define (alpha-rename-abstraction var body env n)
  (let ((renamed (build-var n)))
    (let-values (((renamed-body new-env new-n)
                  (alpha-rename-rec body
                                    (cons (cons var renamed)
                                          env)
                                    (+ n 1))))
      (values (list 'lambda (list renamed) renamed-body)
              env
              new-n))))

(define (alpha-rename-rec in env n)
  (cond
   ((application? in)
    (alpha-rename-application (car in) (car (cdr in)) env n))
   ((abstraction? in)
    (alpha-rename-abstraction (abstraction-var in)
                              (abstraction-body in)
                              env
                              n))
   (else (values (assq-default in env) env n))))
