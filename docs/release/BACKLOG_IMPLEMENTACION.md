# Backlog de implementación UCHI (siguiente etapa)

## Ya implementado en esta etapa
- Launcher determinista `main.lsp` fuera de `app/`.
- Carga ordenada de módulos y fallback controlado.
- Compatibilidad AutoCAD/ZWCAD con fallback de DCL.
- UI base UCHI y flujo topográfico base (`UCHI_FLUJO`).
- Importación y validación inicial de puntos CSV (`UCHI_PUNTOS_IMPORT`/`UCHI_VALIDAR_PUNTOS`) con persistencia de proyecto.
- Compatibilidad de comandos legacy (`UCHI_MAIN`, `TOPO_BASE`).
- Exportación de reporte técnico (`UCHI_REPORTE`).
- Pipeline integral (`UCHI_PROCESAR`) y exportación GIS (`UCHI_EXPORT_GEOJSON`).
- Alineamiento y volumen por estación (`UCHI_ALINEAMIENTO`, `UCHI_VOLUMEN`).
- QC automático y decisión GO/NO-GO (`UCHI_QC`, `UCHI_RELEASE_GO`).
- Estilos CAD, LandXML y TIN base (`UCHI_ESTILOS`, `UCHI_EXPORT_LANDXML`, `UCHI_TIN`).

## Falta implementar para release funcional completo
1. **Puntos**: reglas avanzadas extra (códigos, tolerancias, filtros por capa) y reporte exportable.
2. **Superficie**: TIN ahora usa triangulación incremental tipo Delaunay (Bowyer-Watson), respeta breaklines hard y boundary con huecos (`UCHI_CFG_BOUNDARY_CSV`, `UCHI_CFG_BOUNDARY_HOLES_CSV`); falta optimización para nubes grandes y casuística extrema.
3. **Curvas**: ahora se generan por intersección de niveles sobre TIN con encadenado, depuración de segmentos espurios, deduplicación de vértices y cierre de lazos; falta etiquetado avanzado de producción.
4. **Perfiles y secciones**: ya incluyen plantilla, escalas H/V, rasante por offset, bandas técnicas, offset L/R y presets normativos base (MOP/MTC/CUSTOM); falta catálogo completo de estilos por cliente.
5. **Persistencia**: ahora se genera snapshot `.uchi.json` versionado (schema 1.0.0) en paralelo a `.dat`; falta carga directa desde JSON y migrador bidireccional completo.
6. **QA CAD real**: matriz base automatizada `uchi_qa_cad_matrix.csv` por plataforma/versión (`UCHI_CFG_QA_AUTOCAD_VER`, `UCHI_CFG_QA_ZWCAD_VER`) con estado de checks y ruta de evidencias. Falta completar evidencias reales por versión instalada del cliente.
7. **Telemetría soporte**: log a archivo con rotación (además de consola `[UCHI]`).
8. **Migrador legacy**: asistente para mapear configuraciones antiguas a esquema UCHI.
9. **Replanteo**: módulo base `UCHI_STAKEOUT` implementado (puntos pk/offset y CSV); falta integrar catálogo de códigos y salida para estación total/GNSS.
10. **Drenaje/Cunetas**: módulo `UCHI_DRENAJE` ahora exporta chequeo normativo por segmento (rango de pendiente longitudinal/transversal configurable). Falta cálculo hidráulico avanzado por evento de diseño.
11. **Catastro**: módulos base urbano (`UCHI_CATASTRO`) y rural (`UCHI_CATASTRO_RURAL`) implementados (lotes/predios y CSV); falta integración con nomenclatura oficial y validación SUNARP/Municipal.
11.1 **Subdivisión**: módulo `UCHI_SUBDIVISION` ya usa boundary (polígono irregular), reserva vial orientada (`ROAD_EVERY` + `ROAD_ANGLE`), frente mínimo y aportes reglamentarios con cuadro de áreas automático; falta reglas municipales avanzadas de equipamiento y casuística urbana especial.
12. **Redes agua/desagüe**: módulo `UCHI_REDES` ahora incluye chequeo normativo de diámetro/pendiente/cobertura mínima por red en `uchi_redes.csv`; falta cálculo hidráulico detallado y calibración completa por EPS/cliente.
13. **Carreteras**: módulo `UCHI_CARRETERA` ahora incluye chequeo normativo base (ancho de carril, bermas y bombeo/peralte máximo) y exporta `uchi_carretera_norma.csv`; falta peraltes/sobreanchos en geometría de curva y validación MTC exhaustiva.
14. **Organización de módulos**: `UCHI_MODULOS` implementado para inventario funcional por dominio; falta autogenerar documentación técnica desde registry.

## Módulos aún faltantes para objetivo “producto final”
15. **Hidrología/Hidráulica**: módulo implementado (`UCHI_HIDRAULICA`) con método racional + Manning + selección de diámetro comercial por tramo y chequeo de diámetro mínimo normativo/velocidad en `uchi_hidraulica_tramos.csv`. Falta calibración normativa por tipo de sistema/proyecto.
16. **Pavimentos**: módulo `UCHI_PAVIMENTOS` ahora incorpora chequeo normativo por nivel de tránsito (`BAJO/MEDIO/ALTO`) para espesores mínimos por capa; falta diseño estructural completo por tránsito/material/CBR.
17. **Interferencias 3D**: módulo implementado (`UCHI_INTERFERENCIAS`) con severidad por separación normativa, criticidad por tipo de red y control de separación vertical mínima (`sep_vertical_min`). Falta motor espacial robusto por corredor 3D.
18. **Expediente técnico**: módulo automatizado (`UCHI_EXPEDIENTE`) ahora genera resumen, cuadro por disciplina y consolidado final (`uchi_expediente_final.csv`) con estado de entregables + QA CAD. Falta armado completo de planos/cuadros normativos finales.

## Criterio para “parecerse a CivilCAD” sin copiar
- Misma intención de flujo topográfico de alto nivel (proyecto -> puntos -> superficie/curvas -> perfil).
- Nombres, UI, comandos y estructura propia UCHI (sin branding ni copia literal).
