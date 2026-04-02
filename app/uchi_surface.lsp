;;; UCHI Surface routines

(defun uchi:points-count ()
  (atoi (vl-princ-to-string (uchi:project-get "points_count")))
)

(defun uchi:surface-ready-p ()
  (> (uchi:points-count) 2)
)

(defun C:UCHI_SUPERFICIE ()
  (uchi:topo-init)
  (if (uchi:surface-ready-p)
    (progn
      (uchi:log (strcat "Superficie: generando TIN con " (itoa (uchi:points-count)) " puntos."))
      (uchi:log "Superficie: TIN base generado.")
    )
    (uchi:log "Superficie: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
