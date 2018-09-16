#lang typed/racket/base
(module+ test

  (require
    mutt/typed
    typed/rackunit
    rackunit-abbrevs/typed
    racket/string
    racket/runtime-path
  )

  (*mutt-exe-path* "xargs echo")

  (define-syntax-rule (check-mutt [f arg* ...] expected)
    (let ([p (open-output-string 'mutt-test)])
      (parameterize ([current-output-port p])
        (f arg* ...))
      (let ([actual (get-output-string p)])
        (close-output-port p)
        (check-equal? (string-split actual) expected))))

  (define email_addrs "./email_addrs.txt")
  (define sample_msg  "./sample_message.txt")

  (test-case "mutt"
    (check-mutt [mutt "hello" #:to "adam@west.co" #:subject "hi"]
                '("-shi" "adam@west.co" "hello"))
    (check-mutt [mutt "bye" #:to "mae@west.it" #:subject "yo" #:cc "a@a.a"]
                '("-syo" "-c" "a@a.a" "mae@west.it" "bye"))
    (check-mutt [mutt "yes" #:to "felix@cat.ct" #:subject "--" #:cc '("mr@dont.play") #:bcc '("we@pa.com" "www@dotcom.com")]
                '("-s--" "-c" "mr@dont.play" "-b" "we@pa.com" "-b" "www@dotcom.com" "felix@cat.ct" "yes"))
    (check-mutt [mutt sample_msg #:to "arthur@frayn.zo" #:cc email_addrs #:bcc (list (string->path email_addrs))]
                '("-s<no-subject>" "-c" "john@doe.com" "-c" "jane@doe.gov" "-b" "john@doe.com" "-b" "jane@doe.gov" "arthur@frayn.zo" "we" "trippy" "mane"))
  )

  (test-case "mutt*"
    (check-mutt [mutt* (string->path sample_msg) #:to* email_addrs #:subject "fyi"]
                '("-sfyi" "john@doe.com" "we" "trippy" "mane"
                  "-sfyi" "jane@doe.gov" "we" "trippy" "mane"))
  )

  (test-case "in-email*"
    (check-apply* in-email*
     ['()
      ==> '()]
     ["erik@estrada.eu"
      ==> '("erik@estrada.eu")]
     [email_addrs
      ==> '("john@doe.com" "jane@doe.gov")]
     [(list email_addrs "hello@world.io")
      ==> '("john@doe.com" "jane@doe.gov" "hello@world.io")])
  )

  (test-case "mutt-exe-path-is-#f"
    (check-not-exn
      (lambda ()
        (parameterize ([*mutt-exe-path* #f])
          (mutt "yo" #:to "lo@yo.lo")))))

)
