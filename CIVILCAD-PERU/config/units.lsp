;;; ============================================================================
;;; CIVILCAD-PERÚ - CONFIGURACIÓN DE UNIDADES
;;; Definición de sistemas de unidades
;;; ============================================================================

;;; Variables globales de units
(setq *CCP_UNITS_VERSION* "1.0.0")

;;; Sistemas de unidades disponibles
(setq *CCP_UNIT_SYSTEMS* (list
  (cons 'metric (list
    (cons 'name "Métrico")
    (cons 'lunits 2)           ; Decimal
    (cons 'luprec 3)           ; 3 decimales
    (cons 'aunits 0)           ; Grados decimales
    (cons 'auprec 2)           ; 2 decimales
    (cons 'insunits 4)         ; Metros
    (cons 'suffix " m")
  ))
  
  (cons 'architectural (list
    (cons 'name "Arquitectónico")
    (cons 'lunits 4)           ; Arquitectónico
    (cons 'luprec 4)           ; 1/16"
    (cons 'aunits 0)
    (cons 'auprec 0)
    (cons 'insunits 1)         ; Pulgadas
    (cons 'suffix "\"")
  ))
  
  (cons 'engineering (list
    (cons 'name "Ingeniería")
    (cons 'lunits 5)           ; Ingeniería
    (cons 'luprec 4)           ; 0.00'
    (cons 'aunits 0)
    (cons 'auprec 2)
    (cons 'insunits 1)
    (cons 'suffix "'")
  ))
  
  (cons 'utm (list
    (cons 'name "UTM WGS84")
    (cons 'lunits 2)
    (cons 'luprec 4)           ; 4 decimales para UTM
    (cons 'aunits 0)
    (cons 'auprec 4)
    (cons 'insunits 4)
    (cons 'suffix " m")
  ))
))

;;; Función: CCP-set-unit-system
;;; Configura el sistema de unidades del dibujo
(defun CCP-set-unit-system (system-key / sys-config)
  (setq sys-config (cdr (assoc system-key *CCP_UNIT_SYSTEMS*)))
  
  (if sys-config
    (progn
      (setvar "LUNITS" (cdr (assoc 'lunits sys-config)))
      (setvar "LUPREC" (cdr (assoc 'luprec sys-config)))
      (setvar "AUNITS" (cdr (assoc 'aunits sys-config)))
      (setvar "AUPREC" (cdr (assoc 'auprec sys-config)))
      (setvar "INSUNITS" (cdr (assoc 'insunits sys-config)))
      
      (princ (strcat "\n[UNITS] Sistema configurado: " 
                     (cdr (assoc 'name sys-config))))
      T
    )
    (progn
      (princ (strcat "\n[UNITS] Sistema no encontrado: " 
                     (vl-prin1-to-string system-key)))
      nil
    )
  )
)

;;; Función: CCP-get-current-units
;;; Obtiene configuración actual de unidades
(defun CCP-get-current-units ()
  (list
    (cons 'lunits (getvar "LUNITS"))
    (cons 'luprec (getvar "LUPREC"))
    (cons 'aunits (getvar "AUNITS"))
    (cons 'auprec (getvar "AUPREC"))
    (cons 'insunits (getvar "INSUNITS"))
  )
)

;;; Función: CCP-format-distance
;;; Formatea distancia según unidades actuales
(defun CCP-format-distance (dist / luprec)
  (setq luprec (getvar "LUPREC"))
  (rtos dist (getvar "LUNITS") luprec)
)

;;; Función: CCP-format-angle
;;; Formatea ángulo según unidades actuales
(defun CCP-format-angle (ang / auprec)
  (setq auprec (getvar "AUPREC"))
  (angtos ang (getvar "AUNITS") auprec)
)

;;; Función: CCP-convert-units
;;; Convierte valor entre sistemas de unidades
(defun CCP-convert-units (value from-sys to-sys / factor)
  ;; Factores de conversión a metros
  (setq conversion-factors (list
    (cons 'meters 1.0)
    (cons 'kilometers 1000.0)
    (cons 'centimeters 0.01)
    (cons 'millimeters 0.001)
    (cons 'inches 0.0254)
    (cons 'feet 0.3048)
    (cons 'yards 0.9144)
    (cons 'miles 1609.344)
  ))
  
  (setq from-factor (cdr (assoc from-sys conversion-factors)))
  (setq to-factor (cdr (assoc to-sys conversion-factors)))
  
  (if (and from-factor to-factor)
    (/ (* value from-factor) to-factor)
    value
  )
)

;;; Función: CCP-list-unit-systems
;;; Lista todos los sistemas de unidades disponibles
(defun CCP-list-unit-systems ()
  (princ "\n\n=== SISTEMAS DE UNIDADES ===\n")
  (foreach sys *CCP_UNIT_SYSTEMS*
    (princ (strcat "\n  " (vl-prin1-to-string (car sys)) ": " 
                   (cdr (assoc 'name (cdr sys)))))
  )
  (princ "\n==========================\n")
)

(princ "\n[CONFIG] Units cargados.")
(princ)
