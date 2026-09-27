#import "../components/section_title.typ": section_title
#import "../theme.typ": *

/// Renderiza una lista simple de viñetas estilo Modern
#let render_list(title, items) = {
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
