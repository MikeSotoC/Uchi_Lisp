;;; UCHI Curves routines

(defun uchi:curve-major-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MAJOR") 5)))))
(defun uchi:curve-minor-interval () (max 1 (atoi (vl-princ-to-string (or (getenv "UCHI_CFG_CURVE_MINOR") 1)))))
(defun uchi:curve-ready-p () (> (length *uchi-points*) 2))

(defun uchi:curve-count (zmin zmax step / c z)
  (setq c 0 z zmin)
  (while (<= z zmax) (setq c (+ c 1) z (+ z step)))
  c
)

(defun uchi:edge-intersection-at-z (p1 p2 z / z1 z2 t x y)
  (setq z1 (nth 3 p1) z2 (nth 3 p2))
  (if (and (/= z1 z2)
           (<= (min z1 z2) z)
           (<= z (max z1 z2)))
    (progn
      (setq t (/ (- z z1) (- z2 z1)))
      (setq x (+ (cadr p1) (* t (- (cadr p2) (cadr p1)))))
      (setq y (+ (caddr p1) (* t (- (caddr p2) (caddr p1)))))
      (list x y)
    )
    nil
  )
)

(defun uchi:triangle-contour-segment (tri z / p1 p2 p3 i1 i2 i3 pts)
  (setq p1 (car tri) p2 (cadr tri) p3 (caddr tri))
  (setq i1 (uchi:edge-intersection-at-z p1 p2 z))
  (setq i2 (uchi:edge-intersection-at-z p2 p3 z))
  (setq i3 (uchi:edge-intersection-at-z p3 p1 z))
  (setq pts nil)
  (if i1 (setq pts (append pts (list i1))))
  (if i2 (setq pts (append pts (list i2))))
  (if i3 (setq pts (append pts (list i3))))
  (if (= (length pts) 2) pts nil)
)

(defun uchi:curve-layer-for-z (z major minor)
  (if (= 0 (rem (fix (* 1000.0 z)) (max 1 (fix (* 1000.0 major)))))
    "UCHI_CURVES_MAJOR"
    "UCHI_CURVES"
  )
)

(defun uchi:draw-contours-from-mesh (mesh zmin zmax step major / z tri seg count layer)
  (setq z zmin count 0)
  (while (<= z zmax)
    (foreach tri mesh
      (setq seg (uchi:triangle-contour-segment tri z))
      (if seg
        (progn
          (setq layer (uchi:curve-layer-for-z z major step))
          (uchi:draw-line (list (car (car seg)) (cadr (car seg)) 0.0)
                          (list (car (cadr seg)) (cadr (cadr seg)) 0.0)
                          layer)
          (setq count (+ count 1))
        )
      )
    )
    (setq z (+ z step))
  )
  count
)

(defun C:UCHI_CURVAS_GEN (/ zmin zmax cmj cmn nmaj nmin mesh segs)
  (uchi:topo-init)
  (if (uchi:curve-ready-p)
    (progn
      (setq zmin (uchi:to-real (uchi:project-get "z_min")))
      (setq zmax (uchi:to-real (uchi:project-get "z_max")))
      (setq cmj (uchi:curve-major-interval) cmn (uchi:curve-minor-interval))
      (setq nmaj (uchi:curve-count zmin zmax cmj) nmin (uchi:curve-count zmin zmax cmn))
      (C:UCHI_ESTILOS)
      (setq mesh (uchi:mesh-from-tin-or-strip))
      (setq segs (uchi:draw-contours-from-mesh mesh zmin zmax cmn cmj))
      (uchi:project-set "curves_minor" nmin)
      (uchi:project-set "curves_major" nmaj)
      (uchi:project-set "curves_segments" segs)
      (uchi:project-save)
      (uchi:log (strcat "Curvas TIN: segmentos=" (itoa segs) ", menores=" (itoa nmin) ", mayores=" (itoa nmaj)))
    )
    (uchi:log "Curvas: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
