#import "@preview/based:0.2.0": base64

/// Renderiza una imagen de perfil / avatar ya sea desde una ruta local a disco
/// o desde un Data URI en Base64 ("data:image/...;base64,...").
/// Si foto_data es `none` o string vacío, retorna `none`.
#let render_avatar(
  foto_data,
  width: 2.6cm,
  radius: 50%,
  stroke: 1pt + rgb("#dcdcdc")
) = {
  if foto_data != none and foto_data != "" {
    let img = if type(foto_data) == str and foto_data.starts-with("data:image") {
      let b64 = foto_data.replace(regex("^data:image/[^;]+;base64,"), "")
      image(base64.decode(b64), width: width, height: width, fit: "cover")
    } else {
      let resolved-path = if type(foto_data) == str and not foto_data.starts-with("/") {
        "/" + foto_data
      } else {
        foto_data
      }
      image(resolved-path, width: width, height: width, fit: "cover")
    }

    box(
      width: width,
      height: width,
      radius: radius,
      clip: true,
      stroke: stroke,
      img
    )
  }
}
