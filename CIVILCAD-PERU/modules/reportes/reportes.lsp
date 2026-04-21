;;; ============================================================================
;;; CIVILCAD-PERÚ - MÓDULO DE REPORTES
;;; Generación de reportes y memorias
;;; ============================================================================

;;; Variables globales del módulo
(setq *CCP_REPORTES_VERSION* "1.0.0")
(setq *CCP_REPORTE_DATA* nil)

;;; ============================================================================
;;; FUNCIONES DEL CONTRATO DE MÓDULOS
;;; ============================================================================

;;; Función: CCP_MOD_REPORTES_INIT
;;; Inicializa el módulo de reportes
(defun CCP_MOD_REPORTES_INIT ()
  (princ "\n[REPORTES] Inicializando módulo de Reportes...")
  
  ;; Configurar layers para textos
  (CCP-create-layer "REPORTE-TEXTO" 7 "Continuous")
  (CCP-create-layer "REPORTE-TABLA" 8 "Continuous")
  
  ;; Resetear datos
  (setq *CCP_REPORTE_DATA* nil)
  
  (CCP-log-module-start "Reportes")
  (princ "\n[REPORTES] Módulo inicializado correctamente.")
  T
)

;;; Función: CCP_MOD_REPORTES_RUN
;;; Ejecuta el módulo principal de reportes
(defun CCP_MOD_REPORTES_RUN ()
  (princ "\n[REPORTES] Ejecutando funciones de reportes...")
  
  (princ "\n\n=== REPORTES ===")
  (princ "\n1. Generar memoria descriptiva")
  (princ "\n2. Exportar tabla de puntos")
  (princ "\n3. Cuadro de áreas")
  (princ "\n4. Reporte técnico (TXT)")
  (princ "\n5. Salir")
  
  (princ "\nSeleccione opción: ")
  (setq opcion (getint))
  
  (cond
    ((= opcion 1)
      (CCP_memoria-descriptiva)
    )
    ((= opcion 2)
      (CCP-exportar-puntos)
    )
    ((= opcion 3)
      (CCP-cuadro-areas)
    )
    ((= opcion 4)
      (CCP-reporte-tecnico)
    )
    (T
      (princ "\n[REPORTES] Operación cancelada.")
    )
  )
  
  (CCP-log-module-end "Reportes" T)
  T
)

;;; Función: CCP_MOD_REPORTES_ERROR
;;; Manejador de errores del módulo
(defun CCP_MOD_REPORTES_ERROR (error-msg)
  (princ (strcat "\n[REPORTES] ERROR: " error-msg))
  (CCP-log-event 'error (strcat "Error en Reportes: " error-msg))
  nil
)

;;; ============================================================================
;;; FUNCIONES PRINCIPALES
;;; ============================================================================

;;; Función: CCP_memoria-descriptiva
;;; Genera memoria descriptiva en el dibujo
(defun CCP_memoria-descriptiva ( / pt proyecto cliente fecha texto lines i)
  (princ "\n=== MEMORIA DESCRIPTIVA ===\n")
  
  ;; Solicitar datos del proyecto
  (setq proyecto (getstring "\nNombre del proyecto: "))
  (setq cliente (getstring "\nCliente: "))
  (setq ubicacion (getstring "\nUbicación: "))
  (setq ingeniero (getstring "\nIngeniero responsable: "))
  (setq colegiatura (getstring "\nN° Colegiatura: "))
  
  (if (null proyecto) (setq proyecto "PROYECTO SIN NOMBRE"))
  
  ;; Punto de inserción
  (setq pt (getpoint "\nPunto de inserción: "))
  
  (if (null pt)
    (setq pt (list 0 0 0))
  )
  
  ;; Fecha actual
  (setq fecha (CCP-get-timestamp))
  
  ;; Construir texto de memoria
  (setq lines (list
    "========================================"
    "       MEMORIA DESCRIPTIVA"
    "========================================"
    ""
    (strcat "PROYECTO: " proyecto)
    (strcat "CLIENTE: " cliente)
    (strcat "UBICACIÓN: " ubicacion)
    ""
    "----------------------------------------"
    "         DATOS TÉCNICOS"
    "----------------------------------------"
    ""
    (strcat "Elaborado por: " ingeniero)
    (strcat "CIP N°: " colegiatura)
    (strcat "Fecha: " fecha)
    ""
    "----------------------------------------"
    "             NOTAS"
    "----------------------------------------"
    ""
    "1. Este documento es parte integral del proyecto."
    "2. Las cotas están referidas al nivel del mar."
    "3. Sistema de coordenadas: UTM WGS84."
    "4. Unidades: Sistema Métrico Decimal."
    ""
    "========================================"
  ))
  
  ;; Insertar texto en AutoCAD
  (CCP-set-current-layer "REPORTE-TEXTO")
  
  (setq y-pt (cadr pt))
  (foreach line lines
    (command "_.TEXT" 
             (list (car pt) y-pt 0)
             3.0
             0
             line)
    (setq y-pt (- y-pt 4.0))
  )
  
  (princ "\n\n[REPORTES] Memoria descriptiva insertada.")
  
  T
)

;;; Función: CCP-exportar-puntos
;;; Exporta tabla de puntos al dibujo
(defun CCP-exportar-puntos ( / pt y-pt header col-width)
  (princ "\n=== EXPORTAR TABLA DE PUNTOS ===\n")
  
  ;; Verificar si hay puntos
  (if (or (null *CCP_PUNTOS*) (= (length *CCP_PUNTOS*) 0))
    (progn
      (princ "\n[REPORTES] No hay puntos para exportar.")
      (princ "\nPrimero importe puntos usando el módulo de Topografía.")
      nil
    )
    (progn
      (setq pt (getpoint "\nPunto de inserción de tabla: "))
      
      (if (null pt)
        (setq pt (list 0 0 0))
      )
      
      (CCP-set-current-layer "REPORTE-TABLA")
      
      ;; Encabezados
      (setq col-width 15)
      (setq y-pt (cadr pt))
      
      ;; Dibujar encabezado
      (command "_.TEXT" (list (car pt) y-pt 0) 2.5 0 "PUNTO")
      (command "_.TEXT" (list (+ (car pt) col-width) y-pt 0) 2.5 0 "ESTE (m)")
      (command "_.TEXT" (list (+ (car pt) (* 2 col-width)) y-pt 0) 2.5 0 "NORTE (m)")
      (command "_.TEXT" (list (+ (car pt) (* 3 col-width)) y-pt 0) 2.5 0 "COTA (m)")
      (command "_.TEXT" (list (+ (car pt) (* 4 col-width)) y-pt 0) 2.5 0 "DESCRIPCIÓN")
      
      (setq y-pt (- y-pt 5.0))
      
      ;; Línea separadora
      (command "_.LINE" 
               (list (car pt) y-pt 0)
               (list (+ (car pt) (* 5 col-width)) y-pt 0)
               "")
      
      (setq y-pt (- y-pt 5.0))
      
      ;; Datos de puntos
      (foreach pto *CCP_PUNTOS*
        (setq num-punto (itoa (1+ (nth 0 pto))))
        (setq este (rtos (nth 1 pto) 2 4))
        (setq norte (rtos (nth 2 pto) 2 4))
        (setq cota (rtos (nth 3 pto) 2 3))
        (setq desc (if (nth 4 pto) (nth 4 pto) "-"))
        
        (command "_.TEXT" (list (car pt) y-pt 0) 2.5 0 num-punto)
        (command "_.TEXT" (list (+ (car pt) col-width) y-pt 0) 2.5 0 este)
        (command "_.TEXT" (list (+ (car pt) (* 2 col-width)) y-pt 0) 2.5 0 norte)
        (command "_.TEXT" (list (+ (car pt) (* 3 col-width)) y-pt 0) 2.5 0 cota)
        (command "_.TEXT" (list (+ (car pt) (* 4 col-width)) y-pt 0) 2.5 0 desc)
        
        (setq y-pt (- y-pt 4.0))
      )
      
      (princ (strcat "\n\n[REPORTES] Tabla con " 
                     (itoa (length *CCP_PUNTOS*)) " puntos exportada."))
      
      T
    )
  )
)

;;; Función: CCP-cuadro-areas
;;; Genera cuadro de áreas
(defun CCP-cuadro-areas ( / ss ent area perimeter pt y-pt)
  (princ "\n=== CUADRO DE ÁREAS ===\n")
  
  (princ "\nSeleccione polilíneas para calcular áreas: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYGON"))))
  
  (if (not ss)
    (progn
      (princ "\n[REPORTES] No se seleccionaron entidades.")
      nil
    )
    (progn
      (setq pt (getpoint "\nPunto de inserción del cuadro: "))
      
      (if (null pt)
        (setq pt (list 0 0 0))
      )
      
      (CCP-set-current-layer "REPORTE-TABLA")
      
      ;; Título
      (command "_.TEXT" (list (car pt) (+ (cadr pt) 10) 0) 4.0 0 "CUADRO DE ÁREAS")
      
      (setq y-pt (cadr pt))
      
      ;; Encabezados
      (command "_.TEXT" (list (car pt) y-pt 0) 2.5 0 "LOTE")
      (command "_.TEXT" (list (+ (car pt) 20) y-pt 0) 2.5 0 "ÁREA (m²)")
      (command "_.TEXT" (list (+ (car pt) 50) y-pt 0) 2.5 0 "ÁREA (ha)")
      (command "_.TEXT" (list (+ (car pt) 80) y-pt 0) 2.5 0 "PERÍMETRO (m)")
      
      (setq y-pt (- y-pt 5.0))
      (setq lote 1)
      (setq total-area 0)
      
      ;; Procesar cada entidad
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq area (CCP-get-area ent))
        (setq perimeter (CCP-get-perimeter ent))
        
        (command "_.TEXT" (list (car pt) y-pt 0) 2.5 0 (itoa lote))
        (command "_.TEXT" (list (+ (car pt) 20) y-pt 0) 2.5 0 (rtos area 2 2))
        (command "_.TEXT" (list (+ (car pt) 50) y-pt 0) 2.5 0 (rtos (/ area 10000.0) 2 4))
        (command "_.TEXT" (list (+ (car pt) 80) y-pt 0) 2.5 0 (rtos perimeter 2 2))
        
        (setq total-area (+ total-area area))
        (setq y-pt (- y-pt 4.0))
        (setq lote (1+ lote))
        (setq i (1+ i))
      )
      
      ;; Total
      (setq y-pt (- y-pt 3.0))
      (command "_.LINE" 
               (list (car pt) y-pt 0)
               (list (+ (car pt) 120) y-pt 0)
               "")
      (setq y-pt (- y-pt 5.0))
      
      (command "_.TEXT" (list (car pt) y-pt 0) 3.0 0 "TOTAL:")
      (command "_.TEXT" (list (+ (car pt) 20) y-pt 0) 3.0 0 (rtos total-area 2 2))
      (command "_.TEXT" (list (+ (car pt) 50) y-pt 0) 3.0 0 (rtos (/ total-area 10000.0) 2 4))
      
      (princ (strcat "\n\n[REPORTES] Cuadro generado con " 
                     (itoa (sslength ss)) " lotes."))
      (princ (strcat "\nÁrea total: " (rtos total-area 2 2) " m²"))
      (princ (strcat " (" (rtos (/ total-area 10000.0) 2 4) " ha)"))
      
      T
    )
  )
)

;;; Función: CCP-reporte-tecnico
;;; Genera reporte técnico en archivo TXT
(defun CCP-reporte-tecnico ( / filepath f)
  (princ "\n=== REPORTE TÉCNICO (TXT) ===\n")
  
  (setq filepath (getfiled "Guardar reporte como" "" "txt" 1))
  
  (if (not filepath)
    (progn
      (princ "\n[REPORTES] No se seleccionó archivo.")
      nil
    )
    (progn
      (setq f (open filepath "w"))
      
      (if (not f)
        (progn
          (princ "\n[REPORTES] ERROR: No se pudo crear el archivo.")
          nil
        )
        (progn
          ;; Escribir contenido
          (write-line "CIVILCAD-PERÚ - REPORTE TÉCNICO" f)
          (write-line "=================================" f)
          (write-line (strcat "Fecha: " (CCP-get-timestamp)) f)
          (write-line "")
          
          ;; Información del dibujo
          (write-line "INFORMACIÓN DEL DIBUJO:" f)
          (write-line (strcat "  Archivo: " (getvar "DWGNAME")) f)
          (write-line (strcat "  Ruta: " (getvar "DWGPREFIX")) f)
          (write-line "")
          
          ;; Puntos importados
          (write-line "PUNTOS TOPOGRÁFICOS:" f)
          (if (and *CCP_PUNTOS* (> (length *CCP_PUNTOS*) 0))
            (progn
              (write-line (strcat "  Total: " (itoa (length *CCP_PUNTOS*)) " puntos") f)
              (foreach pto *CCP_PUNTOS*
                (write-line (strcat "  P" (itoa (1+ (nth 0 pto))) 
                                    ": E=" (rtos (nth 1 pto) 2 4)
                                    ", N=" (rtos (nth 2 pto) 2 4)
                                    ", Z=" (rtos (nth 3 pto) 2 3)) f)
              )
            )
            (write-line "  No hay puntos importados." f)
          )
          (write-line "")
          
          ;; Cierre
          (write-line "=================================" f)
          (write-line "Fin del reporte" f)
          
          (close f)
          
          (princ (strcat "\n\n[REPORTES] Reporte guardado en: " filepath))
          
          T
        )
      )
    )
  )
)

(princ "\n[REPORTES] Módulo Reportes cargado.")
(princ)
