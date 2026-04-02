;;; UCHI Templates Perú (configuración base)

(defun uchi:template-file-path (name)
  (strcat (uchi:launcher-dir-safe) "/templates/" name ".tpl")
)

(defun uchi:template-apply-kv-line (line / pos k v)
  (if (and line (> (strlen line) 0) (/= (substr line 1 1) "#"))
    (progn
      (setq pos (vl-string-search "=" line))
      (if pos
        (progn
          (setq k (substr line 1 pos))
          (setq v (substr line (+ pos 2)))
          (if (wcmatch (strcase k) "UCHI_CFG_*")
            (setenv k v)
          )
        )
      )
    )
  )
)

(defun uchi:apply-template-file (name / path lines ln)
  (setq path (uchi:template-file-path name))
  (if (findfile path)
    (progn
      (setq lines (uchi:read-lines path))
      (foreach ln lines (uchi:template-apply-kv-line ln))
      (uchi:log (strcat "Template aplicado desde archivo: " path))
      T
    )
    (progn
      (uchi:log (strcat "Template no encontrado: " path))
      nil
    )
  )
)

(defun uchi:apply-template-pe-generic ()
  (uchi:apply-template-file "pe_generic")
)

(defun C:UCHI_TEMPLATE_PE ()
  (uchi:apply-template-pe-generic)
  (princ)
)

(defun uchi:apply-template-dg2018 ()
  (uchi:apply-template-file "pe_dg2018")
)

(defun C:UCHI_TEMPLATE_DG2018 ()
  (uchi:apply-template-dg2018)
  (princ)
)

(princ)
