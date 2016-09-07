#lang racket/base

(provide
  mutt
  mutt*
)

(require
  mutt/private/parameters
  (only-in racket/list append*)
  (only-in racket/file file->lines)
  racket/sequence
  racket/string
  racket/system
)

;; =============================================================================

(define (mutt msg
              #:to to
              #:subject [subject (*mutt-default-subject*)]
              #:cc [cc (*mutt-default-cc*)]
              #:bcc [bcc (*mutt-default-bcc*)])
  (define mutt-cmd (format "mutt -s'~a' ~a ~a '~a'"
                           subject
                           (format-cc (emails cc))
                           (format-bcc (emails bcc))
                           to))
  (cond
   [(file-exists? msg)
    (system (format "~a < ~a" mutt-cmd (path-string->string msg)))]
   [(string? msg)
    (system (format "echo '~a' | ~a" msg mutt-cmd))]
   [else
    (raise-argument-error 'mutt "(or/c string? file-exists?)" msg)]))

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
   [(null? v)
    v]
   [(pair? v)
    (append* (map in-emails v))]
   [(file-exists? v)
    (in-emails (file->lines v))]
   [(path? v)
    (raise-argument-error 'in-emails "file-exists?" v)]
   [(string? v)
    (if (email? v)
      (list v)
      (begin
        (printf "[mutt] skipping invalid email address '~a'\n" v)
        (list)))]
   [else
    (raise-argument-error 'in-emails "(or/c email? file-exists? (listof (or/c email? file-exists?)))" v)]))

(define (format-*cc emails prefix)
  (if (null? emails)
    ""
    (string-join emails (string-append " " prefix) #:before-first (string-append prefix " "))))

(define (format-cc emails)
  (format-*cc emails "-c"))

(define (format-bcc emails)
  (format-*cc emails "-b"))

(define (path-string->string x)
  (if (path? x)
    (path->string x)
    x))

