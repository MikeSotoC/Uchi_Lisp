// ============================================================================
// UCHI - Configuración General del Proyecto
// Diálogo profesional estilo CivilCAD
// ============================================================================

uchi_config : dialog {
    label = "Configuración General del Proyecto";
    key = "config_dialog";
    fixed_width = true;
    width = 85;
    
    : column {
        // -------------------------------------------------------------------------
        // SECCIÓN: INFORMACIÓN DEL PROYECTO
        // -------------------------------------------------------------------------
        : boxed_column {
            label = "Información del Proyecto";
            key = "project_box";
            alignment = top;
            
            : row {
                : text {
                    label = "Nombre:";
                    width = 12;
                    alignment = left;
                }
                : edit_text {
                    key = "proj_name";
                    width = 40;
                    edit_limit = 128;
                }
            }
            
            : row {
                : text {
                    label = "Código:";
                    width = 12;
                    alignment = left;
                }
                : edit_text {
                    key = "proj_code";
                    width = 20;
                    edit_limit = 32;
                }
                : text {
                    label = "";
                    width = 2;
                }
                : text {
                    label = "Cliente:";
                    width = 10;
                    alignment = left;
                }
                : edit_text {
                    key = "proj_client";
                    width = 25;
                    edit_limit = 64;
                }
            }
            
            : row {
                : text {
                    label = "Ubicación:";
                    width = 12;
                    alignment = left;
                }
                : edit_text {
                    key = "proj_location";
                    width = 55;
                    edit_limit = 256;
                }
            }
            
            : row {
                : text {
                    label = "Descripción:";
                    width = 12;
                    alignment = top;
                }
                : edit_text {
                    key = "proj_desc";
                    width = 55;
                    height = 3;
                    edit_limit = 512;
                    multiline = true;
                }
            }
        }
        
        : spacer { height = 1; }
        
        // -------------------------------------------------------------------------
        // SECCIÓN: PARÁMETROS TÉCNICOS
        // -------------------------------------------------------------------------
        : boxed_column {
            label = "Parámetros Técnicos";
            key = "tech_box";
            alignment = top;
            
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
                            label = "Sistema Coord.:";
                            width = 15;
                            alignment = left;
                        }
                        : popup_list {
                            key = "tech_coordsys";
                            width = 35;
                            list = "UTM WGS84\nPSAD56\nNAD83\nLocal";
                            value = "0";
                        }
                    }
                    
                    : row {
                        : text {
                            label = "Zona UTM:";
                            width = 15;
                            alignment = left;
                        }
                        : edit_text {
                            key = "tech_utmzone";
                            width = 10;
                            edit_limit = 3;
                        }
                        : text {
                            label = "Hemisferio:";
                            width = 12;
                            alignment = left;
                        }
                        : radio_column {
                            key = "tech_hemisphere";
                            : radio_button { label = "Sur"; key = "hemi_s"; value = "1"; }
                            : radio_button { label = "Norte"; key = "hemi_n"; value = "0"; }
                        }
                    }
                }
                
                : spacer { width = 2; }
                
                : column {
                    : row {
                        : text {
                            label = "Precisión (m):";
                            width = 15;
                            alignment = left;
                        }
                        : popup_list {
                            key = "tech_precision";
                            width = 20;
                            list = "0.001\n0.01\n0.1\n1";
                            value = "1";
                        }
                    }
                    
                    : row {
                        : text {
                            label = "Escala Plot:";
                            width = 15;
                            alignment = left;
                        }
                        : edit_text {
                            key = "tech_scale";
                            width = 10;
                            edit_limit = 10;
                            value = "1:1000";
                        }
                    }
                    
                    : row {
                        : text {
                            label = "Intervalo Curvas:";
                            width = 15;
                            alignment = left;
                        }
                        : edit_text {
                            key = "tech_contour_int";
                            width = 10;
                            edit_limit = 10;
                            value = "1.0";
                        }
                        : text {
                            label = "m";
                            width = 5;
                        }
                    }
                }
            }
        }
        
        : spacer { height = 1; }
        
        // -------------------------------------------------------------------------
        // SECCIÓN: ESTÁNDARES Y NORMATIVA
        // -------------------------------------------------------------------------
        : boxed_column {
            label = "Estándares y Normativa";
            key = "standards_box";
            alignment = top;
            
            : row {
                : column {
                    : row {
                        : text {
                            label = "Normativa Vial:";
                            width = 18;
                            alignment = left;
                        }
                        : popup_list {
                            key = "std_road";
                            width = 30;
                            list = "DG-2018 (Perú)\nAASHTO\nNorma Española\nOtra";
                            value = "0";
                        }
                    }
                    
                    : row {
                        : text {
                            label = "Tipo de Vía:";
                            width = 18;
                            alignment = left;
                        }
                        : popup_list {
                            key = "std_roadtype";
                            width = 30;
                            list = "Carretera Nacional\nCarretera Departamental\nVía Vecinal\nAutopista\nTrocha";
                            value = "0";
                        }
                    }
                }
                
                : spacer { width = 2; }
                
                : column {
                    : row {
                        : text {
                            label = "Vel. Diseño (km/h):";
                            width = 18;
                            alignment = left;
                        }
                        : edit_text {
                            key = "std_designspeed";
                            width = 10;
                            edit_limit = 5;
                            value = "40";
                        }
                    }
                    
                    : row {
                        : text {
                            label = "Categoría:";
                            width = 18;
                            alignment = left;
                        }
                        : popup_list {
                            key = "std_category";
                            width = 30;
                            list = "I (1ra Clase)\nII (2da Clase)\nIII (3ra Clase)";
                            value = "0";
                        }
                    }
                }
            }
        }
        
        : spacer { height = 1; }
        
        // -------------------------------------------------------------------------
        // SECCIÓN: OPCIONES DE PROCESAMIENTO
        // -------------------------------------------------------------------------
        : boxed_column {
            label = "Opciones de Procesamiento";
            key = "process_box";
            alignment = top;
            
            : row {
                : toggle {
                    key = "opt_autosave";
                    label = "Auto-guardado cada 10 min";
                    value = "1";
                }
                : spacer { width = 3; }
                : toggle {
                    key = "opt_backup";
                    label = "Crear backup antes de cambios";
                    value = "1";
                }
            }
            
            : row {
                : toggle {
                    key = "opt_log";
                    label = "Generar log de operaciones";
                    value = "1";
                }
                : spacer { width = 3; }
                : toggle {
                    key = "opt_qc";
                    label = "Validación automática QC";
                    value = "1";
                }
            }
            
            : row {
                : toggle {
                    key = "opt_layers";
                    label = "Organizar por capas (layers)";
                    value = "1";
                }
                : spacer { width = 3; }
                : toggle {
                    key = "opt_xref";
                    label = "Usar XREF para superficies";
                    value = "0";
                }
            }
        }
        
        : spacer { height = 2; }
        
        // -------------------------------------------------------------------------
        // BOTONES DE ACCIÓN
        // -------------------------------------------------------------------------
        : row {
            alignment = centered;
            
            : button {
                key = "btn_load";
                label = "Cargar Proyecto";
                width = 18;
                is_default = false;
                mnemonic = "L";
            }
            
            : button {
                key = "btn_save";
                label = "Guardar Proyecto";
                width = 18;
                is_default = false;
                mnemonic = "G";
            }
            
            : button {
                key = "btn_defaults";
                label = "Restaurar Defaults";
                width = 18;
                is_default = false;
                mnemonic = "R";
            }
            
            spacer {};
            
            ok_cancel;
        }
    }
}

// ============================================================================
// Atributos personalizados para consistencia visual
// ============================================================================

uchi_config_field : edit_text {
    width = 25;
    edit_limit = 128;
    alignment = left;
}

uchi_config_label : text {
    width = 18;
    alignment = right;
    color = 7;
}

uchi_config_section : boxed_column {
    label = "";
    alignment = top;
    children_alignment = left;
}
