;;; UCHI Surface routines

(defun uchi:surface-ready-p () (> (length *uchi-points*) 2))

(defun uchi:surface-stats (/ xmin xmax ymin ymax p area)
  (if (not *uchi-points*)
    nil
    (progn
      (setq xmin (cadr (car *uchi-points*)) xmax xmin)
      (setq ymin (caddr (car *uchi-points*)) ymax ymin)
      (foreach p *uchi-points*
        (if (< (cadr p) xmin) (setq xmin (cadr p)))
        (if (> (cadr p) xmax) (setq xmax (cadr p)))
        (if (< (caddr p) ymin) (setq ymin (caddr p)))
        (if (> (caddr p) ymax) (setq ymax (caddr p)))
      )
      (setq area (* (- xmax xmin) (- ymax ymin)))
      (list (cons "xmin" xmin) (cons "xmax" xmax) (cons "ymin" ymin) (cons "ymax" ymax) (cons "area" area))
    )
  )
)

(defun C:UCHI_SUPERFICIE (/ st bbox p)
  (uchi:topo-init)
  (if (uchi:surface-ready-p)
    (progn
      (setq st (uchi:surface-stats))
      (foreach p *uchi-points* (uchi:draw-point (list (cadr p) (caddr p) (nth 3 p)) "UCHI_POINTS"))
      (setq bbox
        (list
          (list (cdr (assoc "xmin" st)) (cdr (assoc "ymin" st)))
          (list (cdr (assoc "xmax" st)) (cdr (assoc "ymin" st)))
          (list (cdr (assoc "xmax" st)) (cdr (assoc "ymax" st)))
          (list (cdr (assoc "xmin" st)) (cdr (assoc "ymax" st)))
          (list (cdr (assoc "xmin" st)) (cdr (assoc "ymin" st)))
        )
      )
      (uchi:draw-polyline-2d bbox "UCHI_SURFACE")
      (uchi:log (strcat "Superficie: puntos dibujados=" (itoa (length *uchi-points*)) ", área aprox=" (rtos (cdr (assoc "area" st)) 2 2)))
    )
    (uchi:log "Superficie: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
