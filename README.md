# CV Universal en Typst (Multi-Plantilla & Schema-Driven)

Motor genérico, agnóstico y desacoplado para generar de manera dinámica Curriculum Vitaes profesionales con múltiples plantillas (**Harvard** y **Modern**) utilizando **Typst v0.15+** y **JSON Schema**.

---

## ✨ Características Principales

- **Multi-Plantilla Dinámica:** Alterna entre plantillas con un simple valor en tu JSON (`"plantilla": "harvard"` o `"plantilla": "modern"`).
- **Soporte de Foto / Avatar:** Soporte opcional para foto de perfil en formatos locales (ej. `assets/foto.jpg`) o Data URIs en Base64 en plantillas compatibles como `modern`.
- **Inversión de dependencias:** El código Typst no tiene secciones fijas. Es un motor de renderizado universal guiado 100% por los datos de tu JSON.
- **Soporte ilimitado de secciones:** Puedes agregar *Experiencia Laboral*, *Educación*, *Proyectos*, *Certificaciones*, *Habilidades*, *Pasatiempos*, *Lecturas* o cualquier otra sección directamente en el JSON sin tocar nunca código Typst.
- **Validación y Autocompletado:** Incluye especificación formal [`schema/cv.schema.json`](schema/cv.schema.json) compatible con VS Code y otros editores.
- **Contactos Polimórficos:** Soporta cualquier cantidad de datos de contacto (Email, Teléfono, LinkedIn, GitHub, Portafolio, etc.) con enlaces interactivos y distribución automática de filas.

---

## 📁 Estructura del Proyecto

```text
├── .vscode/
│   └── settings.json              # Configuración para autocompletado automático de data/*.json
├── schema/
│   └── cv.schema.json             # Especificación JSON Schema formal (plantilla, foto, secciones)
├── docs/
│   ├── SCHEMA.md                  # Guía exhaustiva de uso y ejemplos de cada tipo de sección
│   └── ROADMAP.md                 # Hoja de ruta y planificación futura (Multi-plantillas & Bundle)
├── data/
│   ├── cv.example.json            # Plantilla inicial de ejemplo con todas las secciones y foto
│   └── cv.json                    # Datos reales del candidato
├── src/
│   ├── core/
│   │   └── media.typ              # render_avatar() universal (rutas locales y Base64 URIs)
│   └── templates/                 # Ecosistema desacoplado de plantillas
│       ├── harvard/               # Plantilla académica tradicional (Serif, 1 columna)
│       │   ├── theme.typ          # Variables de diseño (Libertinus Serif, márgenes)
│       │   ├── components/        # Header centrado, cv_entry, section_title
│       │   ├── renderers/         # 4 renderizadores de layouts universales
│       │   └── template.typ       # Orquestador harvard_cv(cv-data)
│       └── modern/                # Plantilla contemporánea (Sans-Serif, azul marino, foto)
│           ├── theme.typ          # Variables de diseño (Liberation Sans, acento #1d3557)
│           ├── components/        # Header adaptativo con foto, cv_entry, section_title
│           ├── renderers/         # 4 renderizadores con estilo moderno
│           └── template.typ       # Orquestador modern_cv(cv-data)
├── build/                         # Artefactos compilados (cv.pdf, preview-1.png)
├── Makefile                       # Automatización de tareas de compilación hacia build/
├── main.typ                       # Router raíz: despacha automáticamente a la plantilla elegida
├── AGENTS.md                      # Memoria persistente del workspace para Antigravity CLI
└── README.md                      # Esta documentación
```

---

## 🔒 Soberanía, Portabilidad y Schemas Personalizados

- **100% Offline y Desacoplado:** Por defecto, el proyecto utiliza la ruta relativa local `"$schema": "../schema/cv.schema.json"` y la configuración integrada en [`.vscode/settings.json`](.vscode/settings.json), garantizando autocompletado y validación estricta sin depender de conexión a internet ni de la disponibilidad de servidores externos.
- **Soporte para Organizaciones y URLs Propias:** Si una organización o empresa desea utilizar su propio esquema corporativo o alojarlo en su infraestructura interna (ej. `"https://schemas.mi-organizacion.com/cv.json"`), puede especificarlo libremente en `"$schema"` o en `.vscode/settings.json`. El motor Typst es agnóstico a esta URL y compilará el documento con total normalidad.

---

## 🚀 Comandos de Compilación (vía Makefile)

Todos los artefactos se generan en la carpeta `build/` para no contaminar el código fuente:

### 1. Compilar el CV a PDF
```bash
make
# o también: make pdf
```
Genera `build/cv.pdf`.

### 2. Modo interactivo (Live Preview / Watch)
Recompila automáticamente al guardar cambios:
```bash
make watch
```

### 3. Generar vista previa en imagen (PNG)
```bash
make png
```
Genera `build/preview-1.png` a 150 PPI.

### 4. Compilación Parametrizada (Elegir Datos, Plantilla o Papel)
Puedes pasar variables para elegir cualquier archivo de datos o forzar plantillas:
```bash
# Compilar usando el archivo de ejemplo
make pdf DATA=cv.example.json

# Forzar plantilla modern sobre tu CV actual
make pdf TEMPLATE=modern

# Combinar dataset de ejemplo con plantilla modern
make pdf DATA=cv.example.json TEMPLATE=modern

# Generar vista previa PNG de esa combinación
make png DATA=cv.example.json TEMPLATE=modern

# Cambiar formato de papel a Carta (US Letter)
make pdf PAPER=us-letter
```

### 5. Empaquetado para Producción (`dist/cv-engine.typ`)
Compila todo el proyecto modular en un único archivo autocontenido listo para usar en SPAs web sin servidor, microservicios o APIs:
```bash
# Generar el bundle único en dist/cv-engine.typ
make bundle

# Ejecutar la batería de pruebas autónoma del bundle
make test-bundle
```

Cualquier sistema externo solo necesita este archivo y el JSON del usuario:
```bash
typst compile --input data="usuario.json" dist/cv-engine.typ salida.pdf
```

### 6. Limpiar artefactos generados
```bash
make clean
```

---

## 📖 Cómo Personalizar tu CV

Consulta la guía detallada [**`docs/SCHEMA.md`**](docs/SCHEMA.md) para ver ejemplos de cómo agregar:
1. Párrafos corridos (`tipo: "texto"`)
2. Entradas cronológicas (`tipo: "entradas"`)
3. Grupos categorizados (`tipo: "agrupado"`)
4. Listas de viñetas (`tipo: "lista"`)

---

## 🤝 Cómo Contribuir con Nuevas Plantillas

El proyecto está diseñado como un ecosistema abierto y extensible. Si deseas diseñar y enviar una nueva plantilla visual (`minimal`, `tech`, `academic`, etc.):

1. Consulta la [**Guía de Contribución de Plantillas**](docs/CONTRIBUTING_TEMPLATES.md).
2. Crea tu carpeta en `src/templates/<tu_plantilla>/` e implementa las 4 primitivas de maquetación universales.
3. El empaquetador `scripts/bundle.py` detectará automáticamente tu plantilla sin requerir cambios en el código de empaquetado.
4. Antes de abrir tu Pull Request, asegúrate de que pasen todos los tests locales:
   ```bash
   make all png
   make test-bundle
   ```

