;;; ============================================================================
;;; CIVILCAD-PERÚ - MÓDULO DE CARRETERAS
;;; Diseño geométrico horizontal y vertical según DG-1999
;;; ============================================================================

;;; Variables globales del módulo
(setq *CCP_CARRETERAS_VERSION* "1.0.0")
(setq *CCP_EJE_DATA* nil)
(setq *CCP_CURVAS_H_DATA* nil)
(setq *CCP_PERALTES_DATA* nil)

;;; ============================================================================
;;; FUNCIONES DEL CONTRATO DE MÓDULOS
;;; ============================================================================

;;; Función: CCP_MOD_CARRETERAS_INIT
;;; Inicializa el módulo de carreteras
(defun CCP_MOD_CARRETERAS_INIT ()
  (princ "\n[CARRETERAS] Inicializando módulo de Carreteras...")
  
  ;; Configurar layers
  (CCP-create-layer "EJE" 1 "Continuous")
  (CCP-create-layer "BORDE-VIA" 3 "Continuous")
  (CCP-create-layer "PERALTES" 4 "Continuous")
  (CCP-create-layer "RASANTE" 2 "Continuous")
  (CCP-create-layer "SECCIONES" 6 "Continuous")
  
  ;; Resetear datos
  (setq *CCP_EJE_DATA* nil)
  (setq *CCP_CURVAS_H_DATA* nil)
  (setq *CCP_PERALTES_DATA* nil)
  
  ;; Configurar unidades
  (CCP-set-units 'metric)
  
  (CCP-log-module-start "Carreteras")
  (princ "\n[CARRETERAS] Módulo inicializado correctamente.")
  T
)

;;; Función: CCP_MOD_CARRETERAS_RUN
;;; Ejecuta el módulo principal de carreteras
(defun CCP_MOD_CARRETERAS_RUN ()
  (princ "\n[CARRETERAS] Ejecutando funciones de carreteras...")
  
  (princ "\n\n=== CARRETERAS (DG-1999) ===")
  (princ "\n1. Diseñar curva horizontal")
  (princ "\n2. Calcular peraltes")
  (princ "\n3. Verificar visibilidad")
  (princ "\n4. Dibujar eje")
  (princ "\n5. Salir")
  
  (princ "\nSeleccione opción: ")
  (setq opcion (getint))
  
  (cond
    ((= opcion 1)
      (CCP_disenar-curva-horizontal)
    )
    ((= opcion 2)
      (CCP_calcular-peraltes)
    )
    ((= opcion 3)
      (CCP_verificar-visibilidad)
    )
    ((= opcion 4)
      (CCP_dibujar-eje)
    )
    (T
      (princ "\n[CARRETERAS] Operación cancelada.")
    )
  )
  
  (CCP-log-module-end "Carreteras" T)
  T
)

;;; Función: CCP_MOD_CARRETERAS_ERROR
;;; Manejador de errores del módulo
(defun CCP_MOD_CARRETERAS_ERROR (error-msg)
  (princ (strcat "\n[CARRETERAS] ERROR: " error-msg))
  (CCP-log-event 'error (strcat "Error en Carreteras: " error-msg))
  nil
)

;;; ============================================================================
;;; FUNCIONES PRINCIPALES
;;; ============================================================================

;;; Función: CCP_disenar-curva-horizontal
;;; Diseña curva horizontal según DG-1999
(defun CCP_disenar-curva-horizontal ( / vel radio lc t e l pi-pt pt pc pt pt)
  (princ "\n=== DISEÑO DE CURVA HORIZONTAL ===\n")
  
  ;; Solicitar velocidad directriz
  (princ "\nVelocidades directrices DG-1999:")
  (princ "\n  I-1 (Autopista): 120 km/h")
  (princ "\n  I-2 (1ra clase): 100 km/h")
  (princ "\n  II-3 (2da clase): 80 km/h")
  (princ "\n  II-4 (3ra clase): 60 km/h")
  (princ "\n  III-5 (Trocha): 40 km/h")
  
  (setq vel (getreal "\nVelocidad directriz (km/h): "))
  
  (if (not vel)
    (setq vel 60)
  )
  
  ;; Obtener radio mínimo según velocidad
  (setq radio-min (CCP-get-norma-value 'DG_1999 
                    (intern (strcat "radio-min-" (rtos vel 2 0) "kmh"))))
  
  (if (not radio-min)
    (setq radio-min 125)  ; Default para 60 km/h
  )
  
  (princ (strcat "\nRadio mínimo recomendado: " (rtos radio-min 2 2) " m"))
  (setq radio (getreal "\nRadio de diseño (m): "))
  
  (if (or (null radio) (< radio radio-min))
    (progn
      (princ (strcat "\n[CARRETERAS] ADVERTENCIA: Radio menor al mínimo."))
      (setq radio radio-min)
      (princ (strcat "\nUsando radio mínimo: " (rtos radio 2 2) " m"))
    )
  )
  
  ;; Solicitar ángulo de deflexión
  (setq ang-def (getreal "\nÁngulo de deflexión (grados): "))
  
  (if (not ang-def)
    (setq ang-def 30.0)
  )
  
  ;; Calcular elementos de la curva
  (setq ang-rad (* ang-def (/ pi 180.0)))
  
  ;; Tangente
  (setq t (* radio (tan (/ ang-rad 2))))
  
  ;; Externa
  (setq e (/ radio (cos (/ ang-rad 2))))
  (setq e (- e radio))
  
  ;; Longitud de curva
  (setq l (* radio ang-rad))
  
  ;; Cuerda máxima (para 60 km/h = 20m)
  (setq cuerma-max (cond
    ((>= vel 100) 10)
    ((>= vel 80) 15)
    ((>= vel 60) 20)
    (T 25)
  ))
  
  ;; Mostrar resultados
  (princ "\n\n=== ELEMENTOS DE CURVA ===")
  (princ (strcat "\nRadio (R): " (rtos radio 2 3) " m"))
  (princ (strcat "\nÁngulo (Δ): " (rtos ang-def 2 4) "°"))
  (princ (strcat "\nTangente (T): " (rtos t 2 3) " m"))
  (princ (strcat "\nExterna (E): " (rtos e 2 3) " m"))
  (princ (strcat "\nLongitud Curva (L): " (rtos l 2 3) " m"))
  (princ (strcat "\nCuerda máx: " (rtos cuerma-max 2 2) " m"))
  
  ;; Guardar datos
  (setq *CCP_CURVAS_H_DATA* (append *CCP_CURVAS_H_DATA* 
    (list (list
      (cons 'vel vel)
      (cons 'radio radio)
      (cons 'angulo ang-def)
      (cons 'tangente t)
      (cons 'externa e)
      (cons 'longitud l)
    )))
  )
  
  (CCP-log-operation "Curva horizontal" 
                    (strcat "R=" (rtos radio 2 2) "m, L=" (rtos l 2 2) "m"))
  
  T
)

;;; Función: CCP_calcular-peraltes
;;; Calcula peraltes según DG-1999
(defun CCP_calcular-peraltes ( / vel radio peralte lc transicion)
  (princ "\n=== CÁLCULO DE PERALTES ===\n")
  
  (setq vel (getreal "\nVelocidad (km/h): "))
  (setq radio (getreal "\nRadio (m): "))
  
  (if (or (null vel) (null radio))
    (progn
      (princ "\n[CARRETERAS] Datos incompletos.")
      nil
    )
    (progn
      ;; Calcular peralte según fórmula DG-1999
      ;; e = (V² / (127*R)) - f
      ;; Donde f es coeficiente de fricción lateral (0.10 a 0.16)
      
      (setq f 0.12)  ; Valor típico
      (setq peralte-teorico (* 100 (- (/ (* vel vel) (* 127 radio)) f)))
      
      ;; Limitar peralte máximo
      (setq peralte-max (CCP-get-norma-value 'DG_1999 'peralte-max-rural))
      (if (null peralte-max)
        (setq peralte-max 10)
      )
      
      (if (> peralte-teorico peralte-max)
        (setq peralte peralte-max)
        (if (< peralte-teorico 2)
          (setq peralte 2)  ; Peralte mínimo
          (setq peralte peralte-teorico)
        )
      )
      
      ;; Longitud de transición
      (setq lc (* 0.0056 vel radio))  ; Fórmula simplificada
      (setq lc (max lc 30))  ; Mínimo 30m
      
      (princ "\n\n=== RESULTADOS ===")
      (princ (strcat "\nPeralte de diseño: " (rtos peralte 2 2) "%"))
      (princ (strcat "\nLongitud transición: " (rtos lc 2 2) " m"))
      
      ;; Guardar datos
      (setq *CCP_PERALTES_DATA* (append *CCP_PERALTES_DATA*
        (list (list
          (cons 'vel vel)
          (cons 'radio radio)
          (cons 'peralte peralte)
          (cons 'longitud-trans lc)
        )))
      )
      
      T
    )
  )
)

;;; Función: CCP_verificar-visibilidad
;;; Verifica distancia de visibilidad
(defun CCP_verificar-visibilidad ( / vel tipo dist-requerida)
  (princ "\n=== VERIFICACIÓN DE VISIBILIDAD ===\n")
  
  (setq vel (getreal "\nVelocidad (km/h): "))
  
  (princ "\nTipo de visibilidad:")
  (princ "\n1. Parada")
  (princ "\n2. Adelantamiento")
  (setq tipo (getint "\nOpción: "))
  
  (if (null vel)
    (setq vel 60)
  )
  
  ;; Obtener distancia requerida
  (if (= tipo 2)
    (setq key (intern (strcat "visibilidad-adelantamiento-" (rtos vel 2 0) "kmh")))
    (setq key (intern (strcat "visibilidad-parada-" (rtos vel 2 0) "kmh")))
  )
  
  (setq dist-requerida (CCP-get-norma-value 'DG_1999 key))
  
  (if (not dist-requerida)
    (setq dist-requerida 100)  ; Default
  )
  
  (princ (strcat "\n\nDistancia de visibilidad requerida: " 
                 (rtos dist-requerida 2 2) " m"))
  
  (setq dist-real (getreal "\nDistancia disponible (m): "))
  
  (if dist-real
    (if (>= dist-real dist-requerida)
      (princ "\n[CARRETERAS] ✓ Visibilidad SATISFACTORIA")
      (princ (strcat "\n[CARRETERAS] ✗ Visibilidad INSUFICIENTE (faltan " 
                     (rtos (- dist-requerida dist-real) 2 2) " m)"))
    )
  )
  
  T
)

;;; Función: CCP_dibujar-eje
;;; Dibuja eje de carretera
(defun CCP_dibujar-eje ( / pts pt)
  (princ "\n=== DIBUJAR EJE ===\n")
  
  (princ "\nIngrese puntos del eje (Enter para terminar):")
  (setq pts nil)
  
  (setq pt (getpoint "\nPI-1: "))
  (while pt
    (setq pts (append pts (list pt)))
    (setq pt (getpoint (strcat "\nPI-" (itoa (1+ (length pts))) ": ")))
  )
  
  (if (< (length pts) 2)
    (progn
      (princ "\n[CARRETERAS] Se necesitan al menos 2 puntos.")
      nil
    )
    (progn
      ;; Dibujar eje
      (CCP-draw-polyline pts "EJE" nil)
      
      (princ (strcat "\n[CARRETERAS] Eje dibujado con " 
                     (itoa (length pts)) " PI's."))
      
      (setq *CCP_EJE_DATA* pts)
      
      T
    )
  )
)

(princ "\n[CARRETERAS] Módulo Carreteras cargado.")
(princ)
