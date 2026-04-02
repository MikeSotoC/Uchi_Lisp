;;; UCHI Hidrología/Hidráulica (base)

(defun uchi:hid-c () (uchi:to-real (or (getenv "UCHI_CFG_HID_C") 0.55)))
(defun uchi:hid-i-mmhr () (uchi:to-real (or (getenv "UCHI_CFG_HID_I") 60.0)))
(defun uchi:hid-area-ha () (uchi:to-real (or (getenv "UCHI_CFG_HID_A_HA") 5.0)))
(defun uchi:hid-n-manning () (uchi:to-real (or (getenv "UCHI_CFG_HID_N") 0.013)))
(defun uchi:hid-slope () (max 0.0001 (uchi:to-real (or (getenv "UCHI_CFG_HID_S") 0.005))))

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

(defun C:UCHI_HIDRAULICA (/ q path fp dmm)
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
      (uchi:project-set "hid_q_lps" q)
      (uchi:project-set "hid_diam_mm" dmm)
      (uchi:project-save)
      (uchi:log (strcat "Hidráulica base calculada. Q=" (rtos q 2 2) " l/s, D~" (rtos dmm 2 1) " mm"))
    )
    (uchi:log "ERROR al exportar hidráulica.")
  )
  (princ)
)

(princ)
