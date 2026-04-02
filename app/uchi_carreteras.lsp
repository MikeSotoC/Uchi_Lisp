;;; UCHI Carreteras (plantilla base Perú)

(defun uchi:road-lane-width () (max 2.5 (uchi:to-real (or (getenv "UCHI_CFG_ROAD_LANE_WIDTH") 3.30))))
(defun uchi:road-lanes () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_ROAD_LANES") 2)))))
(defun uchi:road-shoulder () (max 0.5 (uchi:to-real (or (getenv "UCHI_CFG_ROAD_SHOULDER") 1.20))))
(defun uchi:road-crossfall () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_CROSSFALL") 2.0)))
(defun uchi:road-lane-width-min () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_LANE_MIN_M") 3.00)))
(defun uchi:road-shoulder-min () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_SHOULDER_MIN_M") 1.00)))
(defun uchi:road-crossfall-min () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_CROSSFALL_MIN_PCT") 1.5)))
(defun uchi:road-crossfall-max () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_CROSSFALL_MAX_PCT") 3.5)))
(defun uchi:road-superelev-max () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_SUPER_MAX_PCT") 8.0)))

(defun uchi:road-norm-ok ()
  (if (and (>= (uchi:road-lane-width) (uchi:road-lane-width-min))
           (>= (uchi:road-shoulder) (uchi:road-shoulder-min))
           (>= (abs (uchi:road-crossfall)) (uchi:road-crossfall-min))
           (<= (abs (uchi:road-crossfall)) (uchi:road-crossfall-max))
           (<= (abs (uchi:road-crossfall)) (uchi:road-superelev-max)))
    "SI"
    "NO"
  )
)

(defun uchi:road-export-csv (rows / path fp)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_carretera_norma.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "lanes,lane_m,lane_min_m,shoulder_m,shoulder_min_m,crossfall_pct,crossfall_min_pct,crossfall_max_pct,superelev_max_pct,cumple_norma,secciones" fp)
      (write-line
        (strcat (itoa (uchi:road-lanes)) "," (rtos (uchi:road-lane-width) 2 2) "," (rtos (uchi:road-lane-width-min) 2 2) ","
                (rtos (uchi:road-shoulder) 2 2) "," (rtos (uchi:road-shoulder-min) 2 2) ","
                (rtos (uchi:road-crossfall) 2 2) "," (rtos (uchi:road-crossfall-min) 2 2) ","
                (rtos (uchi:road-crossfall-max) 2 2) "," (rtos (uchi:road-superelev-max) 2 2) ","
                (uchi:road-norm-ok) "," (itoa rows))
        fp
      )
      (close fp)
    )
  )
)

(defun C:UCHI_CARRETERA (/ l pk step p n half e1 e2 rows w)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (setq step 20.0)
      (setq w (+ (* (uchi:road-lanes) (uchi:road-lane-width)) (* 2.0 (uchi:road-shoulder))))
      (setq half (/ w 2.0))
      (setq pk 0.0 rows 0)
      (while (<= pk l)
        (setq p (if (fboundp 'uchi:plan-point-at-chainage) (uchi:plan-point-at-chainage pk) nil))
        (setq n (if (fboundp 'uchi:stakeout-normal) (uchi:stakeout-normal pk) (list 0.0 1.0)))
        (if p
          (progn
            (setq e1 (list (+ (car p) (* (- half) (car n))) (+ (cadr p) (* (- half) (cadr n))) (nth 2 p)))
            (setq e2 (list (+ (car p) (* half (car n))) (+ (cadr p) (* half (cadr n))) (nth 2 p)))
            (uchi:draw-line e1 e2 "UCHI_ROAD")
            (setq rows (+ rows 1))
          )
        )
        (setq pk (+ pk step))
      )
      (uchi:project-set "road_sections" rows)
      (uchi:project-set "road_width" w)
      (uchi:project-set "road_crossfall_pct" (uchi:road-crossfall))
      (uchi:project-set "road_norm_ok" (uchi:road-norm-ok))
      (uchi:road-export-csv rows)
      (uchi:project-save)
      (uchi:log (strcat "Carretera plantilla generada. Secciones=" (itoa rows) ", ancho="
                        (rtos w 2 2) " m, norma=" (uchi:road-norm-ok) "."))
    )
    (uchi:log "Carretera: se requieren al menos 2 puntos.")
  )
  (princ)
)

(princ)
