# Typst 0.15+ Syntax & API Cheatsheet

Guía rápida de referencia para Typst v0.15.x.

---

## 1. Modos de Ejecución

Typst opera en tres modos principales:
1. **Modo Marcado (Markup):** Texto estándar con sintaxis tipo markdown (`*negrita*`, `_cursiva_`, `= Título`, `- Lista`).
2. **Modo Código (Code):** Se introduce con `#` para una expresión (`#let x = 5`, `#import ...`) o bloque `# { ... }`.
3. **Modo Matemático (Math):** Delimitado por `$ ... $` para fórmulas en línea o `$ ... $` en bloque.

---

## 2. Novedades y Reglas Críticas (v0.15.x)

- **Rutas de Archivos (Breaking Change):** Las rutas en `#import`, `#include` y funciones como `image()` **deben usar barras inclinadas (`/`)** en todos los sistemas operativos. Las barras invertidas (`\`) están prohibidas.
- **Fuentes Variables:** Soporte nativo a través de `text(font: "Inter", variations: (wght: 600, slnt: -10))`.
- **Nuevo elemento `divider()`:** Elemento temático para separadores configurables con `show divider: ...`.
- **Selector `within`:** Facilita la introspección contextual (ej. `heading.within(<capitulo1>)`).
- **Colecciones funcionales:**
  - `dict.map((k, v) => ...)` y `dict.filter((k, v) => ...)`
  - `arguments.filter(...)` y acceso a argumentos con nombre por punto (`args.mi_param`).
- **Int.min / Int.max:** Constantes numéricas de límite del sistema.
- **Paths de primera clase:** El tipo `path` permite pasar rutas relativas entre paquetes y archivos de manera segura.

---

## 3. Carga Dinámica de Datos

Typst incluye parsers integrados de alto rendimiento:

```typst
#let json-data = json("ruta/al/archivo.json")
#let csv-data  = csv("ruta/al/archivo.csv")
#let yaml-data = yaml("ruta/al/archivo.yaml")
#let toml-data = toml("ruta/al/archivo.toml")
#let raw-text  = read("ruta/al/archivo.txt")
```

---

## 4. Reglas `set` y `show`

### `set` (Configura valores por defecto)
```typst
set document(title: "Documento", author: "Nombre")
set page(paper: "a4", margin: (x: 1.5cm, y: 2cm))
set text(font: "Libertinus Serif", size: 10pt, lang: "es")
set par(justify: true, leading: 0.65em)
```

### `show` (Transforma o envuelve elementos)
```typst
// Plantilla como función global
#show: doc => mi_plantilla(doc)

// Personalizar un elemento específico
#show heading.where(level: 1): it => block[
  #text(size: 14pt, weight: "bold", upper(it.body))
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt)
]

// Reemplazos de texto dinámico
#show "TODO": text(fill: red, weight: "bold", "PENDIENTE")
```

---

## 5. Diseño y Layout

- **`grid(columns: (1fr, auto), align: (left, right), ...)`**: Ideal para filas de CVs (empresa a la izquierda, fecha a la derecha).
- **`stack(dir: ttb, spacing: 5pt, ...)`**: Apilamiento unidireccional.
- **`block(width: 100%, spacing: 6pt)[ ... ]`**: Contenedor aislado de bloque con control de saltos de página.
- **`box[ ... ]`**: Contenedor a nivel de línea (inline).
- **`align(center)[ ... ]`**: Alineación horizontal o vertical (`top + left`, `center + horizon`, etc.).
- **`line(length: 100%, stroke: 0.5pt + black)`**: Líneas divisorias directas.
