---
name: typst
description: >-
  Comprehensive guide and workflows for Typst 0.15+.
  Use when writing, structuring, styling, debugging, or compiling Typst documents,
  templates, academic papers, books, reports, presentations, and dynamic CVs/resumes.
---

# Typst Expert Skill (v0.15+)

Esta skill provee instrucciones detalladas, mejores prácticas y patrones de diseño para trabajar con **Typst v0.15.x**, incluyendo desarrollo modular de documentos, integración dinámica con datos externos (JSON/YAML/CSV) y maquetación tipográfica avanzada.

---

## 1. Reglas y Novedades de la Versión Actual (0.15.x)

1. **Rutas con barras inclinadas (`/`) obligatorias:**
   - Todas las rutas en `#import`, `#include` e `image()` deben usar `/`.
   - El uso de barras invertidas (`\`) causará un error de sintaxis en 0.15+.
2. **Uso de fuentes variables:**
   - Soporte nativo mediante `#set text(font: "Nombre", variations: (wght: 600, ...))`.
3. **Nuevo elemento `divider()`:**
   - Se puede usar `#divider()` para saltos temáticos o separadores estilizados mediante reglas `show`.
4. **Introspección con selector `within`:**
   - Reemplaza búsquedas manuales complejas para elementos contenidos dentro de secciones o etiquetas específicas.
5. **CLI `typst eval`:**
   - Reemplaza y generaliza la funcionalidad previa de `typst query`.

Para consultar la referencia completa de sintaxis, funciones de cálculo y estructuras de datos, consulta [syntax_cheatsheet.md](./references/syntax_cheatsheet.md).

---

## 2. Arquitectura de Proyectos Recomendada

Para mantener proyectos limpios, modulares y fáciles de mantener (como plantillas, libros o CVs dinámicos):

```text
proyecto/
├── data/                      # Fuentes de datos estructurados (.json, .yaml, .csv)
│   └── datos.json
├── src/
│   ├── styles/                # Variables de diseño, fuentes, paletas de colores
│   │   └── theme.typ
│   ├── components/            # Bloques atómicos reutilizables (títulos, encabezados, tarjetas)
│   │   ├── header.typ
│   │   └── section_title.typ
│   ├── sections/              # Secciones que consumen datos y renderizan componentes
│   │   ├── education.typ
│   │   └── experience.typ
│   └── template.typ           # Función base (#show: template.with(...)) que configura página y metadatos
├── main.typ                   # Punto de entrada que orquesta la carga de datos y secciones
└── README.md
```

---

## 3. Patrón de Plantilla Idiomático (Show-Rule Pattern)

Toda plantilla profesional en Typst debe exponer una función receptora de contenido (`body`) para usarse con la regla `#show`:

```typst
// src/template.typ
#import "styles/theme.typ": *

#let documento_template(
  titulo: "Documento",
  autor: "Autor",
  papel: "a4",
  body
) = {
  set document(title: titulo, author: autor)
  set page(paper: papel, margin: (x: 1.5cm, y: 1.5cm))
  set text(font: ("Times New Roman", "Libertinus Serif"), size: 10pt, lang: "es")
  set par(justify: true, leading: 0.6em)

  body
}
```

Uso en `main.typ`:
```typst
#import "src/template.typ": documento_template

#show: documento_template.with(
  titulo: "Curriculum Vitae",
  autor: "Jesús Matías Rodríguez"
)

= Sección Principal
Contenido del documento...
```

---

## 4. Consumo Reactivo de Datos (JSON, YAML, CSV)

Typst parsea automáticamente los formatos comunes a estructuras nativas (`dict` y `array`):

```typst
#let datos = json("data/cv.json")

// Iteración segura con fallbacks predeterminados:
#for item in datos.at("experiencia", default: ()) [
  #block[
    *#item.puesto* — #item.empresa \
    #text(fill: luma(100), item.periodo)
  ]
]
```

---

## 5. Compilación y Diagnóstico

- **Compilar a PDF:** `typst compile main.typ salida.pdf`
- **Modo interactivo (Live Reload):** `typst watch main.typ salida.pdf`
- **Solución a `error: failed to load file (access denied)` (Snap en Linux):**
  Si Typst está instalado como Snap y el repositorio está en una partición montada (ej. `/mnt/`), ejecutar:
  ```bash
  sudo snap connect typst:removable-media
  ```

Para detalles adicionales de opciones de línea de comandos y variables de entorno, consulta [cli.md](./references/cli.md).
