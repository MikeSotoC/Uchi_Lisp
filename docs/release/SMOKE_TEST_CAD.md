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
22. Ejecutar `UCHI_BOUNDARY` y validar polígono boundary dibujado.
23. Ejecutar `UCHI_TIN` y validar cantidad de triángulos TIN dentro del boundary.
24. Ejecutar `UCHI_BREAKLINES` e importar CSV `p1,p2,tipo` (HARD/SOFT), verificando conteo de válidas/inválidas.
25. Ejecutar `UCHI_STD` y aplicar preset (MOP/MTC), luego correr `UCHI_PERFIL` y `UCHI_SECCIONES` validando banda técnica/offsets.
26. Ejecutar `UCHI_JSON` y verificar `uchi_project.uchi.json` con `schema_version`.
27. Ejecutar `UCHI_STAKEOUT` (o `UCHI_REPLANTEO`) y verificar `uchi_stakeout.csv` con columnas `pk,offset,x,y,z`.
28. Ejecutar `UCHI_DRENAJE` (o `UCHI_CUNETAS`) y verificar `uchi_drainage.csv` con segmentos `long_*`/`trans_*`.
29. Ejecutar `UCHI_EXPORT_LANDXML` y verificar `uchi_surface.xml` con caras `<Faces>`.
30. Ejecutar `UCHI_DIAG` y validar launcher/appdir en logs.
31. Revisar logs `[UCHI] Flujo topográfico base iniciado/completado`.
32. Forzar fallback: mover temporalmente módulos de A y dejar `UCHI_APP_DIR` a B.
33. Verificar que el sistema anuncia fallback usado y ruta final activa.
34. Restaurar módulos y repetir APPLOAD en A.

## Criterio GO
- No hay mezcla de `app/` entre instalaciones.
- No aparece `CivilCAD-like` en UI/mensajes.
- Comandos `UCHI` y `UCHI_TOPO` ejecutan sin error.
- Logs `[UCHI]` muestran ruta activa y eventos de fallback/fallo.
