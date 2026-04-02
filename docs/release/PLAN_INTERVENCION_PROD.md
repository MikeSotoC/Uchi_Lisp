# Plan de intervención de producción UCHI (desde cero)

## Fase 1 — Contención
- Congelar features no críticas.
- Exigir evidencia de artefactos `.lsp/.dcl` para habilitar release.
- Bloquear release automático si no existe base de app.

## Fase 2 — Hardening técnico
- Ruta activa derivada de `main.lsp` cargado por APPLOAD (sin fallback ambiguo por Support Path).
- Carga determinista: orden explícito + validación de existencia antes de `(load ...)`.
- Compatibilidad backward: aceptar claves legacy en lectura y serializar con naming UCHI.
- Logging mínimo obligatorio con prefijo `[UCHI]` + archivo rotativo `uchi_runtime.log`.
- Ejecutar migración de variables legacy con `UCHI_MIGRAR` antes de smoke final.

## Fase 3 — Release hygiene
- Commits atómicos: `hotfix(app-dir):`, `refactor(branding):`, `chore(release):`.
- Gate automatizado: `scripts/release_gate.sh`.
- Smoke test CAD manual en estación local antes de GO.

## Política GO/NO-GO
- GO solo si:
  1. existe código AutoLISP/DCL,
  2. branding legacy no visible,
  3. checks automáticos en PASS,
  4. smoke test CAD validado.
- Cualquier incumplimiento = NO-GO.
