;;; UCHI Curves routines

(defun uchi:curve-major-interval () (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MAJOR") 5))))
(defun uchi:curve-minor-interval () (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MINOR") 1))))
(defun uchi:curve-ready-p () (> (length *uchi-points*) 2))

(defun uchi:curve-count (zmin zmax step / c z)
  (setq c 0)
  (setq z zmin)
  (while (<= z zmax)
    (setq c (+ c 1))
    (setq z (+ z step))
  )
  c
)

(defun C:UCHI_CURVAS_GEN (/ zmin zmax cmj cmn nmaj nmin)
  (uchi:topo-init)
  (if (uchi:curve-ready-p)
    (progn
      (setq zmin (uchi:to-real (uchi:project-get "z_min")))
      (setq zmax (uchi:to-real (uchi:project-get "z_max")))
      (setq cmj (max 1 (uchi:curve-major-interval)))
      (setq cmn (max 1 (uchi:curve-minor-interval)))
      (setq nmaj (uchi:curve-count zmin zmax cmj))
      (setq nmin (uchi:curve-count zmin zmax cmn))
      (uchi:log (strcat "Curvas: menores=" (itoa nmin) ", mayores=" (itoa nmaj) ", zmin=" (rtos zmin 2 2) ", zmax=" (rtos zmax 2 2)))
      (uchi:log "Curvas: generación base completada.")
    )
    (uchi:log "Curvas: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
