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
    : spacer {}
    ok_cancel;
  }
}
