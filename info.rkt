#lang info
(define collection "mutt")
(define deps '("base" "typed-racket-lib" "typed-racket-more" "make-log-interceptor"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib" "rackunit-abbrevs" "typed-racket-doc"))
(define pkg-desc "API for the Mutt email client")
(define version "0.3")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/mutt.scrbl" () ("Email"))))
(define pre-install-collection "private/pre-install.rkt")
