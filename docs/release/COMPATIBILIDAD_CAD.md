# Compatibilidad CAD (AutoCAD / ZWCAD)

## Objetivo
Asegurar que UCHI opere en AutoCAD y ZWCAD sin bifurcar código base.

## Implementación actual
- Capa `app/uchi_cad_compat.lsp` para detección de plataforma y capacidades.
- Detección de producto con `PROGRAM`/`MENUNAME` (`AutoCAD`, `ZWCAD`, fallback genérico).
- Verificación de soporte DCL antes de abrir diálogo.
- Fallback automático a modo consola cuando DCL no está disponible.

## Reglas de desarrollo
1. Toda nueva función dependiente de CAD debe pasar por helpers de compatibilidad.
2. No asumir disponibilidad de DCL: siempre contemplar fallback.
3. Logs siempre con prefijo `[UCHI]` para soporte cruzado entre AutoCAD/ZWCAD.

## Matriz mínima de validación manual
- AutoCAD (última versión disponible en entorno del cliente).
- ZWCAD (misma generación objetivo del cliente).

En ambos:
1. APPLOAD `main.lsp`.
2. Comandos `UCHI`, `UCHI_DIAG`, `UCHI_FLUJO`.
3. Validar diálogo DCL o fallback consola sin crash.

## Matriz QA automatizada (Sprint C)
- Comando: `UCHI_QA_CAD` (alias de `UCHI_QA_MATRIX`).
- Salida: `uchi_qa_cad_matrix.csv`.
- Variables de entorno:
  - `UCHI_CFG_QA_AUTOCAD_VER` (ej. `2024.1`)
  - `UCHI_CFG_QA_ZWCAD_VER` (ej. `2025`)
  - `UCHI_CFG_QA_EVID_DIR` (ej. `evidencias/qa_cad/`)
