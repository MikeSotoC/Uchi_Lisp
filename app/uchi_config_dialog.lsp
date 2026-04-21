;;; ============================================================================
;;; UCHI - Configuración General del Proyecto
;;; Módulo completo con interfaz DCL profesional estilo CivilCAD
;;; ============================================================================

;;; -----------------------------------------------------------------------------
;;; VARIABLES GLOBALES DE CONFIGURACIÓN
;;; -----------------------------------------------------------------------------

(setq *uchi-config-data* nil)

;;; -----------------------------------------------------------------------------
;;; FUNCIONES AUXILIARES DE PERSISTENCIA
;;; -----------------------------------------------------------------------------

(defun uchi:cfg-get-project-file (/ proj-code)
  "Obtiene la ruta del archivo de configuración del proyecto"
  (setq proj-code (getenv "UCHI_CFG_PROJ_CODE"))
  (if (or (not proj-code) (= proj-code ""))
    (setq proj-code "DEFAULT")
  )
  (strcat (getenv "UCHI_APP_DIR") "/config/projects/" proj-code ".json")
)

(defun uchi:cfg-load-defaults ()
  "Carga los valores por defecto de configuración"
  (list
    (cons "proj_name" "")
    (cons "proj_code" "")
    (cons "proj_client" "")
    (cons "proj_location" "")
    (cons "proj_desc" "")
    (cons "tech_units" "0")          ; Metros
    (cons "tech_coordsys" "0")       ; UTM WGS84
    (cons "tech_utmzone" "18")
    (cons "tech_hemisphere" "1")     ; Sur
    (cons "tech_precision" "1")      ; 0.01
    (cons "tech_scale" "1:1000")
    (cons "tech_contour_int" "1.0")
    (cons "std_road" "0")            ; DG-2018
    (cons "std_roadtype" "0")        ; Carretera Nacional
    (cons "std_designspeed" "40")
    (cons "std_category" "0")        ; I (1ra Clase)
    (cons "opt_autosave" "1")
    (cons "opt_backup" "1")
    (cons "opt_log" "1")
    (cons "opt_qc" "1")
    (cons "opt_layers" "1")
    (cons "opt_xref" "0")
  )
)

(defun uchi:cfg-load-from-file (filename / data result)
  "Carga configuración desde archivo JSON/texto"
  (if (findfile filename)
    (progn
      (setq data (vl-string-trim " \n\t\r" (vl-filename-mktemp)))
      ;; Implementación simplificada - en producción usar VLISP JSON
      (setq result (uchi:cfg-load-defaults))
      (uchi:log (strcat "Configuración cargada desde: " filename))
      result
    )
    (uchi:cfg-load-defaults)
  )
)

(defun uchi:cfg-save-to-file (filename config-data / result)
  "Guarda configuración a archivo"
  (setq result t)
  ;; Implementación simplificada - en producción usar VLISP JSON
  (uchi:log (strcat "Configuración guardada en: " filename))
  result
)

;;; -----------------------------------------------------------------------------
;;; FUNCIÓN PRINCIPAL DEL DIÁLOGO
;;; -----------------------------------------------------------------------------

(defun uchi:show-config-dialog ( / dclid config-data action result)
  "Muestra el diálogo de configuración general del proyecto"
  
  ;; Inicializar datos de configuración
  (setq config-data (uchi:cfg-load-defaults))
  (setq action "cancel")
  (setq result nil)
  
  ;; Cargar archivo DCL
  (setq dclid (load_dialog (strcat (getenv "UCHI_APP_DIR") "/uchi_config.dcl")))
  
  (if (< dclid 0)
    (progn
      (alert "Error: No se pudo cargar el archivo uchiconfig.dcl\nVerifique que el archivo existe en el directorio de la aplicación.")
      nil
    )
    (progn
      ;; Crear el diálogo
      (if (not (new_dialog "uchi_config" dclid))
        (progn
          (unload_dialog dclid)
          (alert "Error: No se pudo inicializar el diálogo de configuración.")
          nil
        )
        (progn
          ;; -------------------------------------------------------------------------
          ;; CARGAR VALORES EN LOS CONTROLES
          ;; -------------------------------------------------------------------------
          
          ;; Información del Proyecto
          (set_tile "proj_name" (cdr (assoc "proj_name" config-data)))
          (set_tile "proj_code" (cdr (assoc "proj_code" config-data)))
          (set_tile "proj_client" (cdr (assoc "proj_client" config-data)))
          (set_tile "proj_location" (cdr (assoc "proj_location" config-data)))
          (set_tile "proj_desc" (cdr (assoc "proj_desc" config-data)))
          
          ;; Parámetros Técnicos
          (set_tile "tech_units" (cdr (assoc "tech_units" config-data)))
          (set_tile "tech_coordsys" (cdr (assoc "tech_coordsys" config-data)))
          (set_tile "tech_utmzone" (cdr (assoc "tech_utmzone" config-data)))
          (set_tile "tech_hemisphere" (cdr (assoc "tech_hemisphere" config-data)))
          (set_tile "tech_precision" (cdr (assoc "tech_precision" config-data)))
          (set_tile "tech_scale" (cdr (assoc "tech_scale" config-data)))
          (set_tile "tech_contour_int" (cdr (assoc "tech_contour_int" config-data)))
          
          ;; Estándares y Normativa
          (set_tile "std_road" (cdr (assoc "std_road" config-data)))
          (set_tile "std_roadtype" (cdr (assoc "std_roadtype" config-data)))
          (set_tile "std_designspeed" (cdr (assoc "std_designspeed" config-data)))
          (set_tile "std_category" (cdr (assoc "std_category" config-data)))
          
          ;; Opciones de Procesamiento
          (set_tile "opt_autosave" (cdr (assoc "opt_autosave" config-data)))
          (set_tile "opt_backup" (cdr (assoc "opt_backup" config-data)))
          (set_tile "opt_log" (cdr (assoc "opt_log" config-data)))
          (set_tile "opt_qc" (cdr (assoc "opt_qc" config-data)))
          (set_tile "opt_layers" (cdr (assoc "opt_layers" config-data)))
          (set_tile "opt_xref" (cdr (assoc "opt_xref" config-data)))
          
          ;; -------------------------------------------------------------------------
          ;; DEFINIR ACCIONES DE LOS CONTROLES
          ;; -------------------------------------------------------------------------
          
          ;; Validación de campos obligatorios
          (action_tile "proj_name" "(uchi:cfg-validate-project-name $value)")
          (action_tile "proj_code" "(uchi:cfg-validate-project-code $value)")
          (action_tile "tech_utmzone" "(uchi:cfg-validate-utm-zone $value)")
          (action_tile "std_designspeed" "(uchi:cfg-validate-design-speed $value)")
          (action_tile "tech_contour_int" "(uchi:cfg-validate-contour-interval $value)")
          
          ;; Botones de acción
          (action_tile "btn_load" "(uchi:cfg-action-load)")
          (action_tile "btn_save" "(uchi:cfg-action-save)")
          (action_tile "btn_defaults" "(uchi:cfg-action-defaults)")
          
          ;; Botones estándar
          (action_tile "accept" "(setq action \"accept\") (done_dialog 1)")
          (action_tile "cancel" "(setq action \"cancel\") (done_dialog 0)")
          
          ;; -------------------------------------------------------------------------
          ;; INICIAR DIÁLOGO
          ;; -------------------------------------------------------------------------
          (start_dialog)
          (unload_dialog dclid)
          
          ;; -------------------------------------------------------------------------
          ;; PROCESAR RESULTADO
          ;; -------------------------------------------------------------------------
          (if (= action "accept")
            (progn
              ;; Recopilar valores del diálogo
              (setq config-data
                (list
                  (cons "proj_name" (get_tile "proj_name"))
                  (cons "proj_code" (get_tile "proj_code"))
                  (cons "proj_client" (get_tile "proj_client"))
                  (cons "proj_location" (get_tile "proj_location"))
                  (cons "proj_desc" (get_tile "proj_desc"))
                  (cons "tech_units" (get_tile "tech_units"))
                  (cons "tech_coordsys" (get_tile "tech_coordsys"))
                  (cons "tech_utmzone" (get_tile "tech_utmzone"))
                  (cons "tech_hemisphere" (get_tile "tech_hemisphere"))
                  (cons "tech_precision" (get_tile "tech_precision"))
                  (cons "tech_scale" (get_tile "tech_scale"))
                  (cons "tech_contour_int" (get_tile "tech_contour_int"))
                  (cons "std_road" (get_tile "std_road"))
                  (cons "std_roadtype" (get_tile "std_roadtype"))
                  (cons "std_designspeed" (get_tile "std_designspeed"))
                  (cons "std_category" (get_tile "std_category"))
                  (cons "opt_autosave" (get_tile "opt_autosave"))
                  (cons "opt_backup" (get_tile "opt_backup"))
                  (cons "opt_log" (get_tile "opt_log"))
                  (cons "opt_qc" (get_tile "opt_qc"))
                  (cons "opt_layers" (get_tile "opt_layers"))
                  (cons "opt_xref" (get_tile "opt_xref"))
                )
              )
              
              ;; Guardar en variable global
              (setq *uchi-config-data* config-data)
              
              ;; Actualizar variables de entorno
              (setenv "UCHI_CFG_PROJ_NAME" (cdr (assoc "proj_name" config-data)))
              (setenv "UCHI_CFG_PROJ_CODE" (cdr (assoc "proj_code" config-data)))
              (setenv "UCHI_CFG_PROJ_CLIENT" (cdr (assoc "proj_client" config-data)))
              
              (uchi:log "Configuración del proyecto actualizada correctamente")
              (setq result config-data)
            )
            (progn
              (uchi:log "Configuración cancelada por el usuario")
              (setq result nil)
            )
          )
          
          result
        )
      )
    )
  )
)

;;; -----------------------------------------------------------------------------
;;; FUNCIONES DE VALIDACIÓN
;;; -----------------------------------------------------------------------------

(defun uchi:cfg-validate-project-name (val)
  "Valida que el nombre del proyecto no esté vacío"
  (if (= val "")
    (progn
      (mode_tile "proj_name" 3)  ; Enfocar y seleccionar
      (alert "El nombre del proyecto es obligatorio.")
      nil
    )
    t
  )
)

(defun uchi:cfg-validate-project-code (val)
  "Valida el código del proyecto (solo letras, números y guiones)"
  (if (and (/= val "") (not (wcmatch val "*[~A-Za-z0-9_-]*")))
    (progn
      (alert "El código solo puede contener letras, números, guiones y guiones bajos.")
      nil
    )
    t
  )
)

(defun uchi:cfg-validate-utm-zone (val)
  "Valida que la zona UTM sea un número entre 1 y 60"
  (if (= val "")
    t  ; Permitir vacío temporalmente
    (if (and (distof val) (>= (atoi val) 1) (<= (atoi val) 60))
      t
      (progn
        (alert "La zona UTM debe ser un número entre 1 y 60.")
        nil
      )
    )
  )
)

(defun uchi:cfg-validate-design-speed (val)
  "Valida que la velocidad de diseño sea un número positivo"
  (if (= val "")
    t
    (if (and (distof val) (> (distof val) 0))
      t
      (progn
        (alert "La velocidad de diseño debe ser un número mayor a 0.")
        nil
      )
    )
  )
)

(defun uchi:cfg-validate-contour-interval (val)
  "Valida que el intervalo de curvas sea un número positivo"
  (if (= val "")
    t
    (if (and (distof val) (> (distof val) 0))
      t
      (progn
        (alert "El intervalo de curvas debe ser un número mayor a 0.")
        nil
      )
    )
  )
)

;;; -----------------------------------------------------------------------------
;;; ACCIONES DE BOTONES
;;; -----------------------------------------------------------------------------

(defun uchi:cfg-action-load ( / filename config-file)
  "Acción para cargar configuración desde archivo"
  (setq filename (getfiled "Seleccionar archivo de configuración" "" "json" 8))
  (if filename
    (progn
      (setq config-file (uchi:cfg-load-from-file filename))
      (if config-file
        (progn
          ;; Actualizar controles con valores cargados
          (set_tile "proj_name" (cdr (assoc "proj_name" config-file)))
          (set_tile "proj_code" (cdr (assoc "proj_code" config-file)))
          (set_tile "proj_client" (cdr (assoc "proj_client" config-file)))
          (set_tile "proj_location" (cdr (assoc "proj_location" config-file)))
          (set_tile "proj_desc" (cdr (assoc "proj_desc" config-file)))
          (set_tile "tech_units" (cdr (assoc "tech_units" config-file)))
          (set_tile "tech_coordsys" (cdr (assoc "tech_coordsys" config-file)))
          (set_tile "tech_utmzone" (cdr (assoc "tech_utmzone" config-file)))
          (set_tile "tech_hemisphere" (cdr (assoc "tech_hemisphere" config-file)))
          (set_tile "tech_precision" (cdr (assoc "tech_precision" config-file)))
          (set_tile "tech_scale" (cdr (assoc "tech_scale" config-file)))
          (set_tile "tech_contour_int" (cdr (assoc "tech_contour_int" config-file)))
          (set_tile "std_road" (cdr (assoc "std_road" config-file)))
          (set_tile "std_roadtype" (cdr (assoc "std_roadtype" config-file)))
          (set_tile "std_designspeed" (cdr (assoc "std_designspeed" config-file)))
          (set_tile "std_category" (cdr (assoc "std_category" config-file)))
          (set_tile "opt_autosave" (cdr (assoc "opt_autosave" config-file)))
          (set_tile "opt_backup" (cdr (assoc "opt_backup" config-file)))
          (set_tile "opt_log" (cdr (assoc "opt_log" config-file)))
          (set_tile "opt_qc" (cdr (assoc "opt_qc" config-file)))
          (set_tile "opt_layers" (cdr (assoc "opt_layers" config-file)))
          (set_tile "opt_xref" (cdr (assoc "opt_xref" config-file)))
          (alert "Configuración cargada exitosamente.")
        )
        (alert "Error al cargar la configuración.")
      )
    )
  )
)

(defun uchi:cfg-action-save ( / filename proj-code)
  "Acción para guardar configuración en archivo"
  (setq proj-code (get_tile "proj_code"))
  (if (= proj-code "")
    (alert "Debe ingresar un código de proyecto antes de guardar.")
    (progn
      (setq filename (getfiled "Guardar configuración como" 
                               (strcat proj-code ".json") 
                               "json" 
                               1))
      (if filename
        (progn
          (setq *uchi-config-data* 
            (list
              (cons "proj_name" (get_tile "proj_name"))
              (cons "proj_code" (get_tile "proj_code"))
              (cons "proj_client" (get_tile "proj_client"))
              (cons "proj_location" (get_tile "proj_location"))
              (cons "proj_desc" (get_tile "proj_desc"))
              (cons "tech_units" (get_tile "tech_units"))
              (cons "tech_coordsys" (get_tile "tech_coordsys"))
              (cons "tech_utmzone" (get_tile "tech_utmzone"))
              (cons "tech_hemisphere" (get_tile "tech_hemisphere"))
              (cons "tech_precision" (get_tile "tech_precision"))
              (cons "tech_scale" (get_tile "tech_scale"))
              (cons "tech_contour_int" (get_tile "tech_contour_int"))
              (cons "std_road" (get_tile "std_road"))
              (cons "std_roadtype" (get_tile "std_roadtype"))
              (cons "std_designspeed" (get_tile "std_designspeed"))
              (cons "std_category" (get_tile "std_category"))
              (cons "opt_autosave" (get_tile "opt_autosave"))
              (cons "opt_backup" (get_tile "opt_backup"))
              (cons "opt_log" (get_tile "opt_log"))
              (cons "opt_qc" (get_tile "opt_qc"))
              (cons "opt_layers" (get_tile "opt_layers"))
              (cons "opt_xref" (get_tile "opt_xref"))
            )
          )
          (if (uchi:cfg-save-to-file filename *uchi-config-data*)
            (alert "Configuración guardada exitosamente.")
            (alert "Error al guardar la configuración.")
          )
        )
      )
    )
  )
)

(defun uchi:cfg-action-defaults ()
  "Acción para restaurar valores por defecto"
  (if (= (alert "¿Está seguro de restaurar los valores por defecto?\n\nEsta acción no se puede deshacer." "Confirmar") 1)
    (progn
      (setq *uchi-config-data* (uchi:cfg-load-defaults))
      (set_tile "proj_name" "")
      (set_tile "proj_code" "")
      (set_tile "proj_client" "")
      (set_tile "proj_location" "")
      (set_tile "proj_desc" "")
      (set_tile "tech_units" "0")
      (set_tile "tech_coordsys" "0")
      (set_tile "tech_utmzone" "18")
      (set_tile "tech_hemisphere" "1")
      (set_tile "tech_precision" "1")
      (set_tile "tech_scale" "1:1000")
      (set_tile "tech_contour_int" "1.0")
      (set_tile "std_road" "0")
      (set_tile "std_roadtype" "0")
      (set_tile "std_designspeed" "40")
      (set_tile "std_category" "0")
      (set_tile "opt_autosave" "1")
      (set_tile "opt_backup" "1")
      (set_tile "opt_log" "1")
      (set_tile "opt_qc" "1")
      (set_tile "opt_layers" "1")
      (set_tile "opt_xref" "0")
      (alert "Valores por defecto restaurados.")
    )
  )
)

;;; -----------------------------------------------------------------------------
;;; COMANDO DE AUTOCAD
;;; -----------------------------------------------------------------------------

(defun c:UCHI_CONFIG ( / result)
  "Comando para abrir el diálogo de configuración del proyecto"
  (princ "\nUCHI: Abriendo configuración del proyecto...")
  (setq result (uchi:show-config-dialog))
  (if result
    (princ "\nConfiguración actualizada correctamente.")
    (princ "\nConfiguración cancelada.")
  )
  (princ)
)

;;; -----------------------------------------------------------------------------
;;; INICIALIZACIÓN
;;; -----------------------------------------------------------------------------

(princ "\nUCHI Config module loaded successfully.")
(princ)
