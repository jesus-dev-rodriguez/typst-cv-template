#import "../theme.typ": *
#import "../../../core/media.typ": render_avatar

/// Renderiza el encabezado moderno, adaptándose dinámicamente si existe foto de perfil
#let cv_header(datos) = {
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
