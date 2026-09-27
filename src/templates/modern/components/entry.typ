#import "../theme.typ": *

/// Representa una entrada estándar de CV estilo Modern
#let cv_entry(
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
