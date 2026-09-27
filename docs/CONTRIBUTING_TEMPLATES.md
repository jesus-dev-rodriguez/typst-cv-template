# Guía de Contribución: Creación de Nuevas Plantillas

¡Gracias por tu interés en diseñar o contribuir con una nueva plantilla para el generador de CVs! 

Este proyecto se basa en la **inversión de dependencias**: las plantillas no implementan secciones fijas (como "educación" o "experiencia"), sino que implementan **4 primitivas universales de maquetación**. De esta forma, cualquier usuario puede añadir o reordenar secciones en su JSON y tu plantilla las renderizará de forma consistente, armónica y profesional.

---

## 🏛️ 1. Arquitectura y Principio de Aislamiento

Cada plantilla reside en su propio directorio aislado bajo `src/templates/<nombre_plantilla>/`. 

```text
src/templates/<nombre_plantilla>/
├── theme.typ                  # Tipografías, paleta de colores, márgenes y espaciados
├── components/                # Bloques atómicos reutilizables
│   ├── header.typ             # Cabecera (nombre, título, contactos, foto opcional)
│   ├── entry.typ              # Primitiva de doble fila alineada izquierda/derecha
│   └── section_title.typ      # Título de sección con estilo visual distintivo
├── renderers/                 # Los 4 renderizadores universales obligatorios
│   ├── text_renderer.typ      # tipo: "texto" (párrafos corridos)
│   ├── entries_renderer.typ   # tipo: "entradas" (experiencia, educación, proyectos)
│   ├── grouped_renderer.typ   # tipo: "agrupado" (habilidades, cursos, idiomas)
│   └── list_renderer.typ      # tipo: "lista" (viñetas simples, pasatiempos)
└── template.typ               # Función maestra: <nombre_plantilla>_cv(cv-data, paper: "a4")
```

> [!TIP]
> **Autodescubrimiento Automático:**
> El empaquetador de producción ([`scripts/bundle.py`](../scripts/bundle.py)) escanea automáticamente la carpeta `src/templates/`. Al crear tu carpeta con esta estructura, tu plantilla será integrada automáticamente en el bundle distribuible `dist/cv-engine.typ` sin necesidad de tocar ningún script de Python ni configurar nada extra.

---

## 📐 2. El Contrato de las 4 Primitivas de Maquetación

Toda plantilla debe implementar exactamente estos cuatro renderizadores en su carpeta `renderers/`:

### 1. `text_renderer.typ`: `render_text(title, content)`
- **Propósito:** Párrafos descriptivos corridos (ej. *Objetivo Profesional*, *Perfil*, *Acerca de mí*).
- **Parámetros:**
  - `title`: String con el título de la sección.
  - `content`: String con el texto del párrafo.

### 2. `entries_renderer.typ`: `render_entries(title, items)`
- **Propósito:** Entradas cronológicas de doble nivel (ej. *Experiencia Laboral*, *Formación Académica*, *Proyectos Destacados*).
- **Parámetros de cada ítem:**
  - `primario_izq` / `primary_left`: Empresa, universidad o título principal en negrita.
  - `primario_der` / `primary_right`: Fecha o período a la derecha.
  - `secundario_izq` / `secondary_left`: Cargo, título obtenido o distinción en cursiva/secundario.
  - `secundario_der` / `secondary_right`: Ubicación o detalle secundario a la derecha.
  - `descripcion` / `description` (opcional): Breve resumen del rol.
  - `vinetas` / `items` / `highlights` (opcional): Lista de logros o responsabilidades.

### 3. `grouped_renderer.typ`: `render_grouped(title, groups)`
- **Propósito:** Elementos agrupados por categoría (ej. *Habilidades Técnicas*, *Certificaciones por Institución*, *Idiomas*).
- **Parámetros de cada grupo:**
  - `categoria` / `category`: Nombre de la categoría destacada (ej. `"Lenguajes"` o `"Digital House"`).
  - `elementos` / `items`: Lista de strings con las tecnologías o cursos separados por viñetas o comas.

### 4. `list_renderer.typ`: `render_list(title, items)`
- **Propósito:** Lista directa de viñetas simples (ej. *Pasatiempos e Intereses*, *Lecturas*, *Reconocimientos*).
- **Parámetros:**
  - `title`: Título de la sección.
  - `items`: Lista de strings a renderizar con viñetas.

---

## 🖼️ 3. Cabecera y Soporte de Foto de Perfil

Si tu plantilla admite foto de perfil, utiliza el helper universal [`render_avatar()`](../src/core/media.typ):

```typst
#import "../../core/media.typ": render_avatar

#let cv_header(datos) = {
  let foto = datos.at("foto", default: none)
  let name = datos.at("nombre_completo", default: "")
  ...
  if foto != none and foto != "" {
    grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      render_avatar(foto, width: 2.5cm),
      [ ...datos del candidato... ]
    )
  } else {
    // Disposición limpia sin foto (ej. centrada)
    ...
  }
}
```

`render_avatar` resuelve automáticamente tanto rutas de archivo locales (ej. `"assets/foto.jpg"`) como Data URIs en Base64 en memoria (`"data:image/jpeg;base64,..."`), aplicando recorte circular (`radius: 50%`) y relación de aspecto cuadrada.

---

## 🎨 4. Convenciones de Diseño y Tipografía

1. **Tipografías Seguras y Portables:**
   - Evita fuentes privativas que no estén preinstaladas en Linux estándar.
   - Fuentes Serif recomendadas: `"Libertinus Serif"`, `"Nimbus Roman"`, `"Liberation Serif"`.
   - Fuentes Sans-Serif recomendadas: `"Liberation Sans"`, `"Nimbus Sans"`, `"DejaVu Sans"`.
2. **Estricta Regla de 1 Sola Página:**
   - Mantén los márgenes en rangos eficientes (`top`/`bottom`: `1.2cm - 1.5cm`, `left`/`right`: `1.4cm - 1.6cm`).
   - El tamaño del cuerpo de texto debe oscilar entre `9.2pt` y `9.8pt` con espaciados de párrafo entre `0.55em` y `0.65em`.
3. **Aislamiento Total:**
   - Cada plantilla debe importar únicamente sus propios archivos locales o el módulo universal `src/core/media.typ`. Nunca importes archivos de otra plantilla.

---

## 🔌 5. Registro y Pruebas de tu Plantilla

### Paso A: Registrar la plantilla en el Router (`main.typ`)
En [`main.typ`](../main.typ), importa tu función maestra y añádela al router:

```typst
#import "src/templates/tu_plantilla/template.typ": tu_plantilla_cv

// En el bloque condicional del router:
#if plantilla == "tu_plantilla" {
  tu_plantilla_cv(cv-data, paper: paper)
}
```

### Paso B: Registrar el nombre en el Esquema JSON
Abre [`schema/cv.schema.json`](../schema/cv.schema.json) y añade el nombre de tu plantilla al arreglo `enum`:

```json
"plantilla": {
  "type": "string",
  "enum": [
    "harvard",
    "modern",
    "tu_plantilla"
  ],
  "default": "harvard"
}
```

### Paso C: Probar Localmente
Prueba la compilación de tu plantilla directamente con el `Makefile`:

```bash
# Compilar con tu plantilla forzada
make pdf TEMPLATE=tu_plantilla

# Probar con el dataset de ejemplo
make pdf DATA=cv.example.json TEMPLATE=tu_plantilla

# Generar vista previa en PNG
make png DATA=cv.example.json TEMPLATE=tu_plantilla

# Validar que el bundle de producción la empaquete y compile sin errores
make test-bundle
```

---

## 🚀 6. Envío de tu Pull Request

Antes de abrir tu Pull Request en GitHub:
1. Asegúrate de que `make all png` y `make test-bundle` compilen con **0 errores y 0 warnings**.
2. Verifica que tu diseño se mantenga dentro de **1 sola página** al compilarse con `data/cv.example.json`.
3. Incluye una imagen de vista previa en la descripción de tu PR para que la comunidad pueda apreciar tu diseño.
