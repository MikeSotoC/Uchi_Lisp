;;; UCHI Core

(defun uchi:ensure-list (v) (if (listp v) v (list v)))
(defun uchi:str (v) (vl-princ-to-string v))
(defun uchi:to-real (v) (distof (vl-princ-to-string v) 2))

(defun uchi:point-distance2d (a b / dx dy)
  (setq dx (- (cadr b) (cadr a)))
  (setq dy (- (caddr b) (caddr a)))
  (sqrt (+ (* dx dx) (* dy dy)))
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
    (progn (write-line text fp) (close fp) T)
    nil
  )
)

(defun uchi:split-csv-line (line / pos out rest)
  (setq out nil rest line)
  (while (setq pos (vl-string-search "," rest))
    (setq out (append out (list (substr rest 1 pos))))
    (setq rest (substr rest (+ pos 2)))
  )
  (append out (list rest))
)

(defun uchi:ensure-layer (name color / rec)
  (setq rec (tblsearch "LAYER" name))
  (if (not rec)
    (entmake (list (cons 0 "LAYER") (cons 2 name) (cons 70 0) (cons 62 color)))
  )
  name
)

(defun uchi:draw-line (p1 p2 layer)
  (uchi:ensure-layer layer 7)
  (entmake
    (list
      (cons 0 "LINE")
      (cons 8 layer)
      (cons 10 p1)
      (cons 11 p2)
    )
  )
)

(defun uchi:draw-point (p layer)
  (uchi:ensure-layer layer 3)
  (entmake (list (cons 0 "POINT") (cons 8 layer) (cons 10 p)))
)

(defun uchi:draw-polyline-2d (pts layer / d)
  (uchi:ensure-layer layer 2)
  (if (> (length pts) 1)
    (progn
      (setq d (list (cons 0 "LWPOLYLINE") (cons 8 layer) (cons 90 (length pts))))
      (foreach p pts
        (setq d (append d (list (cons 10 (list (car p) (cadr p))))))
      )
      (entmake d)
    )
  )
)

(princ)
