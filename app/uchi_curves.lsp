;;; UCHI Curves routines

(defun uchi:curve-major-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MAJOR") 5)))))
(defun uchi:curve-minor-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MINOR") 1)))))
(defun uchi:curve-ready-p () (> (length *uchi-points*) 2))

(defun uchi:curve-count (zmin zmax step / c z)
  (setq c 0 z zmin)
  (while (<= z zmax) (setq c (+ c 1) z (+ z step)))
  c
)

(defun C:UCHI_CURVAS_GEN (/ zmin zmax cmj cmn nmaj nmin st ymin ymax xmin xmax z y)
  (uchi:topo-init)
  (if (uchi:curve-ready-p)
    (progn
      (setq zmin (uchi:to-real (uchi:project-get "z_min")))
      (setq zmax (uchi:to-real (uchi:project-get "z_max")))
      (setq cmj (uchi:curve-major-interval) cmn (uchi:curve-minor-interval))
      (setq nmaj (uchi:curve-count zmin zmax cmj) nmin (uchi:curve-count zmin zmax cmn))
      (setq st (uchi:surface-stats))
      (setq xmin (cdr (assoc "xmin" st)) xmax (cdr (assoc "xmax" st)))
      (setq ymin (cdr (assoc "ymin" st)) ymax (cdr (assoc "ymax" st)))
      (setq z zmin)
      (while (<= z zmax)
        (setq y (+ ymin (* (/ (- z zmin) (max 0.0001 (- zmax zmin))) (- ymax ymin))))
        (uchi:draw-line (list xmin y 0.0) (list xmax y 0.0) "UCHI_CURVES")
        (setq z (+ z cmn))
      )
      (uchi:log (strcat "Curvas: dibujadas menores=" (itoa nmin) ", mayores=" (itoa nmaj)))
    )
    (uchi:log "Curvas: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
