# Hoja de Ruta: Sistema Multi-Plantilla y Empaquetador de Producción (`cv-engine.typ`)

Este documento define la planificación estratégica y técnica para evolucionar el generador de CVs hacia un **ecosistema multi-plantilla** con empaquetado para distribución en un único archivo `.typ`.

---

## 🧭 Visión del Sistema Final

```text
               ┌────────────────────────────────────────────────────────┐
               │              Servidor / SPA / CLI / Lambda             │
               │                                                        │
               │   1. dist/cv-engine.typ  (Archivo único autocontenido) │
               │   2. usuario.json        (Datos + plantilla + foto)    │
               └──────────────────────────┬─────────────────────────────┘
                                          │
                                          ▼
     typst compile --input data="usuario.json" dist/cv-engine.typ output.pdf
```

Cualquier sistema externo solo requerirá el binario de Typst, el archivo único `dist/cv-engine.typ` y el archivo JSON para compilar cualquier CV con la plantilla y foto deseada.

---

## 📅 Fases de Implementación

### Fase 1: Arquitectura Multi-Plantilla (✅ Completada)
**Objetivo:** Reestructurar el código para que el repositorio albergue múltiples plantillas independientes compartiendo el mismo esquema JSON universal.

- [x] **Reorganización modular de `src/`:** `src/core/media.typ`, `src/templates/harvard/`, `src/templates/modern/`.
- [x] **Actualización de `schema/cv.schema.json`:** Soporte de `"plantilla"` (`"harvard"` | `"modern"`) y `"foto"` en `datos_personales`.
- [x] **Plantilla `modern`:** Sans-serif contemporánea, paleta azul marino (`#1d3557`), soporte de avatar y renderizadores universales.
- [x] **Router Dinámico (`main.typ`):** Selección automática por JSON con fallback a `"harvard"` para retrocompatibilidad total.
- [x] **Soporte de Foto Universal (`src/core/media.typ`):** Soporta tanto rutas de archivo locales como Data URIs en Base64.
   ```text
   src/
   ├── core/                      # Utilidades universales compartidas
   │   ├── inputs.typ             # Lector dinámico de sys.inputs (archivos o string JSON)
   │   └── media.typ              # Decodificador de imágenes base64 o rutas
   └── templates/                 # Directorio modular de plantillas
       ├── harvard/               # Nuestra plantilla actual
       │   ├── theme.typ
       │   ├── template.typ
       │   └── renderers/
       ├── modern/                # Nueva plantilla (2 columnas, sans-serif, acentos de color)
       │   ├── theme.typ
       │   ├── template.typ
       │   └── renderers/
       └── minimal/               # Plantilla minimalista sobria
           ├── theme.typ
           ├── template.typ
           └── renderers/
   ```

2. **Actualización de `schema/cv.schema.json`:**
   - Incorporar campo `"plantilla"` en la raíz:
     ```json
     "plantilla": {
       "type": "string",
       "enum": ["harvard", "modern", "minimal"],
       "default": "harvard",
       "description": "Plantilla visual a utilizar para renderizar el CV."
     }
     ```
   - Permitir campo opcional `"foto"` en `datos_personales` (acepta ruta local o URI base64).

3. **Orquestador Dinámico (`main.typ`):**
   - Router de plantillas que lee `cv-data.at("plantilla", default: "harvard")` y delega a la plantilla seleccionada.

---

### Fase 2: Soporte Universal de Entrada (`sys.inputs`) (✅ Completada)
**Objetivo:** Permitir que Typst reciba los datos de forma nativa desde la línea de comandos o en memoria sin depender de rutas rígidas.

- [x] **Resolución Universal (`src/core/inputs.typ`):**
  - Carga en memoria mediante `json(bytes(raw))` para SPAs, APIs REST y lambdas.
  - Carga desde disco con rutas flexibles relativas o absolutas.
  - Fallback por defecto a `data/cv.json`.
  - Sobreescritura de plantilla (`get_template_name`) y formato de papel (`get_paper_format`) vía `sys.inputs`.
- [x] **Parametrización en el `Makefile`:**
  - `DATA=<archivo>` con resolución inteligente en `data/` (ej. `make pdf DATA=cv.example.json`).
  - `TEMPLATE=<plantilla>` para forzar `harvard` o `modern`.
  - `PAPER=<formato>` para alternar entre `a4` y `us-letter`.
- [x] **Compatibilidad Total:** `make all png` sin parámetros mantiene idéntica la experiencia de desarrollo local.

---

### Fase 3: Motor de Empaquetado y Minificación (`make bundle`) (✅ Completada)
**Objetivo:** Crear el compilador de producción que tome todo el proyecto modular y genere un único archivo `dist/cv-engine.typ`.

- [x] **Script empaquetador (`scripts/bundle.py`):**
  - Deduplicación de paquetes `@preview/...`.
  - Inlining del núcleo (`media.typ`, `inputs.typ`).
  - Auto-descubrimiento de plantillas en `src/templates/`.
  - Encapsulamiento en módulos diccionario Typst (`#let harvard = { ... }`, `#let modern = { ... }`) para prevenir 100% las colisiones de variables y funciones.
  - Inyección del Router Polimórfico (`available_templates.at(...)`).
  - Generación de `dist/cv-engine.typ`.
- [x] **Automatización en el `Makefile`:**
  - `make bundle`: Genera el archivo único distribuible.
  - `make test-bundle`: Ejecuta suite de validación completa (Harvard, Modern y JSON en memoria).
- [x] **Independencia Total:** Verificado en entornos externos aislados fuera del repositorio.

---

### Fase 4: Ecosistema y Comunidad Open Source (✅ Completada)
**Objetivo:** Permitir que colaboradores de todo el mundo envíen Pull Requests agregando sus propios diseños de forma segura.

- [x] **Guía de Contribución ([`docs/CONTRIBUTING_TEMPLATES.md`](CONTRIBUTING_TEMPLATES.md)):**
  - Documentación exhaustiva del contrato de las 4 primitivas de maquetación universales (`texto`, `entradas`, `agrupado`, `lista`).
  - Especificación de estructura en `src/templates/<nombre>/` y firma obligatoria `<nombre>_cv(cv-data, paper: "a4")`.
  - Explicación del autodescubrimiento automático en `scripts/bundle.py`.
- [x] **Suite de Validación Local Automatizada:**
  - Validación de datasets JSON contra `schema/cv.schema.json`.
  - Compilación automática con Typst de `main.typ` (`make all png`).
  - Batería de pruebas de producción del bundle (`make test-bundle`).
- [x] **100% de la Hoja de Ruta Alcanzada:** El proyecto está completamente desacoplado, empaquetado y listo para ser publicado como código abierto.

