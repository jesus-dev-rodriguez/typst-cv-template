/// Módulo universal de resolución de entradas (sys.inputs)
/// Soporta:
/// 1. JSON crudo en memoria (string iniciado en '{' o '[') -> decodificado directamente como bytes
/// 2. Ruta a archivo en disco (relativa o absoluta)
/// 3. Fallback predeterminado -> /data/cv.json
#let load_cv_data() = {
  if "data" in sys.inputs {
    let raw = sys.inputs.data
    if raw.starts-with("{") or raw.starts-with("[") {
      json(bytes(raw))
    } else {
      let path = if raw.starts-with("/") { raw } else { "/" + raw }
      json(path)
    }
  } else {
    json("/data/cv.json")
  }
}

/// Determina la plantilla visual a utilizar.
/// Prioridad:
/// 1. Flag de CLI / sys.inputs: --input plantilla="..." o --input template="..."
/// 2. Clave en el propio JSON: "plantilla": "..."
/// 3. "harvard" por defecto
#let get_template_name(cv-data) = {
  if "plantilla" in sys.inputs {
    sys.inputs.plantilla
  } else if "template" in sys.inputs {
    sys.inputs.template
  } else {
    cv-data.at("plantilla", default: "harvard")
  }
}

/// Determina el formato de papel a utilizar.
/// Prioridad:
/// 1. Flag de CLI / sys.inputs: --input paper="..."
/// 2. "a4" por defecto
#let get_paper_format() = {
  sys.inputs.at("paper", default: "a4")
}
