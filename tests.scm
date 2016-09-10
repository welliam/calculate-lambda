(use r7rs)

(load "test.scm")
(load "lambda.scm")

(import (test main))

(suite tests
  (suite constants
    (test 'x (calculate-lambda 'x))
    (test 'y (calculate-lambda 'y))
    (test 0 (calculate-lambda 0)))

  (suite applications
    (test '(x x) (calculate-lambda '(x x)))
    (test '0 (calculate-lambda '((lambda (x) x) 0)))
    (test 'y (calculate-lambda '((lambda (x) y) 0)))
    (test '0 (calculate-lambda '((lambda (x) x)
                                 ((lambda (x) x)
                                  0)))))

  (suite abstraction?
    (test (abstraction? '(lambda (x) x)))
    (test (not (abstraction? '(lambda))))
    (test (not (abstraction? '(lambda x x)))))

  (suite application?
    (test (application? '(x x)))
    (test (not (application? '(x . x))))
    (test (not (application? '(x x x)))))

  (suite substitute
    (test 0 (substitute 'x 0 'x))
    (test 'y (substitute 'x 0 'y))
    (test '(0 0) (substitute 'x 0 '(x x)))
    (test '((0 0) (y y)) (substitute 'x 0 '((x x) (y y))))
    (test '(lambda (x) x) (substitute 'x 0 '(lambda (x) x)))
    (test '(lambda (y) 0) (substitute 'x 0 '(lambda (y) x)))
    (test '((lambda (y) 0) 0) (substitute 'x 0 '((lambda (y) x) x))))

  (suite substitute-abstraction
    (test '(lambda (x) x) (substitute-abstraction 'x 0 'x 'x))
    (test '(lambda (y) 0) (substitute-abstraction 'x 0 'y 'x)))

  (suite abstraction-var
    (test 'x (abstraction-var '(lambda (x) x))))

  (suite abstraction-body
    (test 'x (abstraction-body '(lambda (x) x))))

  (suite build-var
    (test (eq? (build-var 0) (build-var 0)))
    (test (not (eq? (build-var 0) (build-var 1)))))

  (suite alpha-rename-rec
    (test 'x (let-values (((result env n) (alpha-rename-rec 'x '() 0)))
               result))

    (test (let-values (((result env n) (alpha-rename-rec '(x x) '() 0)))
            (eq? (car result)
                 (car (cdr result)))))

    (test (let-values (((result env n)
                        (alpha-rename-rec '(lambda (x) x) '() 0)))
            (eq? (abstraction-var result)
                 (abstraction-body result))))

    (test (let-values (((result env n)
                        (alpha-rename-rec '((lambda (x) x) x) '() 0)))
            (not (eq? (abstraction-body (car result))
                      (car (cdr result))))))

    (test (let-values (((result env n)
                        (alpha-rename-rec '((lambda (y) x) x) '() 0)))
            (eq? (abstraction-body (car result))
                 (car (cdr result)))))

    (test (let-values (((result env n)
                        (alpha-rename-rec '((lambda (x) x) (lambda (x) x)) '() 0)))
            (not (eq? (abstraction-body (car result))
                      (abstraction-body (car (cdr result))))))))

  (suite alpha-rename
    (test (let ((result (alpha-rename '(x x))))
            (eq? (car result) (car (cdr result)))))

    (test (let ((result (alpha-rename '((lambda (x) x) x))))
            (not (eq? (abstraction-var (car result))
                      (car (cdr result))))))))
