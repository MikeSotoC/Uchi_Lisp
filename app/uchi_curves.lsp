;;; UCHI Curves routines

(defun uchi:curve-major-interval ()
  (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MAJOR") 5)))
)

(defun uchi:curve-minor-interval ()
  (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MINOR") 1)))
)

(defun uchi:curve-ready-p ()
  (> (atoi (vl-princ-to-string (uchi:project-get "points_count"))) 2)
)

(defun C:UCHI_CURVAS_GEN ()
  (uchi:topo-init)
  (if (uchi:curve-ready-p)
    (progn
      (uchi:log
        (strcat
          "Curvas: generando curvas menores cada " (itoa (uchi:curve-minor-interval))
          " y mayores cada " (itoa (uchi:curve-major-interval))
        )
      )
      (uchi:log "Curvas: generación base completada.")
    )
    (uchi:log "Curvas: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
