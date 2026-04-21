# 🇵🇪 CIVILCAD-PERÚ v1.0.0
## Suite CAD Profesional para Ingeniería Civil

Sistema completo de ingeniería civil para AutoCAD, implementando normativa peruana (RNE, DG-1999, MVCS).

---

## 📋 REQUISITOS

- AutoCAD 2016 o superior
- Visual LISP habilitado
- Sistema operativo Windows

---

## 🚀 INSTALACIÓN

### Método 1: Carga Manual

1. Abra AutoCAD
2. Ejecute el comando `APPLOAD`
3. Navegue a la carpeta `CIVILCAD-PERU`
4. Seleccione `loader.lsp`
5. Haga clic en "Load"

### Método 2: Carga Automática

Agregue al `acaddoc.lsp`:

```lisp
(load "C:/ruta/a/CIVILCAD-PERU/loader.lsp")
```

### Método 3: Startup Suite

1. Ejecute `APPLOAD`
2. Haga clic en "Contents" en Startup Suite
3. Agregue `loader.lsp`

---

## 🎯 USO BÁSICO

### Iniciar el Sistema

Después de cargar el loader:

```lisp
(CCP_LAUNCHER)
```

O use el menú en modo consola que aparecerá automáticamente.

### Comandos Principales

| Comando | Descripción |
|---------|-------------|
| `(CCP_LAUNCHER)` | Inicia la interfaz principal |
| `(CCP_run-module "topografia")` | Ejecuta módulo de topografía |
| `(CCP_run-module "carreteras")` | Ejecuta módulo de carreteras |
| `(CCP_run-module "saneamiento")` | Ejecuta módulo de saneamiento |
| `(CCP_run-module "estructuras")` | Ejecuta módulo de estructuras |
| `(CCP_run-module "reportes")` | Ejecuta módulo de reportes |
| `(CCP_test-runner)` | Ejecuta pruebas del sistema |
| `(CCP_validar-instalacion)` | Valida instalación correcta |

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
CIVILCAD-PERU/
├── loader.lsp              # Punto de entrada principal
├── launcher.lsp            # Interfaz de usuario
├── launcher.dcl            # Diálogo DCL
│
├── /core/
│   ├── core.lsp            # Funciones núcleo
│   ├── registry.lsp        # Registro de módulos
│   └── dispatcher.lsp      # Ejecutor de módulos
│
├── /lib/
│   ├── utils.lsp           # Utilidades generales
│   ├── dcl-helpers.lsp     # Ayudas para DCL
│   ├── dwg-tools.lsp       # Herramientas DWG
│   ├── rne-constants.lsp   # Normativa peruana
│   └── logging.lsp         # Sistema de logs
│
├── /modules/
│   ├── topografia/         # Módulo de topografía
│   ├── carreteras/         # Módulo de carreteras
│   ├── saneamiento/        # Módulo de saneamiento
│   ├── estructuras/        # Módulo de estructuras
│   └── reportes/           # Módulo de reportes
│
├── /config/
│   ├── settings.lsp        # Configuración general
│   ├── units.lsp           # Sistemas de unidades
│   └── modules.lsp         # Configuración de módulos
│
├── /logs/                  # Archivos de log
├── /test/                  # Pruebas del sistema
└── README.md               # Este archivo
```

---

## 🏗️ MÓDULOS DISPONIBLES

### 1. TOPOGRAFÍA

- **Importar Puntos CSV**: Lee archivos CSV con coordenadas UTM
- **Curvas de Nivel**: Generación de curvas (equidistancia configurable)
- **Áreas y Perímetros**: Cálculo preciso de propiedades geométricas
- **Poligonales**: Dibujo y cálculo de poligonales cerradas/abiertas

Formato CSV esperado:
```csv
Este,Norte,Cota,Código,Descripción
500000.00,9000000.00,150.500,PV1,Vértice 1
500025.50,9000012.30,151.200,PV2,Vértice 2
```

### 2. CARRETERAS (DG-1999)

- **Curvas Horizontales**: Diseño según velocidad directriz
- **Peraltes**: Cálculo automático según radio y velocidad
- **Visibilidad**: Verificación de distancia de parada/adelantamiento
- **Eje**: Dibujo de alineamiento horizontal

Parámetros DG-1999 implementados:
- Radios mínimos por velocidad
- Peraltes máximos (8% autopista, 10% rural)
- Distancias de visibilidad

### 3. SANEAMIENTO (MVCS)

- **Agua Potable**: Dimensionamiento de tuberías
- **Hazen-Williams**: Cálculo de pérdida de carga
- **Manning**: Diseño de colectores de desagüe
- **DOT**: Dimensionamiento poblacional

Coeficientes incluidos:
- PVC: n=0.009, C=150
- Concreto: n=0.013, C=130
- Velocidades: 0.60 - 4.00 m/s

### 4. ESTRUCTURAS (RNE)

- **Vigas (E.060)**: Diseño por flexión
- **Columnas (E.060)**: Diseño por compresión
- **Cálculo Sísmico (E.030)**: Corte basal
- **Zapatas (E.050)**: Diseño geotécnico

Normas RNE implementadas:
- E.020: Cargas
- E.030: Diseño Sismorresistente
- E.050: Suelos y Cimentaciones
- E.060: Concreto Armado

### 5. REPORTES

- **Memoria Descriptiva**: Plantilla profesional
- **Tabla de Puntos**: Exportación de coordenadas
- **Cuadro de Áreas**: Resumen de lotes
- **Reporte Técnico**: Archivo TXT externo

---

## 🇵🇪 NORMATIVA PERUANA

### Topografía (IGNP)

| Zona | Código | Meridiano Central |
|------|--------|-------------------|
| 17S | 32717 | -81° |
| 18S | 32718 | -75° |
| 19S | 32719 | -69° |

Precisión según IGNP:
- Planimétrica urbana: 0.01 m
- Altimétrica urbana: 0.02 m

### Carreteras (DG-1999)

| Clase | Vel (km/h) | Radio Mín (m) |
|-------|------------|---------------|
| I-1 | 120 | 680 |
| I-2 | 100 | 420 |
| II-3 | 80 | 250 |
| II-4 | 60 | 125 |
| III-5 | 40 | 55 |

### Estructuras (RNE)

**E.030 - Zonas Sísmicas:**
- Zona 3 (Costa): Z = 0.40
- Zona 2 (Selva): Z = 0.20
- Zona 1 (Sierra): Z = 0.10

**E.060 - Concreto:**
- f'c mínimo: 175 kg/cm²
- f'c usual: 210 kg/cm²
- fy acero: 4200 kg/cm²

---

## 🔧 CONFIGURACIÓN

### Unidades

El sistema soporta:
- Métrico (default)
- UTM WGS84
- Arquitectónico
- Ingeniería

### Capas por Defecto

| Capa | Color | Uso |
|------|-------|-----|
| TOPO-PUNTOS | Rojo (1) | Puntos topográficos |
| TOPO-CURVAS | Verde (3) | Curvas de nivel |
| EJE | Rojo (1) | Eje de carretera |
| AGUA-TUBERIA | Cyan (4) | Tuberías de agua |
| DESAGUE-COLECTOR | Verde (3) | Colectores |

---

## 🧪 PRUEBAS

Ejecute el test runner para validar la instalación:

```lisp
(CCP_test-runner)
```

Pruebas incluidas:
- Utilidades básicas
- Validación UTM Perú
- Cálculos topográficos
- Parámetros DG-1999
- Coeficientes MVCS
- Valores RNE

---

## 📝 LOGGING

El sistema genera logs en `/logs/civilcad.log`

Niveles de log:
- DEBUG: Información detallada
- INFO: Operaciones normales
- WARNING: Advertencias
- ERROR: Errores recuperables
- FATAL: Errores críticos

---

## ⚠️ LIMITACIONES

1. Las curvas de nivel usan interpolación básica
2. El diseño de curvas horizontales no incluye espirales
3. Los reportes son plantillas básicas

---

## 📞 SOPORTE

Para reporte de errores o sugerencias, revise el archivo de log y contacte al administrador del sistema.

---

## 📄 LICENCIA

Software desarrollado para uso profesional en ingeniería civil en Perú.

---

## 👥 CRÉDITOS

Desarrollado siguiendo estándares de:
- Reglamento Nacional de Edificaciones (RNE)
- Ministerio de Transportes y Comunicaciones (DG-1999)
- Ministerio de Vivienda, Construcción y Saneamiento (MVCS)
- Instituto Geográfico Nacional (IGNP)

---

**Versión:** 1.0.0  
**Fecha:** 2024  
**Compatibilidad:** AutoCAD 2016+
