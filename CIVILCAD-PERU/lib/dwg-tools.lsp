;;; ============================================================================
;;; CIVILCAD-PERÚ - DWG TOOLS
;;; Herramientas para manipulación de dibujos AutoCAD
;;; ============================================================================

;;; Variables globales de DWG tools
(setq *CCP_DWG_TOOLS_VERSION* "1.0.0")

;;; Función: CCP-draw-point
;;; Dibuja un punto en coordenadas específicas
(defun CCP-draw-point (pt layer / )
  (CCP-set-current-layer layer)
  (command "_.POINT" pt)
)

;;; Función: CCP-draw-line
;;; Dibuja una línea entre dos puntos
(defun CCP-draw-line (p1 p2 layer / )
  (CCP-set-current-layer layer)
  (command "_.LINE" p1 p2 "")
)

;;; Función: CCP-draw-polyline
;;; Dibuja una polilínea desde lista de puntos
(defun CCP-draw-polyline (points layer closed / )
  (if (< (length points) 2)
    nil
    (progn
      (CCP-set-current-layer layer)
      (command "_.PLINE" (car points))
      (foreach pt (cdr points)
        (command pt)
      )
      (if closed
        (command "_Close")
        (command "")
      )
      T
    )
  )
)

;;; Función: CCP-draw-circle
;;; Dibuja un círculo dado centro y radio
(defun CCP-draw-circle (center radius layer / )
  (CCP-set-current-layer layer)
  (command "_.CIRCLE" center radius)
)

;;; Función: CCP-draw-arc
;;; Dibuja un arco dado centro, radio y ángulos
(defun CCP-draw-arc (center radius start-angle end-angle layer / start-pt end-pt)
  (setq start-pt (polar center (* start-angle (/ pi 180.0)) radius))
  (setq end-pt (polar center (* end-angle (/ pi 180.0)) radius))
  
  (CCP-set-current-layer layer)
  (command "_.ARC" "_C" center start-pt end-pt)
)

;;; Función: CCP-draw-text
;;; Inserta texto en posición específica
(defun CCP-draw-text (text insertion-point height layer rotation / )
  (CCP-set-current-layer layer)
  (command "_.TEXT" insertion-point height rotation text)
)

;;; Función: CCP-draw-mtext
;;; Inserta texto multilínea
(defun CCP-draw-mtext (text insertion-point width layer / )
  (CCP-set-current-layer layer)
  (command "_.MTEXT" insertion-point "_W" width text)
)

;;; Función: CCP-draw-dimension-linear
;;; Cota lineal entre dos puntos
(defun CCP-draw-dimension-linear (p1 p2 dim-pt layer / )
  (CCP-set-current-layer layer)
  (command "_.DIMALIGNED" p1 p2 dim-pt)
)

;;; Función: CCP-draw-dimension-radius
;;; Cota de radio para círculo/arco
(defun CCP-draw-dimension-radius (center pt-on-circle layer / )
  (CCP-set-current-layer layer)
  (command "_.DIMRADIUS" pt-on-circle "")
)

;;; Función: CCP-draw-hatch
;;; Rellena área con patrón de hatch
(defun CCP-draw-hatch (pattern-name scale angle points layer / )
  (CCP-set-current-layer layer)
  (command "_.HATCH" "_P" pattern-name scale angle points "")
)

;;; Función: CCP-get-entity-data
;;; Obtiene datos de una entidad seleccionada
(defun CCP-get-entity-data (ename / entdata)
  (if ename
    (setq entdata (entget ename))
    nil
  )
)

;;; Función: CCP-get-selection-set
;;; Obtiene conjunto de selección por filtro
(defun CCP-get-selection-set (filter-list / ss)
  (setq ss (ssget "_X" filter-list))
  ss
)

;;; Función: CCP-count-entities
;;; Cuenta entidades de un tipo específico
(defun CCP-count-entities (entity-type / ss count)
  (setq ss (CCP-get-selection-set (list (cons 0 entity-type))))
  (if ss
    (setq count (sslength ss))
    (setq count 0)
  )
  count
)

;;; Función: CCP-delete-entities
;;; Elimina entidades de un selection set
(defun CCP-delete-entities (ss / i ent)
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (entdel ent)
        (setq i (1+ i))
      )
      T
    )
    nil
  )
)

;;; Función: CCP-get-bounds
;;; Obtiene límites de las entidades seleccionadas
(defun CCP-get-bounds (ss / i ent bounds min-pt max-pt pt)
  (if (and ss (> (sslength ss) 0))
    (progn
      (setq i 0)
      (setq ent (ssname ss 0))
      (setq entdata (entget ent))
      (setq pt (cdr (assoc 10 entdata)))
      (setq min-pt pt)
      (setq max-pt pt)
      
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq entdata (entget ent))
        (setq pt (cdr (assoc 10 entdata)))
        
        (if pt
          (progn
            (if (< (car pt) (car min-pt))
              (setq min-pt (list (car pt) (cadr min-pt) (or (caddr min-pt) 0)))
            )
            (if (> (car pt) (car max-pt))
              (setq max-pt (list (car max-pt) (cadr pt) (or (caddr max-pt) 0)))
            )
            (if (< (cadr pt) (cadr min-pt))
              (setq min-pt (list (car min-pt) (cadr pt) (or (caddr min-pt) 0)))
            )
            (if (> (cadr pt) (cadr max-pt))
              (setq max-pt (list (car max-pt) (cadr max-pt) (or (caddr max-pt) 0)))
            )
          )
        )
        
        (setq i (1+ i))
      )
      
      (list min-pt max-pt)
    )
    nil
  )
)

;;; Función: CCP-zoom-extents
;;; Zoom a los extents del dibujo
(defun CCP-zoom-extents ()
  (command "_.ZOOM" "_E")
)

;;; Función: CCP-zoom-window
;;; Zoom a ventana definida por dos puntos
(defun CCP-zoom-window (p1 p2)
  (command "_.ZOOM" "_W" p1 p2)
)

;;; Función: CCP-get-block-insertion-points
;;; Obtiene puntos de inserción de bloques
(defun CCP-get-block-insertion-points (block-name / ss pts i ent entdata)
  (setq pts nil)
  (setq ss (ssget "_X" (list (cons 2 block-name) (cons 0 "INSERT"))))
  
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq entdata (entget ent))
        (setq pt (cdr (assoc 10 entdata)))
        (if pt
          (setq pts (append pts (list pt)))
        )
        (setq i (1+ i))
      )
    )
  )
  
  pts
)

;;; Función: CCP-create-block
;;; Crea un bloque desde entidades seleccionadas
(defun CCP-create-block (block-name insertion-point ss / )
  (command "_.BLOCK" block-name insertion-point)
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        ;; Las entidades se mueven al bloque automáticamente
        (setq i (1+ i))
      )
    )
  )
  (command "")
)

;;; Función: CCP-insert-block
;;; Inserta un bloque en posición específica
(defun CCP-insert-block (block-name insertion-point scale rotation / )
  (command "_.INSERT" block-name insertion-point scale scale rotation)
)

;;; Función: CCP-get-area
;;; Calcula área de una entidad cerrada
(defun CCP-get-area (ename / entdata area)
  (if ename
    (progn
      (setq entdata (entget ename))
      (command "_.AREA" "_O" ename)
      (setq area (getvar "AREA"))
      area
    )
    0.0
  )
)

;;; Función: CCP-get-perimeter
;;; Calcula perímetro de una entidad cerrada
(defun CCP-get-perimeter (ename / perimeter)
  (if ename
    (progn
      (command "_.AREA" "_O" ename)
      (setq perimeter (getvar "PERIMETER"))
      perimeter
    )
    0.0
  )
)

;;; Función: CCP-purge-unused
;;; Purga elementos no usados del dibujo
(defun CCP-purge-unused ()
  (command "_.PURGE" "_A" "*" "_N")
  (princ "\n[DWG] Purge completado.")
)

;;; Función: CCP-audit-drawing
;;; Ejecuta AUDIT en el dibujo
(defun CCP-audit-drawing ()
  (command "_.AUDIT" "_Y")
  (princ "\n[DWG] Audit completado.")
)

(princ "\n[LIB] DWG Tools cargados.")
(princ)
