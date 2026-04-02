;;; UCHI Hidrología/Hidráulica (base)

(defun uchi:hid-c () (uchi:to-real (or (getenv "UCHI_CFG_HID_C") 0.55)))
(defun uchi:hid-i-mmhr () (uchi:to-real (or (getenv "UCHI_CFG_HID_I") 60.0)))
(defun uchi:hid-area-ha () (uchi:to-real (or (getenv "UCHI_CFG_HID_A_HA") 5.0)))

(defun uchi:hid-q-rational-lps ()
  ;; Q(l/s)=2.78*C*I(mm/h)*A(ha)
  (* 2.78 (uchi:hid-c) (uchi:hid-i-mmhr) (uchi:hid-area-ha))
)

(defun C:UCHI_HIDRAULICA (/ q path fp)
  (uchi:topo-init)
  (setq q (uchi:hid-q-rational-lps))
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_hidraulica.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "C,I_mm_h,A_ha,Q_lps" fp)
      (write-line (strcat (rtos (uchi:hid-c) 2 3) "," (rtos (uchi:hid-i-mmhr) 2 2) "," (rtos (uchi:hid-area-ha) 2 2) "," (rtos q 2 2)) fp)
      (close fp)
      (uchi:project-set "hid_q_lps" q)
      (uchi:project-save)
      (uchi:log (strcat "Hidráulica base calculada. Q=" (rtos q 2 2) " l/s"))
    )
    (uchi:log "ERROR al exportar hidráulica.")
  )
  (princ)
)

(princ)
