racket-mutt
====
[![Build Status](https://travis-ci.org/bennn/racket-mutt.svg)](https://travis-ci.org/bennn/racket-mutt)
[![Scribble](https://img.shields.io/badge/Docs-Scribble-blue.svg)](http://docs.racket-lang.org/racket-mutt/index.html)

Racket `mutt` API.
Installing this package helps setup `mutt`. Then you can send emails:

```
#lang racket/base
(require mutt)

(mutt "Listen, Boy"
      #:subject "My First Love Story"
      #:to "geegeegeegee@baby.baby")
```

NOTE: this package does not currently support Windows systems.


Install
---

First install the free [`mutt`](http://www.mutt.org/) email client.
It's on [Homebrew](http://brew.sh/) and your local Linux package manager.

Second, install this package from the [Racket package server](http://pkgs.racket-lang.org)

```
$ raco pkg install mutt
```

or Github (the `./` is necessary).

```
$ git clone https://github.com/bennn/racket-mutt
$ raco pkg install ./racket-mutt
```

When prompted, enter your email address and real name.


API
---

- `(mutt message #:to recipient #:subject subject #:cc cc #:bcc bcc)`
  Send `message` to the address `recipient` with subject `subject`.
  Send carbon-copies to the `cc` and blind carbon copies to the `bcc`.
- `(mutt* message #:to* recipients)`
  Similar to `mutt`, but send the same message to a list of recipients.
  Accepts the same options too, except for `#:to`.

See the documentation for more.
In particular, `message` can be a string or a file with newline-separated emails.


FAQ
---

#### Q. gmail says "This message may not have been send by <me>"

This happens if you are sending from a gmail address to another gmail address.
Changing your `~/.muttrc` should fix it, but I don't know how yet. See [Issue 1](https://github.com/bennn/racket-mutt/issues/1).

