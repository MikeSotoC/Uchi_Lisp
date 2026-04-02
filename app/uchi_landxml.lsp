;;; UCHI LandXML export (usa malla procesada si existe)

(defun uchi:landxml-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_surface.xml")
)

(defun uchi:mesh-or-build ()
  (cond
    ((and *uchi-tin* (> (length *uchi-tin*) 0)) *uchi-tin*)
    ((and *uchi-mesh* (> (length *uchi-mesh*) 0)) *uchi-mesh*)
    ((fboundp 'uchi:tin-generate) (uchi:tin-generate))
    (T (uchi:build-mesh-strip))
  )
)

(defun uchi:point-id-map (/ i p out)
  (setq i 1 out nil)
  (foreach p (uchi:sort-points-xy *uchi-points*)
    (setq out (cons (cons p i) out))
    (setq i (+ i 1))
  )
  out
)

(defun uchi:pid-from-map (pt mp)
  (cdr (assoc pt mp))
)

(defun uchi:export-landxml (/ fp p i mesh tri mp)
  (setq fp (open (uchi:landxml-file-path) "w"))
  (if fp
    (progn
      (setq mesh (uchi:mesh-or-build))
      (setq mp (point-id-map))
      (write-line "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" fp)
      (write-line "<LandXML version=\"1.2\">" fp)
      (write-line "  <Surfaces><Surface name=\"UCHI\"><Definition surfType=\"TIN\">" fp)
      (write-line "    <Pnts>" fp)
      (setq i 1)
      (foreach p (uchi:sort-points-xy *uchi-points*)
        (write-line
          (strcat "      <P id=\"" (itoa i) "\">" (rtos (cadr p) 2 3) " " (rtos (caddr p) 2 3) " " (rtos (nth 3 p) 2 3) "</P>")
          fp
        )
        (setq i (+ i 1))
      )
      (write-line "    </Pnts>" fp)
      (write-line "    <Faces>" fp)
      (foreach tri mesh
        (write-line
          (strcat "      <F>"
                  (itoa (uchi:pid-from-map (car tri) mp)) " "
                  (itoa (uchi:pid-from-map (cadr tri) mp)) " "
                  (itoa (uchi:pid-from-map (caddr tri) mp)) "</F>")
          fp
        )
      )
      (write-line "    </Faces>" fp)
      (write-line "  </Definition></Surface></Surfaces>" fp)
      (write-line "</LandXML>" fp)
      (close fp)
      (uchi:log (strcat "LandXML exportado: " (uchi:landxml-file-path)))
      T
    )
    nil
  )
)

(defun C:UCHI_EXPORT_LANDXML ()
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (uchi:export-landxml)
    (uchi:log "LandXML: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
