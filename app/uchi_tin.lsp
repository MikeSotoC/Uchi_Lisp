;;; UCHI TIN Engine (base)

(setq *uchi-tin* nil)

(defun uchi:triangle-key (a b c / ids)
  (setq ids (vl-sort (list (car a) (car b) (car c)) '<))
  (strcat (nth 0 ids) "|" (nth 1 ids) "|" (nth 2 ids))
)

(defun uchi:edge-key (a b / ia ib)
  (setq ia (car a) ib (car b))
  (if (< (vl-string-compare ia ib) 0)
    (strcat ia "|" ib)
    (strcat ib "|" ia)
  )
)

(defun uchi:triangle-has-id-p (tri pid)
  (or (= (car (car tri)) pid)
      (= (car (cadr tri)) pid)
      (= (car (caddr tri)) pid))
)

(defun uchi:triangle-involves-super-p (tri superids / hit sid)
  (setq hit nil)
  (foreach sid superids
    (if (uchi:triangle-has-id-p tri sid) (setq hit T))
  )
  hit
)

(defun uchi:circumcircle-contains-p (tri p / ax ay bx by cx cy d ux uy r2 dx dy)
  ;; Circuncentro 2D del triángulo y prueba p dentro del círculo circunscrito.
  (setq ax (cadr (car tri)) ay (caddr (car tri)))
  (setq bx (cadr (cadr tri)) by (caddr (cadr tri)))
  (setq cx (cadr (caddr tri)) cy (caddr (caddr tri)))
  (setq d (* 2.0 (+ (* ax (- by cy)) (* bx (- cy ay)) (* cx (- ay by)))))
  (if (< (abs d) 1e-12)
    nil
    (progn
      (setq ux (/ (+ (* (+ (* ax ax) (* ay ay)) (- by cy))
                     (* (+ (* bx bx) (* by by)) (- cy ay))
                     (* (+ (* cx cx) (* cy cy)) (- ay by))) d))
      (setq uy (/ (+ (* (+ (* ax ax) (* ay ay)) (- cx bx))
                     (* (+ (* bx bx) (* by by)) (- ax cx))
                     (* (+ (* cx cx) (* cy cy)) (- bx ax))) d))
      (setq r2 (+ (* (- ux ax) (- ux ax)) (* (- uy ay) (- uy ay))))
      (setq dx (- (cadr p) ux))
      (setq dy (- (caddr p) uy))
      (<= (+ (* dx dx) (* dy dy)) (+ r2 1e-8))
    )
  )
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
        (if (not (if (fboundp 'uchi:boundary-point-in-scope)
                   (uchi:boundary-point-in-scope (list (cadr xy) (caddr xy)))
                   (uchi:boundary-point-in-poly (list (cadr xy) (caddr xy)) *uchi-boundary*)))
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
         (if (fboundp 'uchi:boundary-point-in-scope)
           (uchi:boundary-point-in-scope (uchi:tri-centroid-xy tri))
           (uchi:boundary-point-in-poly (uchi:tri-centroid-xy tri) *uchi-boundary*))
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

(defun uchi:tin-super-triangle (/ xmin xmax ymin ymax p dx dy dmax midx midy s1 s2 s3)
  (setq xmin (cadr (car *uchi-points*)) xmax xmin
        ymin (caddr (car *uchi-points*)) ymax ymin)
  (foreach p *uchi-points*
    (if (< (cadr p) xmin) (setq xmin (cadr p)))
    (if (> (cadr p) xmax) (setq xmax (cadr p)))
    (if (< (caddr p) ymin) (setq ymin (caddr p)))
    (if (> (caddr p) ymax) (setq ymax (caddr p)))
  )
  (setq dx (- xmax xmin) dy (- ymax ymin) dmax (max dx dy))
  (setq midx (/ (+ xmin xmax) 2.0) midy (/ (+ ymin ymax) 2.0))
  (setq s1 (list "__SUP1" (- midx (* 20.0 dmax)) (- midy dmax) 0.0))
  (setq s2 (list "__SUP2" midx (+ midy (* 20.0 dmax)) 0.0))
  (setq s3 (list "__SUP3" (+ midx (* 20.0 dmax)) (- midy dmax) 0.0))
  (list s1 s2 s3)
)

(defun uchi:tin-generate (/ tris p bad tri poly edge key ekeys keep super superids out keys bl p1 p2 sorted i)
  (if (<= (length *uchi-points*) 2)
    nil
    (progn
      (setq super (uchi:tin-super-triangle))
      (setq superids (list "__SUP1" "__SUP2" "__SUP3"))
      (setq tris (list super))

      ;; Bowyer-Watson incremental.
      (foreach p *uchi-points*
        (setq bad nil)
        (foreach tri tris
          (if (uchi:circumcircle-contains-p tri p)
            (setq bad (append bad (list tri)))
          )
        )

        ;; Frontera del hueco (aristas no compartidas entre triángulos "bad").
        (setq ekeys nil poly nil)
        (foreach tri bad
          (foreach edge (uchi:triangle-edges tri)
            (setq key (uchi:edge-key (car edge) (cadr edge)))
            (if (assoc key ekeys)
              (setq ekeys (subst (cons key (+ 1 (cdr (assoc key ekeys)))) (assoc key ekeys) ekeys))
              (setq ekeys (cons (cons key 1) ekeys))
            )
            (setq poly (append poly (list edge)))
          )
        )
        ;; Eliminar triángulos bad.
        (setq keep nil)
        (foreach tri tris
          (if (not (vl-position tri bad))
            (setq keep (append keep (list tri)))
          )
        )
        (setq tris keep)

        ;; Recrear triangulación local con aristas de frontera.
        (foreach edge poly
          (setq key (uchi:edge-key (car edge) (cadr edge)))
          (if (= (cdr (assoc key ekeys)) 1)
            (setq tris (append tris (list (list (car edge) (cadr edge) p))))
          )
        )
      )

      ;; Filtrar super-triangle y validar boundary/breaklines.
      (setq out nil keys nil)
      (foreach tri tris
        (if (not (uchi:triangle-involves-super-p tri superids))
          (progn
            (setq out (uchi:tin-add-triangle-if-valid tri out keys))
            (setq out (car out) keys (cadr out))
          )
        )
      )

      ;; Refuerzo de breaklines hard.
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
                  (setq keep (uchi:tin-add-triangle-if-valid tri out keys))
                  (setq out (car keep) keys (cadr keep))
                  (setq i (length sorted))
                )
                (setq i (+ i 1))
              )
            )
          )
        )
      )
      out
    )
  )
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
