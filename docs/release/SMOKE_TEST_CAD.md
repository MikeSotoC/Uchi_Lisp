# Smoke Test CAD — UCHI

## Objetivo
Validar carga estable por APPLOAD, comandos base y aislamiento de ruta activa.

## Precondiciones
- Dos instalaciones de prueba (A nueva, B vieja) para validar no-mezcla.
- APPLOAD apuntando explícitamente a `app/uchi_bootstrap.lsp` de la instalación A.

## Pasos
1. Abrir CAD limpio.
2. Ejecutar APPLOAD sobre `.../A/app/uchi_bootstrap.lsp`.
3. Revisar consola: debe salir `[UCHI] Ruta activa: .../A/app`.
4. Ejecutar comando `UCHI`.
5. Confirmar diálogo con título **UCHI** (sin branding legacy).
6. Ejecutar comando `UCHI_TOPO`.
7. Revisar logs `[UCHI] Flujo topográfico base iniciado/completado`.
8. Forzar fallback: mover temporalmente módulos de A y dejar `UCHI_APP_DIR` a B.
9. Verificar que el sistema anuncia fallback usado y ruta final activa.
10. Restaurar módulos y repetir APPLOAD en A.

## Criterio GO
- No hay mezcla de `app/` entre instalaciones.
- No aparece `CivilCAD-like` en UI/mensajes.
- Comandos `UCHI` y `UCHI_TOPO` ejecutan sin error.
- Logs `[UCHI]` muestran ruta activa y eventos de fallback/fallo.
