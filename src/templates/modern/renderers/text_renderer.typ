#import "../components/section_title.typ": section_title
#import "../theme.typ": *

/// Renderiza un bloque de texto o párrafo justificado con su título de sección
#let render_text(title, content) = {
  if content != none and content != "" {
    section_title(title)
    par(justify: true, leading: 0.65em)[
      #text(size: size-body, fill: color-secondary, content)
    ]
  }
}
