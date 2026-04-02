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
8. Ejecutar comando `UCHI_TOPO`.
9. Ejecutar `UCHI_DIAG` y validar launcher/appdir en logs.
10. Revisar logs `[UCHI] Flujo topográfico base iniciado/completado`.
11. Forzar fallback: mover temporalmente módulos de A y dejar `UCHI_APP_DIR` a B.
12. Verificar que el sistema anuncia fallback usado y ruta final activa.
13. Restaurar módulos y repetir APPLOAD en A.

## Criterio GO
- No hay mezcla de `app/` entre instalaciones.
- No aparece `CivilCAD-like` en UI/mensajes.
- Comandos `UCHI` y `UCHI_TOPO` ejecutan sin error.
- Logs `[UCHI]` muestran ruta activa y eventos de fallback/fallo.
