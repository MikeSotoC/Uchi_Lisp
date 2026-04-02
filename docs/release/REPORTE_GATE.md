# UCHI — Reporte de Gate de Release

Fecha: 2026-04-02 06:43:17 UTC

## Contexto
Este gate prioriza estabilidad de producción y bloquea release cuando faltan artefactos críticos.

## Checks automáticos

### Whitespace check
```bash
git diff --check
```
Resultado: PASS
```text

```

### Launcher principal presente
```bash
test -f main.lsp
```
Resultado: PASS
```text

```

### Launcher no vive dentro de app/
```bash
test ! -f app/main.lsp
```
Resultado: PASS
```text

```

### Capa compatibilidad CAD presente
```bash
test -f app/uchi_cad_compat.lsp
```
Resultado: PASS
```text

```

### Branding legacy visible en UI/mensajes
```bash
rg -n 'CivilCAD-like|civilcad|CivilCAD' app/uchi_ui.lsp app/uchi_commands.lsp app/*.dcl
```
Resultado: PASS
```text
Sin coincidencias.
```

### Referencias de carga/rutas (inventario)
```bash
rg -n --glob '!.git/**' 'main.lsp|APPLOAD|app/|autoload|Support Path|support path|\(load' . || true
```
Resultado: PASS
```text
./scripts/release_gate.sh:68:run_check "Launcher principal presente" "test -f main.lsp"
./scripts/release_gate.sh:69:run_check "Launcher no vive dentro de app/" "test ! -f app/main.lsp"
./scripts/release_gate.sh:70:run_check "Capa compatibilidad CAD presente" "test -f app/uchi_cad_compat.lsp"
./scripts/release_gate.sh:71:run_must_be_empty "Branding legacy visible en UI/mensajes" "rg -n 'CivilCAD-like|civilcad|CivilCAD' app/uchi_ui.lsp app/uchi_commands.lsp app/*.dcl"
./scripts/release_gate.sh:72:run_check "Referencias de carga/rutas (inventario)" "rg -n --glob '!.git/**' 'main.lsp|APPLOAD|app/|autoload|Support Path|support path|\\(load' . || true"
./scripts/release_gate.sh:87:append "2. APPLOAD desde instalación objetivo (nueva)."
./docs/release/BACKLOG_IMPLEMENTACION.md:4:- Launcher determinista `main.lsp` fuera de `app/`.
./docs/release/COMPATIBILIDAD_CAD.md:7:- Capa `app/uchi_cad_compat.lsp` para detección de plataforma y capacidades.
./docs/release/COMPATIBILIDAD_CAD.md:22:1. APPLOAD `main.lsp`.
./docs/release/REPORTE_GATE.md:21:test -f main.lsp
./docs/release/REPORTE_GATE.md:28:### Launcher no vive dentro de app/
./docs/release/REPORTE_GATE.md:30:test ! -f app/main.lsp
./docs/release/REPORTE_GATE.md:39:test -f app/uchi_cad_compat.lsp
./docs/release/REPORTE_GATE.md:48:rg -n 'CivilCAD-like|civilcad|CivilCAD' app/uchi_ui.lsp app/uchi_commands.lsp app/*.dcl
./docs/release/REPORTE_GATE.md:57:rg -n --glob '!.git/**' 'main.lsp|APPLOAD|app/|autoload|Support Path|support path|\(load' . || true
./docs/release/PLAN_INTERVENCION_PROD.md:9:- Ruta activa derivada de `main.lsp` cargado por APPLOAD (sin fallback ambiguo por Support Path).
./docs/release/PLAN_INTERVENCION_PROD.md:10:- Carga determinista: orden explícito + validación de existencia antes de `(load ...)`.
./docs/release/SMOKE_TEST_CAD.md:4:Validar carga estable por APPLOAD, comandos base y aislamiento de ruta activa.
./docs/release/SMOKE_TEST_CAD.md:8:- APPLOAD apuntando explícitamente a `main.lsp` de la instalación A.
./docs/release/SMOKE_TEST_CAD.md:12:2. Ejecutar APPLOAD sobre `.../A/main.lsp`.
./docs/release/SMOKE_TEST_CAD.md:41:31. Restaurar módulos y repetir APPLOAD en A.
./docs/release/SMOKE_TEST_CAD.md:44:- No hay mezcla de `app/` entre instalaciones.
./main.lsp:2:;;; Cargar este archivo por APPLOAD (fuera de app/).
./main.lsp:7:(setq *uchi-launcher-name* "main.lsp")
./main.lsp:97:  ;; 1) app/ relativo al launcher cargado por APPLOAD.
./main.lsp:135:    (progn (load full nil) T)
./main.lsp:146:      (uchi:log "ERROR launcher inválido. APPLOAD debe apuntar a main.lsp fuera de app/.")
./main.lsp:153:          (uchi:log "ERROR no se pudo resolver app/. Use UCHI_APP_DIR válido o selección manual.")
```

## Gate de artefactos
Resultado: PASS — se detectaron artefactos AutoLISP/DCL.

## Smoke test manual requerido (CAD local)
1. Abrir CAD.
2. APPLOAD desde instalación objetivo (nueva).
3. Ejecutar comando principal UCHI.
4. Ejecutar flujo topográfico base.
5. Confirmar que la ruta activa [UCHI] corresponde a la instalación cargada.
6. Confirmar ausencia de branding legacy visible.
