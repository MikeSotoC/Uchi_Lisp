;;; UCHI Surface routines

(defun uchi:surface-ready-p ()
  (> (length *uchi-points*) 2)
)

(defun uchi:surface-stats (/ xmin xmax ymin ymax p area)
  (if (not *uchi-points*)
    nil
    (progn
      (setq xmin (cadr (car *uchi-points*)))
      (setq xmax xmin)
      (setq ymin (caddr (car *uchi-points*)))
      (setq ymax ymin)
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

(defun C:UCHI_SUPERFICIE (/ st)
  (uchi:topo-init)
  (if (uchi:surface-ready-p)
    (progn
      (setq st (uchi:surface-stats))
      (uchi:log (strcat "Superficie: TIN base con " (itoa (length *uchi-points*)) " puntos."))
      (uchi:log (strcat "Superficie: bbox area aprox = " (rtos (cdr (assoc "area" st)) 2 2)))
    )
    (uchi:log "Superficie: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
