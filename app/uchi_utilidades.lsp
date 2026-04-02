;;; UCHI Redes de agua y desagüe (Perú - base configurable)

(defun uchi:util-interval () (max 5.0 (uchi:to-real (or (getenv "UCHI_CFG_BZ_SPACING") 60.0))))
(defun uchi:water-diam () (max 20.0 (uchi:to-real (or (getenv "UCHI_CFG_WATER_DIAM_MM") 110.0))))
(defun uchi:sewer-diam () (max 100.0 (uchi:to-real (or (getenv "UCHI_CFG_SEWER_DIAM_MM") 200.0))))
(defun uchi:water-slope () (uchi:to-real (or (getenv "UCHI_CFG_WATER_SLOPE_PCT") 0.5)))
(defun uchi:sewer-slope () (uchi:to-real (or (getenv "UCHI_CFG_SEWER_SLOPE_PCT") 1.0)))

(defun uchi:util-export-csv (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_redes.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "pk,red,diam_mm,slope_pct,bz_id,x,y,z,accesorio" fp)
      (foreach r rows
        (write-line
          (strcat (rtos (car r) 2 2) "," (nth 1 r) "," (rtos (nth 2 r) 2 0) "," (rtos (nth 3 r) 2 3) ","
                  (nth 4 r) "," (rtos (nth 5 r) 2 3) "," (rtos (nth 6 r) 2 3) "," (rtos (nth 7 r) 2 3) "," (nth 8 r))
          fp
        )
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_REDES (/ l pk step p n wx wy sx sy wz sz rows id acc)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 1)
    (progn
      (setq l (uchi:profile-length))
      (setq step (uchi:util-interval))
      (setq pk 0.0 id 1 rows nil)
      (while (<= pk l)
        (setq p (if (fboundp 'uchi:plan-point-at-chainage) (uchi:plan-point-at-chainage pk) nil))
        (setq n (if (fboundp 'uchi:stakeout-normal) (uchi:stakeout-normal pk) (list 0.0 1.0)))
        (if p
          (progn
            ;; agua (offset +2m)
            (setq wx (+ (car p) (* 2.0 (car n))))
            (setq wy (+ (cadr p) (* 2.0 (cadr n))))
            (setq wz (- (nth 2 p) 1.20))
            (uchi:draw-point (list wx wy wz) "UCHI_WATER")
            (setq acc (if (= 0 (rem id 5)) "VALVULA" "N/A"))
            (setq rows (append rows (list (list pk "AGUA" (uchi:water-diam) (uchi:water-slope) (strcat "BZ-A-" (itoa id)) wx wy wz acc))))
            ;; desagüe (offset -2m)
            (setq sx (+ (car p) (* -2.0 (car n))))
            (setq sy (+ (cadr p) (* -2.0 (cadr n))))
            (setq sz (- (nth 2 p) 1.80))
            (uchi:draw-point (list sx sy sz) "UCHI_SEWER")
            (setq acc (if (= 0 (rem id 4)) "BUZON" "N/A"))
            (setq rows (append rows (list (list pk "DESAGUE" (uchi:sewer-diam) (uchi:sewer-slope) (strcat "BZ-S-" (itoa id)) sx sy sz acc))))
            (setq id (+ id 1))
          )
        )
        (setq pk (+ pk step))
      )
      (uchi:util-export-csv rows)
      (uchi:project-set "redes_nodos" (length rows))
      (uchi:project-save)
      (uchi:log (strcat "Redes base generadas. Nodos=" (itoa (length rows)) ", CSV=uchi_redes.csv"))
    )
    (uchi:log "Redes: se requieren al menos 2 puntos.")
  )
  (princ)
)

(princ)
