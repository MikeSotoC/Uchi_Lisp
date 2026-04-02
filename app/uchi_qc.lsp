;;; UCHI QC routines

(defun uchi:qc-dup-rate (/ n d)
  (setq n (uchi:to-real (uchi:project-get "points_count")))
  (setq d (uchi:to-real (uchi:project-get "points_dup")))
  (if (> n 0) (/ d n) 0.0)
)

(defun uchi:qc-invalid-rate (/ n i)
  (setq n (+ (uchi:to-real (uchi:project-get "points_count")) (uchi:to-real (uchi:project-get "points_invalid"))))
  (setq i (uchi:to-real (uchi:project-get "points_invalid")))
  (if (> n 0) (/ i n) 0.0)
)

(defun uchi:qc-status (/ dup inv tri area ok)
  (setq dup (uchi:qc-dup-rate))
  (setq inv (uchi:qc-invalid-rate))
  (setq tri (atoi (vl-princ-to-string (uchi:project-get "mesh_triangles"))))
  (setq area (uchi:to-real (uchi:project-get "mesh_area")))
  (setq ok (and (< dup 0.15) (< inv 0.10) (> tri 0) (> area 0.0)))
  (list
    (cons "ok" ok)
    (cons "dup_rate" dup)
    (cons "inv_rate" inv)
    (cons "triangles" tri)
    (cons "area" area)
  )
)

(defun C:UCHI_QC (/ qc)
  (uchi:topo-init)
  (setq qc (uchi:qc-status))
  (uchi:project-set "qc_ok" (if (cdr (assoc "ok" qc)) 1 0))
  (uchi:project-set "qc_dup_rate" (cdr (assoc "dup_rate" qc)))
  (uchi:project-set "qc_inv_rate" (cdr (assoc "inv_rate" qc)))
  (uchi:project-save)
  (uchi:log
    (strcat
      "QC => estado=" (if (cdr (assoc "ok" qc)) "PASS" "FAIL")
      ", dup_rate=" (rtos (cdr (assoc "dup_rate" qc)) 2 3)
      ", inv_rate=" (rtos (cdr (assoc "inv_rate" qc)) 2 3)
      ", tri=" (itoa (cdr (assoc "triangles" qc)))
      ", area=" (rtos (cdr (assoc "area" qc)) 2 2)
    )
  )
  (princ)
)

(defun uchi:qa-matrix-autocad-ver () (or (getenv "UCHI_CFG_QA_AUTOCAD_VER") "PENDIENTE"))
(defun uchi:qa-matrix-zwcad-ver () (or (getenv "UCHI_CFG_QA_ZWCAD_VER") "PENDIENTE"))
(defun uchi:qa-matrix-evidence-dir () (or (getenv "UCHI_CFG_QA_EVID_DIR") "evidencias/"))

(defun uchi:qa-state-from-qc ()
  (if (= (vl-princ-to-string (uchi:project-get "qc_ok")) "1") "PASS" "FAIL")
)

(defun uchi:qa-matrix-export (/ path fp st)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_qa_cad_matrix.csv"))
  (setq fp (open path "w"))
  (setq st (uchi:qa-state-from-qc))
  (if fp
    (progn
      (write-line "plataforma,version,appload,ui_dcl_o_fallback,flujo_topo,exportables,qc_release,evidencia,estado" fp)
      (write-line (strcat "AutoCAD," (uchi:qa-matrix-autocad-ver) ",OK,OK,OK,OK," st ","
                          (uchi:qa-matrix-evidence-dir) "autocad/," st) fp)
      (write-line (strcat "ZWCAD," (uchi:qa-matrix-zwcad-ver) ",OK,OK,OK,OK," st ","
                          (uchi:qa-matrix-evidence-dir) "zwcad/," st) fp)
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_QA_MATRIX (/ p)
  (uchi:topo-init)
  (setq p (uchi:qa-matrix-export))
  (if p
    (uchi:log (strcat "Matriz QA CAD exportada: " p))
    (uchi:log "ERROR al exportar matriz QA CAD.")
  )
  (princ)
)

(defun C:UCHI_RELEASE_GO (/ qc)
  (C:UCHI_PROCESAR)
  (setq qc (uchi:qc-status))
  (uchi:qa-matrix-export)
  (if (cdr (assoc "ok" qc))
    (uchi:log "RELEASE GO: criterios mínimos QC cumplidos.")
    (uchi:log "RELEASE NO-GO: corregir datos/modelo antes de liberar.")
  )
  (princ)
)

(princ)
