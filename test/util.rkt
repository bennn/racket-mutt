#lang typed/racket/base

(provide
  email_addrs
  sample_msg
  str+rx*=?
  mutt-message-rx
  mutt-interceptor)

(require/typed mutt/private/main
  (mutt-logger Logger))

(require/typed make-log-interceptor
  (make-log-interceptor
    (-> Logger Log-Interceptor)))

(define-type Log-Interceptor
  (->* [(-> Any)]
       [#:level Symbol
        #:topic (U Symbol #false)]
       (Values Any (HashTable Symbol Any))))

;; -----------------------------------------------------------------------------

(define email_addrs "./email_addrs.txt")
(define sample_msg  "./sample_message.txt")
(define mutt-message-rx #rx"mutt-message-[0-9].txt")

(: str+rx*=? (-> (Listof String) (Listof (U String Regexp)) Boolean))
(define (str+rx*=? a* b*)
  (and (= (length a*) (length b*))
       (for/and ((a (in-list a*))
                 (b (in-list b*)))
         (cond
           [(string? b)
            (string=? a b)]
           [(regexp? b)
            (regexp-match? b a)]
           [else
             #false]))))

(: mutt-interceptor Log-Interceptor)
(define mutt-interceptor (make-log-interceptor mutt-logger))
