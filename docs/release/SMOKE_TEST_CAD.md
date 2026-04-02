# Smoke Test CAD — UCHI

## Objetivo
Validar carga estable por APPLOAD, comandos base y aislamiento de ruta activa.

## Precondiciones
- Dos instalaciones de prueba (A nueva, B vieja) para validar no-mezcla.
- APPLOAD apuntando explícitamente a `main.lsp` de la instalación A.

## Pasos
1. Abrir CAD limpio.
2. Ejecutar APPLOAD sobre `.../A/main.lsp`.
3. Revisar consola: debe salir `[UCHI] Ruta activa: .../A/app`.
4. Ejecutar comando `UCHI`.
5. Confirmar diálogo con título **UCHI** (sin branding legacy).
6. Ejecutar comando `UCHI_IMPORTAR_PUNTOS` con un CSV de prueba.
7. Verificar log de puntos importados y guardado de proyecto.
8. Ejecutar comando `UCHI_VALIDAR_PUNTOS` sobre el último archivo.
9. Ejecutar comando `UCHI_SUPERFICIE`.
10. Ejecutar comando `UCHI_PERFIL`.
11. Ejecutar comando `UCHI_CURVAS` (o `UCHI_CURVAS_GEN`).
12. Ejecutar comando `UCHI_SECCIONES`.
13. Ejecutar comando `UCHI_TOPO`.
14. Ejecutar comando `UCHI_PROCESAR` (pipeline integral).
15. Ejecutar `UCHI_REPORTE` y verificar `uchi_report.txt` con malla/corte/relleno.
16. Ejecutar `UCHI_EXPORT_GEOJSON` y verificar archivo `uchi_points.geojson`.
17. Ejecutar `UCHI_ALINEAMIENTO` y verificar `uchi_alignment.csv`.
18. Ejecutar `UCHI_VOLUMEN` y verificar `uchi_volume.csv`.
19. Ejecutar `UCHI_QC` y validar métricas (dup_rate/inv_rate/tri/area).
20. Ejecutar `UCHI_RELEASE_GO` y verificar mensaje GO/NO-GO.
21. Ejecutar `UCHI_ESTILOS` y validar capas UCHI creadas.
22. Ejecutar `UCHI_BOUNDARY` y validar polígono boundary dibujado; opcionalmente definir `UCHI_CFG_BOUNDARY_CSV` + `UCHI_CFG_BOUNDARY_HOLES_CSV` para validar límites/huecos.
23. Ejecutar `UCHI_TIN` y validar cantidad de triángulos TIN dentro del boundary y fuera de huecos.
24. Ejecutar `UCHI_BREAKLINES` e importar CSV `p1,p2,tipo` (HARD/SOFT), verificando conteo de válidas/inválidas.
25. Ejecutar `UCHI_STD` y aplicar preset (MOP/MTC), luego correr `UCHI_PERFIL` y `UCHI_SECCIONES` validando banda técnica/offsets.
26. Ejecutar `UCHI_JSON` y verificar `uchi_project.uchi.json` con `schema_version`.
27. Ejecutar `UCHI_STAKEOUT` (o `UCHI_REPLANTEO`) y verificar `uchi_stakeout.csv` con columnas `pk,offset,x,y,z`.
28. Ejecutar `UCHI_DRENAJE` (o `UCHI_CUNETAS`) y verificar `uchi_drainage.csv` con segmentos `long_*`/`trans_*` y columnas normativas (`slope_min_pct`,`slope_max_pct`,`cumple_norma`).
29. Verificar archivos externos `templates/pe_generic.tpl`, `templates/pe_dg2018.tpl`, categorías `pe_dg2018_{vecinal,departamental,nacional}.tpl` y variantes por terreno `*_{plano,ondulado,accidentado}.tpl`.
30. Ejecutar `UCHI_TEMPLATE` (Perú) y confirmar variables base de carreteras/redes/catastro.
31. Ejecutar `UCHI_TEMPLATE_DG`, `UCHI_TEMPLATE_DG_VIA` y `UCHI_TEMPLATE_DG_TOPO`, confirmando parámetros DG-2018 por categoría y terreno (ver `docs/release/TEMPLATES_DG2018.md`).
32. Ejecutar `UCHI_CATASTRO` y verificar `uchi_catastro.csv` con lotes.
33. Ejecutar `UCHI_CATASTRO_RUR` y verificar `uchi_catastro_rural.csv` con `area_m2/area_ha`.
34. Ejecutar `UCHI_SUBDIV` y verificar `uchi_subdivision.csv` (type `lot/lot_corner/road/aporte`), con modo por `SUBDIV_COLS/ROWS` o por `SUBDIV_NDIV`, filtro por boundary irregular, frente mínimo y `uchi_subdivision_summary.csv` con cuadro de áreas.
35. Ejecutar `UCHI_MODULOS` y validar inventario por dominios en logs.
36. Ejecutar `UCHI_REDES_PE` y verificar `uchi_redes.csv` con `AGUA/DESAGUE`, `BZ`, accesorios y `cumple_norma` (diámetro/pendiente/cobertura).
37. Ejecutar `UCHI_HIDRO` y verificar `uchi_hidraulica.csv` con `Q_lps`/`D_sugerido_mm` y `uchi_hidraulica_tramos.csv` con `D_comercial_mm`,`D_min_norma_mm`,`vel_m_s`,`cumple_norma` por tramo.
38. Ejecutar `UCHI_PAV` y verificar `uchi_pavimentos.csv` con metrados por capa y chequeo `cumple_norma` según `trafico`.
39. Ejecutar `UCHI_INTERF` y verificar `uchi_interferencias.csv` con cruces detectados, `severidad`, `severidad_criticidad`, `sep_min_norma`, `sep_vertical_min` e `incumple_norma`.
40. Ejecutar `UCHI_QA_CAD` y verificar `uchi_qa_cad_matrix.csv` con plataformas AutoCAD/ZWCAD y versión configurada.
41. Ejecutar `UCHI_EXP` y verificar `uchi_expediente.txt` + `uchi_expediente_cuadros.csv` + `uchi_expediente_final.csv`.
42. Ejecutar `UCHI_ROAD` y validar dibujo de secciones tipo en capa `UCHI_ROAD` + archivo `uchi_carretera_norma.csv` con chequeo normativo base.
43. Ejecutar `UCHI_EXPORT_LANDXML` y verificar `uchi_surface.xml` con caras `<Faces>`.
44. Ejecutar `UCHI_DIAG` y validar launcher/appdir en logs.
45. Revisar logs `[UCHI] Flujo topográfico base iniciado/completado`.
46. Forzar fallback: mover temporalmente módulos de A y dejar `UCHI_APP_DIR` a B.
47. Verificar que el sistema anuncia fallback usado y ruta final activa.
48. Restaurar módulos y repetir APPLOAD en A.

## Criterio GO
- No hay mezcla de `app/` entre instalaciones.
- No aparece `CivilCAD-like` en UI/mensajes.
- Comandos `UCHI` y `UCHI_TOPO` ejecutan sin error.
- Logs `[UCHI]` muestran ruta activa y eventos de fallback/fallo.
