#import "../theme.typ": *

/// Renderiza la cabecera Harvard procesando dinámicamente cualquier tipo de contacto
#let cv_header(datos) = {
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
