;;; ============================================================================
;;; CIVILCAD-PERÚ - REGISTRY SYSTEM
;;; Registro central de módulos
;;; ============================================================================

;;; Variables globales del registry
(setq *CCP_REGISTRY_VERSION* "1.0.0")
(setq *CCP_MODULE_REGISTRY* nil)

;;; Función: CCP-registry-init
;;; Inicializa el registry vacío
(defun CCP-registry-init ()
  (setq *CCP_MODULE_REGISTRY* nil)
  (princ "\n[REGISTRY] Registry inicializado.")
)

;;; Función: CCP-register-module
;;; Registra un módulo en el sistema
(defun CCP-register-module (key name init-func run-func description category / module)
  (setq module (list
    (cons 'key key)
    (cons 'name name)
    (cons 'init-func init-func)
    (cons 'run-func run-func)
    (cons 'description description)
    (cons 'category category)
    (cons 'status 'ready)
    (cons 'last-run nil)
  ))
  
  ;; Verificar si ya existe y actualizar, o agregar nuevo
  (if (CCP-get-module key)
    (progn
      (CCP-unregister-module key)
    )
  )
  
  (setq *CCP_MODULE_REGISTRY* (append *CCP_MODULE_REGISTRY* (list module)))
  (princ (strcat "\n[REGISTRY] Módulo registrado: " name))
  module
)

;;; Función: CCP-unregister-module
;;; Elimina un módulo del registry
(defun CCP-unregister-module (key / new-registry)
  (setq new-registry nil)
  (foreach mod *CCP_MODULE_REGISTRY*
    (if (not (equal (cdr (assoc 'key mod)) key))
      (setq new-registry (append new-registry (list mod)))
    )
  )
  (setq *CCP_MODULE_REGISTRY* new-registry)
  (princ (strcat "\n[REGISTRY] Módulo eliminado: " key))
)

;;; Función: CCP-get-module
;;; Obtiene un módulo por su clave
(defun CCP-get-module (key / mod)
  (setq mod nil)
  (foreach m *CCP_MODULE_REGISTRY*
    (if (equal (cdr (assoc 'key m)) key)
      (setq mod m)
    )
  )
  mod
)

;;; Función: CCP-get-modules-by-category
;;; Obtiene todos los módulos de una categoría
(defun CCP-get-modules-by-category (category / result)
  (setq result nil)
  (foreach mod *CCP_MODULE_REGISTRY*
    (if (equal (cdr (assoc 'category mod)) category)
      (setq result (append result (list mod)))
    )
  )
  result
)

;;; Función: CCP-list-modules
;;; Lista todos los módulos registrados
(defun CCP-list-modules (/ mod)
  (princ "\n\n=== MÓDULOS REGISTRADOS ===\n")
  (foreach mod *CCP_MODULE_REGISTRY*
    (princ (strcat "\n  [" (cdr (assoc 'key mod)) "] " (cdr (assoc 'name mod))))
    (princ (strcat "\n      Categoría: " (cdr (assoc 'category mod))))
    (princ (strcat "\n      Estado: " (vl-prin1-to-string (cdr (assoc 'status mod)))))
    (princ (strcat "\n      Descripción: " (cdr (assoc 'description mod))))
  )
  (princ "\n==========================\n")
  *CCP_MODULE_REGISTRY*
)

;;; Función: CCP-set-module-status
;;; Actualiza el estado de un módulo
(defun CCP-set-module-status (key status / mod)
  (setq mod (CCP-get-module key))
  (if mod
    (progn
      (foreach m *CCP_MODULE_REGISTRY*
        (if (equal (cdr (assoc 'key m)) key)
          (subst (cons 'status status) (assoc 'status m) m)
        )
      )
      T
    )
    nil
  )
)

;;; Función: CCP-set-module-last-run
;;; Actualiza la fecha de última ejecución
(defun CCP-set-module-last-run (key timestamp / mod)
  (setq mod (CCP-get-module key))
  (if mod
    (progn
      (foreach m *CCP_MODULE_REGISTRY*
        (if (equal (cdr (assoc 'key m)) key)
          (subst (cons 'last-run timestamp) (assoc 'last-run m) m)
        )
      )
      T
    )
    nil
  )
)

;;; Función: CCP-get-module-count
;;; Obtiene el número de módulos registrados
(defun CCP-get-module-count ()
  (length *CCP_MODULE_REGISTRY*)
)

;;; Función: CCP-initialize-registry
;;; Inicializa el registry con todos los módulos del sistema
(defun CCP-initialize-registry ()
  (CCP-registry-init)
  
  ;; Registrar módulo de Topografía
  (CCP-register-module
    "topografia"
    "Topografía"
    'CCP_MOD_TOPO_INIT
    'CCP_MOD_TOPO_RUN
    "Importación de puntos, curvas de nivel y cálculo de áreas"
    "topografia"
  )
  
  ;; Registrar módulo de Carreteras
  (CCP-register-module
    "carreteras"
    "Carreteras"
    'CCP_MOD_CARRETERAS_INIT
    'CCP_MOD_CARRETERAS_RUN
    "Diseño geométrico horizontal y vertical según DG-1999"
    "carreteras"
  )
  
  ;; Registrar módulo de Saneamiento
  (CCP-register-module
    "saneamiento"
    "Saneamiento"
    'CCP_MOD_SANEAMIENTO_INIT
    'CCP_MOD_SANEAMIENTO_RUN
    "Diseño de redes de agua y desagüe"
    "saneamiento"
  )
  
  ;; Registrar módulo de Estructuras
  (CCP-register-module
    "estructuras"
    "Estructuras"
    'CCP_MOD_ESTRUCTURAS_INIT
    'CCP_MOD_ESTRUCTURAS_RUN
    "Análisis estructural según RNE"
    "estructuras"
  )
  
  ;; Registrar módulo de Reportes
  (CCP-register-module
    "reportes"
    "Reportes"
    'CCP_MOD_REPORTES_INIT
    'CCP_MOD_REPORTES_RUN
    "Generación de reportes y memorias"
    "reportes"
  )
  
  (princ (strcat "\n[REGISTRY] " (vl-prin1-to-string (CCP-get-module-count)) " módulos registrados."))
  *CCP_MODULE_REGISTRY*
)

(princ "\n[REGISTRY] Módulo registry cargado.")
(princ)
