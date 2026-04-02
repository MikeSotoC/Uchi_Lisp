;;; UCHI Commands

(defun C:UCHI ()
  (uchi:log "Comando principal UCHI")
  (if (= (uchi:show-main-dialog) "ok")
    (uchi:log "UI confirmada.")
    (uchi:log "UI cancelada o no disponible.")
  )
  (princ)
)

(defun C:UCHI_TOPO ()
  (uchi:log "Flujo topográfico base iniciado.")
  ;; Punto de extensión para rutinas productivas.
  (uchi:log "Flujo topográfico base completado.")
  (princ)
)

(princ)
