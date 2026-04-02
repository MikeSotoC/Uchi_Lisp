;;; UCHI Drenaje / Cunetas

(defun uchi:drain-interval () (max 1.0 (uchi:to-real (or (getenv "UCHI_CFG_DRAIN_INT") 20.0))))
(defun uchi:drain-offset () (max 0.5 (uchi:to-real (or (getenv "UCHI_CFG_DRAIN_OFFSET") 4.0))))
(defun uchi:drain-width () (max 0.5 (uchi:to-real (or (getenv "UCHI_CFG_DRAIN_WIDTH") 2.0))))
(defun uchi:drain-depth () (max 0.1 (uchi:to-real (or (getenv "UCHI_CFG_DRAIN_DEPTH") 0.5))))

(defun uchi:drain-normal (pk)
  (if (fboundp 'uchi:stakeout-normal)
    (uchi:stakeout-normal pk)
    (list 0.0 1.0)
  )
)

(defun uchi:drain-center-point (pk side / p n off)
  (setq p (if (fboundp 'uchi:plan-point-at-chainage) (uchi:plan-point-at-chainage pk) nil))
  (setq n (uchi:drain-normal pk))
  (setq off (* side (uchi:drain-offset)))
  (if p
    (list (+ (car p) (* off (car n)))
          (+ (cadr p) (* off (cadr n)))
          (- (nth 2 p) (uchi:drain-depth)))
    nil
  )
)

(defun uchi:drain-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_drainage.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "pk,type,x1,y1,z1,x2,y2,z2,slope_pct" fp)
      (foreach r rows
        (write-line
          (strcat
            (rtos (car r) 2 2) "," (nth 1 r) ","
            (rtos (nth 2 r) 2 3) "," (rtos (nth 3 r) 2 3) "," (rtos (nth 4 r) 2 3) ","
            (rtos (nth 5 r) 2 3) "," (rtos (nth 6 r) 2 3) "," (rtos (nth 7 r) 2 3) ","
            (rtos (nth 8 r) 2 3)
          )
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun uchi:drain-slope-pct (a b / dz dxy)
  (setq dz (- (nth 2 b) (nth 2 a)))
  (setq dxy (max 0.0001 (distance (list (car a) (cadr a) 0.0) (list (car b) (cadr b) 0.0))))
  (* 100.0 (/ dz dxy))
)

(defun C:UCHI_DRENAJE (/ l pk step w rows lc rc lprev rprev n a b slope)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (setq step (uchi:drain-interval))
      (setq w (uchi:drain-width))
      (setq pk 0.0 rows nil lprev nil rprev nil)
      (while (<= pk l)
        (setq lc (uchi:drain-center-point pk -1.0))
        (setq rc (uchi:drain-center-point pk 1.0))
        (if (and lc rc)
          (progn
            ;; Cuneta transversal
            (setq n (uchi:drain-normal pk))
            (setq a (list (- (car lc) (* 0.5 w (car n))) (- (cadr lc) (* 0.5 w (cadr n))) (nth 2 lc)))
            (setq b (list (+ (car lc) (* 0.5 w (car n))) (+ (cadr lc) (* 0.5 w (cadr n))) (- (nth 2 lc) 0.05)))
            (uchi:draw-line a b "UCHI_DRAINAGE")
            (setq slope (uchi:drain-slope-pct a b))
            (setq rows (append rows (list (list pk "trans_left" (car a) (cadr a) (nth 2 a) (car b) (cadr b) (nth 2 b) slope))))

            (setq a (list (- (car rc) (* 0.5 w (car n))) (- (cadr rc) (* 0.5 w (cadr n))) (- (nth 2 rc) 0.05)))
            (setq b (list (+ (car rc) (* 0.5 w (car n))) (+ (cadr rc) (* 0.5 w (cadr n))) (nth 2 rc)))
            (uchi:draw-line a b "UCHI_DRAINAGE")
            (setq slope (uchi:drain-slope-pct a b))
            (setq rows (append rows (list (list pk "trans_right" (car a) (cadr a) (nth 2 a) (car b) (cadr b) (nth 2 b) slope))))

            ;; Cunetas longitudinales
            (if lprev
              (progn
                (uchi:draw-line lprev lc "UCHI_DRAINAGE")
                (setq slope (uchi:drain-slope-pct lprev lc))
                (setq rows (append rows (list (list pk "long_left" (car lprev) (cadr lprev) (nth 2 lprev) (car lc) (cadr lc) (nth 2 lc) slope))))
              )
            )
            (if rprev
              (progn
                (uchi:draw-line rprev rc "UCHI_DRAINAGE")
                (setq slope (uchi:drain-slope-pct rprev rc))
                (setq rows (append rows (list (list pk "long_right" (car rprev) (cadr rprev) (nth 2 rprev) (car rc) (cadr rc) (nth 2 rc) slope))))
              )
            )
            (setq lprev lc rprev rc)
          )
        )
        (setq pk (+ pk step))
      )
      (uchi:drain-export-csv rows)
      (uchi:project-set "drain_segments" (length rows))
      (uchi:project-set "drain_interval" step)
      (uchi:project-save)
      (uchi:log (strcat "Drenaje generado. Segmentos=" (itoa (length rows)) ", CSV=uchi_drainage.csv"))
    )
    (uchi:log "Drenaje: se requieren al menos 2 puntos.")
  )
  (princ)
)

(princ)
