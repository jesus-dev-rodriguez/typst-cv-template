#import "../components/section_title.typ": section_title
#import "../theme.typ": *
#import "../../../core/markdown.typ": render_md

/// Renderiza un bloque de texto o párrafo justificado con su título de sección (con soporte Markdown)
#let render_text(title, content) = {
  if content != none and content != "" {
    section_title(title)
    block(spacing: space-item)[
      #set par(justify: true, leading: 0.65em)
      #set text(size: size-body, fill: color-secondary)
      #render_md(content)
    ]
  }
}
