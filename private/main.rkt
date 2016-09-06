#lang racket/base

(provide
  mutt
)

(require
  racket/sequence
  racket/string
  racket/system
)

;; =============================================================================

(define (mutt msg
              #:to to
              #:subject subject
              #:cc [cc '()]
              #:bcc [bcc '()])
  (system (format "mutt -s'~a' ~a ~a '~a' < ~a"
                  subject
                  (format-cc (emails cc))
                  (format-bcc (emails bcc))
                  to
                  msg)))

(define (mutt* msg
               #:to* to*
               #:subject subject
               #:cc [pre-cc '()]
               #:bcc [pre-bcc '()])
  (define cc (emails pre-cc))
  (define bcc (emails pre-bcc))
  (for ((to (in-emails to*)))
    (mutt msg #:to to #:subject subject #:cc cc #:bcc bcc)))

;; -----------------------------------------------------------------------------

;; type Email = String % #rx
;; ; an Email is an email address

;; type Email-Coercible = (U String Path-String (Listof String) (Listof Path-String))
;; ; something that we can coerce into a list of email addresses

;; String -> (U #f Email)
(define email?
  (let ([rxEMAIL #rx"[^@]+@[^@.]+\\.[^@]+"])
    (lambda (str) (and (regexp-match? rxEMAIL str) str))))

;; Email-Coercible -> (Listof Email)
(define (emails v)
  (sequence->list (in-emails v)))

;; Email-Coercible -> (Sequenceof Email)
(define (in-emails v)
  (cond
   [(string? v)
    (list v)]
   [else
    (error 'in-emails:not-implemented)]))

(define (format-*cc emails prefix)
  (string-join emails (string-append " " prefix) #:before-first (string-append prefix " ")))

(define (format-cc emails)
  (format-*cc emails "-c"))

(define (format-bcc emails)
  (format-*cc emails "-b"))
