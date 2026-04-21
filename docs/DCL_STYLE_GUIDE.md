# Guía de Estilos DCL para UCHI
## Estándares de Interfaz Gráfica estilo CivilCAD

---

## 1. Estructura de Archivos

### Convención de Nombres
- **Archivos DCL**: `uchi_<modulo>.dcl`
- **Archivos LSP**: `uchi_<modulo>_dialog.lsp` (para módulos con UI)
- **Claves de diálogo**: `<modulo>_<funcion>_dialog`

### Organización
```
/workspace/app/
├── uchi_config.dcl          # Definición DCL
├── uchi_config_dialog.lsp   # Lógica del diálogo
├── uchi_main.dcl            # Diálogo principal
└── uchi_ui.lsp              # Gestor de UI
```

---

## 2. Atributos de Estilo Consistente

### Dimensiones Estándar

```dcl
// Anchos de campo comunes
field_short: edit_text { width = 10; }
field_medium: edit_text { width = 25; }
field_long: edit_text { width = 40; }
field_xlong: edit_text { width = 55; }

// Espaciadores
spacer_small: spacer { width = 1; height = 1; }
spacer_medium: spacer { width = 2; height = 1; }
spacer_large: spacer { width = 3; height = 2; }
```

### Alineación y Layout

```dcl
// Contenedores seccionales
section_box: boxed_column {
    label = "";
    alignment = top;
    children_alignment = left;
    fixed_width = true;
}

// Etiquetas estándar
std_label: text {
    alignment = right;
    color = 7;  // Blanco/gris claro
}
```

---

## 3. Patrones de Diseño

### Sección con Etiqueta y Campo

```dcl
: row {
    : text {
        label = "Nombre:";
        width = 12;
        alignment = left;
    }
    : edit_text {
        key = "campo_nombre";
        width = 40;
        edit_limit = 128;
    }
}
```

### Grupo de Radio Buttons

```dcl
: radio_column {
    key = "grupo_opciones";
    : radio_button { 
        label = "Opción 1"; 
        key = "opcion_1"; 
        value = "1"; 
    }
    : radio_button { 
        label = "Opción 2"; 
        key = "opcion_2"; 
        value = "0"; 
    }
}
```

### Lista Desplegable

```dcl
: popup_list {
    key = "lista_seleccion";
    width = 30;
    list = "Opción 1\nOpción 2\nOpción 3";
    value = "0";  // Índice base 0
}
```

### Toggle Checkbox

```dcl
: toggle {
    key = "opcion_activa";
    label = "Activar opción";
    value = "1";  // 1 = activado, 0 = desactivado
}
```

---

## 4. Mejores Prácticas

### Validación en Tiempo Real

```lisp
(action_tile "campo_codigo" "(validar-codigo $value)")

(defun validar-codigo (val)
  (if (not (wcmatch val "*[A-Za-z0-9]*"))
    (progn
      (mode_tile "campo_codigo" 3)  ; Enfocar
      (alert "Código inválido")
      nil
    )
    t
  )
)
```

### Mnemónicos para Accesibilidad

```dcl
: button {
    key = "btn_guardar";
    label = "Guardar";
    mnemonic = "G";  // Alt+G activa el botón
}
```

### Botones por Defecto

```dcl
: button {
    key = "btn_aceptar";
    label = "Aceptar";
    is_default = true;  // Enter activa este botón
    is_cancel = false;
}

: button {
    key = "btn_cancelar";
    label = "Cancelar";
    is_default = false;
    is_cancel = true;  // Esc activa este botón
}
```

---

## 5. Paleta de Colores Recomendada

| Color | Código | Uso |
|-------|--------|-----|
| Blanco/Gris | 7 | Texto de etiquetas |
| Negro | 0 | Texto principal |
| Rojo | 1 | Errores/Advertencias |
| Verde | 3 | Éxito/Activo |
| Azul | 5 | Información/Links |

---

## 6. Ejemplo Completo de Sección

```dcl
: boxed_column {
    label = "Parámetros Técnicos";
    key = "tech_box";
    alignment = top;
    fixed_width = true;
    width = 80;
    
    : row {
        : column {
            : row {
                : text {
                    label = "Unidades:";
                    width = 15;
                    alignment = left;
                }
                : popup_list {
                    key = "tech_units";
                    width = 20;
                    list = "Metros\nPies\nKilómetros";
                    value = "0";
                }
            }
            
            : row {
                : text {
                    label = "Precisión:";
                    width = 15;
                    alignment = left;
                }
                : edit_text {
                    key = "tech_precision";
                    width = 10;
                    edit_limit = 10;
                    value = "0.01";
                }
                : text {
                    label = "m";
                    width = 5;
                }
            }
        }
        
        : spacer { width = 2; }
        
        : column {
            : row {
                : text {
                    label = "Sistema Coord.:";
                    width = 15;
                    alignment = left;
                }
                : popup_list {
                    key = "tech_coordsys";
                    width = 30;
                    list = "UTM WGS84\nPSAD56\nLocal";
                    value = "0";
                }
            }
        }
    }
}
```

---

## 7. Comandos de AutoCAD para Diálogos

### Carga y Descarga

```lisp
;; Cargar archivo DCL
(setq dclid (load_dialog "ruta/archivo.dcl"))

;; Verificar carga
(if (< dclid 0)
    (alert "Error al cargar DCL")
    ;; Continuar...
)

;; Crear instancia del diálogo
(new_dialog "nombre_dialogo" dclid)

;; Iniciar
(start_dialog)

;; Liberar recursos
(unload_dialog dclid)
```

### Manipulación de Tiles

```lisp
;; Establecer valor
(set_tile "key_campo" "valor")

;; Obtener valor
(setq valor (get_tile "key_campo"))

;; Habilitar/Deshabilitar (0=enable, 1=disable, 2=focus, 3=select)
(mode_tile "key_campo" 1)  ; Deshabilitar

;; Actualizar lista
(start_list "key_lista")
    (add_list "Nuevo Item 1")
    (add_list "Nuevo Item 2")
(end_list)
```

---

## 8. Checklist de Calidad

- [ ] Todas las keys siguen convención `seccion_nombre`
- [ ] Labels descriptivos y en español
- [ ] Anchors consistentes (left para labels, centered para botones)
- [ ] Espaciadores adecuados entre secciones
- [ ] Mnemónicos definidos para botones principales
- [ ] Validación implementada para campos críticos
- [ ] Is_default en botón principal (Aceptar/Guardar)
- [ ] Is_cancel en botón Cancelar
- [ ] Width fijo definido para el diálogo
- [ ] Comentarios en código DCL y LISP

---

## 9. Referencia Rápida de Controls

| Control | Uso | Atributos Clave |
|---------|-----|-----------------|
| `edit_text` | Entrada de texto | width, edit_limit, multiline |
| `popup_list` | Lista desplegable | list, value |
| `radio_button` | Selección única | value, label |
| `toggle` | Checkbox | label, value |
| `button` | Botón de acción | label, is_default, mnemonic |
| `boxed_column` | Contenedor con borde | label, alignment |
| `row` | Disposición horizontal | - |
| `column` | Disposición vertical | - |
| `spacer` | Espaciador | width, height |
| `text` | Etiqueta estática | label, alignment |
| `ok_cancel` | Botones predefinidos | - |

---

*Documento generado para el proyecto UCHI - Ingeniería Civil y Topografía*
*Basado en estándares de interfaces profesionales tipo CivilCAD*
