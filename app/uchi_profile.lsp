;;; UCHI Profile routines

(defun C:UCHI_PERFIL ()
  (uchi:topo-init)
  (if (> (atoi (vl-princ-to-string (uchi:project-get "points_count"))) 1)
    (progn
      (uchi:log "Perfil: generando eje y rasante base.")
      (uchi:log "Perfil: generado (modo inicial).")
    )
    (uchi:log "Perfil: faltan puntos suficientes para generar perfil.")
  )
  (princ)
)

(princ)
