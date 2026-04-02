;;; UCHI UI

(defun uchi:show-main-dialog (/ dclid action)
  (setq action "cancel")
  (setq dclid (uchi:cad-safe-load-dialog (strcat (getenv "UCHI_APP_DIR") "/uchi_main.dcl")))
  (if (< dclid 0)
    (progn
      (uchi:log "No se pudo abrir UI DCL (AutoCAD/ZWCAD). Continuando en modo consola.")
      nil
    )
    (progn
      (if (not (new_dialog "uchi_main" dclid))
        (progn (unload_dialog dclid) nil)
        (progn
          (set_tile "title_txt" "UCHI")
          (set_tile "subtitle_txt" "Topografía productiva")
          (action_tile "run_flujo" "(setq action \"flujo\") (done_dialog 1)")
          (action_tile "import_pts" "(setq action \"import\") (done_dialog 1)")
          (action_tile "valid_pts" "(setq action \"valid\") (done_dialog 1)")
          (action_tile "build_surface" "(setq action \"surface\") (done_dialog 1)")
          (action_tile "build_profile" "(setq action \"profile\") (done_dialog 1)")
          (action_tile "build_curves" "(setq action \"curves\") (done_dialog 1)")
          (action_tile "build_sections" "(setq action \"sections\") (done_dialog 1)")
          (action_tile "accept" "(setq action \"ok\") (done_dialog 1)")
          (action_tile "cancel" "(setq action \"cancel\") (done_dialog 0)")
          (start_dialog)
          (unload_dialog dclid)
          action
        )
      )
    )
  )
)

(princ)
