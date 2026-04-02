;;; UCHI LandXML export (base)

(defun uchi:landxml-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_surface.xml")
)

(defun uchi:export-landxml (/ fp i p t)
  (setq fp (open (uchi:landxml-file-path) "w"))
  (if fp
    (progn
      (write-line "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" fp)
      (write-line "<LandXML version=\"1.2\">" fp)
      (write-line "  <Surfaces><Surface name=\"UCHI\"><Definition surfType=\"TIN\">" fp)
      (write-line "    <Pnts>" fp)
      (setq i 1)
      (foreach p *uchi-points*
        (write-line
          (strcat "      <P id=\"" (itoa i) "\">" (rtos (cadr p) 2 3) " " (rtos (caddr p) 2 3) " " (rtos (nth 3 p) 2 3) "</P>")
          fp
        )
        (setq i (+ i 1))
      )
      (write-line "    </Pnts>" fp)
      (write-line "    <Faces>" fp)
      (setq i 2)
      (while (< i (length *uchi-points*))
        (write-line (strcat "      <F>1 " (itoa i) " " (itoa (+ i 1)) "</F>") fp)
        (setq i (+ i 1))
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
