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

### Fase 3: Motor de Empaquetado y Minificación (`make bundle`)
**Objetivo:** Crear el compilador de producción que tome todo el proyecto modular y genere un único archivo `dist/cv-engine.typ`.

1. **Desarrollo del script `scripts/bundle.py`:**
   - **Parser de dependencias:** Rastrea `#import` locales relativos y construye el grafo acíclico dirigido (DAG).
   - **Aislamiento de namespaces:** Prefija funciones internas de cada plantilla para evitar colisiones (ej. `harvard_theme`, `modern_theme`).
   - **Inyección del Router Global:** Ensambla el código en un único flujo determinista con selector de plantillas.
   - **Salida:** Genera `dist/cv-engine.typ`.

2. **Automatización en el `Makefile`:**
   ```makefile
   # Genera el archivo único para producción
   bundle:
   	python3 scripts/bundle.py --out dist/cv-engine.typ

   # Valida que el bundle funcione de forma 100% independiente
   test-bundle: bundle
   	typst compile --input data="data/cv.json" dist/cv-engine.typ build/test-bundle.pdf
   ```

---

### Fase 4: Ecosistema y Comunidad Open Source
**Objetivo:** Permitir que colaboradores de todo el mundo envíen Pull Requests agregando sus propios diseños.

1. **Guía de Contribución (`docs/CONTRIBUTING_TEMPLATES.md`):**
   - Especificación del contrato que debe cumplir cualquier nueva plantilla:
     - Implementar los 4 renderizadores de primitivas (`texto`, `entradas`, `agrupado`, `lista`).
     - Exponer la función `cv_template(data, body)`.
     - Respetar los parámetros opcionales de foto y contacto.
2. **Pruebas Automatizadas en CI/CD:**
   - Workflow en GitHub Actions que compila todos los templates registrados contra `data/cv.example.json` en cada Pull Request para asegurar que ninguno se rompa.
