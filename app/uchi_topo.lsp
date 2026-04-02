;;; UCHI Topografía (base productiva, no clon de terceros)

(setq *uchi-project*
  (list
    (cons "name" "PROYECTO_UCHI")
    (cons "points_file" "")
    (cons "points_count" 0)
    (cons "points_invalid" 0)
    (cons "points_dup" 0)
  )
)

(defun uchi:project-get (k)
  (cdr (assoc k *uchi-project*))
)

(defun uchi:project-set (k v / p)
  (setq p (assoc k *uchi-project*))
  (if p
    (setq *uchi-project* (subst (cons k v) p *uchi-project*))
    (setq *uchi-project* (append *uchi-project* (list (cons k v))))
  )
)

(defun uchi:launcher-dir-safe (/ lf)
  (setq lf (uchi:launcher-file))
  (if lf (vl-filename-directory lf) ".")
)

(defun uchi:project-file-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_project.dat")
)

(defun uchi:project-save (/ ok)
  (setq ok (uchi:write-text (uchi:project-file-path) (vl-princ-to-string *uchi-project*)))
  (if ok
    (uchi:log (strcat "Proyecto guardado: " (uchi:project-file-path)))
    (uchi:log "ERROR no se pudo guardar proyecto.")
  )
  ok
)

(defun uchi:project-load (/ fp data)
  (if (findfile (uchi:project-file-path))
    (progn
      (setq fp (open (uchi:project-file-path) "r"))
      (if fp
        (progn
          (setq data (read fp))
          (close fp)
          (if (listp data)
            (progn
              (setq *uchi-project* data)
              (uchi:log (strcat "Proyecto cargado: " (uchi:project-get "name")))
              T
            )
            nil
          )
        )
        nil
      )
    )
    nil
  )
)

(defun uchi:ensure-project (/ name)
  (setq name (getenv "UCHI_CFG_PROJECT"))
  (if (or (not name) (= name ""))
    (setq name (uchi:project-get "name"))
  )
  (if (or (not name) (= name ""))
    (setq name "PROYECTO_UCHI")
  )
  (uchi:project-set "name" name)
  (setenv "UCHI_CFG_PROJECT" name)
  name
)

(defun uchi:topo-init ()
  (if (not (uchi:project-load))
    (uchi:project-save)
  )
  (uchi:log (strcat "Proyecto activo: " (uchi:ensure-project)))
)

(defun uchi:csv-row-valid-p (cols)
  (and (>= (length cols) 3)
       (/= (car cols) "")
       (numberp (distof (cadr cols) 2))
       (numberp (distof (caddr cols) 2))
  )
)

(defun uchi:import-points-csv (path / lines line cols seen valid invalid dup pid)
  (setq lines (uchi:read-lines path))
  (setq valid 0)
  (setq invalid 0)
  (setq dup 0)
  (setq seen nil)

  (foreach line lines
    (setq cols (uchi:split-csv-line line))
    (if (uchi:csv-row-valid-p cols)
      (progn
        (setq pid (car cols))
        (if (assoc pid seen)
          (setq dup (+ dup 1))
          (progn
            (setq seen (cons (cons pid T) seen))
            (setq valid (+ valid 1))
          )
        )
      )
      (setq invalid (+ invalid 1))
    )
  )

  (list
    (cons "valid" valid)
    (cons "invalid" invalid)
    (cons "dup" dup)
  )
)

(defun uchi:apply-import-summary (f summary)
  (uchi:project-set "points_file" f)
  (uchi:project-set "points_count" (cdr (assoc "valid" summary)))
  (uchi:project-set "points_invalid" (cdr (assoc "invalid" summary)))
  (uchi:project-set "points_dup" (cdr (assoc "dup" summary)))
  (uchi:project-save)
  (uchi:log
    (strcat
      "Importación CSV => válidos: " (itoa (cdr (assoc "valid" summary)))
      ", inválidos: " (itoa (cdr (assoc "invalid" summary)))
      ", duplicados: " (itoa (cdr (assoc "dup" summary)))
    )
  )
)

(defun C:UCHI_PROY ()
  (uchi:topo-init)
  (uchi:log "Módulo proyecto: configuración base lista.")
  (princ)
)

(defun C:UCHI_PUNTOS ()
  (uchi:topo-init)
  (uchi:log "Módulo puntos: preparado para importación/edición.")
  (princ)
)

(defun C:UCHI_PUNTOS_IMPORT (/ f summary)
  (uchi:topo-init)
  (setq f (getfiled "Seleccione CSV de puntos" "" "csv" 16))
  (if f
    (progn
      (setq summary (uchi:import-points-csv f))
      (uchi:apply-import-summary f summary)
    )
    (uchi:log "Importación cancelada.")
  )
  (princ)
)

(defun C:UCHI_PUNTOS_VALIDAR (/ f summary)
  (uchi:topo-init)
  (setq f (uchi:project-get "points_file"))
  (if (and f (/= f "") (findfile f))
    (progn
      (setq summary (uchi:import-points-csv f))
      (uchi:apply-import-summary f summary)
    )
    (uchi:log "No hay archivo de puntos previo para validar.")
  )
  (princ)
)

(defun C:UCHI_CURVAS ()
  (C:UCHI_CURVAS_GEN)
)

(defun C:UCHI_FLUJO ()
  (uchi:log "Flujo UCHI iniciado.")
  (C:UCHI_PROY)
  (C:UCHI_PUNTOS)
  (C:UCHI_CURVAS)
  (uchi:log "Flujo UCHI completado.")
  (princ)
)

(princ)
