;;; UCHI Persistence (.uchi.json versionado)

(defun uchi:json-escape (s / out i ch)
  (setq out "" i 1)
  (if (not s) (setq s ""))
  (while (<= i (strlen s))
    (setq ch (substr s i 1))
    (cond
      ((= ch "\\") (setq out (strcat out "\\\\")))
      ((= ch "\"") (setq out (strcat out "\\\"")))
      ((= ch "\n") (setq out (strcat out "\\n")))
      (T (setq out (strcat out ch)))
    )
    (setq i (+ i 1))
  )
  out
)

(defun uchi:project-json-path ()
  (strcat (uchi:launcher-dir-safe) "/uchi_project.uchi.json")
)

(defun uchi:persistence-schema-version () "1.0.0")

(defun uchi:persist-json-text (/ proj pts brk)
  (setq proj (uchi:json-escape (vl-princ-to-string *uchi-project*)))
  (setq pts  (uchi:json-escape (vl-princ-to-string *uchi-points*)))
  (setq brk  (uchi:json-escape (vl-princ-to-string *uchi-breaklines*)))
  (strcat
    "{"
      "\"schema_version\":\"" (uchi:persistence-schema-version) "\","
      "\"generator\":\"UCHI\","
      "\"project_sexp\":\"" proj "\","
      "\"points_sexp\":\"" pts "\","
      "\"breaklines_sexp\":\"" brk "\""
    "}"
  )
)

(defun uchi:persist-save-json (/ path ok)
  (setq path (uchi:project-json-path))
  (setq ok (uchi:write-text path (uchi:persist-json-text)))
  (if ok
    (uchi:log (strcat "Persistencia JSON guardada: " path))
    (uchi:log "ERROR al guardar persistencia JSON.")
  )
  ok
)

(defun C:UCHI_SAVE_JSON ()
  (uchi:topo-init)
  (uchi:persist-save-json)
  (princ)
)

(princ)
