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
2. **Superficie**: TIN ahora considera breaklines hard importables y validación de cruce de segmentos; falta robustecer con límites complejos (huecos/islas), algoritmo Delaunay completo y suavizado avanzado.
3. **Curvas**: ahora se generan por intersección de niveles sobre TIN con encadenado y suavizado base; falta robustecer topología compleja y etiquetado avanzado de producción.
4. **Perfiles y secciones**: ya incluyen plantilla, escalas H/V, rasante por offset, bandas técnicas y offset L/R en secciones; falta completar bandas normativas y estilos de presentación por cliente.
5. **Persistencia**: migrar de `.dat` a `.uchi.json` con versionado de esquema.
6. **QA CAD real**: matriz por versión de AutoCAD y ZWCAD con evidencias.
7. **Telemetría soporte**: log a archivo con rotación (además de consola `[UCHI]`).
8. **Migrador legacy**: asistente para mapear configuraciones antiguas a esquema UCHI.

## Criterio para “parecerse a CivilCAD” sin copiar
- Misma intención de flujo topográfico de alto nivel (proyecto -> puntos -> superficie/curvas -> perfil).
- Nombres, UI, comandos y estructura propia UCHI (sin branding ni copia literal).
