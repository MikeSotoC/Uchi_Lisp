;;; UCHI Styles routines

(setq *uchi-style-layers*
  (list
    (list "UCHI_POINTS" 3)
    (list "UCHI_SURFACE" 2)
    (list "UCHI_PROFILE" 4)
    (list "UCHI_PROFILE_DESIGN" 1)
    (list "UCHI_CURVES" 5)
    (list "UCHI_CURVES_MAJOR" 30)
    (list "UCHI_SECTIONS" 6)
    (list "UCHI_STAKEOUT" 140)
    (list "UCHI_DRAINAGE" 151)
    (list "UCHI_CATASTRO" 34)
    (list "UCHI_WATER" 150)
    (list "UCHI_SEWER" 10)
    (list "UCHI_ROAD" 32)
    (list "UCHI_BOUNDARY" 1)
  )
)

(defun C:UCHI_ESTILOS (/ l)
  (foreach l *uchi-style-layers*
    (uchi:ensure-layer (car l) (cadr l))
  )
  (uchi:log "Estilos/capas UCHI aplicados.")
  (princ)
)

(princ)
