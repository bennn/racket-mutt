#lang racket/base

(provide setup-mutt!)

(require mutt/private/pre-install)

;; -----------------------------------------------------------------------------

(define (setup-mutt!)
  (printf "[mutt] checking `mutt` configuration...\n")
  (pre-installer #f #f)
  (printf "[mutt] success\n"))
