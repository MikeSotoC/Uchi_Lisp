;;; UCHI Config con compatibilidad legacy

(setq *uchi-config-default*
  (list
    (cons "brand" "UCHI")
    (cons "main_command" "UCHI")
    (cons "topo_command" "UCHI_TOPO")
  )
)

(setq *uchi-legacy-key-map*
  (list
    (cons "civilcad_brand" "brand")
    (cons "civilcad_cmd_main" "main_command")
    (cons "civilcad_cmd_topo" "topo_command")
  )
)

(defun uchi:cfg-get-raw (k / envv)
  (setq envv (getenv (strcat "UCHI_CFG_" (strcase k))))
  (if envv envv nil)
)

(defun uchi:cfg-get-legacy (legacy-k)
  (getenv (strcat "UCHI_CFG_" (strcase legacy-k)))
)

(defun uchi:cfg-get (k / v pair legacy)
  (setq v (uchi:cfg-get-raw k))
  (if v
    v
    (progn
      (setq pair (assoc (strcase k) (mapcar '(lambda (x) (cons (strcase (car x)) (cdr x))) *uchi-legacy-key-map*)))
      (if pair
        (progn
          (setq legacy (uchi:cfg-get-legacy (cdr pair)))
          (if legacy legacy nil)
        )
        (cdr (assoc k *uchi-config-default*))
      )
    )
  )
)

(defun uchi:cfg-brand ()
  "UCHI"
)

(princ)
