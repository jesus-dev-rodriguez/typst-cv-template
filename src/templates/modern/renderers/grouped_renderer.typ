#import "../components/section_title.typ": section_title
#import "../theme.typ": *
#import "../../../core/markdown.typ": render_md

/// Renderiza una sección de elementos agrupados por categoría (habilidades, certificaciones, idiomas)
#let render_grouped(title, groups) = {
  if groups != none and groups.len() > 0 {
    section_title(title)

    for group in groups {
      let cat = group.at("categoria", default: group.at("category", default: ""))
      let elements = group.at("elementos", default: group.at("items", default: ()))

      block(width: 100%, spacing: space-item)[
        #if cat != "" [
          #text(weight: "bold", size: size-body, fill: color-primary)[#render_md(cat): ]
        ]
        #text(
          size: size-body,
          fill: color-secondary,
          elements.map(render_md).join([ #h(3pt) • #h(3pt) ])
        )
      ]
    }
  }
}
