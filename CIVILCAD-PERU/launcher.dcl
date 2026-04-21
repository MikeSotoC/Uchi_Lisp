CCPDIALOG : dialog {
    label = "CIVILCAD-PERÚ v1.0.0";
    key = "ccp_main_dialog";
    width = 80;
    
    : row {
        alignment = centered;
        fixed_width = true;
        
        : text {
            key = "title";
            label = "SUITE CAD PROFESIONAL PARA INGENIERÍA CIVIL";
            alignment = centered;
            width = 60;
        }
    }
    
    spacer_1;
    
    : boxed_column {
        label = "MÓDULOS DE TOPOGRAFÍA";
        key = "box_topo";
        alignment = centered;
        fixed_width = true;
        width = 75;
        
        : row {
            alignment = centered;
            
            : button {
                key = "btn_importar";
                label = "Importar Puntos CSV";
                width = 20;
                action = "(CCP_dcc_topo)";
            }
            
            : button {
                key = "btn_curvas";
                label = "Curvas de Nivel";
                width = 20;
                action = "(CCP_dcc_topo)";
            }
            
            : button {
                key = "btn_areas";
                label = "Áreas y Perímetros";
                width = 20;
                action = "(CCP_dcc_topo)";
            }
        }
    }
    
    spacer_0;
    
    : boxed_column {
        label = "MÓDULOS DE CARRETERAS (DG-1999)";
        key = "box_carreteras";
        alignment = centered;
        fixed_width = true;
        width = 75;
        
        : row {
            alignment = centered;
            
            : button {
                key = "btn_curva_h";
                label = "Curva Horizontal";
                width = 18;
                action = "(CCP_dcc_carreteras)";
            }
            
            : button {
                key = "btn_peraltes";
                label = "Peraltes";
                width = 18;
                action = "(CCP_dcc_carreteras)";
            }
            
            : button {
                key = "btn_visibilidad";
                label = "Visibilidad";
                width = 18;
                action = "(CCP_dcc_carreteras)";
            }
            
            : button {
                key = "btn_eje";
                label = "Dibujar Eje";
                width = 18;
                action = "(CCP_dcc_carreteras)";
            }
        }
    }
    
    spacer_0;
    
    : boxed_column {
        label = "MÓDULOS DE SANEAMIENTO (MVCS)";
        key = "box_saneamiento";
        alignment = centered;
        fixed_width = true;
        width = 75;
        
        : row {
            alignment = centered;
            
            : button {
                key = "btn_agua";
                label = "Agua Potable";
                width = 18;
                action = "(CCP_dcc_saneamiento)";
            }
            
            : button {
                key = "btn_hw";
                label = "Hazen-Williams";
                width = 18;
                action = "(CCP_dcc_saneamiento)";
            }
            
            : button {
                key = "btn_manning";
                label = "Manning";
                width = 18;
                action = "(CCP_dcc_saneamiento)";
            }
            
            : button {
                key = "btn_dot";
                label = "DOT";
                width = 18;
                action = "(CCP_dcc_saneamiento)";
            }
        }
    }
    
    spacer_0;
    
    : boxed_column {
        label = "MÓDULOS DE ESTRUCTURAS (RNE)";
        key = "box_estructuras";
        alignment = centered;
        fixed_width = true;
        width = 75;
        
        : row {
            alignment = centered;
            
            : button {
                key = "btn_viga";
                label = "Diseñar Viga";
                width = 18;
                action = "(CCP_dcc_estructuras)";
            }
            
            : button {
                key = "btn_columna";
                label = "Columna";
                width = 18;
                action = "(CCP_dcc_estructuras)";
            }
            
            : button {
                key = "btn_sismo";
                label = "Cálculo Sísmico";
                width = 18;
                action = "(CCP_dcc_estructuras)";
            }
            
            : button {
                key = "btn_zapata";
                label = "Zapatas";
                width = 18;
                action = "(CCP_dcc_estructuras)";
            }
        }
    }
    
    spacer_0;
    
    : boxed_column {
        label = "REPORTES Y DOCUMENTACIÓN";
        key = "box_reportes";
        alignment = centered;
        fixed_width = true;
        width = 75;
        
        : row {
            alignment = centered;
            
            : button {
                key = "btn_memoria";
                label = "Memoria Descriptiva";
                width = 20;
                action = "(CCP_dcc_reportes)";
            }
            
            : button {
                key = "btn_tabla";
                label = "Tabla de Puntos";
                width = 20;
                action = "(CCP_dcc_reportes)";
            }
            
            : button {
                key = "btn_cuadro";
                label = "Cuadro de Áreas";
                width = 20;
                action = "(CCP_dcc_reportes)";
            }
        }
    }
    
    spacer_1;
    
    : row {
        alignment = centered;
        fixed_width = true;
        
        : button {
            key = "btn_config";
            label = "Configuración";
            width = 18;
            action = "(CCP_dcc_config)";
        }
        
        : button {
            key = "btn_help";
            label = "Ayuda";
            width = 18;
            action = "(CCP_dcc_help)";
        }
        
        : button {
            key = "btn_close";
            label = "Cerrar";
            is_default = true;
            width = 18;
            action = "(CCP_dcc_exit)";
        }
    }
    
    spacer_1;
    
    : row {
        alignment = centered;
        
        : text {
            key = "status";
            label = "Estado: Sistema listo - Normativa peruana aplicada";
            alignment = centered;
            width = 60;
        }
    }
}
