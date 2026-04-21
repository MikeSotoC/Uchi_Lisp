;;; ============================================================================
;;; CIVILCAD-PERÚ - DCL HELPERS
;;; Funciones auxiliares para interfaces DCL
;;; ============================================================================

;;; Variables globales de DCL helpers
(setq *CCP_DCL_VERSION* "1.0.0")
(setq *CCP_CURRENT_DIALOG* nil)

;;; Función: CCP-load-dcl
;;; Carga un archivo DCL y retorna el identificador
(defun CCP-load-dcl (dcl-name / dcl-id)
  (setq dcl-id (load_dialog dcl-name))
  (if (< dcl-id 0)
    (progn
      (princ (strcat "\n[DCL] ERROR cargando: " dcl-name))
      nil
    )
    (progn
      (princ (strcat "\n[DCL] Cargado: " dcl-name))
      dcl-id
    )
  )
)

;;; Función: CCP-unload-dcl
;;; Descarga un archivo DCL
(defun CCP-unload-dcl (dcl-id)
  (if dcl-id
    (unload_dialog dcl-id)
  )
)

;;; Función: CCP-show-dialog
;;; Muestra un diálogo y retorna el código de acción
(defun CCP-show-dialog (dcl-name dialog-key / dcl-id result)
  (setq dcl-id (CCP-load-dcl dcl-name))
  
  (if dcl-id
    (progn
      (setq *CCP_CURRENT_DIALOG* dialog-key)
      (setq result (start_dialog))
      (CCP-unload-dcl dcl-id)
      (setq *CCP_CURRENT_DIALOG* nil)
      result
    )
    -1
  )
)

;;; Función: CCP-set-tile-value
;;; Establece valor en un tile del diálogo
(defun CCP-set-tile-value (key value)
  (mode_tile key 0)  ;; Habilitar
  (set_tile key (vl-prin1-to-string-safe value))
)

;;; Función: CCP-get-tile-value
;;; Obtiene valor de un tile del diálogo
(defun CCP-get-tile-value (key)
  (get_tile key)
)

;;; Función: CCP-enable-tile
;;; Habilita un tile
(defun CCP-enable-tile (key)
  (mode_tile key 0)
)

;;; Función: CCP-disable-tile
;;; Deshabilita un tile
(defun CCP-disable-tile (key)
  (mode_tile key 1)
)

;;; Función: CCP-focus-tile
;;; Establece foco en un tile
(defun CCP-focus-tile (key)
  (mode_tile key 3)
)

;;; Función: CCP-highlight-tile
;;; Resalta un tile
(defun CCP-highlight-tile (key)
  (mode_tile key 2)
)

;;; Función: CCP-set-label
;;; Cambia etiqueta de un botón o texto
(defun CCP-set-label (key label)
  (set_tile key label)
)

;;; Función: CCP-set-image
;;; Establece imagen en un tile de imagen
(defun CCP-set-image (key color-index)
  (fill_image key 0 0 color-index)
)

;;; Función: CCP-vector-image
;;; Dibuja vector en tile de imagen
(defun CCP-vector-image (key x1 y1 x2 y2 color)
  (vector_image key x1 y1 x2 y2 color)
)

;;; Función: CCP-erase-image
;;; Borra área de imagen
(defun CCP-erase-image (key x1 y1 x2 y2)
  (fill_image key x1 y1 (- x2 x1) (- y2 y1) -2)
)

;;; Función: CCP-list-add
;;; Agrega elemento a lista
(defun CCP-list-add (list-key column value)
  (start_list list-key)
  (add_list value)
  (end_list)
)

;;; Función: CCP-list-clear
;;; Limpia todos los elementos de una lista
(defun CCP-list-clear (list-key)
  (start_list list-key 3)
  (end_list)
)

;;; Función: CCP-list-populate
;;; Población masiva de lista desde lista de strings
(defun CCP-list-populate (list-key items)
  (CCP-list-clear list-key)
  (start_list list-key)
  (foreach item items
    (add_list item)
  )
  (end_list)
)

;;; Función: CCP-get-selected-item
;;; Obtiene índice del item seleccionado en lista
(defun CCP-get-selected-item (list-key)
  (get_tile list-key)
)

;;; Función: CCP-set-radio-group
;;; Establece selección en grupo de radio buttons
(defun CCP-set-radio-group (key value)
  (set_tile key (vl-prin1-to-string-safe value))
)

;;; Función: CCP-get-radio-group
;;; Obtiene selección de grupo de radio buttons
(defun CCP-get-radio-group (key)
  (get_tile key)
)

;;; Función: CCP-toggle-button-state
;;; Cambia estado de toggle button
(defun CCP-toggle-button-state (key state)
  (set_tile key (if state "1" "0"))
)

;;; Función: CCP-get-toggle-state
;;; Obtiene estado de toggle button
(defun CCP-get-toggle-state (key)
  (= (get_tile key) "1")
)

;;; Función: CCP-edit-box-text
;;; Obtiene/establece texto en edit box
(defun CCP-edit-box-text (key &optional value)
  (if value
    (set_tile key value)
    (get_tile key)
  )
)

;;; Función: CCP-popup-menu
;;; Muestra menú popup simple
(defun CCP-popup-menu (items title / result)
  ;; Nota: implementación básica, se puede extender
  (alert (strcat title "\n\nOpciones:\n" 
                 (apply 'strcat 
                        (mapcar '(lambda (x) (strcat x "\n")) items))))
  nil
)

;;; Función: CCP-validate-numeric-input
;;; Valida que input sea numérico
(defun CCP-validate-numeric-input (key min-val max-val / val)
  (setq val (distof (get_tile key)))
  
  (cond
    ((null val)
      (progn
        (set_tile key "")
        (mode_tile key 3)
        nil
      )
    )
    ((and min-val (< val min-val))
      (progn
        (set_tile key (rtos min-val 2 4))
        (mode_tile key 3)
        nil
      )
    )
    ((and max-val (> val max-val))
      (progn
        (set_tile key (rtos max-val 2 4))
        (mode_tile key 3)
        nil
      )
    )
    (T T)
  )
)

;;; Función: CCP-create-action-callback
;;; Crea callback para acción de botón
(defun CCP-create-action-callback (callback-func)
  callback-func
)

(princ "\n[LIB] DCL Helpers cargados.")
(princ)
