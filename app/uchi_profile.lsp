;;; UCHI Profile routines

(defun uchi:profile-length (/ prev p len)
  (setq len 0.0)
  (setq prev nil)
  (foreach p *uchi-points*
    (if prev (setq len (+ len (uchi:point-distance2d prev p))))
    (setq prev p)
  )
  len
)

(defun C:UCHI_PERFIL (/ l)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (uchi:log (strcat "Perfil: longitud base = " (rtos l 2 2) " m."))
      (uchi:log "Perfil: generado (modo inicial).")
    )
    (uchi:log "Perfil: faltan puntos suficientes para generar perfil.")
  )
  (princ)
)

(princ)
