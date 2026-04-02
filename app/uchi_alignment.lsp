;;; UCHI Alignment routines

(setq *uchi-alignment* nil)

(defun uchi:build-alignment (/ prev p sta out)
  (setq prev nil sta 0.0 out nil)
  (foreach p *uchi-points*
    (if prev (setq sta (+ sta (uchi:point-distance2d prev p))))
    (setq out (append out (list (list (car p) sta (cadr p) (caddr p) (nth 3 p)))))
    (setq prev p)
  )
  out
)

(defun uchi:alignment-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_alignment.csv")
)

(defun uchi:alignment-export-csv (/ fp row)
  (setq fp (open (uchi:alignment-file-path) "w"))
  (if fp
    (progn
      (write-line "id,station,x,y,z" fp)
      (foreach row *uchi-alignment*
        (write-line
          (strcat
            (car row) ","
            (rtos (cadr row) 2 3) ","
            (rtos (nth 2 row) 2 3) ","
            (rtos (nth 3 row) 2 3) ","
            (rtos (nth 4 row) 2 3)
          )
          fp
        )
      )
      (close fp)
      T
    )
    nil
  )
)

(defun C:UCHI_ALINEAMIENTO ()
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq *uchi-alignment* (uchi:build-alignment))
      (uchi:project-set "alignment_length" (cadr (car (last *uchi-alignment*))))
      (if (uchi:alignment-export-csv)
        (uchi:log (strcat "Alineamiento exportado: " (uchi:alignment-file-path)))
        (uchi:log "ERROR al exportar alineamiento.")
      )
    )
    (uchi:log "Alineamiento: faltan puntos suficientes.")
  )
  (princ)
)

(princ)
