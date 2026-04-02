;;; UCHI Interferencias 3D (base redes)

(defun uchi:interf-th () (uchi:to-real (or (getenv "UCHI_CFG_INTERF_TH_M") 1.5)))

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

(defun C:UCHI_INTERFERENCIAS (/ rows a b d th path fp c)
  (uchi:topo-init)
  (setq rows (uchi:read-redes-csv))
  (setq th (uchi:interf-th))
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_interferencias.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "red_a,bz_a,red_b,bz_b,dist_3d" fp)
      (setq c 0)
      (foreach a rows
        (foreach b rows
          (if (and (/= (nth 4 a) (nth 4 b))
                   (/= (nth 1 a) (nth 1 b)))
            (progn
              (setq d (distance (list (atof (nth 5 a)) (atof (nth 6 a)) (atof (nth 7 a)))
                               (list (atof (nth 5 b)) (atof (nth 6 b)) (atof (nth 7 b)))))
              (if (< d th)
                (progn
                  (write-line (strcat (nth 1 a) "," (nth 4 a) "," (nth 1 b) "," (nth 4 b) "," (rtos d 2 3)) fp)
                  (setq c (+ c 1))
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
