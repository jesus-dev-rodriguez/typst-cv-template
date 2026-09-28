#import "../components/section_title.typ": section_title
#import "../theme.typ": *
#import "../../../core/markdown.typ": render_md

/// Renderiza una lista simple de viñetas (pasatiempos, lecturas, reconocimientos rápidos)
#let render_list(title, items) = {
  if items != none and items.len() > 0 {
    section_title(title)

    block(width: 100%, spacing: space-item)[
      #list(
        ..items.map(it => text(size: size-body, fill: color-secondary, render_md(it))),
        spacing: 4pt,
        tight: true
      )
    ]
  }
}
