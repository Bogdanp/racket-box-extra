#lang info

(define license 'BSD-3-Clause)
(define version "1.0")
(define collection 'multi)
(define deps '("base"))
(define build-deps '("racket-doc"
                     "box-extra-lib"
                     "rackunit-lib"
                     "scribble-lib"))
(define update-implies '("box-extra-lib"))
