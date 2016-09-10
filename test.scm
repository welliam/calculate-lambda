(define-library (test main)
  (import (scheme base) (scheme write))
  (export suite test)
  (begin
    (define-record-type <test>
      (make-test <expression> <expected> <got>)
      test?
      (<expression> test-expression)
      (<expected> test-expected)
      (<got> test-got))

    (define (test-succeeded? t)
      (and (not (error-object? (test-got t)))
           (equal? (test-expected t) (test-got t))))

    (define (run-test expr expect got)
      ((current-suite) (make-test expr expect got)))

    (define-syntax return-exception
      (syntax-rules ()
        ((_ e e* ...)
         (call/cc
          (lambda (k)
            (with-exception-handler k
              (lambda () e e* ...)))))))

    (define (values-as-list e)
      (call-with-values e (lambda xs (cons 'values xs))))

    (define-syntax test
      (syntax-rules ()
        ((_ expression) (test #t (if expression #t #f)))
        ((_ expect expression)
         (run-test 'expression expect (return-exception expression)))
        ((_ expect-value expect-value* ... expression)
         (test (list 'values expect-value expect-value* ...)
               (values-as-list (lambda () expression))))))

    (define-record-type <suite>
      (make-suite <id> <tests>)
      suite?
      (<id> suite-id)
      (<tests> suite-tests set-suite-tests!))

    (define (new-suite name)
      (let ((s (make-suite name '())))
        (values s
                (lambda (t)
                  (set-suite-tests! s (cons t (suite-tests s)))))))

    (define-syntax suite
      (syntax-rules ()
        ((_ name e ...)
         (let-values (((s add) (new-suite 'name)))
           (parameterize ((current-suite add))
             (call/cc
              (lambda (k)
                (with-exception-handler (lambda (x) (add x) (k #t))
                  (lambda () e ...)))))
           ((current-suite) s)))))

    (define current-suite
      (make-parameter
       (lambda (t) (print-tests t))))

    (define (print . xs) (for-each display xs) (newline))

    (define (print-space level)
      (unless (= level 0)
        (display " ")
        (print-space (- level 1))))

    (define (filter p t)
      (cond
       ((null? t) '())
       ((p (car t)) (cons (car t) (filter p (cdr t))))
       (else (filter p (cdr t)))))

    (define (print-tests t)

      (let loop ((t t) (level 0))
        (cond
         ((test? t)
          (unless (test-succeeded? t)
            (print-space level)
            (print-test t)))
         ((error-object? t)
          (print-space level)
          (print-test t))
         ((suite? t)
          (print-space level)

          (let* ((suites-count (length (filter suite? (suite-tests t))))
                 (tests-count (length (filter test? (suite-tests t))))
                 (message (suite-message suites-count tests-count)))
            (print-padded level (->string "- " (suite-id t)) message))
          (for-each (lambda (x) (loop x (+ level 4)))
                    (reverse (suite-tests t)))))))

    (define (suite-message suites-count tests-count)
      (cond
       ((and (zero? suites-count) (zero? tests-count))
        " (nothing ran)")
       ((zero? suites-count)
        (->string " (" tests-count " tests ran)"))
       ((zero? tests-count)
        (->string " (" suites-count " suites ran)"))
       (else
        (->string " (" tests-count " tests and "
                  suites-count " suites ran)"))))

    (define (->string . xs)
      (let ((out (open-output-string)))
        (parameterize ((current-output-port out))
          (for-each display xs))
        (get-output-string out)))

    (define (print-padded other-len s1 s2)
      (let* ((spaces (- 60 (string-length s1) (string-length s2) other-len))
             (spaces (if (<= spaces 0) 1 spaces)))
        (display s1)
        (print-space spaces)
        (print s2)))

    (define (print-test t)
      (cond
       ((error-object? t)
        (print "error occurred in suite: "
               (error-object-message t)))
       ((test-succeeded? t)
        (print "test succeeded: got " (test-got t)
               " from " (test-expression t)))
       ((error-object? (test-got t))
        (print "test error: got " (error-object-message (test-got t))
               " from " (test-expression t)))
       (else
        (print "test failed: expected " (test-expected t)
               " from " (test-expression t)
               " but got " (test-got t)))))))
