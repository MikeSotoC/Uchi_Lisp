;;; UCHI Topografía (lógica base real)

(setq *uchi-project*
  (list
    (cons "name" "PROYECTO_UCHI")
    (cons "points_file" "")
    (cons "points_count" 0)
    (cons "points_invalid" 0)
    (cons "points_dup" 0)
    (cons "z_min" 0.0)
    (cons "z_max" 0.0)
  )
)

(setq *uchi-points* nil)
(setq *uchi-breaklines* nil)

(defun uchi:project-get (k) (cdr (assoc k *uchi-project*)))

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

(defun uchi:project-file-path () (strcat (uchi:launcher-dir-safe) "/uchi_project.dat"))
(defun uchi:points-file-path () (strcat (uchi:launcher-dir-safe) "/uchi_points.dat"))
(defun uchi:breaklines-file-path () (strcat (uchi:launcher-dir-safe) "/uchi_breaklines.dat"))

(defun uchi:project-save (/ ok)
  (setq ok (uchi:write-text (uchi:project-file-path) (vl-princ-to-string *uchi-project*)))
  (if ok (uchi:write-text (uchi:points-file-path) (vl-princ-to-string *uchi-points*)))
  (if ok (uchi:write-text (uchi:breaklines-file-path) (vl-princ-to-string *uchi-breaklines*)))
  (if (and ok (fboundp 'uchi:persist-save-json)) (uchi:persist-save-json))
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
          (if (listp data) (setq *uchi-project* data))
        )
      )
    )
  )
  (if (findfile (uchi:points-file-path))
    (progn
      (setq fp (open (uchi:points-file-path) "r"))
      (if fp
        (progn
          (setq data (read fp))
          (close fp)
          (if (listp data) (setq *uchi-points* data))
        )
      )
    )
  )
  (if (findfile (uchi:breaklines-file-path))
    (progn
      (setq fp (open (uchi:breaklines-file-path) "r"))
      (if fp
        (progn
          (setq data (read fp))
          (close fp)
          (if (listp data) (setq *uchi-breaklines* data))
        )
      )
    )
  )
  (if *uchi-project*
    (uchi:log (strcat "Proyecto cargado: " (uchi:project-get "name")))
  )
  T
)

(defun uchi:point-by-id (pid / out p)
  (setq out nil)
  (foreach p *uchi-points*
    (if (= (car p) pid) (setq out p))
  )
  out
)

(defun uchi:csv-row->breakline (cols / p1 p2 typ)
  (if (>= (length cols) 2)
    (progn
      (setq p1 (car cols))
      (setq p2 (cadr cols))
      (setq typ (if (>= (length cols) 3) (strcase (nth 2 cols)) "HARD"))
      (if (and p1 p2 (/= p1 "") (/= p2 "") (/= p1 p2))
        (list p1 p2 typ)
        nil
      )
    )
    nil
  )
)

(defun uchi:breakline-key (bl / a b)
  (setq a (car bl) b (cadr bl))
  (if (< (vl-string-compare a b) 0)
    (strcat a "|" b)
    (strcat b "|" a)
  )
)

(defun uchi:import-breaklines-csv (path / lines line cols seen valid invalid out bl k)
  (setq lines (uchi:read-lines path))
  (setq seen nil valid 0 invalid 0 out nil)
  (foreach line lines
    (setq cols (uchi:split-csv-line line))
    (setq bl (uchi:csv-row->breakline cols))
    (if (and bl (uchi:point-by-id (car bl)) (uchi:point-by-id (cadr bl)))
      (progn
        (setq k (uchi:breakline-key bl))
        (if (assoc k seen)
          (setq invalid (+ invalid 1))
          (progn
            (setq seen (cons (cons k T) seen))
            (setq valid (+ valid 1))
            (setq out (append out (list bl)))
          )
        )
      )
      (setq invalid (+ invalid 1))
    )
  )
  (list (cons "valid" valid) (cons "invalid" invalid) (cons "breaklines" out))
)

(defun uchi:ensure-project (/ name)
  (setq name (getenv "UCHI_CFG_PROJECT"))
  (if (or (not name) (= name "")) (setq name (uchi:project-get "name")))
  (if (or (not name) (= name "")) (setq name "PROYECTO_UCHI"))
  (uchi:project-set "name" name)
  (setenv "UCHI_CFG_PROJECT" name)
  name
)

(defun uchi:topo-init ()
  (uchi:project-load)
  (if (not (uchi:project-get "name")) (uchi:project-save))
  (uchi:log (strcat "Proyecto activo: " (uchi:ensure-project)))
)

(defun uchi:csv-row->point (cols / pid x y z)
  (setq pid (car cols))
  (setq x (uchi:to-real (cadr cols)))
  (setq y (uchi:to-real (caddr cols)))
  (setq z (if (>= (length cols) 4) (uchi:to-real (nth 3 cols)) 0.0))
  (if (and pid x y z (/= pid "")) (list pid x y z) nil)
)

(defun uchi:import-points-csv (path / lines line cols seen valid invalid dup points pt zmin zmax)
  (setq lines (uchi:read-lines path))
  (setq valid 0 invalid 0 dup 0 seen nil points nil zmin nil zmax nil)

  (foreach line lines
    (setq cols (uchi:split-csv-line line))
    (setq pt (uchi:csv-row->point cols))
    (if pt
      (if (assoc (car pt) seen)
        (setq dup (+ dup 1))
        (progn
          (setq seen (cons (cons (car pt) T) seen))
          (setq points (append points (list pt)))
          (setq valid (+ valid 1))
          (if (or (not zmin) (< (nth 3 pt) zmin)) (setq zmin (nth 3 pt)))
          (if (or (not zmax) (> (nth 3 pt) zmax)) (setq zmax (nth 3 pt)))
        )
      )
      (setq invalid (+ invalid 1))
    )
  )

  (list
    (cons "valid" valid)
    (cons "invalid" invalid)
    (cons "dup" dup)
    (cons "z_min" (if zmin zmin 0.0))
    (cons "z_max" (if zmax zmax 0.0))
    (cons "points" points)
  )
)

(defun uchi:apply-import-summary (f summary)
  (setq *uchi-points* (cdr (assoc "points" summary)))
  (uchi:project-set "points_file" f)
  (uchi:project-set "points_count" (cdr (assoc "valid" summary)))
  (uchi:project-set "points_invalid" (cdr (assoc "invalid" summary)))
  (uchi:project-set "points_dup" (cdr (assoc "dup" summary)))
  (uchi:project-set "z_min" (cdr (assoc "z_min" summary)))
  (uchi:project-set "z_max" (cdr (assoc "z_max" summary)))
  (uchi:project-save)
  (uchi:log
    (strcat
      "Importación CSV => válidos: " (itoa (cdr (assoc "valid" summary)))
      ", inválidos: " (itoa (cdr (assoc "invalid" summary)))
      ", duplicados: " (itoa (cdr (assoc "dup" summary)))
      ", zmin: " (rtos (cdr (assoc "z_min" summary)) 2 2)
      ", zmax: " (rtos (cdr (assoc "z_max" summary)) 2 2)
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

(defun C:UCHI_BREAKLINES_IMPORT (/ f summary)
  (uchi:topo-init)
  (if (not *uchi-points*)
    (uchi:log "Breaklines: primero importe puntos.")
    (progn
      (setq f (getfiled "Seleccione CSV de breaklines (p1,p2,tipo)" "" "csv" 16))
      (if f
        (progn
          (setq summary (uchi:import-breaklines-csv f))
          (setq *uchi-breaklines* (cdr (assoc "breaklines" summary)))
          (uchi:project-set "breaklines_count" (cdr (assoc "valid" summary)))
          (uchi:project-save)
          (uchi:log (strcat "Breaklines importadas=" (itoa (cdr (assoc "valid" summary)))
                            ", inválidas=" (itoa (cdr (assoc "invalid" summary)))))
        )
        (uchi:log "Importación de breaklines cancelada.")
      )
    )
  )
  (princ)
)

(defun C:UCHI_CURVAS () (C:UCHI_CURVAS_GEN))

(defun C:UCHI_FLUJO ()
  (uchi:log "Flujo UCHI iniciado.")
  (C:UCHI_PROY)
  (C:UCHI_PUNTOS)
  (C:UCHI_CURVAS)
  (uchi:log "Flujo UCHI completado.")
  (princ)
)

(princ)
