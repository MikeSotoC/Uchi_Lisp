;;; UCHI Sections routines

(defun uchi:section-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SECTION_INTERVAL") 20)))))
(defun uchi:sections-ready-p () (> (length *uchi-points*) 2))

(defun C:UCHI_SECCIONES (/ l i n)
  (uchi:topo-init)
  (if (uchi:sections-ready-p)
    (progn
      (setq l (uchi:profile-length))
      (setq i (uchi:section-interval))
      (setq n (+ 1 (fix (/ l i))))
      (uchi:log (strcat "Secciones: " (itoa n) " estaciones cada " (itoa i) " m sobre " (rtos l 2 2) " m."))
      (uchi:log "Secciones: generación base completada.")
    )
    (uchi:log "Secciones: se requieren puntos válidos para generar secciones.")
  )
  (princ)
)

(princ)
