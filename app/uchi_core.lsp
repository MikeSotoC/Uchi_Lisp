;;; UCHI Core

(defun uchi:ensure-list (v)
  (if (listp v) v (list v))
)

(defun uchi:str (v)
  (vl-princ-to-string v)
)

(princ)
