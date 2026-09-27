# Especificación del Esquema Universal de CV

Este proyecto implementa una arquitectura basada en **Inversión de Dependencias**: el diseño y motor Typst son 100% agnósticos de los nombres de tus secciones. El documento se compone dinámicamente a partir de la lista `secciones` definida en tu archivo `data/cv.json`.

---

## 💡 Plantilla de Inicio y Autocompletado

Para no arrancar desde un archivo en blanco, puedes usar o duplicar la plantilla de ejemplo completa lista para usar:
👉 [**`data/cv.example.json`**](../data/cv.example.json)

Al inicio de tu archivo JSON, incluye la propiedad `"$schema"`:

```json
{
  "$schema": "../schema/cv.schema.json",
  "datos_personales": { ... },
  "secciones": [ ... ]
}
```

### Portabilidad y Validación en Editores
1. **100% Offline y Portable:** Al usar `"$schema": "../schema/cv.schema.json"`, el proyecto es totalmente autónomo y no depende de conexiones a internet ni de la disponibilidad de servidores externos.
2. **Autocompletado Automático (Zero-Config):** El repositorio incluye `.vscode/settings.json`, el cual asocia automáticamente `schema/cv.schema.json` a cualquier archivo dentro de `data/*.json`. Tendrás validación estricta y sugerencias en tiempo real incluso si no especificas la línea `"$schema"`.
3. **Uso en Organizaciones / URLs Personalizadas:** Si una empresa u organización hospeda su propio esquema centralizado, puede apuntar directamente a su URL en `"$schema"` (ej. `"https://schemas.mi-organizacion.com/cv.json"`). El compilador Typst seguirá funcionando con normalidad sin requerir cambios.

---

## 0. Selección de Plantilla (`plantilla`)

Puedes elegir el diseño de tu CV especificando la clave `"plantilla"` en la raíz del JSON:

- `"harvard"` *(por defecto)*: Formato académico tradicional Harvard (serif sobrio, 1 columna, encabezado centrado).
- `"modern"`: Formato contemporáneo (sans-serif, paleta azul marino `#1d3557` con separadores estilizados, soporte opcional de foto de perfil).

```json
{
  "$schema": "../schema/cv.schema.json",
  "plantilla": "modern",
  "datos_personales": { ... }
}
```

---

## 1. Bloque: `datos_personales`

```json
{
  "datos_personales": {
    "nombre_completo": "Tu Nombre Completo",
    "titulo": "Tu Título Profesional o Perfil",
    "foto": "assets/foto.jpg",
    "contacto": [
      { "tipo": "ubicacion", "valor": "Ciudad, País" },
      { "tipo": "telefono", "valor": "+54 9 11 1234-5678" },
      { "tipo": "email", "valor": "tu.email@gmail.com", "url": "mailto:tu.email@gmail.com" },
      { "tipo": "linkedin", "valor": "linkedin.com/in/tu-usuario", "url": "https://linkedin.com/in/tu-usuario" },
      { "tipo": "github", "valor": "github.com/tu-usuario", "url": "https://github.com/tu-usuario" },
      { "tipo": "portfolio", "valor": "tuportafolio.dev", "url": "https://tuportafolio.dev" }
    ]
  }
}
```

> **Flexibilidad:** Puedes agregar tantos contactos como desees (GitHub, Portfolio, Discord, Telegram, etc.). El motor Typst distribuirá automáticamente los enlaces en filas equilibradas con separadores `•`.

---

## 2. Bloque: `secciones`

La lista `secciones` define el contenido del CV. **El orden en el que coloques las secciones en el JSON es exactamente el orden en el que se renderizarán en el PDF.**

Cada sección debe especificar un `"titulo"` y un `"tipo"`. Existen **4 tipos universales**:

### Tipo 1: `"texto"` (Párrafos corridos)
Ideal para: **Objetivo Profesional**, **Perfil Ejecutivo**, **Filosofía de Trabajo**, **Declaración de Interés**.

```json
{
  "titulo": "Objetivo Profesional",
  "tipo": "texto",
  "contenido": "Ingeniero de Software enfocado en desarrollo backend y sistemas distribuidos. Cuento con experiencia en diseño de arquitecturas limpias y metodologías ágiles..."
}
```

---

### Tipo 2: `"entradas"` (Timeline cronológico de 2 niveles Harvard)
Ideal para: **Experiencia Laboral**, **Educación**, **Proyectos Destacados**, **Premios y Distinciones**, **Voluntariado**, **Publicaciones**.

Campos soportados en cada entrada:
- `primario_izq`: Texto en negrita a la izquierda (Empresa, Universidad, Concurso).
- `primario_der`: Fecha, período o año a la derecha.
- `secundario_izq`: Subtítulo en cursiva a la izquierda (Cargo, Grado obtenido, Distinción).
- `secundario_der`: Ubicación o detalle secundario a la derecha.
- `descripcion`: Párrafo descriptivo opcional.
- `vinetas`: Lista de viñetas con logros y métricas de impacto.

#### Ejemplo: Experiencia Laboral
```json
{
  "titulo": "Experiencia Laboral",
  "tipo": "entradas",
  "items": [
    {
      "primario_izq": "Mercado Libre",
      "primario_der": "Marzo 2024 - Presente",
      "secundario_izq": "Desarrollador Backend Go / PostgreSQL",
      "secundario_der": "Buenos Aires, Argentina (Remoto)",
      "vinetas": [
        "Optimización de microservicios de facturación reduciendo la latencia P99 en un 35%.",
        "Diseño e implementación de arquitectura de eventos con Apache Kafka."
      ]
    }
  ]
}
```

#### Ejemplo: Proyectos Relevantes
```json
{
  "titulo": "Proyectos Destacados",
  "tipo": "entradas",
  "items": [
    {
      "primario_izq": "Sistema de Monitoreo IoT para Invernaderos",
      "primario_der": "2025",
      "secundario_izq": "Next.js, Go, MQTT, PostgreSQL",
      "secundario_der": "github.com/usuario/iot-monitor",
      "vinetas": [
        "Plataforma de telemetría en tiempo real para control hidropónico con alertas automáticas."
      ]
    }
  ]
}
```

---

### Tipo 3: `"agrupado"` (Categorías con lista de elementos)
Ideal para: **Habilidades Técnicas y Blandas**, **Certificaciones agrupadas por institución**, **Idiomas**.

```json
{
  "titulo": "Habilidades",
  "tipo": "agrupado",
  "grupos": [
    {
      "categoria": "Habilidades Técnicas",
      "elementos": ["Go", "TypeScript", "React", "Next.js", "PostgreSQL", "Docker", "Tailwind CSS"]
    },
    {
      "categoria": "Habilidades Interpersonales",
      "elementos": ["Liderazgo de equipos", "Comunicación asertiva", "Resolución analítica de problemas"]
    },
    {
      "categoria": "Idiomas",
      "elementos": ["Español (Nativo)", "Inglés (B2 - Profesional intermedio)"]
    }
  ]
}
```

---

### Tipo 4: `"lista"` (Viñetas simples directas)
Ideal para: **Pasatiempos**, **Lecturas Recomendadas**, **Intereses de Investigación**, **Referencias Disponibles**.

```json
{
  "titulo": "Pasatiempos e Intereses",
  "tipo": "lista",
  "elementos": [
    "Ajedrez competitivo y pensamiento estratégico.",
    "Lecturas sobre arquitectura de software, Domain-Driven Design y sistemas concurrentes.",
    "Colaboración activa en proyectos de código abierto."
  ]
}
```

---

## 3. Ventajas de esta Arquitectura

1. **Cero cambios en Typst:** Si deseas agregar una sección de *"Lecturas"*, *"Voluntariado"* o *"Patentes"*, solo agregas el objeto correspondiente en el JSON con su título y tipo.
2. **Reordenamiento libre:** Cambia de lugar los objetos en la lista `secciones` y el PDF reflejará ese orden inmediatamente.
3. **Omisión automática:** Si no tienes experiencia o proyectos que mostrar hoy, no agregas la sección y el CV se adaptará limpiamente sin dejar espacios vacíos ni arrojar errores.
