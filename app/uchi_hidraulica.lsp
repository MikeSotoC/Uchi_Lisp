;;; UCHI Hidrología/Hidráulica (base)

(defun uchi:hid-c () (uchi:to-real (or (getenv "UCHI_CFG_HID_C") 0.55)))
(defun uchi:hid-i-mmhr () (uchi:to-real (or (getenv "UCHI_CFG_HID_I") 60.0)))
(defun uchi:hid-area-ha () (uchi:to-real (or (getenv "UCHI_CFG_HID_A_HA") 5.0)))
(defun uchi:hid-n-manning () (uchi:to-real (or (getenv "UCHI_CFG_HID_N") 0.013)))
(defun uchi:hid-slope () (max 0.0001 (uchi:to-real (or (getenv "UCHI_CFG_HID_S") 0.005))))
(defun uchi:hid-vmin () (max 0.10 (uchi:to-real (or (getenv "UCHI_CFG_HID_VMIN") 0.60))))
(defun uchi:hid-vmax () (max (uchi:hid-vmin) (uchi:to-real (or (getenv "UCHI_CFG_HID_VMAX") 3.00))))

(defun uchi:hid-q-rational-lps ()
  ;; Q(l/s)=2.78*C*I(mm/h)*A(ha)
  (* 2.78 (uchi:hid-c) (uchi:hid-i-mmhr) (uchi:hid-area-ha))
)

(defun uchi:hid-diam-mm-suggested (q_lps / q n s d)
  ;; Manning tubería circular llena (aprox): Q=0.3117/n*D^(8/3)*S^(1/2)
  (setq q (/ q_lps 1000.0))
  (setq n (uchi:hid-n-manning))
  (setq s (uchi:hid-slope))
  (setq d (expt (/ (* q n) (* 0.3117 (sqrt s))) (/ 3.0 8.0)))
  (* 1000.0 d)
)

(defun uchi:hid-area-m2 (dmm / d)
  (setq d (/ dmm 1000.0))
  (* pi 0.25 d d)
)

(defun uchi:hid-vel-ms (q_lps dmm / q a)
  (setq q (/ q_lps 1000.0))
  (setq a (max 0.000001 (uchi:hid-area-m2 dmm)))
  (/ q a)
)

(defun uchi:hid-read-redes (/ path lines out cols)
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

(defun uchi:hid-filter-red (rows red / out r)
  (setq out nil)
  (foreach r rows
    (if (= (nth 1 r) red)
      (setq out (append out (list r)))
    )
  )
  out
)

(defun uchi:hid-sort-by-pk (rows)
  (vl-sort rows '(lambda (a b) (< (atof (car a)) (atof (car b)))))
)

(defun uchi:hid-tramo-q (qbase idx total / f)
  ;; Mayor aporte aguas abajo: primer tramo usa menos caudal que los finales.
  (setq f (/ (+ idx 1.0) (max 1.0 total)))
  (* qbase (+ 0.35 (* 0.65 f)))
)

(defun uchi:hid-build-tramos-red (rows red qbase / rsorted out i total a b pk0 pk1 len q d v ok)
  (setq rsorted (uchi:hid-sort-by-pk (uchi:hid-filter-red rows red)))
  (setq out nil i 0 total (max 0 (- (length rsorted) 1)))
  (while (< i total)
    (setq a (nth i rsorted))
    (setq b (nth (+ i 1) rsorted))
    (setq pk0 (atof (car a)))
    (setq pk1 (atof (car b)))
    (setq len (max 0.01 (- pk1 pk0)))
    (setq q (uchi:hid-tramo-q qbase i total))
    (setq d (uchi:hid-diam-mm-suggested q))
    (setq v (uchi:hid-vel-ms q d))
    (setq ok (if (and (>= v (uchi:hid-vmin)) (<= v (uchi:hid-vmax))) "SI" "NO"))
    (setq out (append out (list (list red pk0 pk1 len q d v ok))))
    (setq i (+ i 1))
  )
  out
)

(defun C:UCHI_HIDRAULICA (/ q path fp dmm rows tramos r okc)
  (uchi:topo-init)
  (setq q (uchi:hid-q-rational-lps))
  (setq dmm (uchi:hid-diam-mm-suggested q))
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_hidraulica.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "C,I_mm_h,A_ha,Q_lps,n_manning,S_m_m,D_sugerido_mm" fp)
      (write-line (strcat (rtos (uchi:hid-c) 2 3) "," (rtos (uchi:hid-i-mmhr) 2 2) "," (rtos (uchi:hid-area-ha) 2 2) ","
                          (rtos q 2 2) "," (rtos (uchi:hid-n-manning) 2 3) "," (rtos (uchi:hid-slope) 2 4) ","
                          (rtos dmm 2 1)) fp)
      (close fp)
      ;; Dimensionamiento por tramos usando la red base (si existe).
      (setq rows (uchi:hid-read-redes))
      (setq tramos (append (uchi:hid-build-tramos-red rows "AGUA" q)
                           (uchi:hid-build-tramos-red rows "DESAGUE" q)))
      (setq path (strcat (uchi:launcher-dir-safe) "/uchi_hidraulica_tramos.csv"))
      (setq fp (open path "w"))
      (if fp
        (progn
          (write-line "red,pk_ini,pk_fin,long_m,Q_lps,D_sugerido_mm,vel_m_s,cumple_rango_vel" fp)
          (foreach r tramos
            (write-line
              (strcat (car r) "," (rtos (nth 1 r) 2 2) "," (rtos (nth 2 r) 2 2) "," (rtos (nth 3 r) 2 2) ","
                      (rtos (nth 4 r) 2 2) "," (rtos (nth 5 r) 2 1) "," (rtos (nth 6 r) 2 3) "," (nth 7 r))
              fp
            )
          )
          (close fp)
        )
      )
      (setq okc 0)
      (foreach r tramos
        (if (= (nth 7 r) "SI") (setq okc (+ okc 1)))
      )
      (uchi:project-set "hid_q_lps" q)
      (uchi:project-set "hid_diam_mm" dmm)
      (uchi:project-set "hid_tramos_count" (length tramos))
      (uchi:project-set "hid_tramos_vel_ok" okc)
      (uchi:project-save)
      (uchi:log (strcat "Hidráulica calculada. Q=" (rtos q 2 2) " l/s, D~" (rtos dmm 2 1)
                        " mm, tramos=" (itoa (length tramos)) ", vel_ok=" (itoa okc)))
    )
    (uchi:log "ERROR al exportar hidráulica.")
  )
  (princ)
)

(princ)
