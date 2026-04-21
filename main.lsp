;;; UCHI Main Launcher
;;; Cargar este archivo por APPLOAD (fuera de app/).

(vl-load-com)

(setq *uchi-version* "1.1.0")
(setq *uchi-launcher-name* "main.lsp")

(defun uchi:path-normalize (p)
  (if p (vl-string-translate "\\" "/" p) nil)
)

(defun uchi:path-join (base leaf)
  (strcat (vl-string-right-trim "/" (uchi:path-normalize base)) "/" leaf)
)

(defun uchi:file-exists-p (p)
  (and p (findfile p))
)

(defun uchi:log-file-path ()
  (strcat (if (uchi:launcher-dir) (uchi:launcher-dir) ".") "/uchi_runtime.log")
)

(defun uchi:log-max-bytes ()
  (fix (atof (vl-princ-to-string (or (getenv "UCHI_CFG_LOG_MAX_BYTES") 262144))))
)

(defun uchi:log-rotate-if-needed (/ p maxb)
  (setq p (uchi:log-file-path))
  (setq maxb (max 10240 (uchi:log-max-bytes)))
  (if (and (findfile p) (> (vl-file-size p) maxb))
    (progn
      (if (findfile (strcat p ".1")) (vl-file-delete (strcat p ".1")))
      (vl-file-rename p (strcat p ".1"))
    )
  )
)

(defun uchi:log-write-file (msg / fp p)
  (setq p (uchi:log-file-path))
  (uchi:log-rotate-if-needed)
  (setq fp (open p "a"))
  (if fp
    (progn
      (write-line (strcat "[UCHI] " msg) fp)
      (close fp)
    )
  )
)

(defun uchi:log (msg)
  (princ (strcat "\n[UCHI] " msg))
  (uchi:log-write-file msg)
)

(defun uchi:required-modules ()
  (list "uchi_cad_compat.lsp" "uchi_core.lsp" "uchi_config.lsp" "uchi_module_registry.lsp" "uchi_ui.lsp" "uchi_commands.lsp" "uchi_topo.lsp" "uchi_persistence.lsp" "uchi_templates_pe.lsp" "uchi_surface.lsp" "uchi_profile.lsp" "uchi_curves.lsp" "uchi_sections.lsp" "uchi_stakeout.lsp" "uchi_drainage.lsp" "uchi_hidraulica.lsp" "uchi_catastro.lsp" "uchi_catastro_rural.lsp" "uchi_subdivision.lsp" "uchi_utilidades.lsp" "uchi_interferencias.lsp" "uchi_pavimentos.lsp" "uchi_carreteras.lsp" "uchi_expediente.lsp" "uchi_report.lsp" "uchi_alignment.lsp" "uchi_volume.lsp" "uchi_qc.lsp" "uchi_styles.lsp" "uchi_landxml.lsp" "uchi_boundary.lsp" "uchi_tin.lsp" "uchi_engine.lsp" "uchi_migrador.lsp")
)

(defun uchi:launcher-file ()
  (cond
    ((and (boundp '*load-truename*) *load-truename*) *load-truename*)
    ((and (boundp '*load-file-name*) *load-file-name*) (findfile *load-file-name*))
    ((findfile *uchi-launcher-name*))
    (T nil)
  )
)

(defun uchi:launcher-dir (/ f)
  (setq f (uchi:launcher-file))
  (if f
    (vl-filename-directory (uchi:path-normalize f))
    nil
  )
)

(defun uchi:launcher-valid-p (/ f d fname app-core parent-dir)
  ;; Obtener ruta del archivo launcher
  (setq f (uchi:launcher-file))
  
  ;; Si no hay archivo, fallar inmediatamente
  (if (not f)
    (progn
      (uchi:log "DEBUG: No se pudo determinar el archivo launcher (f=nil)")
      (return-from uchi:launcher-valid-p nil)
    )
  )
  
  ;; Obtener directorio
  (setq d (vl-filename-directory (uchi:path-normalize f)))
  
  ;; Si no hay directorio, fallar
  (if (not d)
    (progn
      (uchi:log (strcat "DEBUG: No se pudo determinar el directorio desde: " f))
      (return-from uchi:launcher-valid-p nil)
    )
  )
  
  ;; Extraer nombre del archivo de forma segura
  (setq fname (vl-filename-base f))
  (if (not fname)
    (setq fname "")
  )
  
  ;; Construir ruta al core
  (setq app-core (strcat d "/app/uchi_core.lsp"))
  
  ;; Logging detallado para debug
  (uchi:log (strcat "DEBUG: f=" f))
  (uchi:log (strcat "DEBUG: d=" d))
  (uchi:log (strcat "DEBUG: fname=" fname))
  (uchi:log (strcat "DEBUG: app-core exists=" (if (findfile app-core) "YES" "NO")))
  
  ;; Validación simplificada y robusta
  (and
       ;; Verificar que el archivo se llame main.lsp (case-insensitive)
       (= (strcase fname) "MAIN.LSP")
       ;; Verificar que NO esté dentro de una carpeta llamada "app"
       (not (wcmatch (strcase (vl-filename-base d)) "APP"))
       ;; Verificar que exista app/uchi_core.lsp relativo al launcher
       (findfile app-core)
  )
)

(defun uchi:modules-present-p (appdir / ok mod)
  (setq ok T)
  (foreach mod (uchi:required-modules)
    (if (not (uchi:file-exists-p (uchi:path-join appdir mod)))
      (setq ok nil)
    )
  )
  ok
)

(defun uchi:missing-modules (appdir / out mod)
  (setq out nil)
  (foreach mod (uchi:required-modules)
    (if (not (uchi:file-exists-p (uchi:path-join appdir mod)))
      (setq out (cons mod out))
    )
  )
  (reverse out)
)

(defun uchi:app-dir-from-launcher (/ basedir)
  (setq basedir (uchi:launcher-dir))
  (if basedir
    (uchi:path-join basedir "app")
    nil
  )
)

(defun uchi:validated-saved-app-dir (/ saved)
  (setq saved (getenv "UCHI_APP_DIR"))
  (if (and saved (uchi:modules-present-p saved)) saved nil)
)

(defun uchi:manual-select-app-dir (/ selected)
  (setq selected (getfiled "Seleccione uchi_core.lsp" "" "lsp" 16))
  (if selected
    (vl-filename-directory (uchi:path-normalize selected))
    nil
  )
)

(defun uchi:resolve-app-dir (/ active saved manual)
  ;; 1) app/ relativo al launcher cargado por APPLOAD.
  ;; 2) ruta guardada validada.
  ;; 3) selector manual.
  (setq active (uchi:app-dir-from-launcher))
  (if (and active (uchi:modules-present-p active))
    (progn
      (uchi:log (strcat "Ruta activa: " active))
      active
    )
    (progn
      (if active
        (uchi:log (strcat "Ruta activa inválida (faltan módulos): " active))
      )
      (setq saved (uchi:validated-saved-app-dir))
      (if saved
        (progn
          (uchi:log (strcat "Fallback validado UCHI_APP_DIR: " saved))
          saved
        )
        (progn
          (setq manual (uchi:manual-select-app-dir))
          (if (and manual (uchi:modules-present-p manual))
            (progn
              (setenv "UCHI_APP_DIR" manual)
              (uchi:log (strcat "Fallback manual seleccionado: " manual))
              manual
            )
            nil
          )
        )
      )
    )
  )
)

(defun uchi:load-module (appdir file / full)
  (setq full (uchi:path-join appdir file))
  (if (uchi:file-exists-p full)
    (progn (load full nil) T)
    (progn
      (uchi:log (strcat "ERROR módulo faltante: " full))
      nil
    )
  )
)

(defun uchi:load-all-modules (/ appdir ok mod missing)
  (if (not (uchi:launcher-valid-p))
    (progn
      (uchi:log "ERROR launcher inválido. APPLOAD debe apuntar a main.lsp fuera de app/.")
      nil
    )
    (progn
      (setq appdir (uchi:resolve-app-dir))
      (if (not appdir)
        (progn
          (uchi:log "ERROR no se pudo resolver app/. Use UCHI_APP_DIR válido o selección manual.")
          nil
        )
        (progn
          (setenv "UCHI_APP_DIR" appdir)
          (setq ok T)
          (foreach mod (uchi:required-modules)
            (if (not (uchi:load-module appdir mod))
              (setq ok nil)
            )
          )
          (if ok
            (progn
              (if (fboundp 'uchi:cad-log-banner) (uchi:cad-log-banner))
              (uchi:log (strcat "Carga determinista completada. Versión " *uchi-version*))
            )
            (progn
              (setq missing (uchi:missing-modules appdir))
              (uchi:log (strcat "Carga incompleta. Faltan: " (vl-princ-to-string missing)))
            )
          )
          ok
        )
      )
    )
  )
)

(defun C:UCHI_INIT ()
  (if (uchi:load-all-modules)
    (uchi:log "UCHI_INIT OK.")
    (uchi:log "UCHI_INIT FAIL.")
  )
  (princ)
)

(defun C:UCHI_DIAG (/ appdir)
  (setq appdir (uchi:resolve-app-dir))
  (uchi:log (strcat "Launcher: " (if (uchi:launcher-file) (uchi:launcher-file) "N/A")))
  (uchi:log (strcat "AppDir: " (if appdir appdir "N/A")))
  (if appdir
    (uchi:log (strcat "Módulos faltantes: " (vl-princ-to-string (uchi:missing-modules appdir))))
  )
  (princ)
)

(uchi:load-all-modules)
(princ)
