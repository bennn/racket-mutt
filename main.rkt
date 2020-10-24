#lang racket/base

(require
  mutt/private/main
  mutt/private/parameters
  racket/contract
  (only-in racket/sequence sequence/c)
  (only-in scribble/core content?)
)

;; -----------------------------------------------------------------------------

(provide
  (contract-out
   [mutt
    (->* [(or/c path-string? string? pair?)
          #:to pre-email*/c]
         [#:attachment attachment/c
          #:subject string?
          #:reply-to (or/c #f string?)
          #:cc pre-email*/c
          #:bcc pre-email*/c]
         #:rest content?
         boolean?)]

   [mutt*
    (->* [(or/c path-string? string? pair?)
          #:to* pre-email*/c]
         [#:attachment attachment/c
          #:subject string?
          #:cc pre-email*/c
          #:bcc pre-email*/c]
         #:rest content?
         boolean?)]

   [in-email*
    (-> pre-email*/c (sequence/c email?))]

   [*mutt-default-subject*
    (parameter/c string?)]

   [*mutt-default-cc*
    (parameter/c (listof email?))]

   [*mutt-default-bcc*
    (parameter/c (listof email?))]

   [*mutt-default-attachment*
    (parameter/c (listof path-string?))]

   [*mutt-default-reply-to*
    (parameter/c (or/c #f string?))]

   [*mutt-exe-path*
    (parameter/c (or/c #f path-string?))]

   [email?
    (-> string? (or/c #f string?))]

   [mutt-logger
     logger?]
  )
  attachment/c
  pre-email/c
  pre-email*/c
)

(define attachment/c
  (or/c #f path-string? (listof path-string?)))

(define pre-email/c
  (or/c string? path-string?))

(define (treeof elem-contract)
  (or/c elem-contract
        (listof (recursive-contract (treeof elem-contract) #:flat))))

(define pre-email*/c
  (treeof pre-email/c))

