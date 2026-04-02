# GAP funcional para acercarse a CivilCAD (sin copiar)

## Estado actual de UCHI
Actualmente UCHI ya cubre:
- launcher determinista,
- importación/validación CSV,
- dibujo base de superficie/perfil/curvas/secciones,
- reporte técnico exportable,
- compatibilidad AutoCAD/ZWCAD.

## Lo que falta para parecerse funcionalmente

### 1) Superficie/TIN real (prioridad crítica)
- Triangulación Delaunay/TIN real (no solo bbox/puntos).
- Rupturas (breaklines), límites, huecos y recorte por polígono.
- Recalcular superficie incremental al editar puntos.

### 2) Curvas avanzadas
- Curvas mayores/menores sobre TIN real (no líneas de referencia).
- Suavizado configurable y limpieza topológica.
- Etiquetado automático (cota, dirección, estilo por capa).

### 3) Alineamientos y perfiles completos
- Eje horizontal (PI, tangentes, curvas, espirales).
- Perfil longitudinal con rasante/proyecto y diferencias corte-relleno.
- Secciones transversales sobre estaciones y subestaciones.

### 4) Volúmenes y movimientos de tierra
- Cálculo corte/relleno entre superficie terreno y proyecto.
- Reportes tabulares por estación y acumulados.
- Exportables para control de obra.

### 5) Biblioteca de estilos CAD
- Capas, colores, grosores, tipos de línea, textos y bloques parametrizables.
- Plantillas por cliente/proyecto.

### 6) Importación/Interoperabilidad
- Importar/Exportar LandXML/CSV/GeoJSON.
- Transformaciones de coordenadas y sistemas de referencia.

### 7) UX de producción
- Paleta/panel persistente (además de DCL modal).
- Asistentes por tarea (wizard de superficie, wizard de perfiles).
- Mensajes de error guiados con acciones correctivas.

### 8) QA y rendimiento
- Smoke tests automatizados en AutoCAD y ZWCAD.
- Benchmarks con nubes grandes de puntos.
- Telemetría de errores y tiempos por módulo.

## Plan recomendado por fases
1. **Fase A (núcleo geométrico):** TIN real + curvas reales + breaklines.
2. **Fase B (ingeniería vial):** alineamientos + perfil longitudinal + secciones completas.
3. **Fase C (producción):** volúmenes, reportes avanzados, estilos y automatización QA.

## Nota de producto
Objetivo: igualar **capacidad funcional** sin copiar nombre, UI ni estructura propietaria.
