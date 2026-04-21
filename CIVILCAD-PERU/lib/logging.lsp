;;; ============================================================================
;;; CIVILCAD-PERÚ - LOGGING SYSTEM
;;; Sistema de registro de eventos y errores
;;; ============================================================================

;;; Variables globales de logging
(setq *CCP_LOGGING_VERSION* "1.0.0")
(setq *CCP_LOG_FILE* nil)
(setq *CCP_LOG_ENABLED* T)
(setq *CCP_LOG_LEVEL* 'info)  ; debug, info, warning, error

;;; Niveles de log
(setq *CCP_LOG_LEVELS* (list
  (cons 'debug 0)
  (cons 'info 1)
  (cons 'warning 2)
  (cons 'error 3)
  (cons 'fatal 4)
))

;;; Función: CCP-get-log-path
;;; Obtiene ruta del archivo de log
(defun CCP-get-log-path ()
  (if *CCP_BASE_PATH*
    (strcat *CCP_BASE_PATH* "\\logs\\civilcad.log")
    ".\\logs\\civilcad.log"
  )
)

;;; Función: CCP-init-logging
;;; Inicializa el sistema de logging
(defun CCP-init-logging ()
  (setq *CCP_LOG_FILE* (CCP-get-log-path))
  
  ;; Crear directorio de logs si no existe
  (if (not (findfile *CCP_LOG_FILE*))
    (progn
      ;; Intentar crear el archivo
      (setq f (open *CCP_LOG_FILE* "w"))
      (if f
        (progn
          (close f)
          (CCP-log-event 'info "Sistema de logging inicializado")
        )
        (progn
          (princ "\n[LOGGING] ERROR: No se pudo crear archivo de log")
          (setq *CCP_LOG_ENABLED* nil)
        )
      )
    )
  )
  
  (princ (strcat "\n[LOGGING] Logging inicializado: " *CCP_LOG_FILE*))
  T
)

;;; Función: CCP-get-timestamp-string
;;; Obtiene timestamp formateado para logs (compatible AutoCAD/ZWCAD)
(defun CCP-get-timestamp-string ()
  (cond
    ;; Método 1: Usar menucmd si está disponible (AutoCAD)
    ((CCP-fboundp-safe 'menucmd)
      (menucmd "M=$(edtime,$(getvar,date),YYYY-MM-DD HH:MM:SS)")
    )
    ;; Método 2: Usar rtos con CDATE (ZWCAD/AutoCAD)
    (T
      (setq cdate-val (getvar "CDATE"))
      (if cdate-val
        (strcat
          (rtos (fix (/ cdate-val 10000)) 2 0) "-"  ; Año
          (rtos (fix (/ (rem cdate-val 10000) 100)) 2 0) "-"  ; Mes
          (rtos (fix (rem cdate-val 100)) 2 0) " "  ; Día
          (rtos (fix (/ (rem cdate-val 1) 10000)) 2 0) ":"  ; Hora
          (rtos (fix (rem (/ (rem cdate-val 1) 100) 100)) 2 0) ":"  ; Minutos
          (rtos (fix (rem (rem cdate-val 1) 100)) 2 0)  ; Segundos
        )
        "0000-00-00 00:00:00"
      )
    )
  )
)

;;; Función: CCP-log-level-ok
;;; Verifica si el nivel de log debe ser registrado
(defun CCP-log-level-ok (level / current-level new-level)
  (if (not *CCP_LOG_ENABLED*)
    nil
    (progn
      (setq current-level (cdr (assoc *CCP_LOG_LEVEL* *CCP_LOG_LEVELS*)))
      (setq new-level (cdr (assoc level *CCP_LOG_LEVELS*)))
      
      (if (and current-level new-level)
        (>= new-level current-level)
        T
      )
    )
  )
)

;;; Función: CCP-log-event
;;; Registra un evento en el log (compatible AutoCAD/ZWCAD)
(defun CCP-log-event (level message / log-line timestamp level-str)
  (if (not (CCP-log-level-ok level))
    nil
    (progn
      (setq timestamp (CCP-get-timestamp-string))
      ;; Obtener string del nivel de forma segura
      (setq level-str 
        (cond
          ((= level 'debug) "DEBUG")
          ((= level 'info) "INFO")
          ((= level 'warning) "WARNING")
          ((= level 'error) "ERROR")
          ((= level 'fatal) "FATAL")
          (T "INFO")
        )
      )
      (setq log-line (strcat 
        "[" timestamp "] "
        "[" level-str "] "
        (if *CCP_CURRENT_MODULE*
          (strcat "[" *CCP_CURRENT_MODULE* "] ")
          ""
        )
        message
        "\n"
      ))
      
      ;; Escribir al archivo
      (setq f (open *CCP_LOG_FILE* "a"))
      (if f
        (progn
          (write-line log-line f)
          (close f)
          
          ;; También mostrar en consola si es warning o error
          (if (or (= level 'warning) (= level 'error) (= level 'fatal))
            (princ (strcat "\n[" level-str "] " message))
          )
          
          T
        )
        (progn
          (princ (strcat "\n[LOGGING] ERROR escribiendo al log: " message))
          nil
        )
      )
    )
  )
)

;;; Función: CCP-log-debug
;;; Registra mensaje de debug
(defun CCP-log-debug (message)
  (CCP-log-event 'debug message)
)

;;; Función: CCP-log-info
;;; Registra mensaje informativo
(defun CCP-log-info (message)
  (CCP-log-event 'info message)
)

;;; Función: CCP-log-warning
;;; Registra advertencia
(defun CCP-log-warning (message)
  (CCP-log-event 'warning message)
)

;;; Función: CCP-log-error
;;; Registra error
(defun CCP-log-error (message)
  (CCP-log-event 'error message)
)

;;; Función: CCP-log-fatal
;;; Registra error fatal
(defun CCP-log-fatal (message)
  (CCP-log-event 'fatal message)
)

;;; Función: CCP-log-module-start
;;; Registra inicio de módulo
(defun CCP-log-module-start (module-name)
  (CCP-log-event 'info (strcat "=== INICIO MÓDULO: " module-name " ==="))
)

;;; Función: CCP-log-module-end
;;; Registra fin de módulo
(defun CCP-log-module-end (module-name success)
  (CCP-log-event 'info 
    (strcat "=== FIN MÓDULO: " module-name " - " 
            (if success "EXITOSO" "FALLIDO") " ===")
  )
)

;;; Función: CCP-log-operation
;;; Registra operación específica
(defun CCP-log-operation (operation details / )
  (CCP-log-event 'info 
    (strcat "OPERACIÓN: " operation " | DETALLES: " details)
  )
)

;;; Función: CCP-get-log-content
;;; Obtiene contenido completo del log
(defun CCP-get-log-content (/ f content line)
  (setq content "")
  (setq f (open *CCP_LOG_FILE* "r"))
  
  (if f
    (progn
      (setq line (read-line f))
      (while line
        (setq content (strcat content line "\n"))
        (setq line (read-line f))
      )
      (close f)
    )
  )
  
  content
)

;;; Función: CCP-clear-log
;;; Limpia el archivo de log
(defun CCP-clear-log ()
  (setq f (open *CCP_LOG_FILE* "w"))
  (if f
    (progn
      (close f)
      (CCP-log-event 'info "Log limpiado")
      T
    )
    nil
  )
)

;;; Función: CCP-set-log-level
;;; Establece nivel mínimo de logging
(defun CCP-set-log-level (level)
  (if (assoc level *CCP_LOG_LEVELS*)
    (progn
      (setq *CCP_LOG_LEVEL* level)
      (princ (strcat "\n[LOGGING] Nivel establecido: " (vl-prin1-to-string level)))
      T
    )
    (progn
      (princ (strcat "\n[LOGGING] Nivel inválido: " (vl-prin1-to-string level)))
      nil
    )
  )
)

;;; Función: CCP-enable-logging
;;; Habilita logging
(defun CCP-enable-logging ()
  (setq *CCP_LOG_ENABLED* T)
  (princ "\n[LOGGING] Logging habilitado.")
)

;;; Función: CCP-disable-logging
;;; Deshabilita logging
(defun CCP-disable-logging ()
  (setq *CCP_LOG_ENABLED* nil)
  (princ "\n[LOGGING] Logging deshabilitado.")
)

(princ "\n[LIB] Logging System cargado.")
(princ)
