;;; ============================================================================
;;; CIVILCAD-PERÚ - REGISTRO DE MÓDULOS (CONFIG)
;;; Lista de módulos disponibles para carga
;;; ============================================================================

;;; Variables globales de modules config
(setq *CCP_MODULES_CONFIG_VERSION* "1.0.0")

;;; Lista de módulos disponibles
(setq *CCP_AVAILABLE_MODULES* (list
  ;; Topografía
  (list
    (cons 'key "topografia")
    (cons 'name "Topografía")
    (cons 'category "topografia")
    (cons 'description "Importación de puntos, curvas de nivel y cálculo de áreas")
    (cons 'files (list
      "modules/topografia/topo-utils.lsp"
      "modules/topografia/topo.lsp"
    ))
    (cons 'init-function 'CCP_MOD_TOPO_INIT)
    (cons 'run-function 'CCP_MOD_TOPO_RUN)
    (cons 'enabled T)
  )
  
  ;; Carreteras
  (list
    (cons 'key "carreteras")
    (cons 'name "Carreteras")
    (cons 'category "carreteras")
    (cons 'description "Diseño geométrico horizontal y vertical según DG-1999")
    (cons 'files (list
      "modules/carreteras/carreteras.lsp"
    ))
    (cons 'init-function 'CCP_MOD_CARRETERAS_INIT)
    (cons 'run-function 'CCP_MOD_CARRETERAS_RUN)
    (cons 'enabled T)
  )
  
  ;; Saneamiento
  (list
    (cons 'key "saneamiento")
    (cons 'name "Saneamiento")
    (cons 'category "saneamiento")
    (cons 'description "Diseño de redes de agua y desagüe")
    (cons 'files (list
      "modules/saneamiento/saneamiento.lsp"
    ))
    (cons 'init-function 'CCP_MOD_SANEAMIENTO_INIT)
    (cons 'run-function 'CCP_MOD_SANEAMIENTO_RUN)
    (cons 'enabled T)
  )
  
  ;; Estructuras
  (list
    (cons 'key "estructuras")
    (cons 'name "Estructuras")
    (cons 'category "estructuras")
    (cons 'description "Análisis estructural según RNE")
    (cons 'files (list
      "modules/estructuras/estructuras.lsp"
    ))
    (cons 'init-function 'CCP_MOD_ESTRUCTURAS_INIT)
    (cons 'run-function 'CCP_MOD_ESTRUCTURAS_RUN)
    (cons 'enabled T)
  )
  
  ;; Reportes
  (list
    (cons 'key "reportes")
    (cons 'name "Reportes")
    (cons 'category "reportes")
    (cons 'description "Generación de reportes y memorias")
    (cons 'files (list
      "modules/reportes/reportes.lsp"
    ))
    (cons 'init-function 'CCP_MOD_REPORTES_INIT)
    (cons 'run-function 'CCP_MOD_REPORTES_RUN)
    (cons 'enabled T)
  )
))

;;; Función: CCP-get-module-config
;;; Obtiene configuración de un módulo específico
(defun CCP-get-module-config (module-key / mod)
  (setq mod nil)
  (foreach m *CCP_AVAILABLE_MODULES*
    (if (equal (cdr (assoc 'key m)) module-key)
      (setq mod m)
    )
  )
  mod
)

;;; Función: CCP-enable-module
;;; Habilita un módulo para carga
(defun CCP-enable-module (module-key / mod)
  (setq mod (CCP-get-module-config module-key))
  (if mod
    (progn
      (subst (cons 'enabled T) (assoc 'enabled mod) mod)
      T
    )
    nil
  )
)

;;; Función: CCP-disable-module
;;; Deshabilita un módulo para carga
(defun CCP-disable-module (module-key / mod)
  (setq mod (CCP-get-module-config module-key))
  (if mod
    (progn
      (subst (cons 'enabled nil) (assoc 'enabled mod) mod)
      T
    )
    nil
  )
)

;;; Función: CCP-list-available-modules
;;; Lista todos los módulos disponibles
(defun CCP-list-available-modules ()
  (princ "\n\n=== MÓDULOS DISPONIBLES ===\n")
  (foreach mod *CCP_AVAILABLE_MODULES*
    (princ (strcat "\n  [" (cdr (assoc 'key mod)) "] " 
                   (cdr (assoc 'name mod))))
    (princ (strcat "\n      Categoría: " (cdr (assoc 'category mod))))
    (princ (strcat "\n      Estado: " 
                   (if (cdr (assoc 'enabled mod)) "Habilitado" "Deshabilitado")))
    (princ (strcat "\n      Descripción: " (cdr (assoc 'description mod))))
  )
  (princ "\n=========================\n")
)

;;; Función: CCP-get-enabled-modules
;;; Obtiene lista de módulos habilitados
(defun CCP-get-enabled-modules (/ result)
  (setq result nil)
  (foreach mod *CCP_AVAILABLE_MODULES*
    (if (cdr (assoc 'enabled mod))
      (setq result (append result (list mod)))
    )
  )
  result
)

(princ "\n[CONFIG] Modules config cargado.")
(princ)
