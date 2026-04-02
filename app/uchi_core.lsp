;;; UCHI Core

(defun uchi:ensure-list (v)
  (if (listp v) v (list v))
)

(defun uchi:str (v)
  (vl-princ-to-string v)
)

(defun uchi:read-lines (path / fp lines line)
  (setq lines nil)
  (if (and path (findfile path))
    (progn
      (setq fp (open path "r"))
      (if fp
        (progn
          (setq line (read-line fp))
          (while line
            (setq lines (append lines (list line)))
            (setq line (read-line fp))
          )
          (close fp)
        )
      )
    )
  )
  lines
)

(defun uchi:write-text (path text / fp)
  (setq fp (open path "w"))
  (if fp
    (progn
      (write-line text fp)
      (close fp)
      T
    )
    nil
  )
)

(defun uchi:split-csv-line (line / pos out rest)
  (setq out nil)
  (setq rest line)
  (while (setq pos (vl-string-search "," rest))
    (setq out (append out (list (substr rest 1 pos))))
    (setq rest (substr rest (+ pos 2)))
  )
  (append out (list rest))
)

(princ)
