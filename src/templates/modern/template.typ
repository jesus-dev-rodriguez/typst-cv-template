#import "theme.typ": *
#import "components/header.typ": cv_header
#import "renderers/text_renderer.typ": render_text
#import "renderers/entries_renderer.typ": render_entries
#import "renderers/grouped_renderer.typ": render_grouped
#import "renderers/list_renderer.typ": render_list

/// Orquestador principal de la plantilla Modern
/// Configura página, tipografía contemporánea sans-serif, acento en azul marino,
/// encabezado con soporte opcional de foto/avatar y renderizado dinámico de secciones.
#let modern_cv(cv-data, paper: "a4") = {
  let author = if "datos_personales" in cv-data and "nombre_completo" in cv-data.datos_personales {
    cv-data.datos_personales.nombre_completo
  } else {
    "Curriculum Vitae"
  }

  set document(
    title: "CV - " + author,
    author: author,
  )

  set page(
    paper: paper,
    margin: page-margin,
    header: none,
    footer: none,
  )

  set text(
    font: font-family,
    size: size-body,
    fill: color-secondary,
    lang: "es",
    hyphenate: false,
  )

  set par(
    justify: true,
    leading: 0.6em,
  )

  // Renderizar encabezado automáticamente si hay datos personales
  if "datos_personales" in cv-data {
    cv_header(cv-data.datos_personales)
  }

  // Renderizado dinámico y agnóstico de las secciones definidas en el JSON
  for seccion in cv-data.at("secciones", default: ()) {
    let tipo = seccion.at("tipo", default: "texto")
    let titulo = seccion.at("titulo", default: "")

    if tipo == "texto" [
      #render_text(titulo, seccion.at("contenido", default: ""))
    ] else if tipo == "entradas" [
      #render_entries(titulo, seccion.at("items", default: ()))
    ] else if tipo == "agrupado" [
      #render_grouped(titulo, seccion.at("grupos", default: ()))
    ] else if tipo == "lista" [
      #render_list(titulo, seccion.at("elementos", default: ()))
    ]
  }
}
