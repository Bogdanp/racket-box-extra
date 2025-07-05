#lang racket/base

(module+ test
  (require box-extra
           box-extra/unsafe
           rackunit)

  (define b (box 0))
  (define (reset!)
    (set-box! b 0))
  (define update/busy! (make-box-update-proc b 'busy))
  (define update/semaphore! (make-box-update-proc b 'semaphore))
  (define unsafe-update/busy! (make-unsafe-box-update-proc b 'busy))
  (define unsafe-update/semaphore! (make-unsafe-box-update-proc b 'semaphore))

  (define-check (check-updater m n update! proc expected)
    (reset!)
    (collect-garbage)
    (collect-garbage)
    (time
     (for-each
      thread-wait
      (for/list ([_ (in-range m)])
        (thread
         (lambda ()
           (for ([_ (in-range n)])
             (update! proc)))))))
    (check-equal? (unbox b) expected))

  (define (bad-add1 x)
    (sleep 0)
    (add1 x))

  (check-updater 10 100000 update/busy! add1 1000000)
  (check-updater 10 100000 update/semaphore! add1 1000000)
  (check-updater 1000 10 update/busy! bad-add1 10000)
  (check-updater 1000 10 update/semaphore! bad-add1 10000)

  (check-updater 10 1000000 unsafe-update/busy! add1 10000000)
  (check-updater 10 1000000 unsafe-update/semaphore! add1 10000000)
  (check-updater 1000 10 unsafe-update/busy! bad-add1 10000)
  (check-updater 1000 10 unsafe-update/semaphore! bad-add1 10000))
