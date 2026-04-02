;;; UCHI Profile routines

(defun uchi:profile-length (/ prev p len)
  (setq len 0.0 prev nil)
  (foreach p *uchi-points*
    (if prev (setq len (+ len (uchi:point-distance2d prev p))))
    (setq prev p)
  )
  len
)

(defun uchi:profile-polyline-points (/ prev p acc x)
  (setq prev nil acc nil x 0.0)
  (foreach p *uchi-points*
    (if prev (setq x (+ x (uchi:point-distance2d prev p))))
    (setq acc (append acc (list (list x (nth 3 p)))))
    (setq prev p)
  )
  acc
)

(defun C:UCHI_PERFIL (/ l pts)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (setq pts (uchi:profile-polyline-points))
      (uchi:draw-polyline-2d pts "UCHI_PROFILE")
      (uchi:log (strcat "Perfil: dibujado, longitud=" (rtos l 2 2) " m."))
    )
    (uchi:log "Perfil: faltan puntos suficientes para generar perfil.")
  )
  (princ)
)

(princ)
