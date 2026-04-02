;;; UCHI Volume routines

(setq *uchi-volume-table* nil)

(defun uchi:volume-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_volume.csv")
)

(defun uchi:build-volume-table (/ dz prev p sta cut fill row out z)
  (setq dz (uchi:to-real (or (getenv "UCHI_CFG_DESIGN_Z") 0.0)))
  (setq prev nil sta 0.0 out nil)
  (foreach p *uchi-points*
    (if prev (setq sta (+ sta (uchi:point-distance2d prev p))))
    (setq z (nth 3 p))
    (if (> z dz)
      (setq cut (- z dz) fill 0.0)
      (setq fill (- dz z) cut 0.0)
    )
    (setq row (list sta cut fill))
    (setq out (append out (list row)))
    (setq prev p)
  )
  out
)

(defun uchi:volume-export-csv (/ fp row)
  (setq fp (open (uchi:volume-file-path) "w"))
  (if fp
    (progn
      (write-line "station,cut,fill" fp)
      (foreach row *uchi-volume-table*
        (write-line
          (strcat (rtos (car row) 2 3) "," (rtos (cadr row) 2 3) "," (rtos (caddr row) 2 3))
          fp
        )
      )
      (close fp)
      T
    )
    nil
  )
)

(defun C:UCHI_VOLUMEN ()
  (uchi:topo-init)
  (if (> (length *uchi-points*) 0)
    (progn
      (setq *uchi-volume-table* (uchi:build-volume-table))
      (if (uchi:volume-export-csv)
        (uchi:log (strcat "Volumen por estación exportado: " (uchi:volume-file-path)))
        (uchi:log "ERROR al exportar volumen por estación.")
      )
    )
    (uchi:log "Volumen: no hay puntos cargados.")
  )
  (princ)
)

(princ)
