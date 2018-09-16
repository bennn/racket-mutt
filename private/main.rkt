#lang racket/base

(provide
  mutt
  mutt*
  in-email*
  email?
  mutt-logger)

(require
  mutt/private/parameters
  (only-in racket/list append*)
  (only-in racket/file file->lines)
  racket/sequence
  racket/string
  racket/system
)

;; =============================================================================

(define-logger mutt)

(define (mutt msg
              #:to to
              #:subject [subject (*mutt-default-subject*)]
              #:cc [cc (*mutt-default-cc*)]
              #:bcc [bcc (*mutt-default-bcc*)]
              #:attachment [att* (*mutt-default-attachment*)])
  (mutt/internal msg to subject (in-email* cc) (in-email* bcc) (in-attach* att*)))

(define (mutt* msg
               #:to* to*
               #:subject [subject (*mutt-default-subject*)]
               #:cc [pre-cc (*mutt-default-cc*)]
               #:bcc [pre-bcc (*mutt-default-bcc*)]
               #:attachment [pre-att* (*mutt-default-attachment*)])
  (define att* (in-attach* pre-att*))
  (define cc (in-email* pre-cc))
  (define bcc (in-email* pre-bcc))
  (for/and ((to (in-email* to*)))
    (mutt/internal msg to subject cc bcc att*)))

(define (mutt/internal msg to subject cc bcc att*)
  (define mutt-exe
    (let ([exe (*mutt-exe-path*)])
      (if exe
        (path-string->string exe)
        (begin
          (log-mutt-warning "cannot send mail because parameter `*mutt-exe-path*` is `#f`")
          #f))))
  (define mutt-cmd (format "~a -s'~a' ~a ~a ~a"
                           (or mutt-exe '<mutt-exe>)
                           subject
                           (format-cc cc)
                           (format-bcc bcc)
                           (format-to+attachments to att*)))
  (cond
   [(file-exists? msg)
    (define full-command (format "~a < ~a" mutt-cmd (path-string->string msg)))
    (log-mutt-command full-command)
    (and mutt-exe (system full-command))]
   [(string? msg)
    (define full-command (format "echo '~a' | ~a" msg mutt-cmd))
    (log-mutt-command full-command)
    (and mutt-exe (system full-command))]
   [else
    (raise-argument-error 'mutt "(or/c string? file-exists?)" msg)]))

;; -----------------------------------------------------------------------------

;; type Email = String % #rx
;; ; an Email is an email address

;; type Email-Coercible = (U String Path-String (Listof String) (Listof Path-String))
;; ; something that we can coerce into a list of email addresses

;; String -> (U #f Email)
(define email?
  (let ([rxEMAIL #rx"^[^@ ]+@[^@ ]+\\.[^@ ]+$"])
    (lambda (str) (and (regexp-match? rxEMAIL str) str))))

;; (U #f Path-String (Listof Path-String)) -> (U #f (Pairof Path-String (Listof Path-String)))
(define (in-attach* att*)
  (if (or (not att*) (null? att*))
    #f
    (cond
     [(path-string? att*)
      (list att*)]
     [else
      att*])))

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
    (string-join emails (string-append " " prefix " ") #:before-first (string-append prefix " "))))

(define (format-cc emails)
  (format-*cc emails "-c"))

(define (format-bcc emails)
  (format-*cc emails "-b"))

(define (format-to+attachments pre-to att*)
  (define to-str (format "'~a'" pre-to))
  (if att*
    (string-append (format-*cc att* "-a") " -- " to-str)
    to-str))

(define (path-string->string x)
  (if (path? x)
    (path->string x)
    x))

(define (log-mutt-command str)
  (log-mutt-info "send :: ~a" str))

;; =============================================================================

(module+ test
  (require rackunit rackunit-abbrevs)

  (test-case "email?"
    (check-apply* email?
     ["a@a.a"
      ==> "a@a.a"]
     ["thomas@jefferson.whitehouse"
      ==> "thomas@jefferson.whitehouse"]
     ["aaa"
      ==> #f]
     ["a a@a.a"
      ==> #f]
     [""
      ==> #f])
  )

  (test-case "in-attach*"
    (check-apply* in-attach*
     ['()
      ==> #f]
     [#f
      ==> #f]
     ["z.png"
      ==> '("z.png")]
     ['("file1.jpg" "file2.jpg")
      ==> '("file1.jpg" "file2.jpg")]))

  (test-case "format-*cc"
    (check-apply* format-*cc
     ['() "a"
      ==> ""]
     ['() "yo"
      ==> ""]
     ['("a" "b" "c") "--"
      ==> "-- a -- b -- c"]
     ['("world") "hello"
      ==> "hello world"])
  )

  (test-case "format-bcc"
    (check-apply* format-bcc
     ['()
      ==> ""]
     ['("lincoln" "madison" "buchanan")
      ==> "-b lincoln -b madison -b buchanan"])
  )

  (test-case "format-cc"
    (check-apply* format-cc
     ['()
      ==> ""]
     ['("A" "B")
      ==> "-c A -c B"]
     ['("monroe" "fillmore" "wilson" "adams")
      ==> "-c monroe -c fillmore -c wilson -c adams"])
  )

  (test-case "format-to+attachments"
    (check-apply* format-to+attachments
     ["sam@sam.gov" #f
      ==> "'sam@sam.gov'"]
     ["dave@republic.io" '("free.jpg")
      ==> "-a free.jpg -- 'dave@republic.io'"])
  )

  (test-case "path-string->string"
    (check-apply* path-string->string
     ["foo"
      ==> "foo"]
     [(string->path "foo")
      ==> "foo"])
  )

)
