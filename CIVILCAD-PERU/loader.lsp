;;; ============================================================================
;;; CIVILCAD-PERÚ - LOADER PRINCIPAL
;;; Sistema de Ingeniería Civil para AutoCAD
;;; Versión: 1.0.0
;;; ============================================================================

;;; Variables globales del loader
(setq *CCP_LOADER_VERSION* "1.0.0")
(setq *CCP_BASE_PATH* nil)
(setq *CCP_INITIALIZED* nil)

;;; Función: CCP_get-base-path
;;; Obtiene la ruta base del sistema desde el archivo loader actual
(defun CCP_get-base-path ()
  (if *CCP_BASE_PATH*
    *CCP_BASE_PATH*
    (setq *CCP_BASE_PATH*
      (vl-filename-directory
        (vl-string-translate "/" "\\"
          (rtos (getvar "MENUNAME") 2 0) ; Fallback inicial
        )
      )
    )
    ;; Si falla el método anterior, usar *LOADING* o path relativo
    (if (or (null *CCP_BASE_PATH*) (= *CCP_BASE_PATH* ""))
      (setq *CCP_BASE_PATH*
        (vl-filename-directory
          (cond
            ((and (boundp '*LOADING*) *LOADING*) *LOADING*)
            ((findfile "loader.lsp") (findfile "loader.lsp"))
            (t (getvar "LASTSAVEDFILE"))
          )
        )
      )
    )
    ;; Normalizar path (eliminar nombre de archivo, dejar solo directorio)
    (if (and *CCP_BASE_PATH* 
             (not (wcmatch *CCP_BASE_PATH* "*\\\\$")))
      (setq *CCP_BASE_PATH* 
        (vl-filename-directory 
          (strcat *CCP_BASE_PATH* "\\dummy.lsp")
        )
      )
    )
    *CCP_BASE_PATH*
  )
)

;;; Función: CCP_get-loader-path
;;; Obtiene la ruta completa del archivo loader.lsp
(defun CCP_get-loader-path (/ path)
  (cond
    ;; Método 1: Usar vl-system-registry (si está disponible)
    ((and (fboundp 'vlax-get-acad-object) 
          (setq acadObj (vlax-get-acad-object)))
     (setq path (vl-filename-directory 
                  (vl-string-translate "/" "\\" 
                    (vl-filename-base (vl-filename-directory (vl-princ-to-string (vlax-get-property acadObj 'FullName))))
                  )
                )
     )
    )
    ;; Método 2: Buscar en search path
    ((findfile "loader.lsp")
     (vl-filename-directory (findfile "loader.lsp"))
    )
    ;; Método 3: Usar directorio actual
    (t (getvar "DWGPREFIX"))
  )
)

;;; Función: CCP_setup-paths
;;; Configura todas las rutas del sistema
(defun CCP_setup-paths ()
  ;; Obtener ruta base usando método robusto
  (setq *CCP_BASE_PATH* (CCP_get-loader-path))
  
  ;; Verificar que la ruta existe
  (if (not (findfile *CCP_BASE_PATH*))
    (progn
      (princ "\n[LOADER] ERROR: No se pudo determinar la ruta base.")
      (princ "\n[LOADER] Por favor, cargue el sistema desde APPLOAD con la ruta completa.")
      (exit)
    )
  )
  
  (princ (strcat "\n[LOADER] Ruta base: " *CCP_BASE_PATH*))
  
  ;; Agregar subdirectorios al support path de AutoCAD
  (foreach subdir '("core" "lib" "modules" "config" "resources" "modules/topografia" "modules/carreteras" "modules/saneamiento" "modules/estructuras" "modules/reportes")
    (setq fullpath (strcat *CCP_BASE_PATH* "\\" subdir))
    (if (findfile fullpath)
      (progn
        ;; Agregar al support path temporalmente para esta sesión
        (setq existing-path (getvar "SUPPORTPATH"))
        (if (not (wcmatch existing-path (strcat "*" fullpath "*")))
          (setvar "SUPPORTPATH" (strcat existing-path ";" fullpath))
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
      (setq result (load filepath))
      (if result
        (progn
          (princ (strcat "\n[LOADER] Cargado: " filepath))
          T
        )
        (progn
          (princ (strcat "\n[LOADER] ERROR cargando: " filepath))
          nil
        )
      )
    )
    (progn
      (princ (strcat "\n[LOADER] Archivo no encontrado: " filepath))
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
  (princ "\nSistema de Ingeniería Civil para AutoCAD")
  (princ "\n========================================\n")
  
  (CCP_setup-paths)
  (CCP_load-config)
  (CCP_load-libraries)
  (CCP_load-core)
  (CCP_load-modules)
  
  ;; Inicializar registry
  (if (fboundp 'CCP_initialize-registry)
    (CCP_initialize-registry)
  )
  
  ;; Inicializar logging
  (if (fboundp 'CCP_init-logging)
    (CCP_init-logging)
  )
  
  (setq *CCP_INITIALIZED* T)
  
  (princ "\n\n[LOADER] Sistema inicializado correctamente.")
  (princ "\nEjecutar (CCP_LAUNCHER) para iniciar la interfaz.\n")
  
  *CCP_INITIALIZED*
)

;;; Función: CCP_validate-installation
;;; Valida que la instalación sea correcta
(defun CCP_validate-installation (/ errors)
  (setq errors nil)
  
  (princ "\n\n[VALIDACIÓN] Verificando instalación...")
  
  ;; Verificar loader
  (if (not *CCP_BASE_PATH*)
    (setq errors (append errors '("Loader no inicializado")))
  )
  
  ;; Verificar core
  (if (not (fboundp 'CCP_run-module))
    (setq errors (append errors '("Dispatcher no disponible")))
  )
  
  ;; Verificar registry
  (if (not (fboundp 'CCP-get-module))
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
