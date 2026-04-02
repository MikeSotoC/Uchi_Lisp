;;; UCHI Subdivisión (urbana/rural configurable)

(defun uchi:subdiv-cols () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SUBDIV_COLS") 4)))))
(defun uchi:subdiv-rows () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SUBDIV_ROWS") 4)))))
(defun uchi:subdiv-prefix () (or (getenv "UCHI_CFG_SUBDIV_PREFIX") "SUB"))
(defun uchi:subdiv-road-every () (max 0 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_SUBDIV_ROAD_EVERY") 3)))))
(defun uchi:subdiv-min-area () (max 1.0 (uchi:to-real (or (getenv "UCHI_CFG_SUBDIV_MIN_AREA") 80.0))))

(defun uchi:subdiv-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_subdivision.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "id,type,row,col,xmin,ymin,xmax,ymax,area" fp)
      (foreach r rows
        (write-line
          (strcat (car r) "," (cadr r) "," (itoa (caddr r)) "," (itoa (nth 3 r)) ","
                  (rtos (nth 4 r) 2 3) "," (rtos (nth 5 r) 2 3) ","
                  (rtos (nth 6 r) 2 3) "," (rtos (nth 7 r) 2 3) "," (rtos (nth 8 r) 2 2))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun uchi:subdiv-cell-inside-p (x1 y1 x2 y2 / cx cy)
  (setq cx (/ (+ x1 x2) 2.0) cy (/ (+ y1 y2) 2.0))
  (if (and *uchi-boundary* (> (length *uchi-boundary*) 2))
    (uchi:boundary-point-in-poly (list cx cy) *uchi-boundary*)
    T
  )
)

(defun C:UCHI_SUBDIVISION (/ st xmin xmax ymin ymax cols rows dx dy r c x1 y1 x2 y2 id out area roadn isroad)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (if (fboundp 'C:UCHI_BOUNDARY) (C:UCHI_BOUNDARY))
      (setq st (uchi:surface-stats))
      (setq xmin (cdr (assoc "xmin" st)) xmax (cdr (assoc "xmax" st)))
      (setq ymin (cdr (assoc "ymin" st)) ymax (cdr (assoc "ymax" st)))
      (setq cols (uchi:subdiv-cols) rows (uchi:subdiv-rows))
      (setq roadn (uchi:subdiv-road-every))
      (setq dx (/ (- xmax xmin) cols))
      (setq dy (/ (- ymax ymin) rows))
      (setq r 0 out nil)
      (while (< r rows)
        (setq c 0)
        (while (< c cols)
          (setq x1 (+ xmin (* c dx)) y1 (+ ymin (* r dy)))
          (setq x2 (+ xmin (* (+ c 1) dx)) y2 (+ ymin (* (+ r 1) dy)))
          (setq area (* (- x2 x1) (- y2 y1)))
          (setq isroad (and (> roadn 0) (or (= (rem (+ c 1) roadn) 0) (= (rem (+ r 1) roadn) 0))))
          (if (and (uchi:subdiv-cell-inside-p x1 y1 x2 y2) (>= area (uchi:subdiv-min-area)))
            (progn
              (if isroad
                (progn
                  (uchi:draw-polyline-2d (list (list x1 y1) (list x2 y1) (list x2 y2) (list x1 y2) (list x1 y1)) "UCHI_ROAD")
                  (setq id (strcat "VIA-" (itoa (+ 1 c)) "-" (itoa (+ 1 r))))
                  (setq out (append out (list (list id "road" (+ r 1) (+ c 1) x1 y1 x2 y2 area))))
                )
                (progn
                  (uchi:draw-polyline-2d (list (list x1 y1) (list x2 y1) (list x2 y2) (list x1 y2) (list x1 y1)) "UCHI_SUBDIV")
                  (setq id (strcat (uchi:subdiv-prefix) "-" (itoa (+ 1 c)) "-" (itoa (+ 1 r))))
                  (setq out (append out (list (list id "lot" (+ r 1) (+ c 1) x1 y1 x2 y2 area))))
                )
              )
            )
          )
          (setq c (+ c 1))
        )
        (setq r (+ r 1))
      )
      (uchi:subdiv-export-csv out)
      (uchi:project-set "subdivision_lots" (length out))
      (uchi:project-set "subdivision_cols" cols)
      (uchi:project-set "subdivision_rows" rows)
      (uchi:project-set "subdivision_road_every" roadn)
      (uchi:project-save)
      (uchi:log (strcat "Subdivisión generada. Lotes=" (itoa (length out)) ", CSV=uchi_subdivision.csv"))
    )
    (uchi:log "Subdivisión: se requieren al menos 3 puntos.")
  )
  (princ)
)

(princ)
