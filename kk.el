(require 'elnode)

;; You can define a handler function:

(defun create-attack-action (me target)
  (setq arr [nil nil nil])
  (aset arr 0 (alist-get 'id me))
  (aset arr 1 "attack")
  (aset arr 2 (list (cons 'x (alist-get 'x target))
                    (cons 'y (alist-get 'y target))))
  (copy-sequence arr))

(defun create-heal-action (me target)
  (setq arr [nil nil nil])
  (aset arr 0 (alist-get 'id me))
  (aset arr 1 "heal")
  (aset arr 2 (list (cons 'x (alist-get 'x target))
                    (cons 'y (alist-get 'y target))))
  (copy-sequence arr))

(defun create-move-action (me direction)
  (setq arr [nil nil nil])
  (aset arr 0 (alist-get 'id me))
  (aset arr 1 "move")
  (aset arr 2 (list (cons 'x (+ (alist-get 'x me) (cl-case direction ('up 0) ('down 0) ('left -1) ('right 1))))
                    (cons 'y (+ (alist-get 'y me) (cl-case direction ('up -1) ('down 1) ('left 0) ('right 0))))))
  (copy-sequence arr))

(defun attack-actions (target)
  (--keep (when (can-hit? it target)
            (create-attack-action it target))
          friendly-units))

(defun directions-to (me target)
  (setq dirs ())
  (when (< (alist-get 'x me) (alist-get 'x target))
    (!cons 'right dirs))
  (when (> (alist-get 'x me) (alist-get 'x target))
    (!cons 'left dirs))
  (when (< (alist-get 'y me) (alist-get 'y target))
    (!cons 'down dirs))
  (when (> (alist-get 'y me) (alist-get 'y target))
    (!cons 'up dirs))
  dirs)

(defun nshuffle (sequence)
  (cl-loop for i from (length sequence) downto 2
           do (cl-rotatef (elt sequence (random i))
                          (elt sequence (1- i))))
  sequence)

(defun move-towards (me target)
  (--map (create-move-action me it)
         (nshuffle (directions-to me target))))

(defun my-test-handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon 200 '("Content-type" . "application/json"))

  (setq params (elnode-http-params httpcon))
  (setq data
        (json-read-from-string
         (caar params)))

  (setq enemy-units (mapcar 'identity (alist-get 'enemy-units data)))
  (setq friendly-units (mapcar 'identity (alist-get 'friendly-units data)))

  (setq healer (--find (alist-get 'heals it) friendly-units))

  (setq heal-target nil)
  (when healer
    (setq heal-target (--find (and (can-hit? healer it)
                                   ;; (< (alist-get 'health it)
                                   ;;    (alist-get 'max-health it))
                                   (not (eq healer it)))
                              friendly-units))
    (when heal-target
      (setq opportunity-heal (create-heal-action healer heal-target))))

  (setq target (car (--sort (+ (alist-get 'health it)
                               (alist-get 'armor it))
                            (nshuffle enemy-units))))

  (setq opportunity-attacks (-mapcat 'attack-actions enemy-units))
  (setq moves-to-target (--mapcat (move-towards it target)
                                  (--remove (can-hit? it target) friendly-units)))
  (setq attacks-on-target (--map (create-attack-action it target) friendly-units))

  (elnode-http-return httpcon (json-encode
                               (-concat (when heal-target (list opportunity-heal))
                                        opportunity-attacks
                                        moves-to-target
                                        attacks-on-target))))

;; And then start the server:

(defun rand-nth (coll)
  (nth (random (length coll)) coll))

(defun range-between (a b)
  (+ (abs (- (alist-get 'x a)
             (alist-get 'x b)))
     (abs (- (alist-get 'y a)
             (alist-get 'y b)))))

(defun can-hit? (me target)
  (= (or (alist-get 'range me) 1)
     (range-between me target)))

(require 'json)

(comment
 (elnode-start 'my-test-handler :port 8010 :host "0.0.0.0")

 )
