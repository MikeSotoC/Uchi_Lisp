;;; UCHI Interferencias 3D (base redes)

(defun uchi:interf-th () (uchi:to-real (or (getenv "UCHI_CFG_INTERF_TH_M") 1.5)))
(defun uchi:interf-vsep-min () (uchi:to-real (or (getenv "UCHI_CFG_INTERF_VSEP_MIN_M") 0.30)))

(defun uchi:interf-red-weight (r)
  (cond
    ((= r "DESAGUE") 1.35)
    ((= r "AGUA") 1.20)
    (T 1.00)
  )
)
(defun uchi:interf-min-sep (ra rb)
  (cond
    ((or (and (= ra "AGUA") (= rb "DESAGUE")) (and (= ra "DESAGUE") (= rb "AGUA")))
      (uchi:to-real (or (getenv "UCHI_CFG_SEP_AGUA_DESAGUE_M") 1.50)))
    ((= ra rb)
      (uchi:to-real (or (getenv "UCHI_CFG_SEP_MISMA_RED_M") 1.00)))
    (T
      (uchi:to-real (or (getenv "UCHI_CFG_SEP_OTRAS_RED_M") 1.20)))
  )
)

(defun uchi:interf-sev (d sepmin)
  (cond
    ((< d (* 0.40 sepmin)) "CRITICA")
    ((< d (* 0.70 sepmin)) "ALTA")
    ((< d sepmin) "MEDIA")
    (T "BAJA")
  )
)

(defun uchi:interf-incumple-p (d sepmin)
  (if (< d sepmin) "SI" "NO")
)

(defun uchi:interf-criticidad (ra rb / w)
  (setq w (max (uchi:interf-red-weight ra) (uchi:interf-red-weight rb)))
  (cond
    ((>= w 1.30) "ALTA")
    ((>= w 1.15) "MEDIA")
    (T "BAJA")
  )
)

(defun uchi:interf-sev-critica (d sepmin ra rb / ratio w wr)
  (setq ratio (/ d (max 0.001 sepmin)))
  (setq w (max (uchi:interf-red-weight ra) (uchi:interf-red-weight rb)))
  (setq wr (/ ratio w))
  (cond
    ((< wr 0.40) "CRITICA")
    ((< wr 0.70) "ALTA")
    ((< wr 1.00) "MEDIA")
    (T "BAJA")
  )
)

(defun uchi:interf-vsep-ok (za zb / dz)
  (setq dz (abs (- za zb)))
  (if (>= dz (uchi:interf-vsep-min)) "SI" "NO")
)

(defun uchi:interf-sev-legacy (d)
  (cond
    ((< d 0.50) "CRITICA")
    ((< d 1.00) "ALTA")
    ((< d 1.50) "MEDIA")
    (T "BAJA")
  )
)

(defun uchi:read-redes-csv (/ path lines out cols)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_redes.csv"))
  (setq out nil)
  (foreach line (uchi:read-lines path)
    (setq cols (uchi:split-csv-line line))
    (if (= (length cols) 9)
      (if (/= (car cols) "pk")
        (setq out (append out (list cols)))
      )
    )
  )
  out
)

(defun C:UCHI_INTERFERENCIAS (/ rows a b d th path fp c key seen sepmin dz vsepok crit sevcrit)
  (uchi:topo-init)
  (setq rows (uchi:read-redes-csv))
  (setq th (uchi:interf-th))
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_interferencias.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "red_a,bz_a,red_b,bz_b,dist_3d,sep_min_norma,dz_vertical,sep_vertical_min,cumple_sep_vertical,criticidad_red,severidad,severidad_criticidad,incumple_norma" fp)
      (setq c 0 seen nil)
      (foreach a rows
        (foreach b rows
          (if (and (/= (nth 4 a) (nth 4 b))
                   (/= (nth 1 a) (nth 1 b))
                   (< (vl-string-compare (nth 4 a) (nth 4 b)) 0))
            (progn
              (setq d (distance (list (atof (nth 5 a)) (atof (nth 6 a)) (atof (nth 7 a)))
                               (list (atof (nth 5 b)) (atof (nth 6 b)) (atof (nth 7 b)))))
              (setq sepmin (uchi:interf-min-sep (nth 1 a) (nth 1 b)))
              (if (< d th)
                (progn
                  (setq key (strcat (nth 4 a) "|" (nth 4 b)))
                  (if (not (assoc key seen))
                    (progn
                      (setq dz (abs (- (atof (nth 7 a)) (atof (nth 7 b)))))
                      (setq vsepok (uchi:interf-vsep-ok (atof (nth 7 a)) (atof (nth 7 b))))
                      (setq crit (uchi:interf-criticidad (nth 1 a) (nth 1 b)))
                      (setq sevcrit (uchi:interf-sev-critica d sepmin (nth 1 a) (nth 1 b)))
                      (write-line
                        (strcat (nth 1 a) "," (nth 4 a) "," (nth 1 b) "," (nth 4 b) ","
                                (rtos d 2 3) "," (rtos sepmin 2 3) ","
                                (rtos dz 2 3) "," (rtos (uchi:interf-vsep-min) 2 3) "," vsepok ","
                                crit "," (uchi:interf-sev d sepmin) "," sevcrit ","
                                (uchi:interf-incumple-p d sepmin))
                        fp)
                      (setq c (+ c 1))
                      (setq seen (cons (cons key T) seen))
                    )
                  )
                )
              )
            )
          )
        )
      )
      (close fp)
      (uchi:project-set "interf_count" c)
      (uchi:project-save)
      (uchi:log (strcat "Interferencias detectadas=" (itoa c)))
    )
    (uchi:log "ERROR al exportar interferencias.")
  )
  (princ)
)

(princ)
