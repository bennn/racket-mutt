#lang scribble/manual
@require[
  (for-label mutt/typed racket/base racket/contract
             (only-in typed/racket/base
               Path-String String Boolean Listof U Parameterof))
]

@title{Typed API}
@defmodule[mutt/typed]

Typed clients should import the @racketmodname[mutt/typed] module.

@deftogether[(
 @defthing[mutt (->* [Path-String
                      #:to Pre-Email*]
                     [#:subject String
                      #:cc Pre-Email*
                      #:bcc Pre-Email*
                      #:attachment (U #f Path-String (Listof Path-String))
                      #:reply-to (U #f String)]
                     Boolean)]
 @defthing[mutt* (->* [Path-String
                       #:to Pre-Email*]
                      [#:subject String
                       #:cc Pre-Email*
                       #:bcc Pre-Email*
                       #:attachment (U #f Path-String (Listof Path-String))]
                      Boolean)]
 @defthing[in-email* (-> Pre-Email* (Listof String))]
 @defthing[email? (-> String (U #f String))]
 @defthing[*mutt-default-subject* (Parameterof String)]
 @defthing[*mutt-default-cc* (Parameterof (Listof String))]
 @defthing[*mutt-default-bcc* (Parameterof (Listof String))]
 @defthing[*mutt-default-attachment* (Parameterof (Listof Path-String))]
 @defthing[*mutt-default-reply-to* (Parameterof (U #f String))]
 @defthing[*mutt-exe-path* (Parameterof Path-String)]
)]{}

Type signatures:
@deftogether[(
 @defthing[Pre-Email (U String Path-String)]
 @defthing[Pre-Email* (U Pre-Email (Listof Pre-Email))]
)]{}


