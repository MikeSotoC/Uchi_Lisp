;;; UCHI Main Launcher
;;; Cargar este archivo por APPLOAD (fuera de app/).

(vl-load-com)

(setq *uchi-version* "1.1.0")
(setq *uchi-launcher-name* "main.lsp")

(defun uchi:log (msg)
  (princ (strcat "\n[UCHI] " msg))
)

(defun uchi:path-normalize (p)
  (if p (vl-string-translate "\\" "/" p) nil)
)

(defun uchi:path-join (base leaf)
  (strcat (vl-string-right-trim "/" (uchi:path-normalize base)) "/" leaf)
)

(defun uchi:file-exists-p (p)
  (and p (findfile p))
)

(defun uchi:required-modules ()
  (list "uchi_cad_compat.lsp" "uchi_core.lsp" "uchi_config.lsp" "uchi_ui.lsp" "uchi_commands.lsp" "uchi_topo.lsp" "uchi_surface.lsp" "uchi_profile.lsp" "uchi_curves.lsp" "uchi_sections.lsp" "uchi_report.lsp" "uchi_alignment.lsp" "uchi_volume.lsp" "uchi_qc.lsp" "uchi_styles.lsp" "uchi_landxml.lsp" "uchi_tin.lsp" "uchi_engine.lsp")
)

(defun uchi:launcher-file ()
  (cond
    ((and (boundp '*load-truename*) *load-truename*) *load-truename*)
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

(defun uchi:launcher-valid-p (/ f d)
  (setq f (uchi:launcher-file))
  (setq d (uchi:launcher-dir))
  (and f
       d
       (= (strcase (strcat (vl-filename-base f) "." (vl-filename-extension f))) (strcase *uchi-launcher-name*))
       (not (wcmatch (strcase d) "*/APP"))
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
