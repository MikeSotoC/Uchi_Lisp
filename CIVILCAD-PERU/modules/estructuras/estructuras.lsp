;;; ============================================================================
;;; CIVILCAD-PERÚ - MÓDULO DE ESTRUCTURAS
;;; Análisis estructural según RNE
;;; ============================================================================

;;; Variables globales del módulo
(setq *CCP_ESTRUCTURAS_VERSION* "1.0.0")
(setq *CCP_ELEMENTOS_DATA* nil)

;;; ============================================================================
;;; FUNCIONES DEL CONTRATO DE MÓDULOS
;;; ============================================================================

;;; Función: CCP_MOD_ESTRUCTURAS_INIT
;;; Inicializa el módulo de estructuras
(defun CCP_MOD_ESTRUCTURAS_INIT ()
  (princ "\n[ESTRUCTURAS] Inicializando módulo de Estructuras...")
  
  ;; Configurar layers
  (CCP-create-layer "EJE-COLUMNAS" 1 "Continuous")
  (CCP-create-layer "EJE-VIGAS" 2 "Continuous")
  (CCP-create-layer "LOSAS" 3 "Continuous")
  (CCP-create-layer "CIMIENTOS" 4 "Continuous")
  (CCP-create-layer "ARMADURA" 6 "Continuous")
  
  ;; Resetear datos
  (setq *CCP_ELEMENTOS_DATA* nil)
  
  (CCP-log-module-start "Estructuras")
  (princ "\n[ESTRUCTURAS] Módulo inicializado correctamente.")
  T
)

;;; Función: CCP_MOD_ESTRUCTURAS_RUN
;;; Ejecuta el módulo principal de estructuras
(defun CCP_MOD_ESTRUCTURAS_RUN ()
  (princ "\n[ESTRUCTURAS] Ejecutando funciones de estructuras...")
  
  (princ "\n\n=== ESTRUCTURAS (RNE) ===")
  (princ "\n1. Diseñar viga (E.060)")
  (princ "\n2. Diseñar columna (E.060)")
  (princ "\n3. Calcular carga sísmica (E.030)")
  (princ "\n4. Diseñar zapata (E.050)")
  (princ "\n5. Salir")
  
  (princ "\nSeleccione opción: ")
  (setq opcion (getint))
  
  (cond
    ((= opcion 1)
      (CCP_disenar-viga)
    )
    ((= opcion 2)
      (CCP_disenar-columna)
    )
    ((= opcion 3)
      (CCP_calcular-sismo)
    )
    ((= opcion 4)
      (CCP_disenar-zapata)
    )
    (T
      (princ "\n[ESTRUCTURAS] Operación cancelada.")
    )
  )
  
  (CCP-log-module-end "Estructuras" T)
  T
)

;;; Función: CCP_MOD_ESTRUCTURAS_ERROR
;;; Manejador de errores del módulo
(defun CCP_MOD_ESTRUCTURAS_ERROR (error-msg)
  (princ (strcat "\n[ESTRUCTURAS] ERROR: " error-msg))
  (CCP-log-event 'error (strcat "Error en Estructuras: " error-msg))
  nil
)

;;; ============================================================================
;;; FUNCIONES PRINCIPALES
;;; ============================================================================

;;; Función: CCP_disenar-viga
;;; Diseña viga de concreto armado según E.060
(defun CCP_disenar-viga ( / b h fc fy Mu As rho)
  (princ "\n=== DISEÑO DE VIGA (E.060) ===\n")
  
  (setq b (getreal "\nBase de viga (cm): "))
  (setq h (getreal "\nAltura total (cm): "))
  (setq Mu (getreal "\nMomento último Mu (kg-m): "))
  
  (if (null b) (setq b 25))
  (if (null h) (setq h 50))
  (if (null Mu) (setq Mu 10000))
  
  ;; Propiedades del material
  (setq fc (getreal "\nf'c (kg/cm²) <210>: "))
  (setq fy (getreal "\nfy (kg/cm²) <4200>: "))
  
  (if (null fc) (setq fc 210))
  (if (null fy) (setq fy 4200))
  
  ;; d = h - recubrimiento
  (setq r (CCP-get-norma-value 'RNE_E060 'recubrimiento-viga))
  (if (null r) (setq r 4.0))
  (setq d (- h r))
  
  ;; Cálculo simplificado de área de acero
  ;; As = Mu / (phi * fy * (d - a/2))
  ;; Iteración simplificada
  
  (setq phi 0.9)  ; Factor de reducción para flexión
  (setq j 0.9)     ; Brazo de palanca aproximado
  
  (setq as-req (/ Mu (* phi fy (* j d))))
  
  ;; Verificar cuantías
  (setq rho-min (CCP-get-norma-value 'RNE_E060 'cuantia-minima-viga))
  (setq rho-max (CCP-get-norma-value 'RNE_E060 'cuantia-maxima-viga))
  
  (if (null rho-min) (setq rho-min 0.0033))
  (if (null rho-max) (setq rho-max 0.016))
  
  (setq rho (/ as-req (* b d)))
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nSección: " (rtos b 2 0) " x " (rtos h 2 0) " cm"))
  (princ (strcat "\nd útil: " (rtos d 2 1) " cm"))
  (princ (strcat "\nAs requerida: " (rtos as-req 2 2) " cm²"))
  (princ (strcat "\nCuantía: " (rtos (* rho 100) 2 3) "%"))
  
  ;; Sugerir barras
  (princ "\n\nRefuerzo sugerido:")
  (cond
    ((<= as-req 2.85) (princ "  3Ø3/4\" (As = 2.85 cm²)"))
    ((<= as-req 3.80) (princ "  4Ø3/4\" (As = 3.80 cm²)"))
    ((<= as-req 4.56) (princ "  3Ø1\" (As = 4.56 cm²)"))
    ((<= as-req 5.07) (princ "  4Ø1\" + 2Ø3/4\" (As = 5.07 cm²)"))
    ((<= as-req 6.08) (princ "  4Ø1\" (As = 6.08 cm²)"))
    (T (princ "  Requiere diseño especial"))
  )
  
  T
)

;;; Función: CCP_disenar-columna
;;; Diseña columna según E.060
(defun CCP_disenar-columna ( / b h Pu Mu Ag Asg rho)
  (princ "\n=== DISEÑO DE COLUMNA (E.060) ===\n")
  
  (setq b (getreal "\nBase de columna (cm): "))
  (setq h (getreal "\nAltura de columna (cm): "))
  (setq Pu (getreal "\nCarga última Pu (kg): "))
  
  (if (null b) (setq b 40))
  (if (null h) (setq h 40))
  (if (null Pu) (setq Pu 100000))
  
  (setq fc (getreal "\nf'c (kg/cm²) <280>: "))
  (setq fy (getreal "\nfy (kg/cm²) <4200>: "))
  
  (if (null fc) (setq fc 280))
  (if (null fy) (setq fy 4200))
  
  ;; Área bruta
  (setq ag (* b h))
  
  ;; Cuantía mínima y máxima
  (setq rho-min (CCP-get-norma-value 'RNE_E060 'cuantia-minima-columna))
  (setq rho-max (CCP-get-norma-value 'RNE_E060 'cuantia-maxima-columna))
  
  (if (null rho-min) (setq rho-min 0.01))
  (if (null rho-max) (setq rho-max 0.06))
  
  ;; Cálculo simplificado para columna corta centrada
  ;; Pn = 0.80 * [0.85*fc*(Ag-Ast) + fy*Ast]
  ;; Usando rho = 0.02 típico
  
  (setq rho 0.02)
  (setq asg (* rho ag))
  
  ;; Capacidad nominal aproximada
  (setq pn (* 0.80 (+ (* 0.85 fc (- ag asg)) (* fy asg))))
  (setq phi-pn (* 0.65 pn))  ; Phi para columna estribada
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nSección: " (rtos b 2 0) " x " (rtos h 2 0) " cm"))
  (princ (strcat "\nÁrea bruta: " (rtos ag 2 0) " cm²"))
  (princ (strcat "\nAs total: " (rtos asg 2 2) " cm²"))
  (princ (strcat "\nCuantía: " (rtos (* rho 100) 2 2) "%"))
  (princ (strcat "\nφPn ≈ " (rtos (/ phi-pn 1000) 2 1) " ton"))
  
  ;; Verificación
  (if (< phi-pn Pu)
    (princ "\n[ADVERTENCIA] La columna NO resiste la carga aplicada")
    (princ "\n✓ La columna resiste la carga aplicada")
  )
  
  T
)

;;; Función: CCP_calcular-sismo
;;; Calcula carga sísmica según E.030
(defun CCP_calcular-sismo ( / Z U S C R V peso-corte)
  (princ "\n=== CÁLCULO SÍSMICO (E.030) ===\n")
  
  ;; Zona sísmica
  (princ "\nZona sísmica:")
  (princ "\n1. Zona 3 (Costa)")
  (princ "\n2. Zona 2 (Selva)")
  (princ "\n3. Zona 1 (Sierra)")
  (setq zona-opc (getint "\nOpción: "))
  
  (cond
    ((= zona-opc 1) (setq Z 0.4))
    ((= zona-opc 2) (setq Z 0.2))
    (T (setq Z 0.1))
  )
  
  ;; Uso
  (princ "\nTipo de edificio:")
  (princ "\n1. Común (U=1.0)")
  (princ "\n2. Esencial (U=1.5)")
  (princ "\n3. Peligroso (U=1.3)")
  (setq uso-opc (getint "\nOpción: "))
  
  (cond
    ((= uso-opc 2) (setq U 1.5))
    ((= uso-opc 3) (setq U 1.3))
    (T (setq U 1.0))
  )
  
  ;; Suelo
  (princ "\nTipo de suelo:")
  (princ "\n1. S1 - Rocoso (S=1.0)")
  (princ "\n2. S2 - Intermedio (S=1.2)")
  (princ "\n3. S3 - Flexible (S=1.4)")
  (princ "\n4. S4 - Muy flexible (S=1.8)")
  (setq suelo-opc (getint "\nOpción: "))
  
  (cond
    ((= suelo-opc 2) (setq S 1.2))
    ((= suelo-opc 3) (setq S 1.4))
    ((= suelo-opc 4) (setq S 1.8))
    (T (setq S 1.0))
  )
  
  ;; Sistema estructural
  (princ "\nSistema estructural:")
  (princ "\n1. Pórticos (R=8)")
  (princ "\n2. Muros (R=6)")
  (princ "\n3. Dual (R=7)")
  (setq sist-opc (getint "\nOpción: "))
  
  (cond
    ((= sist-opc 2) (setq R 6))
    ((= sist-opc 3) (setq R 7))
    (T (setq R 8))
  )
  
  ;; Período y coeficiente C
  (setq Tp (getreal "\nPeríodo fundamental T (seg) <0.5>: "))
  (if (null Tp) (setq Tp 0.5))
  
  ;; Tc según suelo
  (setq Tc (cond
    ((= S 1.0) 0.4)
    ((= S 1.2) 0.6)
    ((= S 1.4) 0.8)
    (T 1.0)
  ))
  
  ;; Coeficiente C
  (if (<= Tp Tc)
    (setq C 2.5)
    (setq C (/ 2.5 Tp))
  )
  (if (> C 2.5) (setq C 2.5))
  (if (< C 0.5) (setq C 0.5))
  
  ;; Peso de la edificación
  (setq peso (getreal "\nPeso sísmico total (ton): "))
  (if (null peso) (setq peso 100))
  
  ;; Corte basal
  (setq V (/ (* Z U S C) R))
  (setq corte-base (* V peso))
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nZona: " (rtos Z 2 2)))
  (princ (strcat "\nUso (U): " (rtos U 2 2)))
  (princ (strcat "\nSuelo (S): " (rtos S 2 2)))
  (princ (strcat "\nR: " (rtos R 2 0)))
  (princ (strcat "\nC: " (rtos C 2 3)))
  (princ (strcat "\nV = ZUSC/R: " (rtos V 2 3)))
  (princ (strcat "\nCorte basal: " (rtos corte-base 2 2) " ton"))
  
  T
)

;;; Función: CCP_disenar-zapata
;;; Diseña zapata según E.050
(defun CCP_disenar-zapata ( / Pu qa B L q-diseno)
  (princ "\n=== DISEÑO DE ZAPATA (E.050) ===\n")
  
  (setq Pu (getreal "\nCarga última Pu (kg): "))
  (setq qa (getreal "\nCapacidad portante σa (kg/cm²): "))
  
  (if (null Pu) (setq Pu 100000))
  (if (null qa) (setq qa 2.0))
  
  ;; Convertir qa a ton/m²
  (setq qa-tonm2 (* qa 10))
  
  ;; Área requerida
  (setq area-req (/ (/ Pu 1000) qa-tonm2))  ; Pu en ton
  
  ;; Zapata cuadrada
  (setq B (sqrt area-req))
  (setq B (* (fix (+ B 0.9)) 0.1))  ; Redondear a 10cm
  
  (setq L B)  ; Zapata cuadrada
  (setq area-real (* B L))
  
  ;; Presión de contacto
  (setq q-diseno (/ (/ Pu 1000) area-real))
  
  ;; Espesor mínimo
  (setq h-min 0.40)  ; 40cm mínimo
  
  (princ "\n\n=== RESULTADOS ===")
  (princ (strcat "\nDimensiones: " (rtos (* B 100) 2 0) 
                 " x " (rtos (* L 100) 2 0) " cm"))
  (princ (strcat "\nEspesor mínimo: " (rtos h-min 2 2) " m"))
  (princ (strcat "\nPresión de contacto: " (rtos q-diseno 2 2) " ton/m²"))
  (princ (strcat "\nCapacidad portante: " (rtos qa-tonm2 2 1) " ton/m²"))
  
  (if (<= q-diseno qa-tonm2)
    (princ "\n✓ Zapata satisface capacidad portante")
    (princ "\n[ADVERTENCIA] Revisar dimensiones")
  )
  
  T
)

(princ "\n[ESTRUCTURAS] Módulo Estructuras cargado.")
(princ)
