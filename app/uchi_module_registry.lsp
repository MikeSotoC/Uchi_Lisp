;;; UCHI Registry de módulos (organización funcional)

(defun uchi:module-groups ()
  (list
    (cons "core" (list "uchi_core" "uchi_config" "uchi_cad_compat" "uchi_topo" "uchi_persistence"))
    (cons "ui" (list "uchi_ui" "uchi_main.dcl" "uchi_commands"))
    (cons "topografia" (list "uchi_surface" "uchi_tin" "uchi_engine" "uchi_curves" "uchi_profile" "uchi_sections" "uchi_boundary"))
    (cons "ingenieria" (list "uchi_stakeout" "uchi_drainage" "uchi_hidraulica" "uchi_carreteras" "uchi_pavimentos" "uchi_utilidades" "uchi_interferencias"))
    (cons "territorio" (list "uchi_catastro" "uchi_catastro_rural" "uchi_subdivision"))
    (cons "qa_export" (list "uchi_qc" "uchi_report" "uchi_landxml" "uchi_expediente"))
  )
)

(defun C:UCHI_MODULOS (/ g)
  (uchi:log "=== UCHI módulos por dominio ===")
  (foreach g (uchi:module-groups)
    (uchi:log (strcat (car g) " => " (vl-princ-to-string (cdr g))))
  )
  (princ)
)

(princ)
