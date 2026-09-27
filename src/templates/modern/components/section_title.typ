#import "../theme.typ": *

#let section_title(title) = {
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
