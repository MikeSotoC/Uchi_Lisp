;;; UCHI Commands

(defun uchi:run-main (/ action)
  (uchi:log "Comando principal UCHI")
  (setq action (uchi:show-main-dialog))
  (cond
    ((= action "ok")
      (uchi:log "UI confirmada.")
    )
    ((= action "flujo")
      (C:UCHI_FLUJO)
    )
    ((= action "import")
      (C:UCHI_PUNTOS_IMPORT)
    )
    ((= action "valid")
      (C:UCHI_PUNTOS_VALIDAR)
    )
    ((= action "surface")
      (C:UCHI_SUPERFICIE)
    )
    ((= action "profile")
      (C:UCHI_PERFIL)
    )
    ((= action "curves")
      (C:UCHI_CURVAS_GEN)
    )
    ((= action "sections")
      (C:UCHI_SECCIONES)
    )
    ((= action "report")
      (C:UCHI_REPORTE)
    )
    ((= action "process")
      (C:UCHI_PROCESAR)
    )
    ((= action "geojson")
      (C:UCHI_EXPORT_GEOJSON)
    )
    ((= action "align")
      (C:UCHI_ALINEAMIENTO)
    )
    ((= action "volume")
      (C:UCHI_VOLUMEN)
    )
    ((= action "qc")
      (C:UCHI_QC)
    )
    ((= action "release")
      (C:UCHI_RELEASE_GO)
    )
    ((= action "styles")
      (C:UCHI_ESTILOS)
    )
    ((= action "landxml")
      (C:UCHI_EXPORT_LANDXML)
    )
    ((= action "tin")
      (C:UCHI_TIN)
    )
    ((= action "boundary")
      (C:UCHI_BOUNDARY)
    )
    (T
      (uchi:log "UI cancelada o no disponible.")
    )
  )
)

(defun C:UCHI ()
  (uchi:run-main)
  (princ)
)

(defun C:UCHI_MAIN ()
  ;; Alias de compatibilidad hacia atrás.
  (uchi:run-main)
  (princ)
)

(defun C:UCHI_TOPO ()
  (C:UCHI_FLUJO)
)

(defun C:UCHI_IMPORTAR_PUNTOS ()
  (C:UCHI_PUNTOS_IMPORT)
)

(defun C:UCHI_VALIDAR_PUNTOS ()
  (C:UCHI_PUNTOS_VALIDAR)
)

(defun C:UCHI_SUP ()
  (C:UCHI_SUPERFICIE)
)

(defun C:UCHI_PROF ()
  (C:UCHI_PERFIL)
)


(defun C:UCHI_SEC ()
  (C:UCHI_SECCIONES)
)

(defun C:UCHI_RPT ()
  (C:UCHI_REPORTE)
)

(defun C:UCHI_PROCESO ()
  (C:UCHI_PROCESAR)
)

(defun C:UCHI_GEOJSON ()
  (C:UCHI_EXPORT_GEOJSON)
)

(defun C:UCHI_ALIGN ()
  (C:UCHI_ALINEAMIENTO)
)

(defun C:UCHI_VOL ()
  (C:UCHI_VOLUMEN)
)

(defun C:UCHI_QA ()
  (C:UCHI_QC)
)

(defun C:UCHI_GO ()
  (C:UCHI_RELEASE_GO)
)

(defun C:UCHI_STYLES ()
  (C:UCHI_ESTILOS)
)

(defun C:UCHI_LXML ()
  (C:UCHI_EXPORT_LANDXML)
)

(defun C:UCHI_TIN_GEN ()
  (C:UCHI_TIN)
)

(defun C:UCHI_BOUND ()
  (C:UCHI_BOUNDARY)
)

(defun C:UCHI_BREAKLINES ()
  (C:UCHI_BREAKLINES_IMPORT)
)

(defun C:UCHI_STD ()
  (C:UCHI_PERFIL_PRESET)
)

(defun C:UCHI_JSON ()
  (C:UCHI_SAVE_JSON)
)

(defun C:UCHI_STAKE ()
  (C:UCHI_STAKEOUT)
)

(defun C:UCHI_REPLANTEO ()
  (C:UCHI_STAKEOUT)
)

(defun C:UCHI_DRENAJE_GEN ()
  (C:UCHI_DRENAJE)
)

(defun C:UCHI_CUNETAS ()
  (C:UCHI_DRENAJE)
)

(defun C:UCHI_CATASTRO_GEN ()
  (C:UCHI_CATASTRO)
)

(defun C:UCHI_REDES_PE ()
  (C:UCHI_REDES)
)

(defun C:UCHI_ROAD ()
  (C:UCHI_CARRETERA)
)

(defun C:UCHI_TEMPLATE ()
  (C:UCHI_TEMPLATE_PE)
)

(defun C:TOPO_BASE ()
  ;; Alias legacy.
  (C:UCHI_TOPO)
)

(princ)
