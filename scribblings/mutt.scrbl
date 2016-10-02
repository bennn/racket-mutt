#lang scribble/manual
@require[
  scribble/eval
  scriblib/footnote
  racket/contract
  mutt
  (for-label racket/base racket/contract)
]

@title[#:tag "top"]{Mutt API}
@author[@hyperlink["https://github.com/bennn"]{Ben Greenman}]

@defmodule[mutt]

@(define mutt-exe @hyperlink["http://www.mutt.org/"]{Mutt})
@(define muttrc @tt{~/.muttrc})

@; -----------------------------------------------------------------------------

Racket API for the @|mutt-exe| email client.

@margin-note{This package does not support Windows.}

Goals:
@itemlist[
  @item{
    Installing the package configures @tt{mutt}.
  }
  @item{
    Convenient API for sending emails.
  }
]

Example:
@racketblock[
  (require mutt)

  (parameterize ([*mutt-default-cc* '("beyonce@jayz.gov")])
    (mutt "can you hear me?" #:to "justin@beiber.edu" #:subject "Hello"))
]


@section{Install}

@itemlist[
  @item{
    Install @|mutt-exe| through your local package manager.
    @itemlist[
      @item{
        On Mac, try @tt{brew install mutt}
      }
      @item{
        On Ubuntu, use @tt{sudo apt-get install mutt}
      }
    ]
  }
  @item{
    Run @tt{raco pkg install mutt}.
    When prompted, enter your email address and name.
  }
  @item{
    (optional) make further edits to your @|muttrc| file.
  }
]

If you delete your @|muttrc| file, running @tt{raco pkg update mutt} will rebuild it interactively.
Alternatively, the @racketmodname[mutt/setup] module provides a hook for reconfiguring @tt{mutt}.

@defmodule[mutt/setup]

@defproc[(setup-mutt!) void?]{
  Checks that the @tt{mutt} utility is available and creates a default @|muttrc| file if none exists.

  This function sends prompts to @racket[current-output-port] and expects responses on @racket[current-input-port].
}


@section{API}
@(define mutt-eval
   (make-base-eval
     '(begin (require mutt racket/port)
             (*mutt-exe-path* "xargs echo ")
             (current-output-port (open-output-nowhere)))))

@defproc[(mutt [message path-string?]
               [#:to to email?]
               [#:subject subject string? (*mutt-default-subject*)]
               [#:cc cc pre-email*/c (*mutt-default-cc*)]
               [#:bcc bcc pre-email*/c (*mutt-default-bcc*)])
         boolean?]{
  Send an email to the address @racket[to] with subject @racket[subject] and message body @racket[message].
  If @racket[message] is a filename, the email contains the contents of the file.
  Otherwise, the email contains the string @racket[message].

  Send carbon copies to the @racket[cc] addresses; these are public recipients of the same message.
  Send blind carbon copies to the @racket[bcc] addresses; the @racket[to] address will not see the identity of @racket[bcc]s.

  @examples[#:eval mutt-eval
    (mutt "sry"
          #:to "tswift@gmail.com"
          #:subject "We Are Never Ever Getting Back Together")

    (mutt "https://www.youtube.com/watch?v=eLYbDg242EY"
          #:to "support@comcast.com"
          #:subject "10 Craziest YouTube Fails"
          #:cc "everyone@the.net")
  ]
}

@defproc[(mutt* [message path-string?]
                [#:to* to pre-email*/c]
                [#:subject subject string? (*mutt-default-subject*)]
                [#:cc cc pre-email*/c (*mutt-default-cc*)]
                [#:bcc bcc pre-email*/c (*mutt-default-bcc*)])
         boolean?]{
  For each recipient address in @racket[to*], send an identical email message and include the same cc's and bcc's.

  @examples[#:eval mutt-eval
    (define pilots
      (for/list ([i (in-range 1 22)])
        (format "pilot~a@billboard.com" i)))
    (mutt* "all my friends are heathens"
           #:to* pilots
           #:subject "helpme")
  ]
}

@defproc[(email? [str string]) (or/c #f string)]{
  Returns @racket[#f] if @racket[str] does not match a basic regular expression for email addresses.

  @examples[#:eval mutt-eval
    (email? "support@racket-lang.org")
    (email? "foo@bar.baz")
    (email? "a16_@36.21.asdvu")
    (email? "yo lo@dot.com")
  ]
}

@defthing[pre-email/c (or/c path-string? string?)]{
  Value that the API can convert to a sequence of email addresses.
  These are:
  @itemlist[
    @item{
      strings that pass the @racket[email?] predicate
    }
    @item{
      files that contain newline-separated email addresses
    }
  ]
}

@defthing[pre-email*/c (or/c pre-email/c (listof pre-email/c))]{
  Value or sequence that the API can flatten into a sequence of email addresses.
}

@defproc[(in-email* [pre* pre-email*/c]) (listof email?)]{
  Coerce a sequence of values into a flat list of email addresses.
  Ignores strings in @racket[pre*] that do not pass the @racket[email?] predicate (but prints a warning to @racket[current-output-port]).
  Raises an argument error if @racket[pre*] contains a path that does not exist on the local filesystem.
}

@subsection{Options and Parameters}

@defparam[*mutt-default-subject* subject string? #:value "<no-subject>"]{
  Default subject to use in email addresses.
}

@defparam[*mutt-default-cc* addrs (listof email?) #:value '()]{
  List of addresses to cc by default.
}

@defparam[*mutt-default-bcc* addrs (listof email?) #:value '()]{
  List of addresses to bcc by default.
}

@defparam[*mutt-exe-path* path (or/c #f path-string?) #:value (find-executable-path "mutt")]{
  Path to your @|mutt-exe| executable.
  If @racket[#f], calls to @racket[mutt] will fail.
}

@include-section{typed-mutt.scrbl}


@section{FAQ}

@;@(define (question q . a*)
@;   @(elem (bold q)
@;          "\n"
@;          (elem a*)))

@bold{Q. gmail says 'This message may not have been sent by ....'}

  The problem is that you are using a gmail address but haven't given gmail authentication info in your @|muttrc|.
  I am not sure what info is required; better answer coming soon.
