;;; UCHI Migrador legacy -> esquema UCHI

(defun uchi:mig-legacy-map ()
  (if (boundp '*uchi-legacy-key-map*)
    *uchi-legacy-key-map*
    nil
  )
)

(defun uchi:mig-export-report (rows / path fp r)
  (setq path (strcat (uchi:launcher-dir-safe) "/uchi_migracion_legacy.csv"))
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line "key_new,key_legacy,val_legacy,migrado" fp)
      (foreach r rows
        (write-line (strcat (car r) "," (nth 1 r) "," (nth 2 r) "," (nth 3 r)) fp)
      )
      (close fp)
      path
    )
    nil
  )
)

(defun C:UCHI_MIGRAR_LEGACY (/ rows pair k leg val migrated path)
  (uchi:topo-init)
  (setq rows nil migrated 0)
  (foreach pair (uchi:mig-legacy-map)
    (setq k (car pair))
    (foreach leg (cdr pair)
      (setq val (getenv (uchi:cfg-env-key leg)))
      (if (and val (/= val ""))
        (progn
          (setenv (uchi:cfg-env-key k) val)
          (setq migrated (+ migrated 1))
          (setq rows (append rows (list (list k leg val "SI"))))
        )
        (setq rows (append rows (list (list k leg "" "NO"))))
      )
    )
  )
  (setq path (uchi:mig-export-report rows))
  (uchi:project-set "legacy_migrated" migrated)
  (uchi:project-save)
  (uchi:log (strcat "Migración legacy completada. Claves migradas=" (itoa migrated)
                    (if path (strcat ", reporte=" path) "")))
  (princ)
)

(princ)
