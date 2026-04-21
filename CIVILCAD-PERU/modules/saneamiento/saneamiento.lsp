;;; ============================================================================
;;; CIVILCAD-PERÚ - MÓDULO DE SANEAMIENTO
;;; Diseño de redes de agua y desagüe según MVCS
;;; ============================================================================

;;; Variables globales del módulo
(setq *CCP_SANEAMIENTO_VERSION* "1.0.0")
(setq *CCP_RED_AGUA_DATA* nil)
(setq *CCP_RED_DESAGUE_DATA* nil)

;;; ============================================================================
;;; FUNCIONES DEL CONTRATO DE MÓDULOS
;;; ============================================================================

;;; Función: CCP_MOD_SANEAMIENTO_INIT
;;; Inicializa el módulo de saneamiento
(defun CCP_MOD_SANEAMIENTO_INIT ()
  (princ "\n[SANEAMIENTO] Inicializando módulo de Saneamiento...")
  
  ;; Configurar layers
  (CCP-create-layer "AGUA-TUBERIA" 4 "Continuous")    ; Cyan
  (CCP-create-layer "AGUA-VALVULA" 1 "Continuous")    ; Rojo
  (CCP-create-layer "DESAGUE-COLECTOR" 3 "Continuous") ; Verde
  (CCP-create-layer "DESAGUE-BUZON" 2 "Continuous")   ; Amarillo
  (CCP-create-layer "PERFIL" 7 "Continuous")          ; Blanco
  
  ;; Resetear datos
  (setq *CCP_RED_AGUA_DATA* nil)
  (setq *CCP_RED_DESAGUE_DATA* nil)
  
  (CCP-log-module-start "Saneamiento")
  (princ "\n[SANEAMIENTO] Módulo inicializado correctamente.")
  T
)

;;; Función: CCP_MOD_SANEAMIENTO_RUN
;;; Ejecuta el módulo principal de saneamiento
(defun CCP_MOD_SANEAMIENTO_RUN ()
  (princ "\n[SANEAMIENTO] Ejecutando funciones de saneamiento...")
  
  (princ "\n\n=== SANEAMIENTO (MVCS) ===")
  (princ "\n1. Diseñar tubería de agua")
  (princ "\n2. Calcular pérdida de carga (Hazen-Williams)")
  (princ "\n3. Diseñar colector de desagüe (Manning)")
  (princ "\n4. Dimensionar población (DOT)")
  (princ "\n5. Salir")
  
  (princ "\nSeleccione opción: ")
  (setq opcion (getint))
  
  (cond
    ((= opcion 1)
      (CCP_disenar-tuberia-agua)
    )
    ((= opcion 2)
      (CCP_calcular-hazen-williams)
    )
    ((= opcion 3)
      (CCP_calcular-manning)
    )
    ((= opcion 4)
      (CCP_dimensionar-poblacion)
    )
    (T
      (princ "\n[SANEAMIENTO] Operación cancelada.")
    )
  )
  
  (CCP-log-module-end "Saneamiento" T)
  T
)

;;; Función: CCP_MOD_SANEAMIENTO_ERROR
;;; Manejador de errores del módulo
(defun CCP_MOD_SANEAMIENTO_ERROR (error-msg)
  (princ (strcat "\n[SANEAMIENTO] ERROR: " error-msg))
  (CCP-log-event 'error (strcat "Error en Saneamiento: " error-msg))
  nil
)

;;; ============================================================================
;;; FUNCIONES PRINCIPALES
;;; ============================================================================

;;; Función: CCP_disenar-tuberia-agua
;;; Diseña tubería de agua potable
(defun CCP_disenar-tuberia-agua ( / diametro caudal velocidad presion material)
  (princ "\n=== DISEÑO DE TUBERÍA DE AGUA ===\n")
  
  ;; Solicitar datos
  (setq caudal (getreal "\nCaudal de diseño (L/s): "))
  (setq longitud (getreal "\nLongitud de tubería (m): "))
  (setq presion-disp (getreal "\nPresión disponible (mca): "))
  
  (if (null caudal)
    (setq caudal 5.0)
  )
  
  ;; Seleccionar material
  (princ "\nMaterial:")
  (princ "\n1. PVC")
  (princ "\n2. Fierro fundido")
  (princ "\n3. PEAD")
  (setq mat-opc (getint "\nOpción: "))
  
  (cond
    ((= mat-opc 1)
      (setq material "PVC")
      (setq C 150)  ; Hazen-Williams
      (setq n 0.009) ; Manning
    )
    ((= mat-opc 2)
      (setq material "Fierro fundido")
      (setq C 130)
      (setq n 0.012)
    )
    (T
      (setq material "PEAD")
      (setq C 150)
      (setq n 0.009)
    )
  )
  
  ;; Calcular diámetro preliminar por velocidad óptima
  (setq vel-opt 1.5)  ; m/s
  (setq q_m3s (/ caudal 1000.0))  ; Convertir a m³/s
  (setq area-req (/ q_m3s vel-opt))
  (setq diam-calc (* 2 (sqrt (/ area-req pi))))
  (setq diam-mm (* diam-calc 1000))
  
  ;; Redondear a diámetro comercial
  (setq diam-comerciales '(110 160 200 250 315 400 500 630))
  (setq diametro 110)
  (foreach d diam-comerciales
    (if (>= d diam-mm)
      (progn
        (setq diametro d)
        (setq diam-comerciales nil)  ; Salir del bucle
      )
    )
  )
  
  ;; Recalcular velocidad real
  (setq area-real (/ (* pi (* diametro diametro)) 4000000.0))  ; mm² a m²
  (setq velocidad (/ q_m3s area-real))
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nMaterial: " material))
  (princ (strcat "\nDiámetro comercial: " (itoa diametro) " mm"))
  (princ (strcat "\nVelocidad: " (rtos velocidad 2 3) " m/s"))
  
  ;; Verificar velocidad
  (setq vel-min (CCP-get-norma-value 'SANEAMIENTO 'velocidad-minima))
  (setq vel-max (CCP-get-norma-value 'SANEAMIENTO 'velocidad-maxima))
  
  (if (< velocidad vel-min)
    (princ "\n[ADVERTENCIA] Velocidad menor al mínimo (0.60 m/s)")
  )
  (if (> velocidad vel-max)
    (princ "\n[ADVERTENCIA] Velocidad mayor al máximo (4.00 m/s)")
  )
  
  ;; Guardar datos
  (setq *CCP_RED_AGUA_DATA* (append *CCP_RED_AGUA_DATA*
    (list (list
      (cons 'diametro diametro)
      (cons 'material material)
      (cons 'caudal caudal)
      (cons 'longitud longitud)
      (cons 'velocidad velocidad)
    )))
  )
  
  T
)

;;; Función: CCP_calcular-hazen-williams
;;; Calcula pérdida de carga usando Hazen-Williams
(defun CCP_calcular-hazen-williams ( / Q C D L J hf)
  (princ "\n=== PÉRDIDA DE CARGA (HAZEN-WILLIAMS) ===\n")
  
  (setq Q (getreal "\nCaudal (L/s): "))
  (setq C (getreal "\nCoeficiente C: "))
  (setq D (getreal "\nDiámetro (mm): "))
  (setq L (getreal "\nLongitud (m): "))
  
  (if (null Q) (setq Q 5.0))
  (if (null C) (setq C 150))
  (if (null D) (setq D 160))
  (if (null L) (setq L 100.0))
  
  ;; Fórmula Hazen-Williams (unidades métricas)
  ;; J = 10.67 * Q^1.852 / (C^1.852 * D^4.87)
  ;; Donde Q en m³/s, D en m
  
  (setq q_m3s (/ Q 1000.0))
  (setq d_m (/ D 1000.0))
  
  (setq j (* 10.67 
            (/ (expt q_m3s 1.852))
            (* (expt C 1.852) (expt d_m 4.87))))
  
  (setq hf (* j L))
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nPérdida unitaria (J): " (rtos j 2 6) " m/m"))
  (princ (strcat "\nPérdida total (hf): " (rtos hf 2 3) " m"))
  (princ (strcat "\nPérdida cada 100m: " (rtos (* j 100) 2 3) " m"))
  
  T
)

;;; Función: CCP_calcular-manning
;;; Calcula flujo en tubería usando Manning
(defun CCP_calcular-manning ( / n D S Q v)
  (princ "\n=== CÁLCULO DE COLECTOR (MANNING) ===\n")
  
  (setq n (getreal "\nCoeficiente de rugosidad (n): "))
  (setq D (getreal "\nDiámetro (mm): "))
  (setq S (getreal "\nPendiente (%): "))
  
  (if (null n) (setq n 0.013))  ; Concreto
  (if (null D) (setq D 200))
  (if (null S) (setq S 0.5))
  
  ;; Convertir pendiente a decimal
  (setq s-dec (/ S 100.0))
  
  ;; Diámetro en metros
  (setq d_m (/ D 1000.0))
  
  ;; Para tubería circular llena:
  ;; Q = (1/n) * A * R^(2/3) * S^(1/2)
  ;; A = π*D²/4, R = D/4
  
  (setq area (/ (* pi d_m d_m) 4))
  (setq radio-hid (/ d_m 4))
  
  (setq q_full (* (/ 1.0 n)
                  area
                  (expt radio-hid (/ 2.0 3.0))
                  (sqrt s-dec)))
  
  (setq v-full (/ q_full area))
  
  (princ "\n\n=== RESULTADOS (TUBERÍA LLENA) ===")
  (princ (strcat "\nCaudal capaz: " (rtos (* q_full 1000) 2 2) " L/s"))
  (princ (strcat "\nVelocidad: " (rtos v-full 2 3) " m/s"))
  
  ;; Verificar velocidad
  (setq vel-min (CCP-get-norma-value 'SANEAMIENTO 'velocidad-minima))
  (setq vel-max (CCP-get-norma-value 'SANEAMIENTO 'velocidad-maxima))
  
  (if (< v-full vel-min)
    (princ "\n[ADVERTENCIA] Velocidad menor al mínimo (riesgo de sedimentación)")
  )
  (if (> v-full vel-max)
    (princ "\n[ADVERTENCIA] Velocidad mayor al máximo (erosión)")
  )
  
  ;; Pendiente mínima
  (setq s-min (cond
    ((<= D 160) 0.005)
    ((<= D 200) 0.003)
    (T 0.002)
  ))
  
  (if (< s-dec s-min)
    (princ (strcat "\n[ADVERTENCIA] Pendiente menor al mínimo recomendado (" 
                   (rtos (* s-min 100) 2 2) "%)"))
  )
  
  ;; Guardar datos
  (setq *CCP_RED_DESAGUE_DATA* (append *CCP_RED_DESAGUE_DATA*
    (list (list
      (cons 'diametro D)
      (cons 'pendiente S)
      (cons 'rugosidad n)
      (cons 'caudal (* q_full 1000))
      (cons 'velocidad v-full)
    )))
  )
  
  T
)

;;; Función: CCP_dimensionar-poblacion
;;; Dimensiona población usando DOT
(defun CCP_dimensionar-poblacion ( / dot viv hab dotacion qmd qmh)
  (princ "\n=== DIMENSIONAMIENTO POBLACIONAL ===\n")
  
  (setq viv (getint "\nNúmero de viviendas: "))
  (setq area-ha (getreal "\nÁrea del sector (ha): "))
  
  (if (null viv) (setq viv 100))
  (if (null area-ha) (setq area-ha 1.0))
  
  ;; DOT - Densidad ocupacional territorial
  (setq dot (CCP-get-norma-value 'SANEAMIENTO 'dot-vivienda))
  (if (null dot) (setq dot 5.5))
  
  (setq hab (* viv dot))
  
  ;; Dotación
  (setq dotacion (CCP-get-norma-value 'SANEAMIENTO 'dotacion-urbana))
  (if (null dotacion) (setq dotacion 150))
  
  ;; Caudales
  (setq qmd (/ (* hab dotacion) 86400.0))  ; L/s (caudal medio diario)
  
  ;; Coeficientes
  (setq kh (CCP-get-norma-value 'SANEAMIENTO 'kh-maximo-horario))
  (if (null kh) (setq kh 2.25))
  
  (setq qmh (* qmd kh))  ; Caudal máximo horario
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nDOT: " (rtos dot 2 1) " hab/viv"))
  (princ (strcat "\nPoblación actual: " (itoa hab) " hab"))
  (princ (strcat "\nDensidad: " (rtos (/ hab area-ha) 2 0) " hab/ha"))
  (princ (strcat "\nDotación: " (itoa dotacion) " L/hab/día"))
  (princ (strcat "\nQMD: " (rtos qmd 2 3) " L/s"))
  (princ (strcat "\nQMH: " (rtos qmh 2 3) " L/s"))
  
  T
)

(princ "\n[SANEAMIENTO] Módulo Saneamiento cargado.")
(princ)
