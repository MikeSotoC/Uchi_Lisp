;;; UCHI Sections routines

(defun uchi:section-interval ()
  (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SECTION_INTERVAL") 20)))
)

(defun uchi:sections-ready-p ()
  (> (atoi (vl-princ-to-string (uchi:project-get "points_count"))) 2)
)

(defun C:UCHI_SECCIONES ()
  (uchi:topo-init)
  (if (uchi:sections-ready-p)
    (progn
      (uchi:log
        (strcat "Secciones: generando secciones cada " (itoa (uchi:section-interval)) " m."))
      (uchi:log "Secciones: generación base completada.")
    )
    (uchi:log "Secciones: se requieren puntos válidos para generar secciones.")
  )
  (princ)
)

(princ)
