#import "../theme.typ": *
#import "../../../core/markdown.typ": render_md

#let section_title(title) = {
  v(space-section)
  block(width: 100%)[
    #text(
      font: font-family,
      size: size-section,
      weight: "bold",
      fill: color-primary,
      render_md(upper(title))
    )
    #v(1.5pt)
    #line(length: 100%, stroke: 0.6pt + color-line)
  ]
  v(1pt)
}
