// =============================================================================
// CV Engine — Single-File Bundled Distribution
// Generated automatically by scripts/bundle.py on 2026-09-26 22:47:51
// Engine compatible with Typst v0.15+
// =============================================================================

// External Packages
#import "@preview/based:0.2.0": base64

// Core Utilities
// --- Core: media.typ ---
/// Renderiza una imagen de perfil / avatar ya sea desde una ruta local a disco
/// o desde un Data URI en Base64 ("data:image/...;base64,...").
/// Si foto_data es `none` o string vacío, retorna `none`.
#let render_avatar(
  foto_data,
  width: 2.6cm,
  radius: 50%,
  stroke: 1pt + rgb("#dcdcdc")
) = {
  if foto_data != none and foto_data != "" {
    let img = if type(foto_data) == str and foto_data.starts-with("data:image") {
      let b64 = foto_data.replace(regex("^data:image/[^;]+;base64,"), "")
      image(base64.decode(b64), width: width, height: width, fit: "cover")
    } else {
      let resolved-path = if type(foto_data) == str and not foto_data.starts-with("/") {
        "/" + foto_data
      } else {
        foto_data
      }
      image(resolved-path, width: width, height: width, fit: "cover")
    }

    box(
      width: width,
      height: width,
      radius: radius,
      clip: true,
      stroke: stroke,
      img
    )
  }
}

// --- Core: inputs.typ ---
/// Módulo universal de resolución de entradas (sys.inputs)
/// Soporta:
/// 1. JSON crudo en memoria (string iniciado en '{' o '[') -> decodificado directamente como bytes
/// 2. Ruta a archivo en disco (relativa o absoluta)
/// 3. Fallback predeterminado -> /data/cv.json
#let load_cv_data() = {
  if "data" in sys.inputs {
    let raw = sys.inputs.data
    if raw.starts-with("{") or raw.starts-with("[") {
      json(bytes(raw))
    } else {
      let path = if raw.starts-with("/") { raw } else { "/" + raw }
      json(path)
    }
  } else {
    json("/data/cv.json")
  }
}

/// Determina la plantilla visual a utilizar.
/// Prioridad:
/// 1. Flag de CLI / sys.inputs: --input plantilla="..." o --input template="..."
/// 2. Clave en el propio JSON: "plantilla": "..."
/// 3. "harvard" por defecto
#let get_template_name(cv-data) = {
  if "plantilla" in sys.inputs {
    sys.inputs.plantilla
  } else if "template" in sys.inputs {
    sys.inputs.template
  } else {
    cv-data.at("plantilla", default: "harvard")
  }
}

/// Determina el formato de papel a utilizar.
/// Prioridad:
/// 1. Flag de CLI / sys.inputs: --input paper="..."
/// 2. "a4" por defecto
#let get_paper_format() = {
  sys.inputs.at("paper", default: "a4")
}

// =============================================================================
// Template: HARVARD
// =============================================================================
#let harvard = {
  // [theme.typ]
  // Configuración de estilo y tipografía estilo Harvard
  let font-family = ("Libertinus Serif", "Nimbus Roman", "Liberation Serif")

  // Colores
  let color-primary = rgb("#111111")
  let color-secondary = rgb("#333333")
  let color-muted = rgb("#555555")
  let color-line = rgb("#222222")
  let color-link = rgb("#002b49") // Azul clásico marino discreto o negro

  // Tamaños de fuente
  let size-name = 18pt
  let size-title = 10.5pt
  let size-section = 11pt
  let size-body = 9.8pt
  let size-sub = 9.2pt

  // Espaciados
  let page-margin = (
    top: 1.5cm,
    bottom: 1.5cm,
    left: 1.6cm,
    right: 1.6cm,
  )

  let space-section = 9pt
  let space-item = 5pt

  // [components/section_title.typ]
  let section_title(title) = {
    v(space-section)
    block(width: 100%)[
      #text(
        font: font-family,
        size: size-section,
        weight: "bold",
        fill: color-primary,
        upper(title)
      )
      #v(1.5pt)
      #line(length: 100%, stroke: 0.6pt + color-line)
    ]
    v(1pt)
  }

  // [components/entry.typ]
  /// Representa una entrada estándar de CV estilo Harvard
  /// Soporta dos líneas con alineación izquierda/derecha y una lista de viñetas opcional
  let cv_entry(
    primary-left: "",
    primary-right: "",
    secondary-left: "",
    secondary-right: "",
    description: none,
    items: ()
  ) = {
    block(width: 100%, spacing: space-item)[
      // Fila 1: Título/Institución principal y Fecha/Ubicación
      #if primary-left != "" or primary-right != "" [
        #grid(
          columns: (1fr, auto),
          align: (left + top, right + top),
          text(weight: "bold", size: size-body, primary-left),
          text(weight: "medium", size: size-sub, primary-right)
        )
      ]

      // Fila 2: Subtítulo/Grado/Distinción y Ubicación/Detalle secundario
      #if secondary-left != "" or secondary-right != "" [
        #v(0.5pt)
        #grid(
          columns: (1fr, auto),
          align: (left + top, right + top),
          text(style: "italic", size: size-body, secondary-left),
          text(style: "italic", size: size-sub, fill: color-muted, secondary-right)
        )
      ]

      // Descripción en párrafo si existe
      #if description != none and description != "" [
        #v(1.5pt)
        #text(size: size-body, fill: color-secondary, description)
      ]

      // Viñetas o logros asociados
      #if items.len() > 0 [
        #v(1.5pt)
        #list(
          ..items.map(it => text(size: size-body, fill: color-secondary, it)),
          spacing: 3pt,
          tight: true
        )
      ]
    ]
  }

  // [components/header.typ]
  /// Renderiza la cabecera Harvard procesando dinámicamente cualquier tipo de contacto
  let cv_header(datos) = {
    align(center)[
      #block[
        // Nombre del candidato
        #text(
          size: size-name,
          weight: "bold",
          tracking: 0.5pt,
          datos.at("nombre_completo", default: datos.at("name", default: ""))
        )

        // Título o rol
        #let title = datos.at("titulo", default: datos.at("title", default: ""))
        #if title != "" [
          #v(2pt)
          #text(size: size-title, style: "italic", fill: color-secondary, title)
        ]

        #v(3pt)

        // Procesamiento dinámico de contactos
        #let contact-raw = datos.at("contacto", default: datos.at("contact", default: ()))
        #let rendered-items = ()

        #if type(contact-raw) == array {
          for c in contact-raw {
            let val = c.at("valor", default: c.at("value", default: ""))
            let target-url = c.at("url", default: none)

            if target-url != none and target-url != "" {
              rendered-items.push(link(target-url, text(fill: color-link, val)))
            } else if val.starts-with("http://") or val.starts-with("https://") {
              let clean = val.replace("https://", "").replace("http://", "")
              rendered-items.push(link(val, text(fill: color-link, clean)))
            } else if val.contains("@") {
              rendered-items.push(link("mailto:" + val, text(fill: color-link, val)))
            } else {
              rendered-items.push(text(val))
            }
          }
        } else if type(contact-raw) == dictionary {
          for (key, val) in contact-raw {
            if val != "" and val != none {
              if val.starts-with("http://") or val.starts-with("https://") {
                let clean = val.replace("https://", "").replace("http://", "")
                rendered-items.push(link(val, text(fill: color-link, clean)))
              } else if val.contains("@") {
                rendered-items.push(link("mailto:" + val, text(fill: color-link, val)))
              } else {
                rendered-items.push(text(val))
              }
            }
          }
        }

        // Distribución en 2 líneas equilibradas si hay más de 2 elementos
        #let total = rendered-items.len()
        #if total > 0 [
          #text(size: size-sub, fill: color-secondary)[
            #if total <= 2 [
              #rendered-items.join([ #h(4pt) • #h(4pt) ])
            ] else [
              #let mid = calc.ceil(total / 2)
              #let line1 = rendered-items.slice(0, mid)
              #let line2 = rendered-items.slice(mid, total)
              #line1.join([ #h(4pt) • #h(4pt) ])
              \
              #v(1.5pt)
              #line2.join([ #h(4pt) • #h(4pt) ])
            ]
          ]
        ]
      ]
    ]
  }

  // [renderers/text_renderer.typ]
  /// Renderiza un bloque de texto o párrafo justificado con su título de sección
  let render_text(title, content) = {
    if content != none and content != "" {
      section_title(title)
      par(justify: true, leading: 0.65em)[
        #text(size: size-body, fill: color-secondary, content)
      ]
    }
  }

  // [renderers/entries_renderer.typ]
  /// Renderiza una sección de entradas cronológicas de doble nivel estilo Harvard
  /// Acepta claves tanto en español como en inglés
  let render_entries(title, items) = {
    if items != none and items.len() > 0 {
      section_title(title)

      for item in items {
        let p-left = item.at("primario_izq", default: item.at("primary_left", default: ""))
        let p-right = item.at("primario_der", default: item.at("primary_right", default: ""))
        let s-left = item.at("secundario_izq", default: item.at("secondary_left", default: ""))
        let s-right = item.at("secundario_der", default: item.at("secondary_right", default: ""))
        let desc = item.at("descripcion", default: item.at("description", default: none))
        let bullets = item.at("vinetas", default: item.at("items", default: item.at("highlights", default: ())))

        cv_entry(
          primary-left: p-left,
          primary-right: p-right,
          secondary-left: s-left,
          secondary-right: s-right,
          description: desc,
          items: bullets
        )
      }
    }
  }

  // [renderers/grouped_renderer.typ]
  /// Renderiza una sección de elementos agrupados por categoría (habilidades, certificaciones, idiomas)
  let render_grouped(title, groups) = {
    if groups != none and groups.len() > 0 {
      section_title(title)

      for group in groups {
        let cat = group.at("categoria", default: group.at("category", default: ""))
        let elements = group.at("elementos", default: group.at("items", default: ()))

        block(width: 100%, spacing: space-item)[
          #if cat != "" [
            #text(weight: "bold", size: size-body, cat + ": ")
          ]
          #text(
            size: size-body,
            fill: color-secondary,
            elements.join([ #h(3pt) • #h(3pt) ])
          )
        ]
      }
    }
  }

  // [renderers/list_renderer.typ]
  /// Renderiza una lista simple de viñetas (pasatiempos, lecturas, reconocimientos rápidos)
  let render_list(title, items) = {
    if items != none and items.len() > 0 {
      section_title(title)

      block(width: 100%, spacing: space-item)[
        #list(
          ..items.map(it => text(size: size-body, fill: color-secondary, it)),
          spacing: 4pt,
          tight: true
        )
      ]
    }
  }

  // [template.typ]
  /// Orquestador principal de la plantilla Harvard
  /// Configura página, tipografía serif académica, cabecera y renderiza dinámicamente las secciones.
  let harvard_cv(cv-data, paper: "a4") = {
    let author = if "datos_personales" in cv-data and "nombre_completo" in cv-data.datos_personales {
      cv-data.datos_personales.nombre_completo
    } else {
      "Curriculum Vitae"
    }

    set document(
      title: "CV - " + author,
      author: author,
    )

    set page(
      paper: paper,
      margin: page-margin,
      header: none,
      footer: none,
    )

    set text(
      font: font-family,
      size: size-body,
      fill: color-primary,
      lang: "es",
      hyphenate: false,
    )

    set par(
      justify: true,
      leading: 0.6em,
    )

    // Renderizar encabezado automáticamente si hay datos personales
    if "datos_personales" in cv-data {
      cv_header(cv-data.datos_personales)
    }

    // Renderizado dinámico y agnóstico de las secciones definidas en el JSON
    for seccion in cv-data.at("secciones", default: ()) {
      let tipo = seccion.at("tipo", default: "texto")
      let titulo = seccion.at("titulo", default: "")

      if tipo == "texto" [
        #render_text(titulo, seccion.at("contenido", default: ""))
      ] else if tipo == "entradas" [
        #render_entries(titulo, seccion.at("items", default: ()))
      ] else if tipo == "agrupado" [
        #render_grouped(titulo, seccion.at("grupos", default: ()))
      ] else if tipo == "lista" [
        #render_list(titulo, seccion.at("elementos", default: ()))
      ]
    }
  }

  (cv: harvard_cv)
}

// =============================================================================
// Template: MODERN
// =============================================================================
#let modern = {
  // [theme.typ]
  // Configuración de estilo y tipografía de la plantilla Modern
  let font-family = ("Liberation Sans", "Nimbus Sans", "DejaVu Sans")

  // Paleta de colores contemporánea
  let color-primary = rgb("#1d3557")   // Azul marino profundo para títulos y acentos
  let color-secondary = rgb("#2b2d42") // Carbón suave para texto del cuerpo
  let color-muted = rgb("#6c757d")     // Gris medio para fechas, subtítulos y metadatos
  let color-accent = rgb("#457b9d")    // Azul acero para separadores
  let color-line = rgb("#457b9d")      // Líneas divisorias
  let color-link = rgb("#1d3557")      // Enlaces interactivos
  let color-border = rgb("#dcdcdc")    // Borde de avatar

  // Tamaños de fuente
  let size-name = 19pt
  let size-title = 10.5pt
  let size-section = 11pt
  let size-body = 9.6pt
  let size-sub = 9pt

  // Espaciados
  let page-margin = (
    top: 1.4cm,
    bottom: 1.4cm,
    left: 1.5cm,
    right: 1.5cm,
  )

  let space-section = 8.5pt
  let space-item = 4.5pt

  // [components/section_title.typ]
  let section_title(title) = {
    v(space-section)
    block(width: 100%)[
      #text(
        font: font-family,
        size: size-section,
        weight: "bold",
        fill: color-primary,
        tracking: 0.5pt,
        upper(title)
      )
      #v(2pt)
      #line(length: 100%, stroke: 0.8pt + color-line)
    ]
    v(1pt)
  }

  // [components/entry.typ]
  /// Representa una entrada estándar de CV estilo Modern
  let cv_entry(
    primary-left: "",
    primary-right: "",
    secondary-left: "",
    secondary-right: "",
    description: none,
    items: ()
  ) = {
    block(width: 100%, spacing: space-item)[
      // Fila 1: Título/Institución principal y Fecha/Ubicación
      #if primary-left != "" or primary-right != "" [
        #grid(
          columns: (1fr, auto),
          align: (left + top, right + top),
          text(weight: "bold", size: size-body, fill: color-primary, primary-left),
          text(weight: "medium", size: size-sub, fill: color-muted, primary-right)
        )
      ]

      // Fila 2: Subtítulo/Cargo y Detalle secundario
      #if secondary-left != "" or secondary-right != "" [
        #v(0.5pt)
        #grid(
          columns: (1fr, auto),
          align: (left + top, right + top),
          text(weight: "medium", size: size-body, fill: color-secondary, secondary-left),
          text(size: size-sub, fill: color-muted, secondary-right)
        )
      ]

      // Descripción en párrafo
      #if description != none and description != "" [
        #v(1.5pt)
        #text(size: size-body, fill: color-secondary, description)
      ]

      // Viñetas o logros asociados
      #if items.len() > 0 [
        #v(1.5pt)
        #list(
          ..items.map(it => text(size: size-body, fill: color-secondary, it)),
          spacing: 3pt,
          tight: true
        )
      ]
    ]
  }

  // [components/header.typ]
  /// Renderiza el encabezado moderno, adaptándose dinámicamente si existe foto de perfil
  let cv_header(datos) = {
    let name = datos.at("nombre_completo", default: datos.at("name", default: ""))
    let title = datos.at("titulo", default: datos.at("title", default: ""))
    let foto = datos.at("foto", default: none)
    let contact-raw = datos.at("contacto", default: datos.at("contact", default: ()))

    // Construir lista de enlaces/contactos
    let rendered-items = ()
    if type(contact-raw) == array {
      for c in contact-raw {
        let val = c.at("valor", default: c.at("value", default: ""))
        let target-url = c.at("url", default: none)

        if target-url != none and target-url != "" {
          rendered-items.push(link(target-url, text(fill: color-link, weight: "medium", val)))
        } else if val.starts-with("http://") or val.starts-with("https://") {
          let clean = val.replace("https://", "").replace("http://", "")
          rendered-items.push(link(val, text(fill: color-link, weight: "medium", clean)))
        } else if val.contains("@") {
          rendered-items.push(link("mailto:" + val, text(fill: color-link, weight: "medium", val)))
        } else {
          rendered-items.push(text(fill: color-secondary, val))
        }
      }
    } else if type(contact-raw) == dictionary {
      for (key, val) in contact-raw {
        if val != "" and val != none {
          if val.starts-with("http://") or val.starts-with("https://") {
            let clean = val.replace("https://", "").replace("http://", "")
            rendered-items.push(link(val, text(fill: color-link, weight: "medium", clean)))
          } else if val.contains("@") {
            rendered-items.push(link("mailto:" + val, text(fill: color-link, weight: "medium", val)))
          } else {
            rendered-items.push(text(fill: color-secondary, val))
          }
        }
      }
    }

    let total = rendered-items.len()

    // Bloque con nombre, título y contactos
    let info_block(align_center: true) = [
      #text(
        size: size-name,
        weight: "bold",
        fill: color-primary,
        tracking: 0.3pt,
        name
      )

      #if title != "" [
        #v(1.5pt)
        #text(size: size-title, weight: "medium", fill: color-accent, title)
      ]

      #if total > 0 [
        #v(3pt)
        #text(size: size-sub)[
          #if total <= 2 [
            #rendered-items.join([ #h(4pt) • #h(4pt) ])
          ] else [
            #let mid = calc.ceil(total / 2)
            #let line1 = rendered-items.slice(0, mid)
            #let line2 = rendered-items.slice(mid, total)
            #line1.join([ #h(4pt) • #h(4pt) ])
            \
            #v(1.5pt)
            #line2.join([ #h(4pt) • #h(4pt) ])
          ]
        ]
      ]
    ]

    // Si hay foto, usar disposición lateral; si no, centrado clásico limpio
    if foto != none and foto != "" {
      grid(
        columns: (auto, 1fr),
        gutter: 14pt,
        align: (center + horizon, left + horizon),
        render_avatar(foto, width: 2.6cm, stroke: 1.5pt + color-accent),
        info_block(align_center: false)
      )
    } else {
      align(center)[
        #info_block(align_center: true)
      ]
    }
  }

  // [renderers/text_renderer.typ]
  /// Renderiza un bloque de texto o párrafo justificado con su título de sección
  let render_text(title, content) = {
    if content != none and content != "" {
      section_title(title)
      par(justify: true, leading: 0.65em)[
        #text(size: size-body, fill: color-secondary, content)
      ]
    }
  }

  // [renderers/entries_renderer.typ]
  /// Renderiza una sección de entradas cronológicas de doble nivel estilo Modern
  let render_entries(title, items) = {
    if items != none and items.len() > 0 {
      section_title(title)

      for item in items {
        let p-left = item.at("primario_izq", default: item.at("primary_left", default: ""))
        let p-right = item.at("primario_der", default: item.at("primary_right", default: ""))
        let s-left = item.at("secundario_izq", default: item.at("secondary_left", default: ""))
        let s-right = item.at("secundario_der", default: item.at("secondary_right", default: ""))
        let desc = item.at("descripcion", default: item.at("description", default: none))
        let bullets = item.at("vinetas", default: item.at("items", default: item.at("highlights", default: ())))

        cv_entry(
          primary-left: p-left,
          primary-right: p-right,
          secondary-left: s-left,
          secondary-right: s-right,
          description: desc,
          items: bullets
        )
      }
    }
  }

  // [renderers/grouped_renderer.typ]
  /// Renderiza una sección de elementos agrupados por categoría (habilidades, certificaciones, idiomas)
  let render_grouped(title, groups) = {
    if groups != none and groups.len() > 0 {
      section_title(title)

      for group in groups {
        let cat = group.at("categoria", default: group.at("category", default: ""))
        let elements = group.at("elementos", default: group.at("items", default: ()))

        block(width: 100%, spacing: space-item)[
          #if cat != "" [
            #text(weight: "bold", size: size-body, fill: color-primary, cat + ": ")
          ]
          #text(
            size: size-body,
            fill: color-secondary,
            elements.join([ #h(3pt) • #h(3pt) ])
          )
        ]
      }
    }
  }

  // [renderers/list_renderer.typ]
  /// Renderiza una lista simple de viñetas estilo Modern
  let render_list(title, items) = {
    if items != none and items.len() > 0 {
      section_title(title)

      block(width: 100%, spacing: space-item)[
        #list(
          ..items.map(it => text(size: size-body, fill: color-secondary, it)),
          spacing: 4pt,
          tight: true
        )
      ]
    }
  }

  // [template.typ]
  /// Orquestador principal de la plantilla Modern
  /// Configura página, tipografía contemporánea sans-serif, acento en azul marino,
  /// encabezado con soporte opcional de foto/avatar y renderizado dinámico de secciones.
  let modern_cv(cv-data, paper: "a4") = {
    let author = if "datos_personales" in cv-data and "nombre_completo" in cv-data.datos_personales {
      cv-data.datos_personales.nombre_completo
    } else {
      "Curriculum Vitae"
    }

    set document(
      title: "CV - " + author,
      author: author,
    )

    set page(
      paper: paper,
      margin: page-margin,
      header: none,
      footer: none,
    )

    set text(
      font: font-family,
      size: size-body,
      fill: color-secondary,
      lang: "es",
      hyphenate: false,
    )

    set par(
      justify: true,
      leading: 0.6em,
    )

    // Renderizar encabezado automáticamente si hay datos personales
    if "datos_personales" in cv-data {
      cv_header(cv-data.datos_personales)
    }

    // Renderizado dinámico y agnóstico de las secciones definidas en el JSON
    for seccion in cv-data.at("secciones", default: ()) {
      let tipo = seccion.at("tipo", default: "texto")
      let titulo = seccion.at("titulo", default: "")

      if tipo == "texto" [
        #render_text(titulo, seccion.at("contenido", default: ""))
      ] else if tipo == "entradas" [
        #render_entries(titulo, seccion.at("items", default: ()))
      ] else if tipo == "agrupado" [
        #render_grouped(titulo, seccion.at("grupos", default: ()))
      ] else if tipo == "lista" [
        #render_list(titulo, seccion.at("elementos", default: ()))
      ]
    }
  }

  (cv: modern_cv)
}

// =============================================================================
// Universal Dispatcher & Router
// =============================================================================
#let cv-data = load_cv_data()
#let plantilla = get_template_name(cv-data)
#let paper = get_paper_format()

#let available_templates = (
  "harvard": harvard.cv,
  "modern": modern.cv,
)

#let runner = available_templates.at(plantilla, default: harvard.cv)
#(runner)(cv-data, paper: paper)
