#lang scribble/manual

@(require scribble/example
          (for-label box-extra
                     box-extra/unsafe
                     racket/base
                     racket/contract))

@title{@tt{box-extra}: box utilities}
@author[(author+email "Bogdan Popa" "bogdan@defn.io")]
@defmodule[box-extra]

@(define (box-tech label)
   (tech #:doc '(lib "scribblings/reference/reference.scrbl")
         #:key "box"
         label))

Extra utilities for working with @box-tech{boxes}.


@section{Reference}

@deftogether[(
  @defthing[box-update-strategy/c (or/c 'busy 'semaphore)]
  @defthing[box-update-proc/c (-> (-> any/c any/c) any/c)]
)]

@defproc[(make-box-update-proc [b box?]
                               [strategy box-update-strategy/c 'semaphore]) box-update-proc/c]{

  Returns a procedure that may be used to update the value within
  @racket[b] using the given retry @racket[strategy].

  The @racket['semaphore] strategy synchronizes retrying threads using
  a semaphore.  See @racket[box-update/semaphore!] for details.

  The @racket['busy] strategy retries without any sort of backoff.
  See @racket[box-update/busy!] for details.

  @examples[
    (require box-extra)
    (define b (box 0))
    (define update-b! (make-box-update-proc b))
    (update-b! add1)
    (unbox b)
  ]
}

@defproc[(box-update/busy! [b box?]
                           [proc (-> any/c any/c)]) any/c]{

  Updates @racket[b] by applying @racket[proc] to its current value.
  When @racket[box-cas!] is fails, it retries immediately.  Returns
  the value that was last put in the box.

  Prefer @racket[box-update/semaphore!] over this function.  Only use
  this function if you're sure that multiple threads won't attempt to
  update @racket[b] concurrently.
}

@defproc[(box-update/semaphore! [b box?]
                                [sema semaphore?]
                                [proc (-> any/c any/c)]) any/c]{

  Updates @racket[b] by applying @racket[proc] to its current value.
  When @racket[box-cas!] fails, it waits on @racket[sema] before
  retrying.  Returns the value that was last put in the box.

  The @racket[sema] argument must have an initial count of @racket[1].

  @examples[
    (require box-extra)
    (define b (box 0))
    (define sema (make-semaphore 1))
    (define thds
      (list
       (thread (λ () (box-update/semaphore! b sema add1)))
       (thread (λ () (box-update/semaphore! b sema add1)))))
    (for-each thread-wait thds)
    (unbox b)
  ]
}


@subsection{Unsafe API}
@defmodule[box-extra/unsafe]

@deftogether[(
  @defproc[(make-unsafe-box-update-proc [b box?]
                                        [strategy box-update-strategy/c 'semaphore]) box-update-proc/c]
  @defproc[(unsafe-box-update/busy! [b box?]
                                    [proc (-> any/c any/c)]) any/c]
  @defproc[(unsafe-box-update/semaphore! [b box?]
                                         [sema semaphore?]
                                         [proc (-> any/c any/c)]) any/c]
)]{

  Unsafe variants of @racket[make-box-update-proc],
  @racket[box-update/busy!] and @racket[box-update/semaphore!],
  respectively.
}
