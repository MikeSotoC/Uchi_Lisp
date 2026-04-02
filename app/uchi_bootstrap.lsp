;;; UCHI Bootstrap Loader
;;; Cargar este archivo por APPLOAD.

(vl-load-com)

(setq *uchi-version* "1.0.0")

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

(defun uchi:modules-present-p (dir / ok mod)
  (setq ok T)
  (foreach mod (uchi:required-modules)
    (if (not (uchi:file-exists-p (uchi:path-join dir mod)))
      (setq ok nil)
    )
  )
  ok
)

(defun uchi:bootstrap-file ()
  (cond
    ((and (boundp '*load-truename*) *load-truename*) *load-truename*)
    ((findfile "uchi_bootstrap.lsp"))
    (T nil)
  )
)

(defun uchi:app-dir-from-active-load (/ f)
  (setq f (uchi:bootstrap-file))
  (if f
    (vl-filename-directory (uchi:path-normalize f))
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
  ;; Estrategia determinista:
  ;; 1) Ruta activa del archivo APPLOAD cargado.
  ;; 2) Ruta guardada validada.
  ;; 3) Selector manual.
  (setq active (uchi:app-dir-from-active-load))
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

(defun uchi:load-module (dir file / full)
  (setq full (uchi:path-join dir file))
  (if (uchi:file-exists-p full)
    (progn (load full nil) T)
    (progn
      (uchi:log (strcat "ERROR módulo faltante: " full))
      nil
    )
  )
)

(defun uchi:load-all-modules (/ dir ok mod)
  (setq dir (uchi:resolve-app-dir))
  (if (not dir)
    (progn
      (uchi:log "ERROR no se pudo resolver app/. Use UCHI_APP_DIR válido o selección manual.")
      nil
    )
    (progn
      (setenv "UCHI_APP_DIR" dir)
      (setq ok T)
      (foreach mod (uchi:required-modules)
        (if (not (uchi:load-module dir mod))
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
