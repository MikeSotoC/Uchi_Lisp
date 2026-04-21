;;; ============================================================================
;;; CIVILCAD-PERÚ - TOPOGRAFÍA UTILS
;;; Funciones utilitarias para topografía
;;; ============================================================================

;;; Variables globales
(setq *CCP_TOPO_UTILS_VERSION* "1.0.0")
(setq *CCP_PUNTOS_DATA* nil)

;;; Función: CCP-utm-zone-from-coord
;;; Determina zona UTM desde coordenada Este
(defun CCP-utm-zone-from-coord (east / zone)
  (cond
    ((and (>= east 200000) (< east 450000))
      (setq zone "17S")
    )
    ((and (>= east 450000) (< east 700000))
      (setq zone "18S")
    )
    ((>= east 700000)
      (setq zone "19S")
    )
    (T
      (setq zone "UNKNOWN")
    )
  )
  zone
)

;;; Función: CCP-validate-utm-peru
;;; Valida que coordenadas estén dentro de Perú
(defun CCP-validate-utm-peru (east north / valid zone)
  (setq valid T)
  
  ;; Validar rango Este (aproximado para Perú)
  (if (or (< east 180000) (> east 850000))
    (setq valid nil)
  )
  
  ;; Validar rango Norte (Perú está en hemisferio sur, pero UTM usa falso norte)
  (if (or (< north 8200000) (> north 10000000))
    (setq valid nil)
  )
  
  (if valid
    (setq zone (CCP-utm-zone-from-coord east))
  )
  
  (list valid zone)
)

;;; Función: CCP-calculate-bearing-distance
;;; Calcula rumbo y distancia entre dos puntos
(defun CCP-calculate-bearing-distance (p1 p2 / dx dy dist bearing bearing-str)
  (setq dx (- (car p2) (car p1)))
  (setq dy (- (cadr p2) (cadr p1)))
  (setq dist (sqrt (+ (* dx dx) (* dy dy))))
  
  ;; Calcular ángulo en radianes
  (setq bearing (atan dy dx))
  
  ;; Convertir a grados
  (setq bearing (* bearing (/ 180.0 pi)))
  
  ;; Normalizar a 0-360
  (if (< bearing 0)
    (setq bearing (+ bearing 360.0))
  )
  
  ;; Formato topográfico
  (cond
    ((and (>= bearing 0) (< bearing 90))
      (setq bearing-str (strcat "N " (rtos bearing 2 4) "° E"))
    )
    ((and (>= bearing 90) (< bearing 180))
      (setq bearing-str (strcat "S " (rtos (- 180 bearing) 2 4) "° E"))
    )
    ((and (>= bearing 180) (< bearing 270))
      (setq bearing-str (strcat "S " (rtos (- bearing 180) 2 4) "° W"))
    )
    (T
      (setq bearing-str (strcat "N " (rtos (- 360 bearing) 2 4) "° W"))
    )
  )
  
  (list dist bearing bearing-str)
)

;;; Función: CCP-calculate-area-polygon
;;; Calcula área de polígono usando método de coordenadas
(defun CCP-calculate-area-polygon (points / n i area x1 y1 x2 y2)
  (setq n (length points))
  (if (< n 3)
    0.0
    (progn
      (setq area 0.0)
      (setq i 0)
      
      (while (< i n)
        (setq x1 (car (nth i points)))
        (setq y1 (cadr (nth i points)))
        
        (if (= i (- n 1))
          (progn
            (setq x2 (car (car points)))
            (setq y2 (cadr (car points)))
          )
          (progn
            (setq x2 (car (nth (1+ i) points)))
            (setq y2 (cadr (nth (1+ i) points)))
          )
        )
        
        (setq area (+ area (- (* x1 y2) (* x2 y1))))
        (setq i (1+ i))
      )
      
      (/ (abs area) 2.0)
    )
  )
)

;;; Función: CCP-calculate-perimeter
;;; Calcula perímetro de polígono
(defun CCP-calculate-perimeter (points / n i perimeter)
  (setq n (length points))
  (if (< n 2)
    0.0
    (progn
      (setq perimeter 0.0)
      (setq i 0)
      
      (while (< i n)
        (if (= i (- n 1))
          (setq perimeter (+ perimeter 
                             (CCP-distance-2d (nth i points) (car points))))
          (setq perimeter (+ perimeter 
                             (CCP-distance-2d (nth i points) 
                                             (nth (1+ i) points))))
        )
        (setq i (1+ i))
      )
      
      perimeter
    )
  )
)

;;; Función: CCP-interpolate-elevation
;;; Interpola elevación entre dos puntos conocidos
(defun CCP-interpolate-elevation (p1 z1 p2 z2 target-pt / d1 d2 total-d z)
  (setq d1 (CCP-distance-2d p1 target-pt))
  (setq d2 (CCP-distance-2d p2 target-pt))
  (setq total-d (+ d1 d2))
  
  (if (= total-d 0)
    z1
    (progn
      (setq z (+ z1 (* (/ d1 total-d) (- z2 z1))))
      z
    )
  )
)

;;; Función: CCP-slope-percent
;;; Calcula pendiente en porcentaje
(defun CCP-slope-percent (p1 z1 p2 z2 / h-dist v-dist slope)
  (setq h-dist (CCP-distance-2d p1 p2))
  (setq v-dist (abs (- z2 z1)))
  
  (if (= h-dist 0)
    0.0
    (setq slope (* (/ v-dist h-dist) 100.0))
  )
  
  slope
)

;;; Función: CCP-grade-to-angle
;;; Convierte pendiente (%) a ángulo (grados)
(defun CCP-grade-to-angle (grade)
  (* (/ 180.0 pi) (atan (/ grade 100.0)))
)

;;; Función: CCP-angle-to-grade
;;; Convierte ángulo (grados) a pendiente (%)
(defun CCP-angle-to-grade (angle-deg)
  (* (tan (* angle-deg (/ pi 180.0))) 100.0)
)

;;; Función: CCP-cut-fill
;;; Calcula volumen de corte/relleno entre dos superficies
(defun CCP-cut-fill (existing-z proposed-z area / diff volume)
  (setq diff (- proposed-z existing-z))
  
  (if (< diff 0)
    (list 'cut (* (abs diff) area))
    (list 'fill (* diff area))
  )
)

;;; Función: CCP-stakeout-data
;;; Calcula datos para replanteo
(defun CCP-stakeout-data (station-pt target-pt / bd)
  (setq bd (CCP-calculate-bearing-distance station-pt target-pt))
  
  (list
    (cons 'distance (car bd))
    (cons 'bearing (cadr bd))
    (cons 'bearing-string (caddr bd))
  )
)

(princ "\n[TOPO] Utils cargados.")
(princ)
