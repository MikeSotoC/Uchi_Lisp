;;; UCHI Sections routines

(defun uchi:section-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SECTION_INTERVAL") 20)))))
(defun uchi:sections-ready-p () (> (length *uchi-points*) 2))

(defun C:UCHI_SECCIONES (/ l i n x)
  (uchi:topo-init)
  (if (uchi:sections-ready-p)
    (progn
      (setq l (uchi:profile-length))
      (setq i (uchi:section-interval))
      (setq n (+ 1 (fix (/ l i))))
      (setq x 0.0)
      (repeat n
        (uchi:draw-line (list x -5.0 0.0) (list x 5.0 0.0) "UCHI_SECTIONS")
        (setq x (+ x i))
      )
      (uchi:log (strcat "Secciones: dibujadas " (itoa n) " estaciones cada " (itoa i) " m."))
    )
    (uchi:log "Secciones: se requieren puntos válidos para generar secciones.")
  )
  (princ)
)

(princ)
