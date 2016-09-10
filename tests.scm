(use r7rs)

(load "test.scm")
(load "lambda2.scm")

(import (test main) (lambda-calculator main))

(suite tests
  (suite constants
    (test 'x (calculate-lambda 'x))
    (test 'y (calculate-lambda 'y))
    (test 0 (calculate-lambda 0)))

  (suite applications
    (test '(x x) (calculate-lambda '(x x)))
    (test '0 (calculate-lambda '((lambda (x) x) 0))))

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

  (suite abstraction-var
    (test 'x (abstraction-var '(lambda (x) x)))))


