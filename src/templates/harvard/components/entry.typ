#import "../theme.typ": *

/// Representa una entrada estándar de CV estilo Harvard
/// Soporta dos líneas con alineación izquierda/derecha y una lista de viñetas opcional
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
