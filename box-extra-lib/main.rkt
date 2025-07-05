#lang racket/base

(require racket/contract/base
         "unsafe.rkt")

(provide
 box-update-strategy/c
 box-update-proc/c
 (contract-out
  [rename
   make-unsafe-box-update-proc
   make-box-update-proc
   (->* [box?]
        [box-update-strategy/c]
        box-update-proc/c)]
  [rename
   unsafe-box-update/busy!
   box-update/busy!
   (-> box? update-proc/c any/c)]
  [rename
   unsafe-box-update/semaphore!
   box-update/semaphore!
   (-> box? semaphore? update-proc/c any/c)]))

(define update-proc/c
  (-> any/c any/c))

(define box-update-strategy/c
  (or/c 'busy 'semaphore))

(define box-update-proc/c
  (-> (-> any/c any/c) any/c))
