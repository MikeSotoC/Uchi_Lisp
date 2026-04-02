uchi_main : dialog {
  label = "UCHI";
  : column {
    : text {
      key = "title_txt";
      label = "UCHI";
    }
    : text {
      key = "subtitle_txt";
      label = "Topografía productiva";
    }
    : button {
      key = "run_flujo";
      label = "Ejecutar flujo base";
      is_default = false;
    }
    : button {
      key = "import_pts";
      label = "Importar puntos CSV";
      is_default = false;
    }
    : button {
      key = "valid_pts";
      label = "Validar puntos";
      is_default = false;
    }
    : button {
      key = "build_surface";
      label = "Generar superficie";
      is_default = false;
    }
    : button {
      key = "build_profile";
      label = "Generar perfil";
      is_default = false;
    }
    : button {
      key = "build_curves";
      label = "Generar curvas";
      is_default = false;
    }
    : button {
      key = "build_sections";
      label = "Generar secciones";
      is_default = false;
    }
    : button {
      key = "export_report";
      label = "Exportar reporte";
      is_default = false;
    }
    : button {
      key = "run_process";
      label = "Proceso integral";
      is_default = false;
    }
    : button {
      key = "export_geojson";
      label = "Exportar GeoJSON";
      is_default = false;
    }
    : button {
      key = "build_align";
      label = "Generar alineamiento";
      is_default = false;
    }
    : button {
      key = "build_volume";
      label = "Generar volumen";
      is_default = false;
    }
    : button {
      key = "run_qc";
      label = "Ejecutar QC";
      is_default = false;
    }
    : button {
      key = "run_release";
      label = "Release GO/NO-GO";
      is_default = false;
    }
    : spacer {}
    ok_cancel;
  }
}
