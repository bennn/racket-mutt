#lang typed/racket/base

(require/typed/provide mutt/private/main
  [mutt (->* [Path-String
              #:to String]
             [#:subject String
              #:cc Pre-Email*
              #:bcc Pre-Email*]
             Boolean)]
  [mutt* (->* [Path-String
               #:to* String]
              [#:subject String
               #:cc Pre-Email*
               #:bcc Pre-Email*]
              Boolean)]
  [in-email* (-> Pre-Email* (Listof String))]
  [email? (-> String (U #f String))])

(require/typed/provide mutt/private/parameters
  [*mutt-default-subject* (Parameterof String)]
  [*mutt-default-cc* (Parameterof (Listof String))]
  [*mutt-default-bcc* (Parameterof (Listof String))]
  [*mutt-exe-path* (Parameterof Path-String)])

(provide
  Pre-Email
  Pre-Email*
)

(define-type Pre-Email (U String Path-String))
(define-type Pre-Email* (U Pre-Email (Listof Pre-Email)))
