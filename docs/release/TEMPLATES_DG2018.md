# Template DG-2018 (Perú) — UCHI

La plantilla externa `templates/pe_dg2018.tpl` contiene parámetros configurables para:

- sección transversal vial (carriles, bermas, bombeo/peralte),
- control horizontal/vertical (Rmin, pendientes, K),
- taludes/cunetas,
- estacado/replanteo,
- redes básicas y subdivisión asociada,
- presentación de perfiles/secciones/curvas.

Incluye control de subdivisión por:
- malla (`UCHI_CFG_SUBDIV_COLS`, `UCHI_CFG_SUBDIV_ROWS`), o
- número objetivo de divisiones (`UCHI_CFG_SUBDIV_NDIV`).

## Uso
1. Editar `templates/pe_dg2018.tpl` según proyecto.
2. En CAD, ejecutar `UCHI_TEMPLATE_DG`.
3. Ejecutar módulos (`UCHI_ROAD`, `UCHI_DRENAJE`, `UCHI_PERFIL`, `UCHI_SECCIONES`, etc.).

## Categorías de vía (DG-2018)
También se incluyen plantillas por categoría:
- `templates/pe_dg2018_vecinal.tpl`
- `templates/pe_dg2018_departamental.tpl`
- `templates/pe_dg2018_nacional.tpl`

Comando recomendado: `UCHI_TEMPLATE_DG_VIA` para seleccionar categoría (`VECINAL/DEPARTAMENTAL/NACIONAL`).

## Categoría + tipo de terreno
Plantillas finas por categoría y terreno:
- Vecinal: `pe_dg2018_vecinal_{plano,ondulado,accidentado}.tpl`
- Departamental: `pe_dg2018_departamental_{plano,ondulado,accidentado}.tpl`
- Nacional: `pe_dg2018_nacional_{plano,ondulado,accidentado}.tpl`

Comando recomendado: `UCHI_TEMPLATE_DG_TOPO` para seleccionar categoría + terreno.

## Nota
Los valores son base referencial y deben ser validados por especialista para categoría y condición de terreno del proyecto.
