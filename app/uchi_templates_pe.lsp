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

(defun uchi:apply-template-dg2018-cat (cat / name)
  (setq name
    (cond
      ((= cat "VECINAL") "pe_dg2018_vecinal")
      ((= cat "DEPARTAMENTAL") "pe_dg2018_departamental")
      ((= cat "NACIONAL") "pe_dg2018_nacional")
      (T "pe_dg2018")
    )
  )
  (uchi:apply-template-file name)
)

(defun C:UCHI_TEMPLATE_DG_CAT (/ cat)
  (initget "VECINAL DEPARTAMENTAL NACIONAL")
  (setq cat (getkword "\nCategoría DG-2018 [VECINAL/DEPARTAMENTAL/NACIONAL] <VECINAL>: "))
  (if (or (not cat) (= cat "")) (setq cat "VECINAL"))
  (uchi:apply-template-dg2018-cat (strcase cat))
  (princ)
)

(defun uchi:apply-template-dg2018-cat-terrain (cat terr / name)
  (setq name (strcat "pe_dg2018_" (strcase cat) "_" (strcase terr)))
  (setq name (vl-string-translate " " "_" (strcase name)))
  (setq name (strcase name T))
  (if (not (uchi:apply-template-file name))
    (uchi:log "No se encontró template cat+terreno; se mantiene configuración previa.")
  )
)

(defun C:UCHI_TEMPLATE_DG_TERR (/ cat terr)
  (initget "VECINAL DEPARTAMENTAL NACIONAL")
  (setq cat (getkword "\nCategoría [VECINAL/DEPARTAMENTAL/NACIONAL] <VECINAL>: "))
  (if (or (not cat) (= cat "")) (setq cat "VECINAL"))
  (initget "PLANO ONDULADO ACCIDENTADO")
  (setq terr (getkword "\nTerreno [PLANO/ONDULADO/ACCIDENTADO] <ONDULADO>: "))
  (if (or (not terr) (= terr "")) (setq terr "ONDULADO"))
  (uchi:apply-template-dg2018-cat-terrain cat terr)
  (princ)
)

(princ)
