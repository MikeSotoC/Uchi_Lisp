;;; ============================================================================
;;; CIVILCAD-PERÚ - LOADER PRINCIPAL
;;; Sistema de Ingeniería Civil para AutoCAD y ZWCAD
;;; Versión: 1.0.0
;;; ============================================================================

;;; Variables globales del loader
(setq *CCP_LOADER_VERSION* "1.0.0")
(setq *CCP_BASE_PATH* nil)
(setq *CCP_INITIALIZED* nil)

;;; Función: CCP-fboundp-early
;;; Verifica si una función existe (versión temprana antes de cargar core.lsp)
;;; NO usa fboundp directamente para evitar errores en ZWCAD
(defun CCP-fboundp-early (func-name / result)
  (vl-catch-all-apply
    '(lambda ()
       ;; Intentar evaluar el símbolo
       (setq result (eval func-name))
       ;; Si es una función o subr, existe
       (if (or (functionp result) (subrp result))
         T
         ;; Si no, verificar si puede ser llamada
         (progn
           (vl-catch-all-apply '(lambda () (apply func-name nil)))
           T
         )
       )
     )
  )
  ;; Si hubo error al evaluar, la función no existe
  (if (vl-catch-all-error-p 
        (vl-catch-all-apply '(lambda () (eval func-name))))
    nil
    T
  )
)

;;; Función: CCP-load-vlisp
;;; Carga VLISP si está disponible (AutoCAD) o usa alternativas (ZWCAD)
(defun CCP-load-vlisp ()
  (if (not (CCP-fboundp-early 'vl-filename-directory))
    (progn
      ;; Intentar cargar vlisp en AutoCAD
      (if (findfile "vlisp.fas")
        (load "vlisp.fas")
      )
    )
  )
  T
)

;;; Función: CCP_get-loader-path
;;; Obtiene la ruta completa del archivo loader.lsp (compatible ZWCAD/AutoCAD)
(defun CCP_get-loader-path (/ path)
  (cond
    ;; Método 1: Usar *LOADING* si está disponible
    ((and (boundp '*LOADING*) *LOADING*)
     (vl-filename-directory *LOADING*)
    )
    ;; Método 2: Buscar en search path
    ((findfile "loader.lsp")
     (vl-filename-directory (findfile "loader.lsp"))
    )
    ;; Método 3: Usar directorio actual
    (t 
      (setq path (getvar "DWGPREFIX"))
      (if (or (null path) (= path ""))
        "."
        path
      )
    )
  )
)

;;; Función: CCP_setup-paths
;;; Configura todas las rutas del sistema (compatible AutoCAD/ZWCAD)
(defun CCP_setup-paths ()
  ;; Obtener ruta base usando método robusto
  (setq *CCP_BASE_PATH* (CCP_get-loader-path))
  
  ;; Verificar que la ruta existe
  (if (or (null *CCP_BASE_PATH*) (= *CCP_BASE_PATH* "") (= *CCP_BASE_PATH* "."))
    (progn
      (princ "\n[LOADER] ADVERTENCIA: Usando directorio actual como ruta base.")
      (setq *CCP_BASE_PATH* (getvar "DWGPREFIX"))
    )
  )
  
  (princ (strcat "\n[LOADER] Ruta base: " *CCP_BASE_PATH*))
  
  ;; Agregar subdirectorios al support path (AutoCAD/ZWCAD)
  (foreach subdir '("core" "lib" "modules" "config" "resources" "modules/topografia" "modules/carreteras" "modules/saneamiento" "modules/estructuras" "modules/reportes")
    (setq fullpath (strcat *CCP_BASE_PATH* "\\" subdir))
    (if (findfile fullpath)
      (progn
        ;; Agregar al support path si está disponible
        (if (getvar "SUPPORTPATH")
          (progn
            (setq existing-path (getvar "SUPPORTPATH"))
            (if (not (wcmatch existing-path (strcat "*" fullpath "*")))
              (setvar "SUPPORTPATH" (strcat existing-path ";" fullpath))
            )
          )
        )
      )
    )
  )
  (princ "\n[LOADER] Rutas configuradas correctamente.")
)

;;; Función: CCP_load-file
;;; Carga un archivo LSP con manejo de errores
(defun CCP_load-file (filepath / result)
  (if (findfile filepath)
    (progn
      (setq result (vl-catch-all-apply '(lambda () (load filepath))))
      (if (not (vl-catch-all-error-p result))
        (progn
          (princ (strcat "\n[LOADER] Cargado: " filepath))
          T
        )
        (progn
          (princ (strcat "\n[LOADER] ERROR cargando: " filepath " - " (vl-catch-all-error-msg result)))
          nil
        )
      )
    )
    (progn
      ;; Archivo no encontrado, continuar sin error fatal
      (princ (strcat "\n[LOADER] Info: Archivo no encontrado: " filepath))
      nil
    )
  )
)

;;; Función: CCP_load-config
;;; Carga archivos de configuración
(defun CCP_load-config ()
  (princ "\n[LOADER] Cargando configuración...")
  
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\config\\settings.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\config\\units.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\config\\modules.lsp"))
  
  (princ "\n[LOADER] Configuración cargada.")
)

;;; Función: CCP_load-libraries
;;; Carga librerías compartidas
(defun CCP_load-libraries ()
  (princ "\n[LOADER] Cargando librerías...")
  
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\lib\\utils.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\lib\\dcl-helpers.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\lib\\dwg-tools.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\lib\\rne-constants.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\lib\\logging.lsp"))
  
  (princ "\n[LOADER] Librerías cargadas.")
)

;;; Función: CCP_load-core
;;; Carga el núcleo del sistema
(defun CCP_load-core ()
  (princ "\n[LOADER] Cargando núcleo del sistema...")
  
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\core\\core.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\core\\registry.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\core\\dispatcher.lsp"))
  
  (princ "\n[LOADER] Núcleo cargado.")
)

;;; Función: CCP_load-modules
;;; Carga todos los módulos registrados
(defun CCP_load-modules ()
  (princ "\n[LOADER] Cargando módulos...")
  
  ;; Topografía
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\topografia\\topo-utils.lsp"))
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\topografia\\topo.lsp"))
  
  ;; Carreteras
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\carreteras\\carreteras.lsp"))
  
  ;; Saneamiento
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\saneamiento\\saneamiento.lsp"))
  
  ;; Estructuras
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\estructuras\\estructuras.lsp"))
  
  ;; Reportes
  (CCP_load-file (strcat *CCP_BASE_PATH* "\\modules\\reportes\\reportes.lsp"))
  
  (princ "\n[LOADER] Módulos cargados.")
)

;;; Función: CCP_init-system
;;; Inicializa todo el sistema
(defun CCP_init-system ()
  (princ "\n\n========================================")
  (princ "\nCIVILCAD-PERÚ v1.0.0")
  (princ "\nSistema de Ingeniería Civil para AutoCAD y ZWCAD")
  (princ "\n========================================\n")
  
  ;; Cargar VLISP si es necesario (compatibilidad)
  (CCP-load-vlisp)
  
  (CCP_setup-paths)
  (CCP_load-config)
  (CCP_load-libraries)
  (CCP_load-core)
  (CCP_load-modules)
  
  ;; Inicializar registry - verificar si existe la función
  (if (and (boundp '*CCP_MODULE_REGISTRY*) 
           (not (null *CCP_MODULE_REGISTRY*)))
    (progn
      (princ "\n[LOADER] Registry ya inicializado.")
    )
    (progn
      (if (CCP-fboundp-early 'CCP-initialize-registry)
        (CCP-initialize-registry)
        (princ "\n[LOADER] ADVERTENCIA: CCP-initialize-registry no disponible, usando fallback.")
      )
    )
  )
  
  ;; Inicializar logging
  (if (CCP-fboundp-early 'CCP-init-logging)
    (CCP-init-logging)
  )
  
  (setq *CCP_INITIALIZED* T)
  
  (princ "\n\n[LOADER] Sistema inicializado correctamente.")
  (princ "\nEjecutar (CCP_LAUNCHER) para iniciar la interfaz.\n")
  
  *CCP_INITIALIZED*
)

;;; Función: CCP_validate-installation
;;; Valida que la instalación sea correcta (compatible ZWCAD/AutoCAD)
(defun CCP_validate-installation (/ errors)
  (setq errors nil)
  
  (princ "\n\n[VALIDACIÓN] Verificando instalación...")
  
  ;; Verificar loader
  (if (not *CCP_BASE_PATH*)
    (setq errors (append errors '("Loader no inicializado")))
  )
  
  ;; Verificar core
  (if (not (CCP-fboundp-early 'CCP_run-module))
    (setq errors (append errors '("Dispatcher no disponible")))
  )
  
  ;; Verificar registry
  (if (not (CCP-fboundp-early 'CCP-get-module))
    (setq errors (append errors '("Registry no disponible")))
  )
  
  ;; Verificar normativa
  (if (not (boundp '*CCP_RNE_E020*))
    (setq errors (append errors '("Normativa RNE no cargada")))
  )
  
  (if errors
    (progn
      (princ "\n[VALIDACIÓN] ERRORES encontrados:")
      (foreach err errors
        (princ (strcat "\n  - " err))
      )
      nil
    )
    (progn
      (princ "\n[VALIDACIÓN] Instalación correcta.")
      T
    )
  )
)

;;; Auto-load al cargar este archivo
(CCP_init-system)

(princ "\n[CIVILCAD-PERU] Loader completado.")
(princ)
