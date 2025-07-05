#lang racket/base

(provide
 make-unsafe-box-update-proc
 unsafe-box-update/busy!
 unsafe-box-update/semaphore!)

(define (make-unsafe-box-update-proc b [strat 'semaphore])
  (case strat
    [(busy)
     (λ (proc)
       (unsafe-box-update/busy! b proc))]
    [(semaphore)
     (let ([sema (make-semaphore 1)])
       (λ (proc)
         (unsafe-box-update/semaphore! b sema proc)))]
    [else
     (raise-argument-error 'make-unsafe-box-update-proc "(or/c 'busy 'semaphore)" strat)]))

(define (unsafe-box-update/busy! b proc)
  (let loop ([old (unbox b)])
    (define new (proc old))
    (cond
      [(box-cas! b old new) new]
      [else (loop (unbox b))])))

(define (unsafe-box-update/semaphore! b sema proc)
  (let loop ([old (unbox b)] [acquired? #f])
    (define new (proc old))
    (cond
      [(box-cas! b old new) new]
      [(eq? (unbox b) old) (loop old acquired?)]
      [acquired? (loop (unbox b) #t)]
      [else
       (dynamic-wind
         (λ () (semaphore-wait sema))
         (λ () (loop (unbox b) #t))
         (λ () (semaphore-post sema)))])))
