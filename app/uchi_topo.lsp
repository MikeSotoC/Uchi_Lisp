;;; UCHI Topografía (base productiva, no clon de terceros)

(setq *uchi-project*
  (list
    (cons "name" "PROYECTO_UCHI")
    (cons "points_file" "")
    (cons "points_count" 0)
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

(defun uchi:import-points-csv (path / lines line cols count)
  (setq lines (uchi:read-lines path))
  (setq count 0)
  (foreach line lines
    (setq cols (uchi:split-csv-line line))
    (if (>= (length cols) 3)
      (setq count (+ count 1))
    )
  )
  count
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

(defun C:UCHI_PUNTOS_IMPORT (/ f cnt)
  (uchi:topo-init)
  (setq f (getfiled "Seleccione CSV de puntos" "" "csv" 16))
  (if f
    (progn
      (setq cnt (uchi:import-points-csv f))
      (uchi:project-set "points_file" f)
      (uchi:project-set "points_count" cnt)
      (uchi:project-save)
      (uchi:log (strcat "Puntos importados: " (itoa cnt)))
    )
    (uchi:log "Importación cancelada.")
  )
  (princ)
)

(defun C:UCHI_CURVAS ()
  (uchi:topo-init)
  (uchi:log "Módulo curvas: preparado para generación de curvas.")
  (princ)
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
