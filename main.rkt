#lang racket/base

(require
  mutt/private/main
  mutt/private/parameters
  racket/contract
  (only-in racket/sequence sequence/c)
)

;; -----------------------------------------------------------------------------

(provide
  (contract-out
   [mutt
    (->* [path-string?
          #:to string?]
         [#:subject string?
          #:cc pre-email*/c
          #:bcc pre-email*/c]
         boolean?)]

   [mutt*
    (->* [path-string?
          #:to* pre-email*/c]
         [#:subject string?
          #:cc pre-email*/c
          #:bcc pre-email*/c]
         boolean?)]

   [in-email*
    (-> pre-email*/c (sequence/c email?))]

   [*mutt-default-subject*
    (parameter/c string?)]

   [*mutt-default-cc*
    (parameter/c (listof email?))]

   [*mutt-default-bcc*
    (parameter/c (listof email?))]

   [*mutt-exe-path*
    (parameter/c path-string?)]

   [email?
    (-> string? (or/c #f string?))]
)
   pre-email/c
   pre-email*/c
)

(define pre-email/c
  (or/c string? path-string?))

(define pre-email*/c
  (or/c pre-email/c (listof pre-email/c)))

