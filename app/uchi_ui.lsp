;;; UCHI UI

(defun uchi:show-main-dialog (/ dclid action)
  (setq dclid (load_dialog (strcat (getenv "UCHI_APP_DIR") "/uchi_main.dcl")))
  (if (< dclid 0)
    (progn
      (uchi:log "No se pudo abrir UI DCL. Continuando en modo consola.")
      nil
    )
    (progn
      (if (not (new_dialog "uchi_main" dclid))
        (progn (unload_dialog dclid) nil)
        (progn
          (set_tile "title_txt" "UCHI")
          (set_tile "subtitle_txt" "Topografía")
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
