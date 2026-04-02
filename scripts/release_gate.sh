#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REPORT="docs/release/REPORTE_GATE.md"
DATE_UTC="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

append() { printf "%s\n" "$1" >> "$REPORT"; }

run_check() {
  local name="$1"
  local cmd="$2"
  append "### ${name}"
  append '```bash'
  append "$cmd"
  append '```'
  if output=$(bash -lc "$cmd" 2>&1); then
    append "Resultado: PASS"
    append '```text'
    append "$output"
    append '```'
  else
    append "Resultado: FAIL"
    append '```text'
    append "$output"
    append '```'
    return 1
  fi
  append ""
}

run_must_be_empty() {
  local name="$1"
  local cmd="$2"
  append "### ${name}"
  append '```bash'
  append "$cmd"
  append '```'
  output=$(bash -lc "$cmd" 2>&1 || true)
  if [[ -n "$output" ]]; then
    append "Resultado: FAIL"
    append '```text'
    append "$output"
    append '```'
    return 1
  fi
  append "Resultado: PASS"
  append '```text'
  append "Sin coincidencias."
  append '```'
  append ""
}

: > "$REPORT"
append "# UCHI — Reporte de Gate de Release"
append ""
append "Fecha: ${DATE_UTC}"
append ""
append "## Contexto"
append "Este gate prioriza estabilidad de producción y bloquea release cuando faltan artefactos críticos."
append ""
append "## Checks automáticos"
append ""

run_check "Whitespace check" "git diff --check"
run_must_be_empty "Branding legacy visible en UI/mensajes" "rg -n 'CivilCAD-like|civilcad|CivilCAD' app/uchi_ui.lsp app/uchi_commands.lsp app/*.dcl"
run_check "Referencias de carga/rutas (inventario)" "rg -n --glob '!.git/**' 'APPLOAD|app/|autoload|Support Path|support path|\\(load' . || true"

append "## Gate de artefactos"
if rg --files | rg -q '\.(lsp|dcl)$'; then
  append "Resultado: PASS — se detectaron artefactos AutoLISP/DCL."
else
  append "Resultado: FAIL — no se detectaron archivos .lsp/.dcl en el repositorio."
  append "Acción: NO-GO hasta incorporar código de aplicación real."
  echo "[UCHI] FAIL: no se detectaron archivos .lsp/.dcl" >&2
  exit 2
fi

append ""
append "## Smoke test manual requerido (CAD local)"
append "1. Abrir CAD."
append "2. APPLOAD desde instalación objetivo (nueva)."
append "3. Ejecutar comando principal UCHI."
append "4. Ejecutar flujo topográfico base."
append "5. Confirmar que la ruta activa [UCHI] corresponde a la instalación cargada."
append "6. Confirmar ausencia de branding legacy visible."

printf "[UCHI] Reporte generado: %s\n" "$REPORT"
