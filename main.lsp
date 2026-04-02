;;; UCHI Main Launcher
;;; Cargar este archivo por APPLOAD (fuera de app/).

(vl-load-com)

(setq *uchi-version* "1.0.1")

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
  (list "uchi_core.lsp" "uchi_config.lsp" "uchi_ui.lsp" "uchi_commands.lsp")
)

(defun uchi:launcher-file ()
  (cond
    ((and (boundp '*load-truename*) *load-truename*) *load-truename*)
    ((findfile "main.lsp"))
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

(defun uchi:modules-present-p (appdir / ok mod)
  (setq ok T)
  (foreach mod (uchi:required-modules)
    (if (not (uchi:file-exists-p (uchi:path-join appdir mod)))
      (setq ok nil)
    )
  )
  ok
)

(defun uchi:app-dir-from-launcher (/ basedir appdir)
  (setq basedir (uchi:launcher-dir))
  (if basedir
    (setq appdir (uchi:path-join basedir "app"))
    (setq appdir nil)
  )
  appdir
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
  ;; Estrategia determinista:
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

(defun uchi:load-all-modules (/ appdir ok mod)
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
        (uchi:log (strcat "Carga determinista completada. Versión " *uchi-version*))
        (uchi:log "Carga incompleta: revisar módulos faltantes.")
      )
      ok
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

(uchi:load-all-modules)
(princ)
