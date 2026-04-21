;;; ============================================================================
;;; LISP: Diseño de Alineamiento Horizontal (Curvas Circulares Simples)
;;; Módulo: DRV_ALINEAMIENTO
;;; Nivel: Profesional (Estilo CivilCAD)
;;; ============================================================================

(vl-load-com)

;; Variables globales para el estado del diálogo
(setq *uchi-alin-data* nil)
(setq *uchi-alin-pis* '()) ;; Lista de PIs: ((nombre N E Elev) ...)
(setq *uchi-alin-curva-actual* nil)

;;; -----------------------------------------------------------------------------
;;; FUNCIONES MATEMÁTICAS Y GEOMÉTRICAS
;;; -----------------------------------------------------------------------------

(defun uchi:deg-to-rad (ang)
  "Convierte grados decimales a radianes"
  (* ang (/ pi 180.0))
)

(defun uchi:rad-to-deg (ang)
  "Convierte radianes a grados decimales"
  (* ang (/ 180.0 pi))
)

(defun uchi:decimal-to-ddms (dec)
  "Convierte grados decimales a formato D-D-M-S (ej. 123.4567 -> \"123-27-24\")"
  (if (null dec)
    "00-00-00"
    (progn
      (setq d (fix dec))
      (setq m (fix (* (- dec d) 60.0)))
      (setq s (rtos (* (- (* (- dec d) 60.0) m) 60.0) 2 0))
      (if (< m 10) (setq m (strcat "0" (itoa m))))
      (if (< s 10) (setq s (strcat "0" s)))
      (strcat (itoa d) "-" m "-" s)
    )
  )
)

(defun uchi:distancia-2p (p1 p2)
  "Calcula distancia entre dos puntos 2D"
  (distance p1 p2)
)

(defun uchi:angulo-2p (p1 p2)
  "Calcula ángulo entre dos puntos en radianes"
  (angle p1 p2)
)

;;; -----------------------------------------------------------------------------
;;; CÁLCULO DE ELEMENTOS DE CURVA CIRCULAR SIMPLE
;;; -----------------------------------------------------------------------------

(defun uchi:calcular-elementos-curva (radio deflexion-rad)
  "Calcula todos los elementos de una curva circular simple dado Radio y Deflexión"
  (if (or (<= radio 0) (<= deflexion-rad 0))
    nil
    (list
      (cons 'tangente (* radio (tan (/ deflexion-rad 2.0))))
      (cons 'long_curva (* radio deflexion-rad))
      (cons 'cuerda_larga (* 2 radio (sin (/ deflexion-rad 2.0))))
      (cons 'externa (* radio (- (/ 1.0 (cos (/ deflexion-rad 2.0))) 1.0)))
      (cons 'ordenada_media (* radio (- 1.0 (cos (/ deflexion-rad 2.0)))))
    )
  )
)

(defun tan (x)
  "Función tangente"
  (/ (sin x) (cos x))
)

;;; -----------------------------------------------------------------------------
;;; GESTIÓN DE DATOS DE P.I.
;;; -----------------------------------------------------------------------------

(defun uchi:agregar-pi (nombre n e elev)
  "Agrega un PI a la lista global"
  (setq *uchi-alin-pis* 
    (append *uchi-alin-pis* (list (list nombre n e elev)))
  )
  (uchi:actualizar-lista-pis-dialog)
)

(defun uchi:eliminar-pi-index (index)
  "Elimina un PI por índice de lista"
  (if (and (>= index 0) (< index (length *uchi-alin-pis*)))
    (progn
      (setq *uchi-alin-pis* 
        (vl-remove-if-not 
          '(lambda(x) (/= (car (member x *uchi-alin-pis*)) (nth index *uchi-alin-pis*)))
          *uchi-alin-pis*
        )
      )
      ;; Reconstruir lista correctamente
      (setq new-list '())
      (foreach item *uchi-alin-pis*
        (if (/= (car item) (car (nth index (vl-sort *uchi-alin-pis* '(lambda(a b) (< (car a) (car b))))))
          (setq new-list (append new-list (list item)))
        )
      )
      ;; Método simplificado
      (setq *uchi-alin-pis* 
        (append 
          (vl-sublis (nth index *uchi-alin-pis*) '() *uchi-alin-pis*)
        )
      )
      (uchi:actualizar-lista-pis-dialog)
      t
    )
    nil
  )
)

(defun uchi:formato-fila-pi (pi-data)
  "Formatea datos de PI para mostrar en list_box"
  (if pi-data
    (strcat 
      (vl-princ-to-string (car pi-data)) "\t"
      (rtos (cadr pi-data) 2 3) "\t"
      (rtos (caddr pi-data) 2 3) "\t"
      (rtos (cadddr pi-data) 2 2)
    )
    ""
  )
)

;;; -----------------------------------------------------------------------------
;;; FUNCIONES DEL DIÁLOGO DCL
;;; -----------------------------------------------------------------------------

(defun c:UCHI_ALINEAMIENTO (/ dcl_id retval)
  "Comando principal para iniciar el diseño de alineamiento horizontal"
  (if (not (findfile "dcl_alineamiento.dcl"))
    (progn
      (alert "Error: No se encuentra el archivo dcl_alineamiento.dcl")
      (exit)
    )
  )
  
  ;; Cargar DCL
  (setq dcl_id (load_dialog "dcl_alineamiento.dcl"))
  (if (< dcl_id 0)
    (progn
      (alert "Error al cargar el archivo DCL")
      (exit)
    )
  )
  
  ;; Inicializar datos si es necesario
  (if (null *uchi-alin-pis*)
    (setq *uchi-alin-pis* '())
  )
  
  ;; Mostrar diálogo principal
  (if (not (new_dialog "UCHI_Alineamiento" dcl_id))
    (progn
      (unload_dialog dcl_id)
      (exit)
    )
  )
  
  ;; Configurar valores iniciales
  (set_tile "proyecto_nombre" (getvar "DWGNAME"))
  (set_tile "ingeniero_resp" (getenv "USERNAME"))
  (set_tile "velocidad_diseno" "60")
  (set_tile "radio_curva" "150.00")
  
  ;; Actualizar lista de PIs
  (uchi:actualizar-lista-pis-dialog)
  
  ;; Definir acciones de los tiles
  (uchi:definir-acciones-dialogo dcl_id)
  
  ;; Ejecutar diálogo
  (setq retval (start_dialog))
  
  ;; Limpiar
  (unload_dialog dcl_id)
  
  (if (= retval 1)
    (progn
      (princ "\nAlineamiento procesado correctamente.")
      (uchi:ejectar-dibujo-alineamiento)
    )
    (princ "\nComando cancelado.")
  )
  (princ)
)

(defun uchi:actualizar-lista-pis-dialog ()
  "Actualiza el list_box con los PIs definidos"
  (start_list "lista_pis")
  (mapcar 'add_list 
    (mapcar 'uchi:formato-fila-pi *uchi-alin-pis*)
  )
  (end_list)
)

(defun uchi:definir-acciones-dialogo (dcl_id)
  "Define las funciones callback para cada elemento del diálogo"
  
  ;; Botón Pick en Pantalla
  (action_tile "btn_pick_pi" 
    "(uchi:callback-pick-pi)"
  )
  
  ;; Botón Importar TXT/CSV
  (action_tile "btn_import_txt" 
    "(uchi:callback-importar-pis)"
  )
  
  ;; Botón Agregar Manual
  (action_tile "btn_agregar_pi" 
    "(uchi:callback-agregar-manual)"
  )
  
  ;; Botón Editar
  (action_tile "btn_editar_pi" 
    "(uchi:callback-editar-pi)"
  )
  
  ;; Botón Eliminar
  (action_tile "btn_eliminar_pi" 
    "(uchi:callback-eliminar-pi)"
  )
  
  ;; Cambio de Radio (recalcular en tiempo real si hay selección)
  (action_tile "radio_curva" 
    "(uchi:callback-cambiar-radio)"
  )
  
  ;; Botón Calcular Todo
  (action_tile "btn_calcular_todo" 
    "(uchi:callback-calcular-todo)"
  )
  
  ;; Botón Previsualizar
  (action_tile "btn_previsualizar" 
    "(uchi:callback-previsualizar)"
  )
  
  ;; Botón Ayuda
  (action_tile "help_button" 
    "(uchi:callback-ayuda)"
  )
  
  ;; Selección en lista de PIs
  (action_tile "lista_pis" 
    "(uchi:callback-seleccion-pi $value)"
  )
)

;;; -----------------------------------------------------------------------------
;;; CALLBACKS (FUNCIONES DE RESPUESTA A EVENTOS)
;;; -----------------------------------------------------------------------------

(defun uchi:callback-pick-pi ()
  "Permite pickear un punto en pantalla para agregar como PI"
  (done_dialog 0) ;; Cerrar temporalmente
  (graphscr)
  (princ "\nSeleccione punto para P.I. o [Cancelar]: ")
  (setq pt (getpoint))
  (if pt
    (progn
      (setq nom (getstring "\nNombre del P.I. (ej. PI-1): "))
      (if (= nom "") (setq nom "PI-?"))
      (setq n (cadr pt))
      (setq e (car pt))
      (setq el (getreal "\nElevación <0.0>: "))
      (if (null el) (setq el 0.0))
      (uchi:agregar-pi nom n e el)
    )
  )
  ;; Reabrir diálogo (se requiere lógica adicional para estado completo)
  (c:UCHI_ALINEAMIENTO)
)

(defun uchi:callback-importar-pis ()
  "Importa PIs desde archivo TXT/CSV"
  (setq filename (getfiled "Seleccionar archivo de PIs" "" "txt;csv" 16))
  (if filename
    (progn
      (setq f (open filename "r"))
      (if f
        (progn
          (setq linea (read-line f))
          (while linea
            ;; Parsear línea (asumiendo formato: Nombre,N,E,Elev o similar)
            ;; Implementación simplificada
            (setq linea (read-line f))
          )
          (close f)
          (alert "Puntos importados (implementación pendiente de parser).")
          (uchi:actualizar-lista-pis-dialog)
        )
        (alert "No se pudo abrir el archivo.")
      )
    )
  )
)

(defun uchi:callback-agregar-manual ()
  "Abre diálogo secundario para ingreso manual"
  (setq dcl_id (load_dialog "dcl_alineamiento.dcl"))
  (if (new_dialog "UCHI_IngresoPI" dcl_id)
    (progn
      (set_tile "pi_nombre" "PI-?")
      (set_tile "pi_elevacion" "0.00")
      (action_tile "accept" "(done_dialog 1)")
      (action_tile "cancel" "(done_dialog 0)")
      (if (= (start_dialog) 1)
        (progn
          (setq nom (get_tile "pi_nombre"))
          (setq n (atof (get_tile "pi_norte")))
          (setq e (atof (get_tile "pi_este")))
          (setq el (atof (get_tile "pi_elevacion")))
          (if (and nom (> (strlen nom) 0) n e)
            (uchi:agregar-pi nom n e el)
            (alert "Datos inválidos.")
          )
        )
      )
      (unload_dialog dcl_id)
    )
  )
)

(defun uchi:callback-editar-pi ()
  "Edita el PI seleccionado en la lista"
  (setq sel (get_tile "lista_pis"))
  (if (= sel "-1")
    (alert "Seleccione un P.I. de la lista primero.")
    (progn
      (setq idx (atoi sel))
      (setq pi (nth idx *uchi-alin-pis*))
      (if pi
        (progn
          ;; Lógica de edición similar a agregar manual
          (alert "Función de edición en desarrollo.")
        )
      )
    )
  )
)

(defun uchi:callback-eliminar-pi ()
  "Elimina el PI seleccionado"
  (setq sel (get_tile "lista_pis"))
  (if (= sel "-1")
    (alert "Seleccione un P.I. de la lista primero.")
    (progn
      (if (= (alert "¿Eliminar este P.I.?") 1) ;; Simplificación
        (progn
          (setq idx (atoi sel))
          (setq *uchi-alin-pis* 
            (vl-remove (nth idx *uchi-alin-pis*) *uchi-alin-pis*)
          )
          (uchi:actualizar-lista-pis-dialog)
        )
      )
    )
  )
)

(defun uchi:callback-cambiar-radio ()
  "Recalcula elementos al cambiar radio"
  (uchi:callback-calcular-todo)
)

(defun uchi:callback-calcular-todo ()
  "Calcula todos los elementos geométricos basados en los PIs y radios"
  (if (< (length *uchi-alin-pis*) 3)
    (progn
      (alert "Se requieren al menos 3 P.I. para definir un alineamiento (Inicio, PI, Fin).")
      (exit)
    )
  )
  
  ;; Obtener radio actual
  (setq radio (atof (get_tile "radio_curva")))
  (if (<= radio 0)
    (progn
      (alert "El radio debe ser mayor a 0.")
      (exit)
    )
  )
  
  ;; Calcular deflexiones y elementos para cada PI intermedio
  ;; (Implementación simplificada para demostración)
  (setq i 1)
  (setq total-pis (length *uchi-alin-pis*))
  
  (while (< i (1- total-pis))
    (setq pi-ant (nth (1- i) *uchi-alin-pis*))
    (setq pi-act (nth i *uci-alin-pis*))
    (setq pi-sig (nth (1+ i) *uchi-alin-pis*))
    
    ;; Calcular ángulos de entrada y salida
    (setq ang1 (angle (list (caddr pi-ant) (cadr pi-ant)) (list (caddr pi-act) (cadr pi-act))))
    (setq ang2 (angle (list (caddr pi-act) (cadr pi-act)) (list (caddr pi-sig) (cadr pi-sig))))
    
    ;; Calcular deflexión
    (setq defl (- ang2 ang1))
    (if (< defl 0) (setq defl (+ defl (* 2 pi))))
    (if (> defl pi) (setq defl (- (* 2 pi) defl))) ;; Tomar el menor ángulo
    
    ;; Calcular elementos
    (setq elems (uchi:calcular-elementos-curva radio defl))
    
    ;; Mostrar resultados (solo último calculado para demo)
    (if elems
      (progn
        (set_tile "res_deflexion" (uchi:decimal-to-ddms (uchi:rad-to-deg defl)))
        (set_tile "res_tangente" (strcat (rtos (cdr (assoc 'tangente elems)) 2 2) " m"))
        (set_tile "res_long_curva" (strcat (rtos (cdr (assoc 'long_curva elems)) 2 2) " m"))
        (set_tile "res_cuerda" (strcat (rtos (cdr (assoc 'cuerda_larga elems)) 2 2) " m"))
        (set_tile "res_externa" (strcat (rtos (cdr (assoc 'externa elems)) 2 2) " m"))
        (set_tile "res_media" (strcat (rtos (cdr (assoc 'ordenada_media elems)) 2 2) " m"))
      )
    )
    
    (setq i (1+ i))
  )
  
  (alert "Cálculos completados.")
)

(defun uchi:callback-previsualizar ()
  "Dibuja una previsualización temporal en el área de dibujo"
  (uchi:ejectar-dibujo-alineamiento t) ;; Modo temporal
)

(defun uchi:callback-seleccion-pi (val)
  "Acción al seleccionar un PI en la lista"
  (if (/= val "-1")
    (progn
      ;; Podría zoom al punto seleccionado
      (princ (strcat "\nPI Seleccionado: " (vl-princ-to-string (nth (atoi val) *uchi-alin-pis*))))
    )
  )
)

(defun uchi:callback-ayuda ()
  "Muestra diálogo de ayuda"
  (setq dcl_id (load_dialog "dcl_alineamiento.dcl"))
  (if (new_dialog "UCHI_AyudaFormulas" dcl_id)
    (progn
      (action_tile "accept" "(done_dialog 1)")
      (start_dialog)
      (unload_dialog dcl_id)
    )
  )
)

;;; -----------------------------------------------------------------------------
;;; DIBUJO EN AUTOCAD
;;; -----------------------------------------------------------------------------

(defun uchi:ejectar-dibujo-alineamiento (/ es-temporal)
  "Dibuja el alineamiento en AutoCAD"
  (setq es-temporal (if (null es-temporal) nil es-temporal))
  
  (if (< (length *uchi-alin-pis*) 2)
    (progn
      (alert "No hay suficientes PIs para dibujar.")
      (exit)
    )
  )
  
  ;; Crear capa
  (if (not (tblsearch "LAYER" "EJE_VIAL"))
    (command "_-LAYER" "N" "EJE_VIAL" "C" "3" "EJE_VIAL" "")
  )
  (setvar "CLAYER" "EJE_VIAL")
  
  ;; Dibujar líneas rectas entre PIs
  (setq pts (mapcar '(lambda(x) (list (caddr x) (cadr x))) *uchi-alin-pis*))
  
  ;; Dibujar polilínea base
  (command "_PLINE")
  (foreach p pts
    (command p)
  )
  (command "")
  
  ;; Si hay curvas calculadas, dibujar arcos (simplificado)
  ;; Aquí iría la lógica completa de recorte y arco
  
  (if es-temporal
    (princ "\nPrevisualización generada.")
    (princ "\nAlineamiento dibujado permanentemente.")
  )
  (princ)
)

;;; -----------------------------------------------------------------------------
;;; INICIALIZACIÓN
;;; -----------------------------------------------------------------------------

(princ "\n:: Módulo DRV_ALINEAMIENTO cargado. Use comando UCHI_ALINEAMIENTO ::")
(princ)
