;;; UCHI Templates Perú (configuración base)

(defun uchi:apply-template-pe-generic ()
  ;; Topografía
  (setenv "UCHI_CFG_CURVE_MAJOR" "5")
  (setenv "UCHI_CFG_CURVE_MINOR" "1")
  (setenv "UCHI_CFG_PROFILE_HSCALE" "1.0")
  (setenv "UCHI_CFG_PROFILE_VSCALE" "10.0")
  ;; Carreteras
  (setenv "UCHI_CFG_ROAD_LANE_WIDTH" "3.30")
  (setenv "UCHI_CFG_ROAD_LANES" "2")
  (setenv "UCHI_CFG_ROAD_SHOULDER" "1.20")
  (setenv "UCHI_CFG_ROAD_CROSSFALL" "2.0")
  ;; Agua / desagüe
  (setenv "UCHI_CFG_WATER_DIAM_MM" "110")
  (setenv "UCHI_CFG_WATER_SLOPE_PCT" "0.5")
  (setenv "UCHI_CFG_SEWER_DIAM_MM" "200")
  (setenv "UCHI_CFG_SEWER_SLOPE_PCT" "1.0")
  (setenv "UCHI_CFG_BZ_SPACING" "60")
  ;; Catastro
  (setenv "UCHI_CFG_CATASTRO_LOT_W" "8")
  (setenv "UCHI_CFG_CATASTRO_LOT_D" "20")
  (setenv "UCHI_CFG_RURAL_FRONT" "60")
  (setenv "UCHI_CFG_RURAL_DEPTH" "200")
  (setenv "UCHI_CFG_RURAL_USE" "AGRICOLA")
  (uchi:log "Template Perú aplicado (topo + carreteras + saneamiento + catastro).")
)

(defun C:UCHI_TEMPLATE_PE ()
  (uchi:apply-template-pe-generic)
  (princ)
)

(princ)
