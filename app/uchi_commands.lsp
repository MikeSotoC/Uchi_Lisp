;;; UCHI Commands

(defun uchi:run-main ()
  (uchi:log "Comando principal UCHI")
  (if (= (uchi:show-main-dialog) "ok")
    (uchi:log "UI confirmada.")
    (uchi:log "UI cancelada o no disponible.")
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
  (uchi:log "Flujo topográfico base iniciado.")
  ;; Punto de extensión para rutinas productivas.
  (uchi:log "Flujo topográfico base completado.")
  (princ)
)

(defun C:TOPO_BASE ()
  ;; Alias legacy.
  (C:UCHI_TOPO)
)

(princ)
