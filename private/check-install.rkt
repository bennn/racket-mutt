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
  (check-system-type)
  (check-mutt)
  (check-mail)
  (check-muttrc)
  (void))

;; 2016-09-06: Windows isn't supported because Windows isn't tested.
(define (check-system-type)
  (when (eq? (cross-system-type 'os) 'windows)
    (raise-user-error errloc "this Racket mutt client does not yet support Windows")))

;; Check for `mutt` executable,
;;  raise error if it's not found
(define (check-mutt)
  (unless (system "type mutt >& /dev/null")
    (raise-user-error errloc "could not locate `mutt` executable, install with your package manager and try again")))

;; Check for a mailbox folder
;;  and other config folders/files
(define (check-mail)
  (define home (find-system-path 'home-dir))
  (define home/.mail (build-path home ".mail"))
  (when (and (not (directory-exists? home/.mail))
             (bool-prompt "Directory ~a does not exist. Create it? [y/n]" home/.mail))
    (make-directory home/.mail))
  (void))

;; Check if `.muttrc` exists,
;;  if not, help user create one
(define (check-muttrc)
  (define home (find-system-path 'home-dir))
  (define home/.muttrc (build-path home ".muttrc"))
  (define home/.mutt/muttrc (build-path home ".mutt" "muttrc"))
  (unless (or (file-exists? home/.muttrc)
              (file-exists? home/.mutt/muttrc))
    (printf "could not locate `muttrc` file at '~a' or '~a'\n" home/.muttrc home/.mutt/muttrc)
    (printf "creating '~a' ...\n" home/.muttrc)
    (call-with-output-file home/.muttrc
      (lambda (cfg)
        (define email-addr (email-prompt "for the 'from' field of outgoing messages"))
        ;; -- basic config, credits to http://www.calmar.ws/mutt/
        (fprintf cfg "unmy_hdr *    # delete existing header settings, if any\n")
        (fprintf cfg "# my_hdr X-Homepage: http://www.google.com    # Uncomment to add your homepage to the header\n")
        (fprintf cfg "set from=\"~a\"\n" email-addr)
        (fprintf cfg "set realname=\"~a\"\n" (string-prompt "Please enter your name:"))
        (if (and (string-suffix? email-addr "@gmail.com")
                 #f ;; TODO figure out how to authenticate with gmail
                 (bool-prompt "Are you sending from a gmail account?"))
          (let ([gmail-user (car (string-split email-addr "@"))]
                [gmail-pass (string-prompt "Enter your gmail password (leave blank to fill in later)")])
            (fprintf cfg "set imap_user = \"~a\"\n" email-addr)
            (fprintf cfg "set imap_pass = \"~a\"\n" gmail-pass)
            (fprintf cfg "set imap_keepalive = 900\n")
            (fprintf cfg "set folder = imaps://imap.gmail.com/\n")
            (fprintf cfg "set record = \"+[Gmail]/Sent Mail\"\n")
            (fprintf cfg "set postponed = \"+[Gmail]/Drafts\"\n")
            (void))
          (begin
            (fprintf cfg "set folder=\"~~/.mail\"\n")
            (fprintf cfg "set record=\"+Sent-`date +%Y`\"       # sent messages goes there (e.g. $folder/Sent-2006)\n")
            (fprintf cfg "set postponed=+postponed              # an 'internal' box for mutt basically\n")
            (void)))
        (fprintf cfg "set spoolfile=+INBOX                  # incoming mails (~~/.mail/inbox)\n")
        (fprintf cfg "set mbox_type=mbox\n")
        (fprintf cfg "set move=yes                          # yes (move read mails automatically to $mbox)\n")
        (fprintf cfg "set keep_flagged=yes                  # esc-f to mark message in spool, and it won't move to $mbox)\n")
        (fprintf cfg "set mbox=+read_inbox                  # ~~/.mail/read_inbox\n")
        (fprintf cfg "set header_cache=~~/.mail/mutt_cache/ # a much faster opening of mailboxes\n")
        (fprintf cfg "set timeout=10                        # mutt 'presses' (like) a key for you (while you're idle) \n")
        (fprintf cfg "                                      # each x sec to trigger the thing below\n")
        (fprintf cfg "set mail_check=5                      # mutt checks for new mails on every keystroke\n")
        (fprintf cfg "                                      # but not more often then once in 5 seconds\n")
        (fprintf cfg "set beep_new                          # beep on new messages in the mailboxes\n")
        (fprintf cfg "\n# Mutt Guide: https://dev.mutt.org/trac/wiki/MuttGuide\n")
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
  (prompt/fail (apply format msg arg*)
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
         [rxEMAIL #rx"[^@]+@[^@.]+\\.[^@]+"]
         [lam (lambda (x) (if (regexp-match? rxEMAIL x) x INVALID-INPUT))])
    (lambda (reason)
      (prompt/fail (format msg reason) lam))))
