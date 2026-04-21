;;; ============================================================================
;;; CIVILCAD-PERÚ - TEST RUNNER
;;; Sistema de pruebas y validación
;;; ============================================================================

(setq *CCP_TEST_VERSION* "1.0.0")
(setq *CCP_TEST_RESULTS* nil)
(setq *CCP_TEST_PASSED* 0)
(setq *CCP_TEST_FAILED* 0)

;;; Función: CCP_test-runner
;;; Ejecuta todas las pruebas del sistema
(defun CCP_test-runner ()
  (princ "\n\n========================================")
  (princ "\nCIVILCAD-PERÚ - TEST RUNNER")
  (princ "========================================\n")
  
  ;; Resetear contadores
  (setq *CCP_TEST_PASSED* 0)
  (setq *CCP_TEST_FAILED* 0)
  (setq *CCP_TEST_RESULTS* nil)
  
  ;; Ejecutar pruebas
  (CCP_test-utils)
  (CCP_test-topo)
  (CCP_test-carreteras)
  (CCP_test-saneamiento)
  (CCP_test-estructuras)
  (CCP_test-normativa)
  
  ;; Mostrar resultados
  (princ "\n\n========================================")
  (princ "\nRESULTADOS DE PRUEBAS")
  (princ "========================================")
  (princ (strcat "\nPASADAS:  " (itoa *CCP_TEST_PASSED*)))
  (princ (strcat "\nFALLIDAS: " (itoa *CCP_TEST_FAILED*)))
  (princ (strcat "\nTOTAL:    " (itoa (+ *CCP_TEST_PASSED* *CCP_TEST_FAILED*))))
  (princ "\n========================================\n")
  
  (list
    (cons 'passed *CCP_TEST_PASSED*)
    (cons 'failed *CCP_TEST_FAILED*)
    (cons 'total (+ *CCP_TEST_PASSED* *CCP_TEST_FAILED*))
  )
)

;;; Función auxiliar para tests
(defun CCP_test-assert (condition test-name / )
  (if condition
    (progn
      (princ (strcat "\n[PASS] " test-name))
      (setq *CCP_TEST_PASSED* (1+ *CCP_TEST_PASSED*))
      T
    )
    (progn
      (princ (strcat "\n[FAIL] " test-name))
      (setq *CCP_TEST_FAILED* (1+ *CCP_TEST_FAILED*))
      nil
    )
  )
)

;;; Pruebas de utilidades
(defun CCP_test-utils ()
  (princ "\n\n--- PRUEBAS DE UTILIDADES ---")
  
  ;; Test parse CSV
  (setq result (CCP-parse-csv-line "1,2,3,4"))
  (CCP_test-assert (= (length result) 4) "Parse CSV simple")
  
  ;; Test trim
  (setq result (CCP-trim "  hello  "))
  (CCP_test-assert (= result "hello") "Trim string")
  
  ;; Test to-real
  (setq result (CCP-to-real "123.456"))
  (CCP_test-assert (= result 123.456) "String to real")
  
  ;; Test distance 2D
  (setq result (CCP-distance-2d '(0 0) '(3 4)))
  (CCP_test-assert (= result 5.0) "Distance 2D (3-4-5)")
  
  ;; Test midpoint
  (setq result (CCP-midpoint '(0 0) '(10 10)))
  (CCP_test-assert (and (= (car result) 5.0) (= (cadr result) 5.0)) "Midpoint")
  
  ;; Test clamp
  (setq result (CCP-clamp 15 0 10))
  (CCP_test-assert (= result 10) "Clamp max")
  
  (setq result (CCP-clamp -5 0 10))
  (CCP_test-assert (= result 0) "Clamp min")
)

;;; Pruebas de topografía
(defun CCP_test-topo ()
  (princ "\n\n--- PRUEBAS DE TOPOGRAFÍA ---")
  
  ;; Test validación UTM Perú
  (setq result (CCP-validate-utm-peru 500000 9000000))
  (CCP_test-assert (car result) "UTM Perú válido")
  
  ;; Test zona UTM
  (setq zone (CCP-utm-zone-from-coord 300000))
  (CCP_test-assert (= zone "17S") "Zona UTM 17S")
  
  (setq zone (CCP-utm-zone-from-coord 500000))
  (CCP_test-assert (= zone "18S") "Zona UTM 18S")
  
  (setq zone (CCP-utm-zone-from-coord 750000))
  (CCP_test-assert (= zone "19S") "Zona UTM 19S")
  
  ;; Test bearing-distance
  (setq result (CCP-calculate-bearing-distance '(0 0) '(100 100)))
  (CCP_test-assert (> (car result) 140) "Bearing distance calculation")
  
  ;; Test área polígono
  (setq pts '((0 0) (10 0) (10 10) (0 10)))
  (setq area (CCP-calculate-area-polygon pts))
  (CCP_test-assert (= area 100.0) "Área cuadrado 10x10")
  
  ;; Test perímetro
  (setq perim (CCP-calculate-perimeter pts))
  (CCP_test-assert (= perim 40.0) "Perímetro cuadrado 10x10")
  
  ;; Test pendiente
  (setq slope (CCP-slope-percent '(0 0) 100 '(100 0) 105))
  (CCP_test-assert (= slope 5.0) "Pendiente 5%")
)

;;; Pruebas de carreteras
(defun CCP_test-carreteras ()
  (princ "\n\n--- PRUEBAS DE CARRETERAS ---")
  
  ;; Test radio mínimo DG-1999
  (setq radio (CCP-get-norma-value 'DG_1999 'radio-min-60kmh))
  (CCP_test-assert (and radio (> radio 0)) "Radio mínimo 60 km/h")
  
  ;; Test visibilidad
  (setq vis (CCP-get-norma-value 'DG_1999 'visibilidad-parada-80kmh))
  (CCP_test-assert (and vis (> vis 0)) "Visibilidad parada 80 km/h")
  
  ;; Test peralte máximo
  (setq emp (CCP-get-norma-value 'DG_1999 'peralte-max-rural))
  (CCP_test-assert (and emp (> emp 0)) "Peralte máximo rural")
)

;;; Pruebas de saneamiento
(defun CCP_test-saneamiento ()
  (princ "\n\n--- PRUEBAS DE SANEAMIENTO ---")
  
  ;; Test Manning PVC
  (setq n (CCP-get-norma-value 'SANEAMIENTO 'manning-pvc))
  (CCP_test-assert (= n 0.009) "Manning PVC")
  
  ;; Test Hazen-Williams
  (setq C (CCP-get-norma-value 'SANEAMIENTO 'hazen-williams-pvc))
  (CCP_test-assert (= C 150) "Hazen-Williams PVC")
  
  ;; Test velocidad mínima
  (setq vmin (CCP-get-norma-value 'SANEAMIENTO 'velocidad-minima))
  (CCP_test-assert (= vmin 0.60) "Velocidad mínima colector")
  
  ;; Test DOT
  (setq dot (CCP-get-norma-value 'SANEAMIENTO 'dot-vivienda))
  (CCP_test-assert (= dot 5.5) "DOT vivienda")
)

;;; Pruebas de estructuras
(defun CCP_test-estructuras ()
  (princ "\n\n--- PRUEBAS DE ESTRUCTURAS ---")
  
  ;; Test RNE E.020
  (setq cv (CCP-get-norma-value 'RNE_E020 'carga-viva-vivienda))
  (CCP_test-assert (= cv 200) "Carga viva vivienda E.020")
  
  ;; Test RNE E.030
  (setq z (CCP-get-norma-value 'RNE_E030 'zona-3-U))
  (CCP_test-assert (= z 0.4) "Factor Z zona 3 E.030")
  
  ;; Test RNE E.050
  (setq cp (CCP-get-norma-value 'RNE_E050 'capacidad-portante-roca))
  (CCP_test-assert (= cp 5000) "Capacidad portante roca E.050")
  
  ;; Test RNE E.060
  (setq fc (CCP-get-norma-value 'RNE_E060 'fc-usual))
  (CCP_test-assert (= fc 210) "f'c usual E.060")
  
  ;; Test recubrimientos
  (setq rec (CCP-get-norma-value 'RNE_E060 'recubrimiento-zapata))
  (CCP_test-assert (= rec 7.5) "Recubrimiento zapata E.060")
)

;;; Pruebas de normativa
(defun CCP_test-normativa ()
  (princ "\n\n--- PRUEBAS DE NORMATIVA ---")
  
  ;; Test existencia de normas
  (CCP_test-assert (boundp '*CCP_RNE_E020*) "RNE E.020 cargada")
  (CCP_test-assert (boundp '*CCP_RNE_E030*) "RNE E.030 cargada")
  (CCP_test-assert (boundp '*CCP_RNE_E050*) "RNE E.050 cargada")
  (CCP_test-assert (boundp '*CCP_RNE_E060*) "RNE E.060 cargada")
  (CCP_test-assert (boundp '*CCP_DG_1999*) "DG-1999 cargada")
  (CCP_test-assert (boundp '*CCP_TOPO_PERU*) "Topo Perú cargada")
  (CCP_test-assert (boundp '*CCP_SANEAMIENTO_MVCS*) "Saneamiento MVCS cargado")
  
  ;; Test zonas UTM Perú
  (setq utm17 (CDR (assoc 'utm-17s *CCP_TOPO_PERU*)))
  (CCP_test-assert utm17 "Zona UTM 17S definida")
  
  (setq utm18 (CDR (assoc 'utm-18s *CCP_TOPO_PERU*)))
  (CCP_test-assert utm18 "Zona UTM 18S definida")
  
  (setq utm19 (CDR (assoc 'utm-19s *CCP_TOPO_PERU*)))
  (CCP_test-assert utm19 "Zona UTM 19S definida")
)

(princ "\n[TEST] Test runner cargado.")
(princ)
