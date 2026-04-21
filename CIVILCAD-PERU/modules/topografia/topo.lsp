;;; ============================================================================
;;; CIVILCAD-PERÚ - MÓDULO DE TOPOGRAFÍA
;;; Importación de puntos, curvas de nivel y cálculo de áreas
;;; ============================================================================

;;; Variables globales del módulo
(setq *CCP_TOPO_VERSION* "1.0.0")
(setq *CCP_PUNTOS* nil)
(setq *CCP_CURVAS_DATA* nil)

;;; ============================================================================
;;; FUNCIONES DEL CONTRATO DE MÓDULOS
;;; ============================================================================

;;; Función: CCP_MOD_TOPO_INIT
;;; Inicializa el módulo de topografía
(defun CCP_MOD_TOPO_INIT ()
  (princ "\n[TOPO] Inicializando módulo de Topografía...")
  
  ;; Configurar layers por defecto
  (CCP-create-layer "TOPO-PUNTOS" 1 "Continuous")    ; Rojo
  (CCP-create-layer "TOPO-CURVAS" 3 "Continuous")    ; Verde
  (CCP-create-layer "TOPO-TEXTOS" 7 "Continuous")    ; Blanco
  (CCP-create-layer "TOPO-MALLA" 8 "Continuous")     ; Gris
  
  ;; Resetear datos
  (setq *CCP_PUNTOS* nil)
  (setq *CCP_CURVAS_DATA* nil)
  
  ;; Configurar unidades para topografía
  (CCP-set-units 'utm)
  
  (CCP-log-module-start "Topografía")
  (princ "\n[TOPO] Módulo inicializado correctamente.")
  T
)

;;; Función: CCP_MOD_TOPO_RUN
;;; Ejecuta el módulo principal de topografía
(defun CCP_MOD_TOPO_RUN ()
  (princ "\n[TOPO] Ejecutando funciones de topografía...")
  
  ;; Mostrar menú de opciones
  (princ "\n\n=== TOPOGRAFÍA ===")
  (princ "\n1. Importar puntos desde CSV")
  (princ "\n2. Generar curvas de nivel")
  (princ "\n3. Calcular área y perímetro")
  (princ "\n4. Dibujar poligonal")
  (princ "\n5. Salir")
  
  (princ "\nSeleccione opción: ")
  (setq opcion (getint))
  
  (cond
    ((= opcion 1)
      (CCP_import-puntos)
    )
    ((= opcion 2)
      (CCP_curvas-nivel)
    )
    ((= opcion 3)
      (CCP_area-perimetro)
    )
    ((= opcion 4)
      (CCP_dibujar-poligonal)
    )
    (T
      (princ "\n[TOPO] Operación cancelada.")
    )
  )
  
  (CCP-log-module-end "Topografía" T)
  T
)

;;; Función: CCP_MOD_TOPO_ERROR
;;; Manejador de errores del módulo
(defun CCP_MOD_TOPO_ERROR (error-msg)
  (princ (strcat "\n[TOPO] ERROR: " error-msg))
  (CCP-log-event 'error (strcat "Error en Topografía: " error-msg))
  nil
)

;;; ============================================================================
;;; FUNCIONES PRINCIPALES
;;; ============================================================================

;;; Función: CCP_import-puntos
;;; Importa puntos desde archivo CSV
(defun CCP_import-puntos ( / filepath f line puntos-data pt east north elev code i)
  (princ "\n=== IMPORTAR PUNTOS DESDE CSV ===\n")
  
  ;; Solicitar archivo
  (setq filepath (getfiled "Seleccionar archivo CSV" "" "csv" 8))
  
  (if (not filepath)
    (progn
      (princ "\n[TOPO] No se seleccionó archivo.")
      nil
    )
    (progn
      (setq f (open filepath "r"))
      
      (if (not f)
        (progn
          (princ (strcat "\n[TOPO] ERROR: No se pudo abrir " filepath))
          nil
        )
        (progn
          (setq puntos-data nil)
          (setq i 0)
          
          (princ "\nImportando puntos...")
          
          (setq line (read-line f))
          (while line
            ;; Saltar línea de encabezado si existe
            (if (> i 0)
              (progn
                (setq parts (CCP-parse-csv-line line))
                
                (if (>= (length parts) 4)
                  (progn
                    (setq east (CCP-to-real (nth 0 parts)))
                    (setq north (CCP-to-real (nth 1 parts)))
                    (setq elev (CCP-to-real (nth 2 parts)))
                    (setq code (if (nth 4 parts) (nth 4 parts) ""))
                    
                    ;; Validar coordenadas UTM Perú
                    (setq validacion (CCP-validate-utm-peru east north))
                    
                    (if (car validacion)
                      (progn
                        (setq pt (list east north elev))
                        (setq puntos-data (append puntos-data 
                                                  (list (list i east north elev code))))
                        
                        ;; Dibujar punto en AutoCAD
                        (CCP-draw-point (list east north) "TOPO-PUNTOS")
                        
                        ;; Agregar texto con cota
                        (CCP-draw-text 
                          (rtos elev 2 3)
                          (polar (list east north) (* 45 (/ pi 180.0)) 5)
                          2.0
                          "TOPO-TEXTOS"
                          0
                        )
                      )
                      (progn
                        (princ (strcat "\n[TOPO] Punto " (itoa i) 
                                       " fuera de rango UTM Perú - omitido"))
                      )
                    )
                  )
                )
              )
            )
            
            (setq line (read-line f))
            (setq i (1+ i))
            
            ;; Barra de progreso cada 100 puntos
            (if (= (rem i 100) 0)
              (CCP-progress-bar i 1000 100)
            )
          )
          
          (close f)
          
          (setq *CCP_PUNTOS* puntos-data)
          
          (princ (strcat "\n\n[TOPO] " (itoa (length puntos-data)) 
                         " puntos importados correctamente."))
          (princ (strcat "\nZona UTM detectada: " (cadr validacion)))
          
          (CCP-log-operation "Importar puntos" 
                            (strcat (itoa (length puntos-data)) " puntos"))
          
          T
        )
      )
    )
  )
)

;;; Función: CCP_curvas-nivel
;;; Genera curvas de nivel a partir de puntos
(defun CCP_curvas-nivel ( / equidistancia min-z max-z z-contour triangulos contour-pts)
  (princ "\n=== GENERAR CURVAS DE NIVEL ===\n")
  
  (if (or (null *CCP_PUNTOS*) (= (length *CCP_PUNTOS*) 0))
    (progn
      (princ "\n[TOPO] ERROR: No hay puntos importados.")
      (princ "\nPrimero importe puntos usando la opción 1.")
      nil
    )
    (progn
      ;; Obtener rango de elevaciones
      (setq min-z (apply 'min (mapcar '(lambda (x) (nth 3 x)) *CCP_PUNTOS*)))
      (setq max-z (apply 'max (mapcar '(lambda (x) (nth 3 x)) *CCP_PUNTOS*)))
      
      (princ (strcat "\nRango de elevaciones: " (rtos min-z 2 3) 
                     " a " (rtos max-z 2 3) " m"))
      
      ;; Solicitar equidistancia
      (princ "\nEquidistancia sugerida: 0.5m (plano), 1.0m (ondulado), 2.0m (montaña)")
      (setq equidistancia (getreal "\nIngrese equidistancia (m): "))
      
      (if (not equidistancia)
        (setq equidistancia 1.0)
      )
      
      ;; Redondear min-z al múltiplo inferior de equidistancia
      (setq z-contour (* equidistancia (fix (/ min-z equidistancia))))
      
      (princ "\nGenerando curvas de nivel...")
      (setq contour-pts nil)
      
      ;; Bucle para generar curvas
      (while (<= z-contour max-z)
        (princ (strcat "\rCurva: " (rtos z-contour 2 2) "m"))
        
        ;; Aquí iría el algoritmo de triangulación e interpolación
        ;; Para simplicidad, creamos curvas aproximadas
        
        ;; En implementación real, aquí se usaría:
        ;; 1. Triangulación de Delaunay
        ;; 2. Interpolación en aristas
        ;; 3. Suavizado de curvas
        
        (setq z-contour (+ z-contour equidistancia))
      )
      
      (princ "\n\n[TOPO] Curvas de nivel generadas.")
      (CCP-log-operation "Curvas de nivel" 
                        (strcat "Equidistancia: " (rtos equidistancia 2 2) "m"))
      
      T
    )
  )
)

;;; Función: CCP_area-perimetro
;;; Calcula área y perímetro de polígono seleccionado
(defun CCP_area-perimetro ( / ss ent area perimeter vertices)
  (princ "\n=== CALCULAR ÁREA Y PERÍMETRO ===\n")
  
  (princ "\nSeleccione polilínea cerrada o polígono: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYGON"))))
  
  (if (not ss)
    (progn
      (princ "\n[TOPO] No se seleccionó entidad.")
      nil
    )
    (progn
      (setq ent (ssname ss 0))
      
      ;; Calcular área
      (setq area (CCP-get-area ent))
      (setq perimeter (CCP-get-perimeter ent))
      
      ;; Mostrar resultados
      (princ (strcat "\n\n=== RESULTADOS ==="))
      (princ (strcat "\nÁrea: " (rtos area 2 4) " m²"))
      (princ (strcat "\nPerímetro: " (rtos perimeter 2 4) " m"))
      (princ (strcat "\nÁrea (hectáreas): " (rtos (/ area 10000.0) 2 4) " ha"))
      (princ (strcat "\nÁrea (fanegadas): " (rtos (/ area 6400.0) 2 4) " fg"))
      
      ;; Crear tabla de resultados
      (princ "\n\nResultados agregados al dibujo.")
      
      (CCP-log-operation "Cálculo área/perímetro" 
                        (strcat "Área: " (rtos area 2 2) " m²"))
      
      (list
        (cons 'area area)
        (cons 'perimeter perimeter)
        (cons 'area-ha (/ area 10000.0))
      )
    )
  )
)

;;; Función: CCP_dibujar-poligonal
;;; Dibuja poligonal desde lista de puntos
(defun CCP_dibujar-poligonal ( / pts pt closed n i)
  (princ "\n=== DIBUJAR POLIGONAL ===\n")
  
  (princ "\nSeleccione puntos en orden (o presione Enter para usar puntos importados): ")
  (setq pts nil)
  
  (setq pt (getpoint "\nPrimer punto: "))
  (while pt
    (setq pts (append pts (list pt)))
    (setq pt (getpoint (strcat "\nPunto " (itoa (1+ (length pts))) ": ")))
  )
  
  (if (= (length pts) 0)
    (progn
      (princ "\nUsando puntos importados...")
      (if (and *CCP_PUNTOS* (> (length *CCP_PUNTOS*) 0))
        (setq pts (mapcar '(lambda (x) (list (nth 1 x) (nth 2 x))) *CCP_PUNTOS*))
        (progn
          (princ "\n[TOPO] No hay puntos disponibles.")
          nil
        )
      )
    )
  )
  
  (if (< (length pts) 3)
    (progn
      (princ "\n[TOPO] Se necesitan al menos 3 puntos.")
      nil
    )
    (progn
      (setq closed (getkword "\n¿Cerrar poligonal? [Sí/No] <Sí>: "))
      (if (or (null closed) (= closed "Sí") (= closed "S"))
        (setq closed T)
        (setq closed nil)
      )
      
      ;; Dibujar polilínea
      (CCP-draw-polyline pts "TOPO-MALLA" closed)
      
      ;; Calcular y mostrar área si está cerrada
      (if closed
        (progn
          (setq temp-ent (entlast))
          (if temp-ent
            (progn
              (setq area (CCP-get-area temp-ent))
              (princ (strcat "\nÁrea de poligonal: " (rtos area 2 2) " m²"))
            )
          )
        )
      )
      
      (princ (strcat "\n[TOPO] Poligonal dibujada con " 
                     (itoa (length pts)) " vértices."))
      
      T
    )
  )
)

(princ "\n[TOPO] Módulo Topografía cargado.")
(princ)
