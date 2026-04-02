;;; UCHI Catastro Rural

(defun uchi:rural-front () (max 20.0 (uchi:to-real (or (getenv "UCHI_CFG_RURAL_FRONT") 60.0))))
(defun uchi:rural-depth () (max 50.0 (uchi:to-real (or (getenv "UCHI_CFG_RURAL_DEPTH") 200.0))))
(defun uchi:rural-use () (or (getenv "UCHI_CFG_RURAL_USE") "AGRICOLA"))

(defun uchi:rural-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_catastro_rural.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "id,uso,xmin,ymin,xmax,ymax,area_m2,area_ha" fp)
      (foreach r rows
        (write-line
          (strcat (car r) "," (cadr r) "," (rtos (nth 2 r) 2 3) "," (rtos (nth 3 r) 2 3) ","
                  (rtos (nth 4 r) 2 3) "," (rtos (nth 5 r) 2 3) "," (rtos (nth 6 r) 2 2) "," (rtos (nth 7 r) 2 4))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_CATASTRO_RURAL (/ st xmin xmax ymin ymax f d x y id rows area)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq st (uchi:surface-stats))
      (setq xmin (cdr (assoc "xmin" st)) xmax (cdr (assoc "xmax" st)))
      (setq ymin (cdr (assoc "ymin" st)) ymax (cdr (assoc "ymax" st)))
      (setq f (uchi:rural-front) d (uchi:rural-depth))
      (setq x xmin id 1 rows nil)
      (while (< x xmax)
        (setq y ymin)
        (while (< y ymax)
          (uchi:draw-polyline-2d
            (list (list x y)
                  (list (min xmax (+ x f)) y)
                  (list (min xmax (+ x f)) (min ymax (+ y d)))
                  (list x (min ymax (+ y d)))
                  (list x y))
            "UCHI_CATASTRO_RURAL")
          (setq area (* (- (min xmax (+ x f)) x) (- (min ymax (+ y d)) y)))
          (setq rows
            (append rows
                    (list (list (strcat "RUR-" (itoa id)) (uchi:rural-use) x y (min xmax (+ x f)) (min ymax (+ y d))
                                area (/ area 10000.0)))))
          (setq id (+ id 1))
          (setq y (+ y d))
        )
        (setq x (+ x f))
      )
      (uchi:rural-export-csv rows)
      (uchi:project-set "catastro_rural_lotes" (length rows))
      (uchi:project-save)
      (uchi:log (strcat "Catastro rural generado. Predios=" (itoa (length rows)) ", CSV=uchi_catastro_rural.csv"))
    )
    (uchi:log "Catastro rural: se requieren al menos 3 puntos.")
  )
  (princ)
)

(princ)
