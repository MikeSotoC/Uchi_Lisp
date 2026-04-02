;;; UCHI Subdivisión (urbana/rural configurable)

(defun uchi:subdiv-cols () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SUBDIV_COLS") 4)))))
(defun uchi:subdiv-rows () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SUBDIV_ROWS") 4)))))
(defun uchi:subdiv-prefix () (or (getenv "UCHI_CFG_SUBDIV_PREFIX") "SUB"))

(defun uchi:subdiv-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_subdivision.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "id,row,col,xmin,ymin,xmax,ymax,area" fp)
      (foreach r rows
        (write-line
          (strcat (car r) "," (itoa (cadr r)) "," (itoa (caddr r)) ","
                  (rtos (nth 3 r) 2 3) "," (rtos (nth 4 r) 2 3) ","
                  (rtos (nth 5 r) 2 3) "," (rtos (nth 6 r) 2 3) "," (rtos (nth 7 r) 2 2))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_SUBDIVISION (/ st xmin xmax ymin ymax cols rows dx dy r c x1 y1 x2 y2 id out area)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq st (uchi:surface-stats))
      (setq xmin (cdr (assoc "xmin" st)) xmax (cdr (assoc "xmax" st)))
      (setq ymin (cdr (assoc "ymin" st)) ymax (cdr (assoc "ymax" st)))
      (setq cols (uchi:subdiv-cols) rows (uchi:subdiv-rows))
      (setq dx (/ (- xmax xmin) cols))
      (setq dy (/ (- ymax ymin) rows))
      (setq r 0 out nil)
      (while (< r rows)
        (setq c 0)
        (while (< c cols)
          (setq x1 (+ xmin (* c dx)) y1 (+ ymin (* r dy)))
          (setq x2 (+ xmin (* (+ c 1) dx)) y2 (+ ymin (* (+ r 1) dy)))
          (uchi:draw-polyline-2d (list (list x1 y1) (list x2 y1) (list x2 y2) (list x1 y2) (list x1 y1)) "UCHI_SUBDIV")
          (setq id (strcat (uchi:subdiv-prefix) "-" (itoa (+ 1 c)) "-" (itoa (+ 1 r))))
          (setq area (* (- x2 x1) (- y2 y1)))
          (setq out (append out (list (list id (+ r 1) (+ c 1) x1 y1 x2 y2 area))))
          (setq c (+ c 1))
        )
        (setq r (+ r 1))
      )
      (uchi:subdiv-export-csv out)
      (uchi:project-set "subdivision_lots" (length out))
      (uchi:project-set "subdivision_cols" cols)
      (uchi:project-set "subdivision_rows" rows)
      (uchi:project-save)
      (uchi:log (strcat "Subdivisión generada. Lotes=" (itoa (length out)) ", CSV=uchi_subdivision.csv"))
    )
    (uchi:log "Subdivisión: se requieren al menos 3 puntos.")
  )
  (princ)
)

(princ)
