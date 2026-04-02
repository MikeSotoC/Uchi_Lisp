;;; UCHI Commands

(defun uchi:run-main (/ action)
  (uchi:log "Comando principal UCHI")
  (setq action (uchi:show-main-dialog))
  (cond
    ((= action "ok")
      (uchi:log "UI confirmada.")
    )
    ((= action "flujo")
      (C:UCHI_FLUJO)
    )
    ((= action "import")
      (C:UCHI_PUNTOS_IMPORT)
    )
    ((= action "valid")
      (C:UCHI_PUNTOS_VALIDAR)
    )
    (T
      (uchi:log "UI cancelada o no disponible.")
    )
  )
)

(defun C:UCHI ()
  (uchi:run-main)
  (princ)
)

(defun C:UCHI_MAIN ()
  ;; Alias de compatibilidad hacia atrás.
  (uchi:run-main)
  (princ)
)

(defun C:UCHI_TOPO ()
  (C:UCHI_FLUJO)
)

(defun C:UCHI_IMPORTAR_PUNTOS ()
  (C:UCHI_PUNTOS_IMPORT)
)


(defun C:UCHI_VALIDAR_PUNTOS ()
  (C:UCHI_PUNTOS_VALIDAR)
)

(defun C:TOPO_BASE ()
  ;; Alias legacy.
  (C:UCHI_TOPO)
)

(princ)
