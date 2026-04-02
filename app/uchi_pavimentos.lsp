;;; UCHI Pavimentos (metrados base)

(defun uchi:pav-width () (uchi:to-real (or (getenv "UCHI_CFG_ROAD_PLATFORM_WIDTH") 10.8)))
(defun uchi:pav-th-base () (uchi:to-real (or (getenv "UCHI_CFG_PAV_BASE_M") 0.20)))
(defun uchi:pav-th-subbase () (uchi:to-real (or (getenv "UCHI_CFG_PAV_SUBBASE_M") 0.20)))
(defun uchi:pav-th-asphalt () (uchi:to-real (or (getenv "UCHI_CFG_PAV_AC_M") 0.05)))
(defun uchi:pav-trafico () (strcase (or (getenv "UCHI_CFG_PAV_TRAFICO") "MEDIO")))

(defun uchi:pav-norm-min (layer / t)
  (setq t (uchi:pav-trafico))
  (cond
    ((= layer "subbase") (cond ((= t "ALTO") 0.25) ((= t "BAJO") 0.15) (T 0.20)))
    ((= layer "base") (cond ((= t "ALTO") 0.20) ((= t "BAJO") 0.12) (T 0.15)))
    ((= layer "ac") (cond ((= t "ALTO") 0.07) ((= t "BAJO") 0.04) (T 0.05)))
    (T 0.0)
  )
)

(defun C:UCHI_PAVIMENTOS (/ l w path fp a v1 v2 v3 sbm bm acm ok)
  (uchi:topo-init)
  (setq l (if (fboundp 'uchi:profile-length) (uchi:profile-length) 0.0))
  (setq w (uchi:pav-width))
  (setq a (* l w))
  (setq v1 (* a (uchi:pav-th-subbase)))
  (setq v2 (* a (uchi:pav-th-base)))
  (setq v3 (* a (uchi:pav-th-asphalt)))
  (setq sbm (uchi:pav-norm-min "subbase"))
  (setq bm (uchi:pav-norm-min "base"))
  (setq acm (uchi:pav-norm-min "ac"))
  (setq ok (if (and (>= (uchi:pav-th-subbase) sbm)
                    (>= (uchi:pav-th-base) bm)
                    (>= (uchi:pav-th-asphalt) acm)) "SI" "NO"))
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_pavimentos.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "trafico,area_m2,subbase_m,subbase_min_m,subbase_m3,base_m,base_min_m,base_m3,ac_m,ac_min_m,asfalto_m3,cumple_norma" fp)
      (write-line (strcat (uchi:pav-trafico) "," (rtos a 2 2) ","
                          (rtos (uchi:pav-th-subbase) 2 3) "," (rtos sbm 2 3) "," (rtos v1 2 2) ","
                          (rtos (uchi:pav-th-base) 2 3) "," (rtos bm 2 3) "," (rtos v2 2 2) ","
                          (rtos (uchi:pav-th-asphalt) 2 3) "," (rtos acm 2 3) "," (rtos v3 2 2) "," ok) fp)
      (close fp)
      (uchi:project-set "pav_area" a)
      (uchi:project-set "pav_norm_ok" ok)
      (uchi:project-save)
      (uchi:log (strcat "Pavimentos exportado: uchi_pavimentos.csv, norma=" ok))
    )
    (uchi:log "ERROR al exportar pavimentos.")
  )
  (princ)
)

(princ)
