;;; UCHI TIN Engine (base)

(setq *uchi-tin* nil)

(defun uchi:triangle-key (a b c / ids)
  (setq ids (vl-sort (list (car a) (car b) (car c)) '<))
  (strcat (nth 0 ids) "|" (nth 1 ids) "|" (nth 2 ids))
)

(defun uchi:nearest-two-points (p pts / sorted out q)
  (setq sorted
    (vl-sort pts
      '(lambda (u v)
         (< (uchi:point-distance2d p u) (uchi:point-distance2d p v))
       )
    )
  )
  (setq out nil)
  (foreach q sorted
    (if (and (/= (car q) (car p)) (< (length out) 2))
      (setq out (append out (list q)))
    )
  )
  out
)

(defun uchi:tin-generate (/ tris keys p near tri key)
  (setq tris nil keys nil)
  (foreach p *uchi-points*
    (setq near (uchi:nearest-two-points p *uchi-points*))
    (if (= (length near) 2)
      (progn
        (setq tri (list p (nth 0 near) (nth 1 near)))
        (if (> (uchi:tri-area2d (car tri) (cadr tri) (caddr tri)) 0.00001)
          (progn
            (setq key (uchi:triangle-key (car tri) (cadr tri) (caddr tri)))
            (if (not (assoc key keys))
              (progn
                (setq keys (cons (cons key T) keys))
                (setq tris (append tris (list tri)))
              )
            )
          )
        )
      )
    )
  )
  tris
)

(defun C:UCHI_TIN ()
  (uchi:topo-init)
  (if (> (length *uchi-points*) 2)
    (progn
      (setq *uchi-tin* (uchi:tin-generate))
      (uchi:project-set "tin_triangles" (length *uchi-tin*))
      (uchi:project-save)
      (uchi:log (strcat "TIN generado. Triángulos=" (itoa (length *uchi-tin*))))
    )
    (uchi:log "TIN: se requieren al menos 3 puntos válidos.")
  )
  (princ)
)

(princ)
