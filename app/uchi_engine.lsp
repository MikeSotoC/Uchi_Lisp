;;; UCHI Engine - avances grandes integrados

(setq *uchi-mesh* nil)

(defun uchi:tri-area2d (a b c / x1 y1 x2 y2 x3 y3)
  (setq x1 (cadr a) y1 (caddr a)
        x2 (cadr b) y2 (caddr b)
        x3 (cadr c) y3 (caddr c))
  (/ (abs (- (* (- x2 x1) (- y3 y1)) (* (- x3 x1) (- y2 y1)))) 2.0)
)

(defun uchi:build-mesh-fan (/ p0 rest tri mesh)
  (setq mesh nil)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq p0 (car *uchi-points*))
      (setq rest (cdr *uchi-points*))
      (while (> (length rest) 1)
        (setq tri (list p0 (car rest) (cadr rest)))
        (setq mesh (append mesh (list tri)))
        (setq rest (cdr rest))
      )
    )
  )
  mesh
)

(defun uchi:mesh-area-total (mesh / a t)
  (setq t 0.0)
  (foreach a mesh
    (setq t (+ t (uchi:tri-area2d (car a) (cadr a) (caddr a))))
  )
  t
)

(defun uchi:design-z ()
  (uchi:to-real (or (getenv "UCHI_CFG_DESIGN_Z") 0.0))
)

(defun uchi:volume-cut-fill (/ dz p cut fill z)
  (setq cut 0.0 fill 0.0 dz (uchi:design-z))
  (foreach p *uchi-points*
    (setq z (nth 3 p))
    (if (> z dz)
      (setq cut (+ cut (- z dz)))
      (setq fill (+ fill (- dz z)))
    )
  )
  (list (cons "cut" cut) (cons "fill" fill))
)

(defun uchi:export-geojson (/ path fp first p)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_points.geojson"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "{\"type\":\"FeatureCollection\",\"features\":[" fp)
      (setq first T)
      (foreach p *uchi-points*
        (if (not first) (write-line "," fp))
        (write-line
          (strcat
            "{\"type\":\"Feature\",\"properties\":{\"id\":\"" (car p) "\",\"z\":" (rtos (nth 3 p) 2 3) "},"
            "\"geometry\":{\"type\":\"Point\",\"coordinates\":[" (rtos (cadr p) 2 3) "," (rtos (caddr p) 2 3) "]}}"
          )
          fp
        )
        (setq first nil)
      )
      (write-line "]}" fp)
      (close fp)
      (uchi:log (strcat "GeoJSON exportado: " path))
      path
    )
    (progn
      (uchi:log "ERROR al exportar GeoJSON.")
      nil
    )
  )
)

(defun C:UCHI_EXPORT_GEOJSON ()
  (uchi:topo-init)
  (if *uchi-points* (uchi:export-geojson) (uchi:log "No hay puntos para exportar."))
  (princ)
)

(defun C:UCHI_PROCESAR (/ mesh area vol)
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq mesh (uchi:build-mesh-fan))
      (setq *uchi-mesh* mesh)
      (setq area (uchi:mesh-area-total mesh))
      (setq vol (uchi:volume-cut-fill))
      (uchi:project-set "mesh_triangles" (length mesh))
      (uchi:project-set "mesh_area" area)
      (uchi:project-set "cut" (cdr (assoc "cut" vol)))
      (uchi:project-set "fill" (cdr (assoc "fill" vol)))
      (uchi:project-save)

      (C:UCHI_SUPERFICIE)
      (C:UCHI_CURVAS_GEN)
      (C:UCHI_PERFIL)
      (C:UCHI_SECCIONES)
      (C:UCHI_REPORTE)

      (uchi:log (strcat "Proceso integral OK. Triángulos=" (itoa (length mesh))
                        ", Área=" (rtos area 2 2)
                        ", Corte=" (rtos (cdr (assoc "cut" vol)) 2 2)
                        ", Relleno=" (rtos (cdr (assoc "fill" vol)) 2 2)))
    )
    (uchi:log "Proceso integral requiere al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
