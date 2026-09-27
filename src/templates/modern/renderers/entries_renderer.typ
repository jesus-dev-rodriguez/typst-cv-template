#import "../components/section_title.typ": section_title
#import "../components/entry.typ": cv_entry

/// Renderiza una sección de entradas cronológicas de doble nivel estilo Modern
#let render_entries(title, items) = {
  if items != none and items.len() > 0 {
    section_title(title)

    for item in items {
      let p-left = item.at("primario_izq", default: item.at("primary_left", default: ""))
      let p-right = item.at("primario_der", default: item.at("primary_right", default: ""))
      let s-left = item.at("secundario_izq", default: item.at("secondary_left", default: ""))
      let s-right = item.at("secundario_der", default: item.at("secondary_right", default: ""))
      let desc = item.at("descripcion", default: item.at("description", default: none))
      let bullets = item.at("vinetas", default: item.at("items", default: item.at("highlights", default: ())))

      cv_entry(
        primary-left: p-left,
        primary-right: p-right,
        secondary-left: s-left,
        secondary-right: s-right,
        description: desc,
        items: bullets
      )
    }
  }
}
