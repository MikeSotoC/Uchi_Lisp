;;; UCHI CAD Compatibility Layer (AutoCAD / ZWCAD)

(defun uchi:cad-safe-getvar (name / val)
  (setq val (vl-catch-all-apply 'getvar (list name)))
  (if (vl-catch-all-error-p val) nil val)
)

(defun uchi:cad-product-name (/ p m)
  (setq p (uchi:cad-safe-getvar "PROGRAM"))
  (setq m (uchi:cad-safe-getvar "MENUNAME"))
  (cond
    ((and p (wcmatch (strcase p) "*ZWCAD*")) "ZWCAD")
    ((and m (wcmatch (strcase m) "*ZWCAD*")) "ZWCAD")
    ((and p (wcmatch (strcase p) "*AUTOCAD*")) "AutoCAD")
    (T "CAD-Compatible")
  )
)

(defun uchi:cad-supports-dcl-p ()
  (and (fboundp 'load_dialog)
       (fboundp 'new_dialog)
       (fboundp 'start_dialog)
       (fboundp 'unload_dialog)
  )
)

(defun uchi:cad-safe-load-dialog (path / id)
  (if (not (uchi:cad-supports-dcl-p))
    -1
    (progn
      (setq id (vl-catch-all-apply 'load_dialog (list path)))
      (if (vl-catch-all-error-p id) -1 id)
    )
  )
)

(defun uchi:cad-log-banner ()
  (uchi:log (strcat "CAD detectado: " (uchi:cad-product-name)))
  (if (uchi:cad-supports-dcl-p)
    (uchi:log "DCL disponible.")
    (uchi:log "DCL no disponible, modo consola.")
  )
)

(princ)
