// ============================================================================
// DCL: Diseño de Alineamiento Horizontal (Curvas Circulares Simples)
// Módulo: DRV_ALINEAMIENTO
// Nivel: Profesional (Estilo CivilCAD)
// ============================================================================

UCHI_Alineamiento : dialog {
    label = "Diseño de Alineamiento Horizontal";
    key = "main_frame";
    alignment = centered;
    width = 105;
    
    : row {
        alignment = left;
        fixed_width = true;
        width = 100;
        
        // COLUMNA IZQUIERDA: Datos de Entrada y PI
        : column {
            width = 48;
            fixed_width = true;
            alignment = top;
            
            : text {
                label = "Datos del Proyecto:";
                alignment = left;
                width = 46;
            }
            : edit_box {
                key = "proyecto_nombre";
                label = "Nombre Proyecto:";
                edit_width = 25;
                mnemonic = "N";
                tab_stop = true;
            }
            : edit_box {
                key = "ingeniero_resp";
                label = "Ingeniero Responsable:";
                edit_width = 25;
                mnemonic = "I";
                tab_stop = true;
            }
            : edit_box {
                key = "velocidad_diseno";
                label = "Vel. Diseño (km/h):";
                edit_width = 10;
                value = "60";
                mnemonic = "V";
                tab_stop = true;
                edit_limit = 3;
            }
            
            spacer_0;
            
            : text {
                label = "Definición de P.I. (Punto de Intersección):";
                alignment = left;
                width = 46;
            }
            : row {
                : text_button {
                    key = "btn_pick_pi";
                    label = "Pick en Pantalla <";
                    width = 20;
                    mnemonic = "P";
                    is_default = false;
                    fixed_width = true;
                }
                : text_button {
                    key = "btn_import_txt";
                    label = "Importar TXT/CSV";
                    width = 20;
                    mnemonic = "M";
                    fixed_width = true;
                }
            }
            
            : list_box {
                key = "lista_pis";
                label = "Lista de P.I. Definidos:";
                width = 46;
                height = 12;
                fixed_width = true;
                tabs = "8 18 28 38";
                multiple_select = false;
                tab_stop = true;
                mnemonic = "L";
            }
            
            : row {
                : text_button {
                    key = "btn_agregar_pi";
                    label = "Agregar Manual";
                    width = 15;
                    mnemonic = "A";
                    fixed_width = true;
                }
                : text_button {
                    key = "btn_editar_pi";
                    label = "Editar";
                    width = 10;
                    mnemonic = "E";
                    fixed_width = true;
                }
                : text_button {
                    key = "btn_eliminar_pi";
                    label = "Eliminar";
                    width = 10;
                    mnemonic = "X";
                    fixed_width = true;
                }
            }
        }
        
        spacer_1;
        
        // COLUMNA DERECHA: Parámetros de Curva y Resultados
        : column {
            width = 48;
            fixed_width = true;
            alignment = top;
            
            : boxed_row {
                label = "Parámetros de Curva Circular";
                alignment = left;
                width = 46;
                
                : column {
                    : edit_box {
                        key = "radio_curva";
                        label = "Radio (m):";
                        edit_width = 12;
                        value = "150.00";
                        mnemonic = "R";
                        tab_stop = true;
                    }
                    : edit_box {
                        key = "espiral_long";
                        label = "Long. Espiral (m):";
                        edit_width = 12;
                        value = "0.00";
                        mnemonic = "S";
                        enabled = false; // Futura expansión a clotoides
                        tab_stop = true;
                    }
                    : popup_toggle {
                        key = "tipo_curva";
                        label = "Tipo:";
                        width = 20;
                        mnemonic = "T";
                        tab_stop = true;
                        list = "Circular Simple";
                    }
                }
            }
            
            spacer_0;
            
            : boxed_column {
                label = "Elementos Calculados";
                alignment = left;
                width = 46;
                height = 14;
                
                : row {
                    : text { label = "Ángulo de Deflexión (Δ):"; width = 20; }
                    : text { key = "res_deflexion"; label = "00-00-00"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Tangente (T):"; width = 20; }
                    : text { key = "res_tangente"; label = "0.00 m"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Long. Curva (Lc):"; width = 20; }
                    : text { key = "res_long_curva"; label = "0.00 m"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Cuerda Larga (CL):"; width = 20; }
                    : text { key = "res_cuerda"; label = "0.00 m"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Externa (E):"; width = 20; }
                    : text { key = "res_externa"; label = "0.00 m"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Ordenada Media (M):"; width = 20; }
                    : text { key = "res_media"; label = "0.00 m"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Abscisa PC:"; width = 20; }
                    : text { key = "res_abscisa_pc"; label = "0+000.00"; width = 15; alignment = right; }
                }
                : row {
                    : text { label = "Abscisa PT:"; width = 20; }
                    : text { key = "res_abscisa_pt"; label = "0+000.00"; width = 15; alignment = right; }
                }
            }
            
            spacer_0;
            
            : row {
                : toggle_button {
                    key = "chk_dibujar_curva";
                    label = "Dibujar Curva";
                    value = "1";
                    mnemonic = "D";
                    tab_stop = true;
                }
                : toggle_button {
                    key = "chk_etiquetar";
                    label = "Etiquetar Elementos";
                    value = "1";
                    mnemonic = "Q";
                    tab_stop = true;
                }
            }
        }
    }
    
    spacer_1;
    
    // BOTONES DE ACCIÓN GLOBAL
    : row {
        alignment = centered;
        fixed_width = true;
        
        : text_button {
            key = "btn_calcular_todo";
            label = "Calcular Todo";
            width = 15;
            mnemonic = "C";
            is_default = true;
            fixed_width = true;
        }
        : text_button {
            key = "btn_previsualizar";
            label = "Previsualizar en CAD";
            width = 20;
            mnemonic = "P";
            fixed_width = true;
        }
        
        spacer_0;
        
        ok_button;
        cancel_button;
        help_button;
    }
}

// Diálogo secundario para ingreso manual de coordenadas
UCHI_IngresoPI : dialog {
    label = "Ingresar Coordenadas P.I.";
    alignment = centered;
    width = 40;
    
    : column {
        : edit_box {
            key = "pi_nombre";
            label = "Nombre (ej. PI-1):";
            edit_width = 20;
            mnemonic = "N";
        }
        : edit_box {
            key = "pi_norte";
            label = "Norte (Y):";
            edit_width = 15;
            mnemonic = "O";
        }
        : edit_box {
            key = "pi_este";
            label = "Este (X):";
            edit_width = 15;
            mnemonic = "E";
        }
        : edit_box {
            key = "pi_elevacion";
            label = "Elevación (opcional):";
            edit_width = 15;
            value = "0.00";
            mnemonic = "L";
        }
    }
    
    spacer_1;
    
    : row {
        alignment = centered;
        ok_button;
        cancel_button;
    }
}

// Diálogo de ayuda rápida sobre fórmulas
UCHI_AyudaFormulas : dialog {
    label = "Fórmulas de Curvas Horizontales";
    alignment = centered;
    width = 60;
    
    : scroll_bar {
        : column {
            : text { label = "Curva Circular Simple:"; alignment = left; font = "bold"; }
            : text { label = "T = R * tan(Δ/2)"; alignment = left; }
            : text { label = "Lc = R * Δ (rad)"; alignment = left; }
            : text { label = "E = R * (sec(Δ/2) - 1)"; alignment = left; }
            : text { label = "M = R * (1 - cos(Δ/2))"; alignment = left; }
            : text { label = ""; }
            : text { label = "Donde:"; alignment = left; font = "bold"; }
            : text { label = "R = Radio de la curva"; alignment = left; }
            : text { label = "Δ = Ángulo de deflexión en el PI"; alignment = left; }
        }
    }
    
    spacer_1;
    
    : row {
        alignment = centered;
        ok_button;
    }
}
