;;; UCHI Engine - triangulación y volúmenes mejorados

(setq *uchi-mesh* nil)

(defun uchi:mesh-from-tin-or-strip ()
  (if (and (fboundp 'uchi:tin-generate) (> (length *uchi-points*) 2))
    (progn
      (setq *uchi-tin* (uchi:tin-generate))
      (if (> (length *uchi-tin*) 0) *uchi-tin* (uchi:build-mesh-strip))
    )
    (uchi:build-mesh-strip)
  )
)

(defun uchi:sort-points-xy (pts)
  (vl-sort pts
    '(lambda (a b)
       (if (= (cadr a) (cadr b))
         (< (caddr a) (caddr b))
         (< (cadr a) (cadr b))
       )
     )
  )
)

(defun uchi:tri-area2d (a b c / x1 y1 x2 y2 x3 y3)
  (setq x1 (cadr a) y1 (caddr a)
        x2 (cadr b) y2 (caddr b)
        x3 (cadr c) y3 (caddr c))
  (/ (abs (- (* (- x2 x1) (- y3 y1)) (* (- x3 x1) (- y2 y1)))) 2.0)
)

(defun uchi:tri-avg-z (a b c)
  (/ (+ (nth 3 a) (nth 3 b) (nth 3 c)) 3.0)
)

(defun uchi:build-mesh-strip (/ pts i a b c mesh)
  (setq pts (uchi:sort-points-xy *uchi-points*))
  (setq mesh nil i 0)
  (while (< (+ i 2) (length pts))
    (setq a (nth i pts) b (nth (+ i 1) pts) c (nth (+ i 2) pts))
    (if (> (uchi:tri-area2d a b c) 0.00001)
      (setq mesh (append mesh (list (list a b c))))
    )
    (setq i (+ i 1))
  )
  mesh
)

(defun uchi:mesh-area-total (mesh / t tri)
  (setq t 0.0)
  (foreach tri mesh
    (setq t (+ t (uchi:tri-area2d (car tri) (cadr tri) (caddr tri))))
  )
  t
)

(defun uchi:design-z ()
  (uchi:to-real (or (getenv "UCHI_CFG_DESIGN_Z") 0.0))
)

(defun uchi:volume-cut-fill-mesh (mesh / dz cut fill tri area delta)
  (setq dz (uchi:design-z) cut 0.0 fill 0.0)
  (foreach tri mesh
    (setq area (uchi:tri-area2d (car tri) (cadr tri) (caddr tri)))
    (setq delta (- (uchi:tri-avg-z (car tri) (cadr tri) (caddr tri)) dz))
    (if (> delta 0)
      (setq cut (+ cut (* area delta)))
      (setq fill (+ fill (* area (- delta))))
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
    (progn (uchi:log "ERROR al exportar GeoJSON.") nil)
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
      (C:UCHI_ESTILOS)
      (setq mesh (uchi:mesh-from-tin-or-strip))
      (setq *uchi-mesh* mesh)
      (setq area (uchi:mesh-area-total mesh))
      (setq vol (uchi:volume-cut-fill-mesh mesh))

      (uchi:project-set "mesh_triangles" (length mesh))
      (uchi:project-set "tin_triangles" (length mesh))
      (uchi:project-set "mesh_area" area)
      (uchi:project-set "cut" (cdr (assoc "cut" vol)))
      (uchi:project-set "fill" (cdr (assoc "fill" vol)))
      (uchi:project-save)

      (C:UCHI_SUPERFICIE)
      (C:UCHI_CURVAS_GEN)
      (C:UCHI_PERFIL)
      (C:UCHI_SECCIONES)
      (C:UCHI_ALINEAMIENTO)
      (C:UCHI_VOLUMEN)
      (C:UCHI_QC)
      (C:UCHI_REPORTE)
      (C:UCHI_EXPORT_LANDXML)

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
