#lang racket/base

;; provide
(define-syntax-rule (defparam id : t val)
  (begin
    (define id #;: #;(Parameterof t) (make-parameter val))
    (provide id)))

;; =============================================================================

;(define-type Email String)

(defparam *mutt-default-subject* : String "<no-subject>")

(defparam *mutt-default-cc* : (Listof Email) '())
(defparam *mutt-default-bcc* : (Listof Email) '())

(defparam *mutt-exe-path* : Path-String (find-executable-path "mutt"))
