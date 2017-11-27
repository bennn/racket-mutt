#lang racket/base

;; Check that the user's system is ready to use this Mutt API

(provide pre-installer)

(require
  setup/cross-system
  (only-in racket/system system)
  racket/string
)

;; =============================================================================

(define errloc 'mutt:pre-install)

(define (pre-installer collections-top-path racl-path)
  (unless (or (getenv "PLT_PKG_BUILD_SERVICE")
              (getenv "TRAVIS"))
    (check-system-type)
    (check-mutt)
    (check-muttrc))
  (void))

;; 2016-09-06: Windows isn't supported because Windows isn't tested.
(define (check-system-type)
  (when (eq? (cross-system-type 'os) 'windows)
    (raise-user-error errloc "this Racket mutt client does not yet support Windows")))

;; Check for `mutt` executable,
;;  raise error if it's not found
(define (check-mutt)
  (unless (find-executable-path "mutt")
    (raise-user-error errloc "could not locate `mutt` executable, install with your package manager and try again")))

;; Check if `.muttrc` exists,
;;  if not, help user create one
(define (check-muttrc)
  (define home (find-system-path 'home-dir))
  (define home/.muttrc (build-path home ".muttrc"))
  (define home/.mutt/muttrc (build-path home ".mutt" "muttrc"))
  (unless (or (file-exists? home/.muttrc)
              (file-exists? home/.mutt/muttrc))
    (printf "could not locate `muttrc` file at '~a' or '~a'~n" home/.muttrc home/.mutt/muttrc)
    (printf "creating '~a' ...~n" home/.muttrc)
    (call-with-output-file home/.muttrc
      (lambda (cfg)
        (define email-addr (email-prompt "for the 'from' field of outgoing messages"))
        (fprintf cfg "set realname=\"~a\"~n" (string-prompt "Please enter your name:"))
        (fprintf cfg "set from=\"~a\"~n" email-addr)
        (fprintf cfg "set use_from = yes~n")
        (if (and (string-suffix? email-addr "@gmail.com")
                 (bool-prompt "Configure gmail SMTP settings?"))
          (let ([gmail-user (car (string-split email-addr "@"))]
                [gmail-pass (string-prompt "Enter your gmail password (leave blank to fill in later)")])
            (fprintf cfg "set imap_user = \"$from\"~n")
            (fprintf cfg "set imap_pass = \"~a\"~n" gmail-pass)
            (fprintf cfg "set smtp_url = \"smtps://$imap_user@smtp.gmail.com:465/\"~n")
            (fprintf cfg "set smtp_pass = \"$imap_pass\"~n")
            (fprintf cfg "set folder = \"imaps://imap.gmail.com:993\"~n")
            (void))
          (begin
            (fprintf cfg "set folder=\"~~/.mutt/mail\"~n")
            (void)))
        (fprintf cfg "set spoolfile=+INBOX~n")
        (fprintf cfg "set ssl_force_tls = yes~n")
        (fprintf cfg "set smtp_authenticators = 'gssapi:login'~n")
        (fprintf cfg "set header_cache=~~/.mutt/cache/~n")
        (fprintf cfg "set timeout=10  # seconds~n")
        (fprintf cfg "set mail_check=5  # seconds~n")
        (fprintf cfg "~n# Mutt Guide: https://dev.mutt.org/trac/wiki/MuttGuide~n")
        (void)))))

;; -----------------------------------------------------------------------------

(define INVALID-INPUT (gensym))

;; Print a format string,
;;  request a "y" or "n" from the user,
;;  repeat if input is bad
;; String (-> String (U Any INVALID-INPUT)) -> (U Any Eof)
(define (prompt msg parse-input)
  (let loop ()
    (display "[mutt-setup] ")
    (displayln msg)
    (define ln (read-line))
    (if (eof-object? ln)
      ln
      (let ([v (parse-input ln)])
        (if (eq? INVALID-INPUT v)
          (loop)
          v)))))

(define (prompt/fail msg parse-input)
  (define v (prompt msg parse-input))
  (if (eof-object? v)
    (raise-user-error 'prompt "got EOF symbol")
    v))

(define (bool-prompt msg . arg*)
  (prompt/fail (apply format (string-append msg " [y/n]") arg*)
    (lambda (x)
      (case (string-downcase x)
       [("y" "yes")
        #t]
       [("n" "no")
        #f]
       [else
        INVALID-INPUT]))))

;; String -> String
(define (string-prompt msg)
  (prompt/fail msg (lambda (x) x)))

;; Prompt the user for an email address
;; String -> String
(define email-prompt
  (let* ([msg "Please enter an email address (~a):"]
         [rxEMAIL #rx"^[^@ ]+@[^@ ]+\\.[^@ ]+$"]
         [lam (lambda (x) (if (regexp-match? rxEMAIL x) x INVALID-INPUT))])
    (lambda (reason)
      (prompt/fail (format msg reason) lam))))

;; =============================================================================

(module+ test
  (require rackunit)

  (test-case "prompt"
  )

  (test-case "prompt/fail"
  )

  (test-case "bool-prompt"
  )

  (test-case "string-prompt"
  )

  (test-case "email-prompt"
  )
)
