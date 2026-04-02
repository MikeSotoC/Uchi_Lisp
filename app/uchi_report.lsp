;;; UCHI Report routines

(defun uchi:report-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_report.txt")
)

(defun uchi:build-report-text (/ txt)
  (setq txt
    (strcat
      "[UCHI] Reporte de Proyecto\n"
      "Proyecto: " (vl-princ-to-string (uchi:project-get "name")) "\n"
      "Archivo puntos: " (vl-princ-to-string (uchi:project-get "points_file")) "\n"
      "Puntos válidos: " (itoa (atoi (vl-princ-to-string (uchi:project-get "points_count")))) "\n"
      "Puntos inválidos: " (itoa (atoi (vl-princ-to-string (uchi:project-get "points_invalid")))) "\n"
      "Duplicados: " (itoa (atoi (vl-princ-to-string (uchi:project-get "points_dup")))) "\n"
      "Z min: " (rtos (uchi:to-real (uchi:project-get "z_min")) 2 2) "\n"
      "Z max: " (rtos (uchi:to-real (uchi:project-get "z_max")) 2 2) "\n"
      "Triángulos malla: " (itoa (atoi (vl-princ-to-string (uchi:project-get "mesh_triangles")))) "\n"
      "Triángulos TIN: " (itoa (atoi (vl-princ-to-string (uchi:project-get "tin_triangles")))) "\n"
      "Área malla: " (rtos (uchi:to-real (uchi:project-get "mesh_area")) 2 2) "\n"
      "Corte: " (rtos (uchi:to-real (uchi:project-get "cut")) 2 2) "\n"
      "Relleno: " (rtos (uchi:to-real (uchi:project-get "fill")) 2 2) "\n"
      "Longitud alineamiento: " (rtos (uchi:to-real (uchi:project-get "alignment_length")) 2 2) "\n"
      "Archivo alineamiento: uchi_alignment.csv\n"
      "Archivo volumen: uchi_volume.csv\n"
      "Archivo LandXML: uchi_surface.xml\n"
      "QC OK: " (itoa (atoi (vl-princ-to-string (uchi:project-get "qc_ok")))) "\n"
      "QC dup_rate: " (rtos (uchi:to-real (uchi:project-get "qc_dup_rate")) 2 3) "\n"
      "QC inv_rate: " (rtos (uchi:to-real (uchi:project-get "qc_inv_rate")) 2 3) "\n"
    )
  )
  txt
)

(defun C:UCHI_REPORTE ()
  (uchi:topo-init)
  (if (uchi:write-text (uchi:report-file-path) (uchi:build-report-text))
    (uchi:log (strcat "Reporte exportado: " (uchi:report-file-path)))
    (uchi:log "ERROR al exportar reporte.")
  )
  (princ)
)

(princ)
