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

(defun uchi:orientation2d (a b c / v)
  (setq v (- (* (- (cadr b) (cadr a)) (- (caddr c) (caddr a)))
             (* (- (caddr b) (caddr a)) (- (cadr c) (cadr a)))))
  (cond
    ((> v 0.0000001) 1)
    ((< v -0.0000001) -1)
    (T 0)
  )
)

(defun uchi:on-segment2d-p (a b p)
  (and (<= (min (cadr a) (cadr b)) (cadr p) (max (cadr a) (cadr b)))
       (<= (min (caddr a) (caddr b)) (caddr p) (max (caddr a) (caddr b)))
       (= 0 (uchi:orientation2d a b p)))
)

(defun uchi:segment-intersect2d-p (a b c d / o1 o2 o3 o4)
  (setq o1 (uchi:orientation2d a b c))
  (setq o2 (uchi:orientation2d a b d))
  (setq o3 (uchi:orientation2d c d a))
  (setq o4 (uchi:orientation2d c d b))
  (or (and (/= o1 o2) (/= o3 o4))
      (and (= o1 0) (uchi:on-segment2d-p a b c))
      (and (= o2 0) (uchi:on-segment2d-p a b d))
      (and (= o3 0) (uchi:on-segment2d-p c d a))
      (and (= o4 0) (uchi:on-segment2d-p c d b)))
)

(defun uchi:tri-has-edge-p (tri p1 p2 / a b c)
  (setq a (car tri) b (cadr tri) c (caddr tri))
  (or (and (= (car a) (car p1)) (= (car b) (car p2)))
      (and (= (car b) (car p1)) (= (car a) (car p2)))
      (and (= (car b) (car p1)) (= (car c) (car p2)))
      (and (= (car c) (car p1)) (= (car b) (car p2)))
      (and (= (car c) (car p1)) (= (car a) (car p2)))
      (and (= (car a) (car p1)) (= (car c) (car p2))))
)

(defun uchi:triangle-edges (tri)
  (list
    (list (car tri) (cadr tri))
    (list (cadr tri) (caddr tri))
    (list (caddr tri) (car tri))
  )
)

(defun uchi:hard-breaklines (/ out bl)
  (setq out nil)
  (foreach bl *uchi-breaklines*
    (if (= (strcase (nth 2 bl)) "HARD")
      (setq out (append out (list bl)))
    )
  )
  out
)

(defun uchi:tri-respects-breaklines-p (tri / bl p1 p2 edges e)
  (setq edges (uchi:triangle-edges tri))
  (foreach bl (uchi:hard-breaklines)
    (setq p1 (uchi:point-by-id (car bl)))
    (setq p2 (uchi:point-by-id (cadr bl)))
    (if (and p1 p2 (not (uchi:tri-has-edge-p tri p1 p2)))
      (foreach e edges
        (if (and (not (= (car (car e)) (car p1)))
                 (not (= (car (car e)) (car p2)))
                 (not (= (car (cadr e)) (car p1)))
                 (not (= (car (cadr e)) (car p2)))
                 (uchi:segment-intersect2d-p (car e) (cadr e) p1 p2))
          (setq edges nil)
        )
      )
    )
  )
  (if edges T nil)
)

(defun uchi:tri-centroid-xy (tri)
  (list
    (/ (+ (cadr (car tri)) (cadr (cadr tri)) (cadr (caddr tri))) 3.0)
    (/ (+ (caddr (car tri)) (caddr (cadr tri)) (caddr (caddr tri))) 3.0)
  )
)

(defun uchi:tri-vertices-inside-boundary-p (tri / p xy)
  (if (and *uchi-boundary* (> (length *uchi-boundary*) 2))
    (progn
      (setq p T)
      (foreach xy tri
        (if (not (uchi:boundary-point-in-poly (list (cadr xy) (caddr xy)) *uchi-boundary*))
          (setq p nil)
        )
      )
      p
    )
    T
  )
)

(defun uchi:tri-inside-boundary-p (tri)
  (and (uchi:tri-vertices-inside-boundary-p tri)
       (if (and *uchi-boundary* (> (length *uchi-boundary*) 2))
         (uchi:boundary-point-in-poly (uchi:tri-centroid-xy tri) *uchi-boundary*)
         T))
)

(defun uchi:tin-add-triangle-if-valid (tri tris keys / key)
  (if (and (> (uchi:tri-area2d (car tri) (cadr tri) (caddr tri)) 0.00001)
           (uchi:tri-inside-boundary-p tri)
           (uchi:tri-respects-breaklines-p tri))
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
  (list tris keys)
)

(defun uchi:tin-generate (/ tris keys p near tri key bl p1 p2 sorted i out)
  (setq tris nil keys nil)
  (foreach p *uchi-points*
    (setq near (uchi:nearest-two-points p *uchi-points*))
    (if (= (length near) 2)
      (progn
        (setq tri (list p (nth 0 near) (nth 1 near)))
        (setq out (uchi:tin-add-triangle-if-valid tri tris keys))
        (setq tris (car out) keys (cadr out))
      )
    )
  )
  ;; Triángulos forzados por breaklines hard: para cada segmento se conecta al punto
  ;; más cercano por cada lado geométrico (regla simple de ingeniería base).
  (foreach bl (uchi:hard-breaklines)
    (setq p1 (uchi:point-by-id (car bl)))
    (setq p2 (uchi:point-by-id (cadr bl)))
    (if (and p1 p2)
      (progn
        (setq sorted
          (vl-sort *uchi-points*
            '(lambda (u v)
               (< (+ (uchi:point-distance2d u p1) (uchi:point-distance2d u p2))
                  (+ (uchi:point-distance2d v p1) (uchi:point-distance2d v p2)))
             )
          )
        )
        (setq i 0)
        (while (< i (length sorted))
          (setq p (nth i sorted))
          (if (and (/= (car p) (car p1)) (/= (car p) (car p2)))
            (progn
              (setq tri (list p1 p2 p))
              (setq out (uchi:tin-add-triangle-if-valid tri tris keys))
              (setq tris (car out) keys (cadr out))
              (setq i (length sorted))
            )
            (setq i (+ i 1))
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
