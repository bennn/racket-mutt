#lang info
(define collection "mutt")
(define deps '("base" "typed-racket-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define pkg-desc "API for the Mutt email client")
(define version "0.1")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/mutt.scrbl" () ("Email" "Scripting"))))
(define pre-install-collection "private/check-install.rkt")
