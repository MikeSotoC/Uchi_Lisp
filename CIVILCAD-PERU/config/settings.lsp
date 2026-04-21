;;; ============================================================================
;;; CIVILCAD-PERÚ - CONFIGURACIÓN GENERAL
;;; Parámetros de configuración del sistema
;;; ============================================================================

;;; Variables globales de settings
(setq *CCP_SETTINGS_VERSION* "1.0.0")

;;; Configuración general
(setq *CCP_CONFIG* (list
  (cons 'system-name "CIVILCAD-PERÚ")
  (cons 'version "1.0.0")
  (cons 'author "Equipo CivilCAD Perú")
  (cons 'language "es-PE")
  
  ;; Rutas
  (cons 'base-path nil)  ; Se establece en loader
  (cons 'logs-path ".\\logs\\")
  (cons 'temp-path ".\\temp\\")
  (cons 'backup-path ".\\backup\\")
  
  ;; Unidades por defecto
  (cons 'default-units 'metric)
  (cons 'default-precision 3)
  (cons 'angle-units 'decimal-degrees)
  (cons 'angle-precision 2)
  
  ;; Capas por defecto
  (cons 'layer-points "TOPO-PUNTOS")
  (cons 'layer-curves "TOPO-CURVAS")
  (cons 'layer-text "TOPO-TEXTOS")
  (cons 'layer-dimensions "TOPO-COTAS")
  (cons 'layer-border "MARCO")
  
  ;; Colores por capa
  (cons 'color-points 1)      ; Rojo
  (cons 'color-curves 3)      ; Verde
  (cons 'color-text 7)        ; Blanco
  (cons 'color-dimensions 4)  ; Cyan
  (cons 'color-border 6)      ; Magenta
  
  ;; Estilos de texto
  (cons 'text-style "STANDARD")
  (cons 'text-height 2.5)
  (cons 'text-factor 0.8)
  
  ;; Logging
  (cons 'logging-enabled T)
  (cons 'logging-level 'info)  ; debug, info, warning, error
  (cons 'log-file-max-size 1048576)  ; 1MB
  
  ;; Auto-save
  (cons 'auto-save-enabled T)
  (cons 'auto-save-interval 15)  ; minutos
  
  ;; Backup
  (cons 'backup-enabled T)
  (cons 'backup-count 5)
  
  ;; Interfaz
  (cons 'show-progress T)
  (cons 'confirm-delete T)
  (cons 'undo-groups T)
))

;;; Función: CCP-get-setting
;;; Obtiene valor de configuración
(defun CCP-get-setting (key / value)
  (cdr (assoc key *CCP_CONFIG*))
)

;;; Función: CCP-set-setting
;;; Establece valor de configuración
(defun CCP-set-setting (key value / found new-config pair)
  (setq found nil)
  (setq new-config nil)
  
  (foreach pair *CCP_CONFIG*
    (if (equal (car pair) key)
      (progn
        (setq new-config (append new-config (list (cons key value))))
        (setq found T)
      )
      (setq new-config (append new-config (list pair)))
    )
  )
  
  (if (not found)
    (setq new-config (append new-config (list (cons key value))))
  )
  
  (setq *CCP_CONFIG* new-config)
  T
)

;;; Función: CCP-reset-settings
;;; Restablece configuración a valores por defecto
(defun CCP-reset-settings ()
  (CCP-init-settings)
  (princ "\n[SETTINGS] Configuración restablecida.")
)

;;; Función: CCP-save-settings
;;; Guarda configuración en archivo
(defun CCP-save-settings (filepath / )
  ;; Implementación para guardar en archivo
  (princ (strcat "\n[SETTINGS] Configuración guardada en: " filepath))
  T
)

;;; Función: CCP-load-settings-file
;;; Carga configuración desde archivo
(defun CCP-load-settings-file (filepath / )
  ;; Implementación para cargar desde archivo
  (princ (strcat "\n[SETTINGS] Configuración cargada desde: " filepath))
  T
)

(princ "\n[CONFIG] Settings cargados.")
(princ)
