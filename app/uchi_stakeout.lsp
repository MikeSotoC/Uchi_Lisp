;;; UCHI Stakeout / Replanteo

(defun uchi:stakeout-interval () (max 1.0 (uchi:to-real (or (getenv "UCHI_CFG_STAKEOUT_INT") 20.0))))
(defun uchi:stakeout-offset () (max 0.0 (uchi:to-real (or (getenv "UCHI_CFG_STAKEOUT_OFFSET") 5.0))))

(defun uchi:plan-point-at-chainage (pk / p)
  (setq p (uchi:point-at-chainage pk))
  (if p (list (cadr p) (caddr p) (nth 3 p)) nil)
)

(defun uchi:stakeout-normal (pk / p1 p2 dx dy n)
  (setq p1 (uchi:plan-point-at-chainage pk))
  (setq p2 (uchi:plan-point-at-chainage (+ pk 0.5)))
  (if (and p1 p2)
    (progn
      (setq dx (- (car p2) (car p1)))
      (setq dy (- (cadr p2) (cadr p1)))
      (setq n (max 0.0001 (sqrt (+ (* dx dx) (* dy dy)))))
      (list (/ (- dy) n) (/ dx n))
    )
    (list 0.0 1.0)
  )
)

(defun uchi:stakeout-export-csv (rows / path fp first r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_stakeout.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "pk,offset,x,y,z" fp)
      (foreach r rows
        (write-line
          (strcat (rtos (car r) 2 2) "," (rtos (cadr r) 2 2) ","
                  (rtos (nth 2 r) 2 3) "," (rtos (nth 3 r) 2 3) "," (rtos (nth 4 r) 2 3))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_STAKEOUT (/ l pk step off n c rows x y z p)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (setq step (uchi:stakeout-interval))
      (setq off (uchi:stakeout-offset))
      (setq pk 0.0 rows nil)
      (while (<= pk l)
        (setq p (uchi:plan-point-at-chainage pk))
        (if p
          (progn
            (setq n (uchi:stakeout-normal pk))
            (foreach c (list (- off) 0.0 off)
              (setq x (+ (car p) (* c (car n))))
              (setq y (+ (cadr p) (* c (cadr n))))
              (setq z (nth 2 p))
              (uchi:draw-point (list x y z) "UCHI_STAKEOUT")
              (setq rows (append rows (list (list pk c x y z))))
            )
          )
        )
        (setq pk (+ pk step))
      )
      (uchi:stakeout-export-csv rows)
      (uchi:project-set "stakeout_interval" step)
      (uchi:project-set "stakeout_offset" off)
      (uchi:project-set "stakeout_points" (length rows))
      (uchi:project-save)
      (uchi:log (strcat "Stakeout generado. Puntos=" (itoa (length rows)) ", CSV=uchi_stakeout.csv"))
    )
    (uchi:log "Stakeout: se requieren al menos 2 puntos.")
  )
  (princ)
)

(princ)
