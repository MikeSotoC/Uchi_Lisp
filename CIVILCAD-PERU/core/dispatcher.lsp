;;; ============================================================================
;;; CIVILCAD-PERÚ - DISPATCHER SYSTEM
;;; Ejecutor unificado de módulos - Compatible con AutoCAD y ZWCAD
;;; ============================================================================

;;; Variables globales del dispatcher
(setq *CCP_DISPATCHER_VERSION* "1.0.0")
(setq *CCP_CURRENT_MODULE* nil)
(setq *CCP_EXECUTION_LOG* nil)

;;; Función: CCP-run-module
;;; Ejecuta un módulo completo (INIT + RUN) con manejo de errores
(defun CCP-run-module (module-key / module init-func run-func result error-occurred)
  (setq error-occurred nil)
  
  ;; Validar que el módulo existe
  (setq module (CCP-get-module module-key))
  
  (if (not module)
    (progn
      (princ (strcat "\n[DISPATCHER] ERROR: Módulo no encontrado: " module-key))
      (CCP-log-event "error" (strcat "Módulo no encontrado: " module-key))
      (setq result nil)
    )
    (progn
      ;; Obtener funciones del módulo
      (setq init-func (cdr (assoc 'init-func module)))
      (setq run-func (cdr (assoc 'run-func module)))
      
      ;; Actualizar estado del módulo
      (CCP-set-module-status module-key 'running)
      (setq *CCP_CURRENT_MODULE* module-key)
      
      (princ (strcat "\n\n[DISPATCHER] Ejecutando módulo: " (cdr (assoc 'name module))))
      (princ (strcat "\n[DISPATCHER] Clave: " module-key))
      
      ;; Iniciar grupo UNDO
      (CCP-start-undo)
      
      ;; Ejecutar INIT si existe
      (if (and init-func (CCP-fboundp-safe init-func))
        (progn
          (princ "\n[DISPATCHER] Ejecutando inicialización...")
          (setq result (vl-catch-all-apply init-func))
          
          (if (vl-catch-all-error-p result)
            (progn
              (setq error-occurred T)
              (princ (strcat "\n[DISPATCHER] ERROR en INIT: " (vl-catch-all-error-message result)))
              (CCP-log-event "error" (strcat "Error en INIT de " module-key ": " (vl-catch-all-error-message result)))
            )
            (progn
              (princ "\n[DISPATCHER] Inicialización completada.")
              (CCP-log-event "info" (strcat "INIT completado para " module-key))
            )
          )
        )
        (progn
          (princ "\n[DISPATCHER] No hay función INIT definida.")
        )
      )
      
      ;; Ejecutar RUN si no hubo error en INIT
      (if (and (not error-occurred) run-func (CCP-fboundp-safe run-func))
        (progn
          (princ "\n[DISPATCHER] Ejecutando módulo principal...")
          (setq result (vl-catch-all-apply run-func))
          
          (if (vl-catch-all-error-p result)
            (progn
              (setq error-occurred T)
              (princ (strcat "\n[DISPATCHER] ERROR en RUN: " (vl-catch-all-error-message result)))
              (CCP-log-event "error" (strcat "Error en RUN de " module-key ": " (vl-catch-all-error-message result)))
              (CCP-cancel-undo)
              (princ "\n[DISPATCHER] Operación cancelada. Cambios deshechos.")
            )
            (progn
              (princ "\n[DISPATCHER] Módulo ejecutado correctamente.")
              (CCP-log-event "success" (strcat "RUN completado para " module-key))
              
              ;; Registrar timestamp
              (CCP-set-module-last-run module-key (rtos (getvar "CDATE") 2 0))
            )
          )
        )
      )
      
      ;; Finalizar grupo UNDO si todo salió bien
      (if (and (not error-occurred))
        (progn
          (CCP-end-undo)
          (princ "\n[DISPATCHER] Grupo UNDO cerrado.")
        )
      )
      
      ;; Actualizar estado final
      (if error-occurred
        (CCP-set-module-status module-key 'error)
        (CCP-set-module-status module-key 'ready)
      )
      
      (setq *CCP_CURRENT_MODULE* nil)
      
      (princ (strcat "\n[DISPATCHER] Ejecución de " module-key " finalizada."))
      
      (not error-occurred)
    )
  )
)

;;; Función: CCP-run-module-quiet
;;; Ejecuta un módulo sin output detallado (para batch)
(defun CCP-run-module-quiet (module-key / result)
  (setq *CCP_DEBUG_MODE* nil)
  (setq result (CCP-run-module module-key))
  (setq *CCP_DEBUG_MODE* nil)
  result
)

;;; Función: CCP-run-all-modules
;;; Ejecuta todos los módulos en secuencia
(defun CCP-run-all-modules (/ results mod)
  (setq results nil)
  
  (princ "\n[DISPATCHER] Ejecutando todos los módulos...")
  
  (foreach mod *CCP_MODULE_REGISTRY*
    (setq key (cdr (assoc 'key mod)))
    (princ (strcat "\n\n--- Módulo: " key " ---"))
    (setq result (CCP-run-module key))
    (setq results (append results (list (cons key result))))
  )
  
  (princ "\n\n[DISPATCHER] Todos los módulos ejecutados.")
  results
)

;;; Función: CCP-execute-function
;;; Ejecuta una función específica con manejo de errores (compatible ZWCAD/AutoCAD)
(defun CCP-execute-function (func-name args / result)
  (if (CCP-fboundp-safe func-name)
    (progn
      (setq result (vl-catch-all-apply func-name args))
      (if (vl-catch-all-error-p result)
        (progn
          (princ (strcat "\n[DISPATCHER] Error ejecutando " (vl-prin1-to-string-safe func-name) ": "))
          (princ (vl-catch-all-error-message result))
          (CCP-log-event "error" (strcat "Error en " (vl-prin1-to-string-safe func-name) ": " (vl-catch-all-error-message result)))
          nil
        )
        result
      )
    )
    (progn
      (princ (strcat "\n[DISPATCHER] Función no encontrada: " (vl-prin1-to-string-safe func-name)))
      nil
    )
  )
)

;;; Función: CCP-validate-module
;;; Valida que un módulo esté listo para ejecución (compatible ZWCAD/AutoCAD)
(defun CCP-validate-module (module-key / module errors)
  (setq errors nil)
  (setq module (CCP-get-module module-key))
  
  (if (not module)
    (setq errors (append errors '("Módulo no registrado")))
    (progn
      ;; Verificar función INIT
      (if (not (CCP-fboundp-safe (cdr (assoc 'init-func module))))
        (setq errors (append errors '("Función INIT no disponible")))
      )
      
      ;; Verificar función RUN
      (if (not (CCP-fboundp-safe (cdr (assoc 'run-func module))))
        (setq errors (append errors '("Función RUN no disponible")))
      )
    )
  )
  
  (if errors
    (progn
      (princ (strcat "\n[VALIDACIÓN] Módulo " module-key " tiene errores:"))
      (foreach err errors
        (princ (strcat "\n  - " err))
      )
      nil
    )
    (progn
      (princ (strcat "\n[VALIDACIÓN] Módulo " module-key " está listo."))
      T
    )
  )
)

;;; Función: CCP-get-execution-history
;;; Obtiene el historial de ejecución
(defun CCP-get-execution-history ()
  *CCP_EXECUTION_LOG*
)

;;; Función: CCP-clear-execution-history
;;; Limpia el historial de ejecución
(defun CCP-clear-execution-history ()
  (setq *CCP_EXECUTION_LOG* nil)
  (princ "\n[DISPATCHER] Historial limpiado.")
)

(princ "\n[DISPATCHER] Módulo dispatcher cargado.")
(princ)
