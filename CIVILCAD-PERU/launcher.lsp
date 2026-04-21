;;; ============================================================================
;;; CIVILCAD-PERÚ - LAUNCHER UI
;;; Interfaz principal del sistema - Compatible con AutoCAD y ZWCAD
;;; ============================================================================

(setq *CCP_LAUNCHER_VERSION* "1.0.0")
(setq *CCP_DCL_LOADED* nil)

;;; Función: CCP_LAUNCHER
;;; Función principal que inicia la interfaz
(defun CCP_LAUNCHER ()
  (if (not *CCP_INITIALIZED*)
    (progn
      (alert "CIVILCAD-PERÚ\n\nEl sistema no está inicializado.\nEjecute primero el loader.")
      nil
    )
    (progn
      (princ "\n[LAUNCHER] Iniciando interfaz...")
      
      ;; Cargar DCL
      (setq dcl-path (strcat *CCP_BASE_PATH* "\\launcher.dcl"))
      
      (if (not (findfile dcl-path))
        (progn
          (princ "\n[LAUNCHER] ERROR: No se encontró launcher.dcl")
          (CCP_launcher-simple)  ; Fallback a modo simple
          nil
        )
        (progn
          (setq dcl-id (load_dialog dcl-path))
          
          (if (< dcl-id 0)
            (progn
              (princ "\n[LAUNCHER] ERROR cargando DCL")
              (CCP_launcher-simple)
              nil
            )
            (progn
              (setq *CCP_DCL_LOADED* T)
              
              ;; Mostrar diálogo
              (setq result (start_dialog))
              
              (unload_dialog dcl-id)
              (setq *CCP_DCL_LOADED* nil)
              
              result
            )
          )
        )
      )
    )
  )
)

;;; Función: CCP_launcher-simple
;;; Launcher en modo consola (fallback)
(defun CCP_launcher-simple (/ opcion)
  (princ "\n\n")
  (princ "╔════════════════════════════════════════════╗\n")
  (princ "║     CIVILCAD-PERÚ v1.0.0                  ║\n")
  (princ "║     Suite CAD para Ingeniería Civil       ║\n")
  (princ "╠════════════════════════════════════════════╣\n")
  (princ "║  MÓDULOS DISPONIBLES:                     ║\n")
  (princ "║                                           ║\n")
  (princ "║  1. TOPOGRAFÍA                            ║\n")
  (princ "║     - Importar puntos CSV                 ║\n")
  (princ "║     - Curvas de nivel                     ║\n")
  (princ "║     - Áreas y perímetros                  ║\n")
  (princ "║                                           ║\n")
  (princ "║  2. CARRETERAS (DG-1999)                  ║\n")
  (princ "║     - Curvas horizontales                 ║\n")
  (princ "║     - Peraltes                            ║\n")
  (princ "║     - Visibilidad                         ║\n")
  (princ "║                                           ║\n")
  (princ "║  3. SANEAMIENTO (MVCS)                    ║\n")
  (princ "║     - Agua potable                        ║\n")
  (princ "║     - Desagüe (Manning)                   ║\n")
  (princ "║     - DOT                                 ║\n")
  (princ "║                                           ║\n")
  (princ "║  4. ESTRUCTURAS (RNE)                     ║\n")
  (princ "║     - Vigas y columnas                    ║\n")
  (princ "║     - Cálculo sísmico                     ║\n")
  (princ "║     - Zapatas                             ║\n")
  (princ "║                                           ║\n")
  (princ "║  5. REPORTES                              ║\n")
  (princ "║     - Memorias                            ║\n")
  (princ "║     - Tablas                              ║\n")
  (princ "║     - Exportar                            ║\n")
  (princ "║                                           ║\n")
  (princ "╠════════════════════════════════════════════╣\n")
  (princ "║  0. SALIR                                 ║\n")
  (princ "╚════════════════════════════════════════════╝\n")
  
  (setq continuar T)
  
  (while continuar
    (princ "\nSeleccione módulo (0-5): ")
    (setq opcion (getint))
    
    (cond
      ((= opcion 1)
        (CCP_run-module "topografia")
      )
      ((= opcion 2)
        (CCP_run-module "carreteras")
      )
      ((= opcion 3)
        (CCP_run-module "saneamiento")
      )
      ((= opcion 4)
        (CCP_run-module "estructuras")
      )
      ((= opcion 5)
        (CCP_run-module "reportes")
      )
      ((= opcion 0)
        (setq continuar nil)
        (princ "\n[CIVILCAD-PERÚ] Sesión finalizada.")
      )
      (T
        (princ "\nOpción inválida. Intente nuevamente.")
      )
    )
  )
  
  T
)

;;; Callbacks para DCL
(defun CCP_dcc_exit ()
  (done_dialog 0)
)

(defun CCP_dcc_topo ()
  (done_dialog 1)
  (CCP_run-module "topografia")
)

(defun CCP_dcc_carreteras ()
  (done_dialog 2)
  (CCP_run-module "carreteras")
)

(defun CCP_dcc_saneamiento ()
  (done_dialog 3)
  (CCP_run-module "saneamiento")
)

(defun CCP_dcc_estructuras ()
  (done_dialog 4)
  (CCP_run-module "estructuras")
)

(defun CCP_dcc_reportes ()
  (done_dialog 5)
  (CCP_run-module "reportes")
)

(defun CCP_dcc_config ()
  (alert "Configuración\n\nEsta función estará disponible en próximas versiones.")
)

(defun CCP_dcc_help ()
  (alert "AYUDA CIVILCAD-PERÚ\n\n"
         "Topografía: Importe puntos CSV y genere curvas de nivel.\n\n"
         "Carreteras: Diseño geométrico según DG-1999.\n\n"
         "Saneamiento: Redes de agua y desagüe según MVCS.\n\n"
         "Estructuras: Diseño según RNE (E.020, E.030, E.050, E.060).\n\n"
         "Reportes: Genere memorias y tablas.")
)

(princ "\n[LAUNCHER] Módulo launcher cargado.")
(princ)
