#lang racket

(require
  "sonic-pi/startup.rkt"
  (for-syntax syntax/parse))

;; all kinds of interesting interface questions here. Implicit sequence
;; wrapped around the whole thing? Implicit parallelism for loops next to
;; each other? How does Sonic Pi handle this?

;; very nice how sonic pi saves state, reopens desktop

;; optional arguments seem very important, here.

;; sonic pi uses ADSR from the get-go.

;; create a synth for every note?

;; a uscore is a representation of a user's program
;; a uscore is a list of uevents

#;((match-define (list job-synth-group job-mixer) (start-job))
(time (synchronize))
(time (synchronize))
(play-note job-synth-group 60)
(sleep 1)
(play-note job-synth-group 61)
(sleep 1)
(play-note job-synth-group 62)
(sleep 2)
(end-job job-synth-group job-mixer)
)

(define (queue-events score)
  (printf "not actually queueing events: ~v\n"
          score))

(define (uscore->score uscore vtime)
  (cond [(empty? uscore) empty]
        [else (cond [(pisleep? (first uscore))
                     (uscore->score (rest uscore)
                                    (+ vtime (pisleep-duration
                                              (first uscore))))]
                    [(synth-note? (first uscore))
                     (cons (list vtime (first uscore))
                           (uscore->score (rest uscore)
                                          vtime))])]))

(define (play uscore)
  (queue-events (uscore->score uscore 0)))

(define (psleep t)
  (pisleep t))

(struct pisleep (duration) #:prefab)
;; will we be re-using instruments?
(struct synth-note (name note release) #:prefab)

(define (synth name #:note [note 60]
               #:release [release 1])
  (synth-note name note release))

(define-syntax (go stx)
  (syntax-parse stx
    [(_ e:expr ...) #'(play (list e ...))]))

(go
 (synth 'beep #:note 60)
 (psleep 4)
 (synth 'beep #:note 66))