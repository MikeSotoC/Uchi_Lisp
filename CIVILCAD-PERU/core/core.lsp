;;; ============================================================================
;;; CIVILCAD-PERÚ - CORE SYSTEM
;;; Núcleo principal del sistema - Compatible con AutoCAD y ZWCAD
;;; ============================================================================

;;; Variables globales del core
(setq *CCP_CORE_VERSION* "1.0.0")
(setq *CCP_DEBUG_MODE* nil)

;;; Función: vl-prin1-to-string-safe
;;; Fallback seguro para vl-prin1-to-string (compatible ZWCAD/AutoCAD)
(defun vl-prin1-to-string-safe (obj / result str-result)
  ;; Intentar usar vl-prin1-to-string si está disponible
  (if (and (boundp 'vl-prin1-to-string) 
           (not (vl-catch-all-error-p (vl-catch-all-apply '(lambda () (vl-prin1-to-string ""))))))
    (progn
      (setq result (vl-catch-all-apply '(lambda () (vl-prin1-to-string obj))))
      (if (or (null result) (vl-catch-all-error-p result))
        ;; Si falla, usar fallbacks
        (cond
          ((stringp obj) obj)
          ((numberp obj) (rtos obj 2 4))
          ((symbolp obj) (vl-symbol-name-safe obj))
          ((listp obj) (vl-list->string-safe obj))
          (t (princ-to-string obj))
        )
        result
      )
    )
    ;; vl-prin1-to-string no disponible, usar fallbacks directos
    (cond
      ((stringp obj) obj)
      ((numberp obj) (rtos obj 2 4))
      ((symbolp obj) (vl-symbol-name-safe obj))
      ((listp obj) (vl-list->string-safe obj))
      (t (princ-to-string obj))
    )
  )
)

;;; Función: vl-symbol-name-safe
;;; Fallback seguro para vl-symbol-name
(defun vl-symbol-name-safe (sym / result)
  (if (and (boundp 'vl-symbol-name)
           (not (vl-catch-all-error-p (vl-catch-all-apply '(lambda () (vl-symbol-name 'test))))))
    (progn
      (setq result (vl-catch-all-apply '(lambda () (vl-symbol-name sym))))
      (if (or (null result) (vl-catch-all-error-p result))
        (princ-to-string sym)
        result
      )
    )
    (princ-to-string sym)
  )
)

;;; Función: vl-list->string-safe
;;; Fallback seguro para vl-list->string
(defun vl-list->string-safe (lst / result str)
  (if (and (boundp 'vl-list->string)
           (not (vl-catch-all-error-p (vl-catch-all-apply '(lambda () (vl-list->string '(1 2 3)))))))
    (progn
      (setq result (vl-catch-all-apply '(lambda () (vl-list->string lst))))
      (if (or (null result) (vl-catch-all-error-p result))
        ;; Fallback: convertir lista a string manualmente
        (princ-to-string lst)
        result
      )
    )
    (princ-to-string lst)
  )
)

;;; Función: vl-catch-all-error-message-safe
;;; Fallback seguro para vl-catch-all-error-message (compatible ZWCAD/AutoCAD)
(defun vl-catch-all-error-message-safe (err-obj / result)
  (cond
    ;; Si es un objeto de error VLISP
    ((and (boundp 'vl-catch-all-error-message)
          (not (vl-catch-all-error-p (vl-catch-all-apply '(lambda () (vl-catch-all-error-message err-obj))))))
      (setq result (vl-catch-all-apply '(lambda () (vl-catch-all-error-message err-obj))))
      (if (or (null result) (vl-catch-all-error-p result))
        (princ-to-string err-obj)
        result
      )
    )
    ;; Si err-obj ya es un string
    ((stringp err-obj) err-obj)
    ;; Fallback genérico
    (t (princ-to-string err-obj))
  )
)

;;; Función: CCP-fboundp-safe
;;; Verifica si una función existe (compatible ZWCAD/AutoCAD)
;;; Esta función NO usa fboundp directamente para evitar errores en ZWCAD
(defun CCP-fboundp-safe (func-name / result test-result)
  ;; Intentar verificar si el símbolo está bound
  (setq result 
    (vl-catch-all-apply
      '(lambda ()
         (setq test-result (eval func-name))
         (if (or (functionp test-result) (subrp test-result))
           T
           (progn
             ;; Si no es función directa, verificar si puede ser llamada
             (vl-catch-all-apply
               '(lambda () (apply func-name nil))
             )
             T
           )
         )
       )
    )
  )
  ;; Si hubo error, la función no existe
  (if (vl-catch-all-error-p result)
    nil
    result
  )
)

;;; Función: CCP-debug
;;; Imprime mensajes de debug si está activado
(defun CCP-debug (msg)
  (if *CCP_DEBUG_MODE*
    (princ (strcat "\n[DEBUG] " msg))
  )
)

;;; Función: CCP-safe-call
;;; Ejecuta una función con manejo seguro de errores (compatible ZWCAD/AutoCAD)
(defun CCP-safe-call (func-name / result)
  (if (CCP-fboundp-safe func-name)
    (vl-catch-all-apply '(lambda () (apply func-name nil)))
    (progn
      (princ (strcat "\n[CORE] Función no encontrada: " (vl-prin1-to-string-safe func-name)))
      nil
    )
  )
)

;;; Función: CCP-get-dwg-info
;;; Obtiene información del dibujo actual
(defun CCP-get-dwg-info ()
  (list
    (cons 'dwg-name (getvar "DWGNAME"))
    (cons 'dwg-prefix (getvar "DWGPREFIX"))
    (cons 'units (getvar "LUNITS"))
    (cons 'precision (getvar "LUPREC"))
    (cons 'insbase (getvar "INSBASE"))
  )
)

;;; Función: CCP-set-units
;;; Configura unidades según estándar peruano
(defun CCP-set-units (unit-type / )
  (cond
    ((= unit-type 'metric)
      (setvar "LUNITS" 2)      ; Decimal
      (setvar "LUPREC" 3)      ; 3 decimales
      (setvar "AUNITS" 0)      ; Grados decimales
      (setvar "AUPREC" 2)      ; 2 decimales para ángulos
    )
    ((= unit-type 'utm)
      (setvar "LUNITS" 2)
      (setvar "LUPREC" 4)      ; 4 decimales para UTM
      (setvar "AUNITS" 0)
      (setvar "AUPREC" 4)
    )
  )
  (princ (strcat "\n[CORE] Unidades configuradas: " (vl-prin1-to-string-safe unit-type)))
)

;;; Función: CCP-start-undo
;;; Inicia grupo UNDO
(defun CCP-start-undo ()
  (command "_.UNDO" "_Begin")
)

;;; Función: CCP-end-undo
;;; Finaliza grupo UNDO
(defun CCP-end-undo ()
  (command "_.UNDO" "_End")
)

;;; Función: CCP-cancel-undo
;;; Cancela grupo UNDO en caso de error
(defun CCP-cancel-undo ()
  (command "_.UNDO" "_Back")
)

;;; Función: CCP-layer-exists
;;; Verifica si existe un layer
(defun CCP-layer-exists (layer-name)
  (tblsearch "LAYER" layer-name)
)

;;; Función: CCP-create-layer
;;; Crea un layer con propiedades específicas
(defun CCP-create-layer (layer-name color linetype / )
  (if (not (CCP-layer-exists layer-name))
    (progn
      (command "_.LAYER" "_Make" layer-name "_Color" (vl-prin1-to-string-safe color) "" "")
      (if (and linetype (not (tblsearch "LTYPE" linetype)))
        (command "_.LINETYPE" "_Load" linetype "acad.lin" "")
      )
      (if linetype
        (command "_.LAYER" "_Set" layer-name "_LType" linetype "" "")
      )
      T
    )
    nil
  )
)

;;; Función: CCP-set-current-layer
;;; Establece el layer actual, creándolo si no existe
(defun CCP-set-current-layer (layer-name / )
  (if (not (CCP-layer-exists layer-name))
    (CCP-create-layer layer-name 7 "Continuous")
  )
  (command "_.LAYER" "_Set" layer-name "")
  layer-name
)

;;; Función: CCP-get-user-input
;;; Obtiene input del usuario con validación
(defun CCP-get-user-input (prompt-msg data-type / result)
  (setq result nil)
  
  (cond
    ((= data-type 'string)
      (setq result (getstring prompt-msg))
    )
    ((= data-type 'real)
      (setq result (getreal prompt-msg))
    )
    ((= data-type 'int)
      (setq result (getint prompt-msg))
    )
    ((= data-type 'point)
      (setq result (getpoint prompt-msg))
    )
    ((= data-type 'dist)
      (setq result (getdist prompt-msg))
    )
    ((= data-type 'angle)
      (setq result (getangle prompt-msg))
    )
  )
  
  result
)

;;; Función: CCP-message-box
;;; Muestra mensaje al usuario
(defun CCP-message-box (msg type / )
  (cond
    ((= type 'info)
      (alert (strcat "CIVILCAD-PERÚ\n\n" msg))
    )
    ((= type 'warning)
      (alert (strcat "ADVERTENCIA\n\n" msg))
    )
    ((= type 'error)
      (alert (strcat "ERROR\n\n" msg))
    )
  )
)

;;; Función: CCP-progress-bar
;;; Simula barra de progreso en línea de comando
(defun CCP-progress-bar (current total step / pct bars i)
  (setq pct (/ (* 100.0 current) total))
  (setq bars (fix (/ pct 5)))
  (princ "\r[")
  (setq i 0)
  (while (< i bars)
    (princ "#")
    (setq i (1+ i))
  )
  (while (< i 20)
    (princ ".")
    (setq i (1+ i))
  )
  (princ (strcat "] " (rtos pct 2 1) "%"))
  (if (= current total)
    (princ "\n")
  )
)

(princ "\n[CORE] Módulo core cargado.")
(princ)
