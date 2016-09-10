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
    (test '0 (calculate-lambda '((lambda (x) x) 0)))
    (test (abstraction? '(lambda (x) x)))))
