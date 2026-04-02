;;; UCHI Catastro (lotes base)

(defun uchi:cat-lot-w () (max 4.0 (uchi:to-real (or (getenv "UCHI_CFG_CATASTRO_LOT_W") 8.0))))
(defun uchi:cat-lot-d () (max 8.0 (uchi:to-real (or (getenv "UCHI_CFG_CATASTRO_LOT_D") 20.0))))

(defun uchi:catastro-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_catastro.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "id,xmin,ymin,xmax,ymax,area" fp)
      (foreach r rows
        (write-line
          (strcat (car r) "," (rtos (cadr r) 2 3) "," (rtos (caddr r) 2 3) ","
                  (rtos (nth 3 r) 2 3) "," (rtos (nth 4 r) 2 3) "," (rtos (nth 5 r) 2 2))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_CATASTRO (/ st xmin xmax ymin ymax w d x y id rows poly area)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq st (uchi:surface-stats))
      (setq xmin (cdr (assoc "xmin" st)) xmax (cdr (assoc "xmax" st)))
      (setq ymin (cdr (assoc "ymin" st)) ymax (cdr (assoc "ymax" st)))
      (setq w (uchi:cat-lot-w) d (uchi:cat-lot-d))
      (setq x xmin id 1 rows nil)
      (while (< x xmax)
        (setq y ymin)
        (while (< y ymax)
          (setq poly (list (list x y) (list (min xmax (+ x w)) y) (list (min xmax (+ x w)) (min ymax (+ y d)))
                           (list x (min ymax (+ y d))) (list x y)))
          (uchi:draw-polyline-2d poly "UCHI_CATASTRO")
          (setq area (* (- (min xmax (+ x w)) x) (- (min ymax (+ y d)) y)))
          (setq rows (append rows (list (list (strcat "LOT-" (itoa id)) x y (min xmax (+ x w)) (min ymax (+ y d)) area))))
          (setq id (+ id 1))
          (setq y (+ y d))
        )
        (setq x (+ x w))
      )
      (uchi:catastro-export-csv rows)
      (uchi:project-set "catastro_lotes" (length rows))
      (uchi:project-save)
      (uchi:log (strcat "Catastro base generado. Lotes=" (itoa (length rows)) ", CSV=uchi_catastro.csv"))
    )
    (uchi:log "Catastro: se requieren al menos 3 puntos.")
  )
  (princ)
)

(princ)
