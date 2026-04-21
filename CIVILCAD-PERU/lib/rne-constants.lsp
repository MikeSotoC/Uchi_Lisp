;;; ============================================================================
;;; CIVILCAD-PERÚ - RNE CONSTANTS & NORMAS TÉCNICAS
;;; Constantes y parámetros según normativa peruana
;;; ============================================================================

;;; Variables globales de normativa
(setq *CCP_RNE_VERSION* "1.0.0")

;;; ============================================================================
;;; RNE - REGLAMENTO NACIONAL DE EDIFICACIONES
;;; ============================================================================

;;; E.020 - Cargas
(setq *CCP_RNE_E020* (list
  (cons 'nombre "E.020 - Cargas")
  (cons 'version "2006")
  (cons 'carga-viva-vivienda 200)        ; kg/m²
  (cons 'carga-viva-oficina 250)         ; kg/m²
  (cons 'carga-viva-comercio 400)        ; kg/m²
  (cons 'carga-viva-educacion 300)       ; kg/m²
  (cons 'carga-viva-hospital 300)        ; kg/m²
  (cons 'carga-viva-parqueo 200)         ; kg/m²
  (cons 'carga-muro-tabique 150)         ; kg/m² (muro ligero)
  (cons 'peso-concreto-armado 2400)      ; kg/m³
  (cons 'peso-concreto-simple 2200)      ; kg/m³
  (cons 'peso-acero 7850)                ; kg/m³
  (cons 'peso-albanileria 1800)          ; kg/m³
))

;;; E.030 - Diseño Sismorresistente
(setq *CCP_RNE_E030* (list
  (cons 'nombre "E.030 - Diseño Sismorresistente")
  (cons 'version "2016")
  (cons 'zona-1-U 1.0)                   ; Costa (excepto sur)
  (cons 'zona-2-U 0.7)                   ; Selva
  (cons 'zona-3-U 0.4)                   ; Sierra
  (cons 'factor-suelo-s1 1.0)            ; Suelo rocoso/rígido
  (cons 'factor-suelo-s2 1.2)            ; Suelo intermedio
  (cons 'factor-suelo-s3 1.4)            ; Suelo flexible
  (cons 'factor-suelo-s4 1.8)            ; Suelo muy flexible
  (cons 'coeficiente-sismo-basico 0.4)   ; Zona 3, suelo rígido
  (cons 'reduccion-R-porticos 8)         ; Pórticos de concreto
  (cons 'reduccion-R-muros 6)            ; Muros estructurales
  (cons 'reduccion-R-dual 7)             ; Sistema dual
  (cons 'importancia-edificio 1.0)       ; Edificios comunes
  (cons 'importancia-esencial 1.5)       ; Hospitales, bomberos
  (cons 'importancia-peligroso 1.3)      ; Plantas químicas
))

;;; E.050 - Suelos y Cimentaciones
(setq *CCP_RNE_E050* (list
  (cons 'nombre "E.050 - Suelos y Cimentaciones")
  (cons 'version "2016")
  (cons 'capacidad-portante-roca 5000)   ; kPa
  (cons 'capacidad-portante-grava 300)   ; kPa
  (cons 'capacidad-portante-arena-densa 250) ; kPa
  (cons 'capacidad-portante-arcilla-dura 200) ; kPa
  (cons 'capacidad-portante-limo 100)    ; kPa
  (cons 'capacidad-portante-arcilla-blanda 50) ; kPa
  (cons 'profundidad-cimentacion-minima 0.80) ; m
  (cons 'factor-seguridad-volteo 1.5)
  (cons 'factor-seguridad-deslizamiento 1.5)
))

;;; E.060 - Concreto Armado
(setq *CCP_RNE_E060* (list
  (cons 'nombre "E.060 - Concreto Armado")
  (cons 'version "2009")
  (cons 'fc-min 175)                     ; kg/cm² (concreto mínimo)
  (cons 'fc-usual 210)                   ; kg/cm² (uso común)
  (cons 'fc-estructural 280)             ; kg/cm² (estructural)
  (cons 'fy-acero-grado-60 4200)         ; kg/cm²
  (cons 'fy-acero-grado-40 2800)         ; kg/cm²
  (cons 'recubrimiento-zapata 7.5)       ; cm
  (cons 'recubrimiento-columna 4.0)      ; cm
  (cons 'recubrimiento-viga 4.0)         ; cm
  (cons 'recubrimiento-losa 2.0)         ; cm
  (cons 'cuantia-minima-viga 0.0033)
  (cons 'cuantia-maxima-viga 0.016)
  (cons 'cuantia-minima-columna 0.01)
  (cons 'cuantia-maxima-columna 0.06)
))

;;; ============================================================================
;;; DG-1999 - CARRETERAS (MINISTERIO DE TRANSPORTES)
;;; ============================================================================

(setq *CCP_DG_1999* (list
  (cons 'nombre "DG-1999 - Diseño Geométrico de Carreteras")
  (cons 'version "1999")
  
  ;; Velocidades directrices (km/h)
  (cons 'vel-directriz-I-1 120)          ; Autopista
  (cons 'vel-directriz-I-2 100)          ; Primera clase
  (cons 'vel-directriz-II-3 80)          ; Segunda clase
  (cons 'vel-directriz-II-4 60)          ; Tercera clase
  (cons 'vel-directriz-III-5 40)         ; Trocha carrozable
  
  ;; Pendientes máximas (%)
  (cons 'pendiente-max-plano 5)
  (cons 'pendiente-max-ondulado 6)
  (cons 'pendiente-max-montana 7)
  (cons 'pendiente-max-escarpada 9)
  
  ;; Radios mínimos de curva horizontal (m)
  (cons 'radio-min-120kmh 680)
  (cons 'radio-min-100kmh 420)
  (cons 'radio-min-80kmh 250)
  (cons 'radio-min-60kmh 125)
  (cons 'radio-min-40kmh 55)
  
  ;; Anchos de carril (m)
  (cons 'ancho-carril-autopista 3.60)
  (cons 'ancho-carril-primera 3.30)
  (cons 'ancho-carril-segunda 3.00)
  (cons 'ancho-carril-tercera 2.70)
  
  ;; Bermas (m)
  (cons 'berma-exterior-min 1.80)
  (cons 'berma-interior-min 0.60)
  
  ;; Peraltes máximos (%)
  (cons 'peralte-max-autopista 8)
  (cons 'peralte-max-rural 10)
  (cons 'peralte-normal 4)
  
  ;; Distancias de visibilidad (m)
  (cons 'visibilidad-parada-120kmh 220)
  (cons 'visibilidad-parada-100kmh 155)
  (cons 'visibilidad-parada-80kmh 105)
  (cons 'visibilidad-parada-60kmh 65)
  (cons 'visibilidad-parada-40kmh 35)
  
  (cons 'visibilidad-adelantamiento-120kmh 600)
  (cons 'visibilidad-adelantamiento-100kmh 450)
  (cons 'visibilidad-adelantamiento-80kmh 300)
  (cons 'visibilidad-adelantamiento-60kmh 200)
  (cons 'visibilidad-adelantamiento-40kmh 120)
))

;;; ============================================================================
;;; TOPOGRAFÍA - IGNP PERÚ
;;; ============================================================================

(setq *CCP_TOPO_PERU* (list
  (cons 'nombre "Topografía Perú - IGNP")
  (cons 'datum "WGS84")
  (cons 'elipsoide "WGS84")
  
  ;; Zonas UTM Perú
  (cons 'utm-17s (list
    (cons 'codigo 32717)
    (cons 'meridiano-central -81.0)
    (cons 'factor-escala 0.9996)
    (cons 'falso-este 500000)
    (cons 'falso-norte 10000000)
    (cons 'limite-oeste -84.0)
    (cons 'limite-este -78.0)
  ))
  
  (cons 'utm-18s (list
    (cons 'codigo 32718)
    (cons 'meridiano-central -75.0)
    (cons 'factor-escala 0.9996)
    (cons 'falso-este 500000)
    (cons 'falso-norte 10000000)
    (cons 'limite-oeste -78.0)
    (cons 'limite-este -72.0)
  ))
  
  (cons 'utm-19s (list
    (cons 'codigo 32719)
    (cons 'meridiano-central -69.0)
    (cons 'factor-escala 0.9996)
    (cons 'falso-este 500000)
    (cons 'falso-norte 10000000)
    (cons 'limite-oeste -72.0)
    (cons 'limite-este -66.0)
  ))
  
  ;; Precisión IGNP
  (cons 'precision-planimetrica-urbana 0.01)   ; m
  (cons 'precision-planimetrica-rural 0.05)    ; m
  (cons 'precision-altimetrica-urbana 0.02)    ; m
  (cons 'precision-altimetrica-rural 0.05)     ; m
  
  ;; Equidistancia curvas de nivel
  (cons 'equidistancia-plano 0.50)        ; m
  (cons 'equidistancia-ondulado 1.00)     ; m
  (cons 'equidistancia-montana 2.00)      ; m
  (cons 'equidistancia-escarpada 5.00)    ; m
))

;;; ============================================================================
;;; SANEAMIENTO - MVCS
;;; ============================================================================

(setq *CCP_SANEAMIENTO_MVCS* (list
  (cons 'nombre "Saneamiento - MVCS")
  
  ;; Coeficiente de rugosidad Manning
  (cons 'manning-pvc 0.009)
  (cons 'manning-concreto 0.013)
  (cons 'manning-fierro-fundido 0.012)
  (cons 'manning-asbesto-cemento 0.010)
  (cons 'manning-pead 0.009)
  
  ;; Coeficiente Hazen-Williams
  (cons 'hazen-williams-pvc 150)
  (cons 'hazen-williams-concreto 130)
  (cons 'hazen-williams-fierro-nuevo 130)
  (cons 'hazen-williams-fierro-viejo 100)
  (cons 'hazen-williams-asbesto 140)
  
  ;; Pendientes mínimas tuberías
  (cons 'pendiente-min-colector-160mm 0.005)
  (cons 'pendiente-min-colector-200mm 0.003)
  (cons 'pendiente-min-colector-250mm 0.002)
  
  ;; Velocidades en colectores
  (cons 'velocidad-minima 0.60)          ; m/s
  (cons 'velocidad-maxima 4.00)          ; m/s
  (cons 'velocidad-optima 1.50)          ; m/s
  
  ;; Profundidades
  (cons 'profundidad-minima-colector 1.20) ; m
  (cons 'profundidad-maxima-colector 5.00) ; m
  
  ;; Diámetros comerciales (mm)
  (cons 'diametros-pvc '(110 160 200 250 315 400 500 630))
  
  ;; DOT - Densidad poblacional
  (cons 'dot-vivienda 5.5)               ; hab/viv
  (cons 'dot-urbano 150)                 ; hab/ha
  (cons 'dot-semiurbano 80)              ; hab/ha
  
  ;; Dotación de agua
  (cons 'dotacion-urbana 150)            ; L/hab/día
  (cons 'dotacion-rural 60)              ; L/hab/día
  
  ;; Coeficientes de variación
  (cons 'kh-maximo-horario 2.25)
  (cons 'kd-maximo-diario 1.3)
))

;;; Función: CCP-get-norma-value
;;; Obtiene valor específico de una norma
(defun CCP-get-norma-value (norma key / value)
  (cond
    ((= norma 'RNE_E020)
      (cdr (assoc key *CCP_RNE_E020*))
    )
    ((= norma 'RNE_E030)
      (cdr (assoc key *CCP_RNE_E030*))
    )
    ((= norma 'RNE_E050)
      (cdr (assoc key *CCP_RNE_E050*))
    )
    ((= norma 'RNE_E060)
      (cdr (assoc key *CCP_RNE_E060*))
    )
    ((= norma 'DG_1999)
      (cdr (assoc key *CCP_DG_1999*))
    )
    ((= norma 'TOPO_PERU)
      (cdr (assoc key *CCP_TOPO_PERU*))
    )
    ((= norma 'SANEAMIENTO)
      (cdr (assoc key *CCP_SANEAMIENTO_MVCS*))
    )
    (T nil)
  )
)

;;; Función: CCP-list-normas
;;; Lista todas las normas disponibles
(defun CCP-list-normas ()
  (princ "\n\n=== NORMAS DISPONIBLES ===\n")
  (foreach norma (list
    *CCP_RNE_E020*
    *CCP_RNE_E030*
    *CCP_RNE_E050*
    *CCP_RNE_E060*
    *CCP_DG_1999*
    *CCP_TOPO_PERU*
    *CCP_SANEAMIENTO_MVCS*
  )
    (princ (strcat "\n  - " (cdr (assoc 'nombre norma))))
  )
  (princ "\n=========================\n")
)

(princ "\n[LIB] RNE Constants cargados.")
(princ)
