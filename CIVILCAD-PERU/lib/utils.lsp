;;; ============================================================================
;;; CIVILCAD-PERÚ - UTILIDADES GENERALES
;;; Librería de funciones utilitarias
;;; ============================================================================

;;; Variables globales de utils
(setq *CCP_UTILS_VERSION* "1.0.0")

;;; Función: CCP-parse-csv-line
;;; Parsea una línea CSV retornando lista de valores
(defun CCP-parse-csv-line (line / result pos char current in-quote)
  (setq result nil)
  (setq current "")
  (setq pos 0)
  (setq in-quote nil)
  
  (while (< pos (strlen line))
    (setq char (substr line (1+ pos) 1))
    
    (cond
      ;; Comilla
      ((= char "\"")
        (if in-quote
          (setq in-quote nil)
          (setq in-quote T)
        )
      )
      ;; Coma (separador)
      ((and (= char ",") (not in-quote))
        (setq result (append result (list current)))
        (setq current "")
      )
      ;; Punto y coma (separador alternativo)
      ((and (= char ";") (not in-quote))
        (setq result (append result (list current)))
        (setq current "")
      )
      ;; Caracter normal
      (T
        (setq current (strcat current char))
      )
    )
    
    (setq pos (1+ pos))
  )
  
  ;; Agregar último valor
  (if (/= current "")
    (setq result (append result (list current)))
  )
  
  result
)

;;; Función: CCP-trim
;;; Elimina espacios en blanco al inicio y final
(defun CCP-trim (str / start end)
  (setq start 0)
  (setq end (strlen str))
  
  ;; Trim izquierdo
  (while (and (< start end) 
              (or (= (substr str (1+ start) 1) " ") 
                  (= (substr str (1+ start) 1) "\t")))
    (setq start (1+ start))
  )
  
  ;; Trim derecho
  (while (and (> end start) 
              (or (= (substr str end 1) " ") 
                  (= (substr str end 1) "\t")))
    (setq end (1- end))
  )
  
  (substr str (1+ start) (- end start -1))
)

;;; Función: CCP-to-real
;;; Convierte string a real con manejo de errores
(defun CCP-to-real (str / result)
  (setq result (distof str 2))
  (if (null result)
    (setq result 0.0)
  )
  result
)

;;; Función: CCP-to-int
;;; Convierte string a entero con manejo de errores
(defun CCP-to-int (str / result)
  (setq result (atoi str))
  result
)

;;; Función: CCP-format-number
;;; Formatea número con decimales específicos
(defun CCP-format-number (num decimals / fmt result)
  (setq fmt (cond
    ((= decimals 0) "%.0f")
    ((= decimals 1) "%.1f")
    ((= decimals 2) "%.2f")
    ((= decimals 3) "%.3f")
    ((= decimals 4) "%.4f")
    (T "%.2f")
  ))
  (rtos num 2 decimals)
)

;;; Función: CCP-format-coordinate
;;; Formatea coordenada UTM
(defun CCP-format-coordinate (coord type / )
  (cond
    ((= type 'E)
      (strcat (CCP-format-number coord 4) " E")
    )
    ((= type 'N)
      (strcat (CCP-format-number coord 4) " N")
    )
    ((= type 'Z)
      (strcat (CCP-format-number coord 3) " m")
    )
    (T
      (CCP-format-number coord 4)
    )
  )
)

;;; Función: CCP-distance-2d
;;; Calcula distancia 2D entre dos puntos
(defun CCP-distance-2d (p1 p2 / dx dy)
  (setq dx (- (car p2) (car p1)))
  (setq dy (- (cadr p2) (cadr p1)))
  (sqrt (+ (* dx dx) (* dy dy)))
)

;;; Función: CCP-distance-3d
;;; Calcula distancia 3D entre dos puntos
(defun CCP-distance-3d (p1 p2 / dx dy dz)
  (setq dx (- (car p2) (car p1)))
  (setq dy (- (cadr p2) (cadr p1)))
  (setq dz (- (caddr p2) (caddr p1)))
  (sqrt (+ (* dx dx) (* dy dy) (* dz dz)))
)

;;; Función: CCP-angle-between
;;; Calcula ángulo entre dos puntos en grados
(defun CCP-angle-between (p1 p2 / dx dy ang)
  (setq dx (- (car p2) (car p1)))
  (setq dy (- (cadr p2) (cadr p1)))
  (setq ang (atan dy dx))
  (* ang (/ 180.0 pi))
)

;;; Función: CCP-bearing
;;; Calcula rumbo entre dos puntos (formato topográfico)
(defun CCP-bearing (p1 p2 / ang quad bearing-val bearing-str)
  (setq ang (CCP-angle-between p1 p2))
  
  ;; Normalizar a 0-360
  (if (< ang 0)
    (setq ang (+ ang 360.0))
  )
  
  ;; Determinar cuadrante
  (cond
    ((and (>= ang 0) (< ang 90))
      (setq quad "NE")
      (setq bearing-val ang)
    )
    ((and (>= ang 90) (< ang 180))
      (setq quad "SE")
      (setq bearing-val (- 180 ang))
    )
    ((and (>= ang 180) (< ang 270))
      (setq quad "SW")
      (setq bearing-val (- ang 180))
    )
    (T
      (setq quad "NW")
      (setq bearing-val (- 360 ang))
    )
  )
  
  (strcat "N " (CCP-format-number bearing-val 4) "° " quad)
)

;;; Función: CCP-polar-point
;;; Obtiene punto dado distancia y ángulo
(defun CCP-polar-point (base dist ang-deg / ang-rad)
  (setq ang-rad (* ang-deg (/ pi 180.0)))
  (polar base ang-rad dist)
)

;;; Función: CCP-midpoint
;;; Calcula punto medio entre dos puntos
(defun CCP-midpoint (p1 p2)
  (list
    (/ (+ (car p1) (car p2)) 2.0)
    (/ (+ (cadr p1) (cadr p2)) 2.0)
    (if (and (caddr p1) (caddr p2))
      (/ (+ (caddr p1) (caddr p2)) 2.0)
      0.0
    )
  )
)

;;; Función: CCP-interpolate
;;; Interpola punto entre p1 y p2 dado factor t (0-1)
(defun CCP-interpolate (p1 p2 t)
  (list
    (+ (car p1) (* t (- (car p2) (car p1))))
    (+ (cadr p1) (* t (- (cadr p2) (cadr p1))))
    (if (and (caddr p1) (caddr p2))
      (+ (caddr p1) (* t (- (caddr p2) (caddr p1))))
      0.0
    )
  )
)

;;; Función: CCP-get-timestamp
;;; Obtiene timestamp formateado
(defun CCP-get-timestamp ()
  (menucmd "M=$(edtime,$(getvar,date),YYYY-MM-DD HH:MM:SS)")
)

;;; Función: CCP-random
;;; Genera número aleatorio entre min y max
(defun CCP-random (min max)
  (+ min (* (rand) (- max min)))
)

;;; Función: CCP-clamp
;;; Limita valor entre min y max
(defun CCP-clamp (val min-val max-val)
  (cond
    ((< val min-val) min-val)
    ((> val max-val) max-val)
    (T val)
  )
)

;;; Función: CCP-linspace
;;; Genera lista de valores equidistantes
(defun CCP-linspace (start end count / step result i)
  (setq result nil)
  (setq step (/ (- end start) (1- count)))
  (setq i 0)
  
  (while (< i count)
    (setq result (append result (list (+ start (* i step)))))
    (setq i (1+ i))
  )
  
  result
)

(princ "\n[LIB] Utils cargadas.")
(princ)
