#lang racket/base

(provide
  mutt
  mutt*
  in-email*
  email?
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
  (define mutt-cmd (format "~a -s'~a' ~a ~a '~a'"
                           (path-string->string (*mutt-exe-path*))
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
               #:subject [subject (*mutt-default-subject*)]
               #:cc [pre-cc (*mutt-default-cc*)]
               #:bcc [pre-bcc (*mutt-default-bcc*)])
  (define cc (emails pre-cc))
  (define bcc (emails pre-bcc))
  (for/and ((to (in-email* to*)))
    (mutt msg #:to to #:subject subject #:cc cc #:bcc bcc)))

;; -----------------------------------------------------------------------------

;; type Email = String % #rx
;; ; an Email is an email address

;; type Email-Coercible = (U String Path-String (Listof String) (Listof Path-String))
;; ; something that we can coerce into a list of email addresses

;; String -> (U #f Email)
(define email?
  (let ([rxEMAIL #rx"^[^@ ]+@[^@ ]+\\.[^@ ]+$"])
    (lambda (str) (and (regexp-match? rxEMAIL str) str))))

;; Email-Coercible -> (Listof Email)
(define (emails v)
  (sequence->list (in-email* v)))

;; Email-Coercible -> (Sequenceof Email)
(define (in-email* v)
  (cond
   [(null? v)
    v]
   [(pair? v)
    (append* (map in-email* v))]
   [(file-exists? v)
    (in-email* (file->lines v))]
   [(path? v)
    (raise-argument-error 'in-email* "file-exists?" v)]
   [(string? v)
    (if (email? v)
      (list v)
      (begin
        (printf "[mutt] skipping invalid email address '~a'\n" v)
        (list)))]
   [else
    (raise-argument-error 'in-email* "(or/c email? file-exists? (listof (or/c email? file-exists?)))" v)]))

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

;; =============================================================================

(module+ test
  (require rackunit)

  (check-pred email? "a@a.a")
  (check-false (email? "aaa"))
  (check-false (email? "a a@a.a"))

)
