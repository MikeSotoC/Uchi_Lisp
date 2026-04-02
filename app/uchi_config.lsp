;;; UCHI Config con compatibilidad legacy

(setq *uchi-config-default*
  (list
    (cons "brand" "UCHI")
    (cons "main_command" "UCHI")
    (cons "topo_command" "UCHI_TOPO")
  )
)

;; Mapa: clave nueva -> lista de claves legacy aceptadas en lectura.
(setq *uchi-legacy-key-map*
  (list
    (cons "brand" (list "civilcad_brand"))
    (cons "main_command" (list "civilcad_cmd_main" "main_cmd"))
    (cons "topo_command" (list "civilcad_cmd_topo" "topo_cmd"))
  )
)

(defun uchi:cfg-env-key (k)
  (strcat "UCHI_CFG_" (strcase k))
)

(defun uchi:cfg-get-raw (k / envv)
  (setq envv (getenv (uchi:cfg-env-key k)))
  (if envv envv nil)
)

(defun uchi:cfg-get-legacy (legacy-keys / val)
  (setq val nil)
  (while (and legacy-keys (not val))
    (setq val (getenv (uchi:cfg-env-key (car legacy-keys))))
    (setq legacy-keys (cdr legacy-keys))
  )
  val
)

(defun uchi:cfg-get-default (k)
  (cdr (assoc k *uchi-config-default*))
)

(defun uchi:cfg-get (k / raw legacyPair legacyVal)
  (setq raw (uchi:cfg-get-raw k))
  (if raw
    raw
    (progn
      (setq legacyPair (assoc k *uchi-legacy-key-map*))
      (if legacyPair
        (progn
          (setq legacyVal (uchi:cfg-get-legacy (cdr legacyPair)))
          (if legacyVal legacyVal (uchi:cfg-get-default k))
        )
        (uchi:cfg-get-default k)
      )
    )
  )
)

(defun uchi:cfg-brand ()
  "UCHI"
)

(princ)
