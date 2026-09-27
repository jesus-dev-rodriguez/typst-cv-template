# AGENTS.md — Memoria de Arquitectura y Guía Operativa del Proyecto

Este archivo es leído automáticamente por **Antigravity CLI** al iniciar cualquier sesión en este workspace. Actúa como el **Memory Bank** y atajo arquitectónico para entender, mantener y modificar el proyecto sin necesidad de reexplorar los archivos desde cero.

---

## 1. Visión y Propósito del Proyecto
- **Objetivo:** Generar de forma dinámica, agnóstica y desacoplada Curriculum Vitaes profesionales con múltiples plantillas (`harvard`, `modern`), soporte opcional para avatar/foto de perfil, tipografía optimizada y maquetación estricta en una sola página.
- **Motor:** Typst v0.15.x.
- **Fuente de Verdad:** `data/cv.json` validado contra `schema/cv.schema.json`.
- **Principio Fundamental (Inversión de Dependencias y Multi-Plantilla):** Typst **no conoce** nombres de secciones fijas (educación, experiencia, etc.). Las plantillas implementan **4 primitivas de maquetación universales** (`texto`, `entradas`, `agrupado`, `lista`). El orquestador `main.typ` selecciona la plantilla solicitada en el JSON (`"plantilla": "harvard" | "modern"`), defaulting a `"harvard"`.

---

## 2. Mapa de Arquitectura y Responsabilidades

```text
cv/
├── AGENTS.md                      # [Este archivo] Memoria persistente y reglas del workspace para IA
├── .vscode/
│   └── settings.json              # Mapeo automático de schema para data/*.json sin dependencias web
├── schema/
│   └── cv.schema.json             # Especificación JSON Schema formal con autocompletado y validación
├── docs/
│   ├── SCHEMA.md                  # Guía de usuario con ejemplos de cada tipo de sección y plantilla
│   └── ROADMAP.md                 # Planificación y hoja de ruta (Multi-plantilla y Bundling)
├── data/
│   ├── cv.example.json            # Plantilla inicial de ejemplo con todas las secciones y foto
│   └── cv.json                    # Datos estructurados del candidato según cv.schema.json
├── src/
│   ├── core/
│   │   ├── inputs.typ             # load_cv_data(), get_template_name(), get_paper_format() (sys.inputs)
│   │   └── media.typ              # render_avatar() universal (rutas locales y Base64 URIs)
│   └── templates/                 # Ecosistema desacoplado de plantillas
│       ├── harvard/               # Plantilla clásica académica serif (1 columna)
│       │   ├── theme.typ          # Variables de diseño (Libertinus Serif, márgenes, grises)
│       │   ├── components/        # Header centrado, cv_entry, section_title
│       │   ├── renderers/         # 4 renderizadores de layouts universales
│       │   └── template.typ       # Función harvard_cv(cv-data, paper: "a4")
│       └── modern/                # Plantilla contemporánea sans-serif + foto opcional
│           ├── theme.typ          # Variables de diseño (Liberation Sans, acento #1d3557)
│           ├── components/        # Header adaptativo con foto, cv_entry, section_title
│           ├── renderers/         # 4 renderizadores con estética moderna
│           └── template.typ       # Función modern_cv(cv-data, paper: "a4")
├── dist/                          # Artefactos empaquetados para producción
│   └── cv-engine.typ              # Archivo único autocontenido (distribuible para SPAs/APIs)
├── scripts/
│   └── bundle.py                  # Compilador/empaquetador monolítico modular hacia dist/
├── build/                         # Artefactos de salida compilados (ignorado por git)
│   ├── cv.pdf                     # PDF final generado
│   └── preview-1.png              # Vista previa en imagen
├── Makefile                       # Automatización (all, watch, png, bundle, test-bundle, clean)
├── main.typ                       # Router raíz: selecciona harvard_cv o modern_cv según cv-data.plantilla
├── .agents/skills/typst/          # Skill especializada de Typst 0.15+ (sintaxis moderna, CLI)
└── README.md                      # Documentación pública para el usuario humano
```

### Flujo de Datos
```mermaid
flowchart TD
    S["schema/cv.schema.json"] -. Valida .-> A["data/cv.json"]
    A -->|json()| B["main.typ (Router)"]
    B -->|plantilla == 'harvard'| C["src/templates/harvard/template.typ: harvard_cv"]
    B -->|plantilla == 'modern'| D["src/templates/modern/template.typ: modern_cv"]
    CORE["src/core/media.typ"] -.-> D
    C & D -->|make (typst compile)| H["build/cv.pdf"]
```

---

## 3. Protocolo para Realizar Modificaciones

### A. Para agregar o modificar secciones o datos en el CV:
1. **No tocar código Typst.** Abrir `data/cv.json`.
2. Para cambiar de plantilla, especificar en la raíz: `"plantilla": "harvard"` o `"plantilla": "modern"`.
3. Para agregar foto en `modern`, definir en `datos_personales`: `"foto": "assets/foto.jpg"` o `"foto": "data:image/jpeg;base64,..."`.
4. Agregar o modificar objetos dentro del arreglo `"secciones"` eligiendo la primitiva adecuada:
   - `"tipo": "texto"` (Objetivos, perfiles, cartas).
   - `"tipo": "entradas"` (Experiencia, educación, proyectos, premios).
   - `"tipo": "agrupado"` (Habilidades, certificaciones por entidad, idiomas).
   - `"tipo": "lista"` (Pasatiempos, lecturas, referencias).
5. **Reordenar secciones:** Cambiar el orden de los objetos en `"secciones"` altera el orden en el PDF al instante.
6. **Validar compilación:** Ejecutar `make` y verificar que el diseño se mantenga dentro de 1 página.

### B. Para ajustar estilos de una plantilla:
- Modificar el archivo `theme.typ` correspondiente dentro de `src/templates/<nombre_plantilla>/theme.typ`.

---

## 4. Comandos Críticos de Compilación y Entorno

- **Compilar PDF (por defecto):** `make` (o `make pdf` -> genera `build/cv.pdf`)
- **Modo Watch (desarrollo en vivo):** `make watch`
- **Generar preview PNG:** `make png` (-> genera `build/preview-1.png`)
- **Empaquetar bundle de producción:** `make bundle` (-> genera `dist/cv-engine.typ`)
- **Validar suite de pruebas del bundle:** `make test-bundle`
- **Limpiar artefactos:** `make clean`
- **Ambiente Linux con Typst en Snap:** Si la ruta del proyecto está montada en `/mnt/`, Typst requiere:
  ```bash
  sudo snap connect typst:removable-media
  ```

---

## 5. Registro de Decisiones de Arquitectura (ADR Log)

| ID | Fecha | Decisión / Cambio | Contexto y Razón |
| :--- | :--- | :--- | :--- |
| **ADR-001** | 2026-09-25 | Desacoplamiento JSON + Typst modular | Separar 100% los datos del diseño para permitir actualizar el CV sin tocar código Typst. |
| **ADR-002** | 2026-09-25 | Agrupamiento dinámico de certificaciones | 10 certificaciones individuales saturaban el espacio vertical; se agruparon por institución (`Digital House`, `Platzi`). |
| **ADR-003** | 2026-09-25 | Distribución de cabecera en 2 líneas de contacto | Evitar que la URL de LinkedIn se partiera con guiones; línea 1 (ubicación + tel), línea 2 (email + linkedin). |
| **ADR-004** | 2026-09-25 | Prioridad de fuentes con `Libertinus Serif` nativa | Prevenir warnings de fuentes en Linux sin Microsoft Core Fonts instaladas, garantizando estética Harvard. |
| **ADR-005** | 2026-09-26 | Adopción de `AGENTS.md` como Memory Bank | Permitir a Antigravity CLI cargar automáticamente el contexto del proyecto al iniciar cualquier sesión. |
| **ADR-006** | 2026-09-26 | Centralización de artefactos en `build/` vía `Makefile` | Evitar contaminar la raíz del código fuente con PDFs y PNGs generados. |
| **ADR-007** | 2026-09-26 | Motor agnóstico e inversión de dependencias con JSON Schema | Eliminar secciones hardcodeadas en Typst (`src/sections/*`) reemplazándolas por 4 primitivas polimórficas (`texto`, `entradas`, `agrupado`, `lista`) y contrato formal `schema/cv.schema.json`. |
| **ADR-008** | 2026-09-26 | Desacoplamiento de Schema Web y adopción de modelo local portable | Evitar puntos únicos de falla (repos privados, cambios de URL, falta de conexión) mediante rutas relativas y `.vscode/settings.json`, permitiendo a organizaciones usar schemas corporativos propios. |
| **ADR-009** | 2026-09-26 | Arquitectura Multi-Plantilla con Router Dinámico y Soporte de Foto | Modularizar `src/templates/` (`harvard`, `modern`) y `src/core/media.typ` permitiendo alternar templates y avatares (archivos locales o Base64) desde el JSON con retrocompatibilidad absoluta. |
| **ADR-010** | 2026-09-26 | Soporte Universal de Entrada con `sys.inputs` y Parametrización en `Makefile` | Desacoplar la E/S de Typst permitiendo cargar datos desde archivos externos o strings JSON en memoria (APIs/SPAs), y seleccionar plantilla (`TEMPLATE=`) y dataset (`DATA=`) desde la línea de comandos y el Makefile. |
| **ADR-012** | 2026-09-26 | Estandarización de Contrato de Contribución Abierta de Plantillas | Publicar guía formal para diseñadores (`docs/CONTRIBUTING_TEMPLATES.md`) para extender el catálogo de plantillas con autodescubrimiento en `bundle.py` y validación local de compilación. |

