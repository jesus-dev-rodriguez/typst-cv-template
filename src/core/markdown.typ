/// Módulo nativo universal de procesamiento Markdown para Typst (v0.15+)
/// 100% offline y desacoplado, sin paquetes externos de Typst Universe.
///
/// Soporta de forma segura y completa:
/// - Enlaces: [texto](url) -> link("url")[texto]
/// - Negrita: **texto** o __texto__
/// - Cursiva: *texto* o _texto_
/// - Negrita + Cursiva: ***texto*** o ___texto___
/// - Tachado: ~~texto~~ -> strike[texto]
/// - Resaltado: ==texto== -> highlight[texto]
/// - Subrayado: <u>texto</u> o ++texto++ -> underline[texto]
/// - Superíndice: ^texto^ -> super[texto]
/// - Subíndice: ~texto~ -> sub[texto]
/// - Citas / Blockquotes: > cita -> quote[cita]
/// - Código en línea: `código`
/// - Párrafos múltiples con saltos de línea dobles
/// - Escape automático de caracteres propios de Typst (#, $, @) para evitar
///   colisiones de sintaxis con términos técnicos (C#, @usuario, $1000).

#let render_md(input) = {
  if input == none { return none }
  if type(input) == content { return input }
  let s = str(input)
  if s == "" { return "" }

  // 1. Escapar caracteres sintácticos de Typst (#, $, @)
  let t = s.replace("#", "\\#").replace("$", "\\$").replace("@", "\\@")

  // 2. Enlaces Markdown: [texto](url) -> #link("url")[texto]
  t = t.replace(regex("\[(.*?)\]\((.*?)\)"), m => {
    let target = m.captures.at(1).replace("\\#", "#")
    "#link(\"" + target + "\")[" + m.captures.at(0) + "]"
  })

  // 3. Negrita + Cursiva: ***texto*** o ___texto___ -> #strong[#emph[texto]]
  t = t.replace(regex("\*\*\*(.*?)\*\*\*"), m => "#strong[#emph[" + m.captures.at(0) + "]]")
  t = t.replace(regex("___(.*?)___"), m => "#strong[#emph[" + m.captures.at(0) + "]]")

  // 4. Negrita: **texto** o __texto__ -> #strong[texto]
  t = t.replace(regex("\*\*(.*?)\*\*"), m => "#strong[" + m.captures.at(0) + "]")
  t = t.replace(regex("__(.*?)__"), m => "#strong[" + m.captures.at(0) + "]")

  // 5. Tachado: ~~texto~~ -> #strike[texto]
  t = t.replace(regex("~~(.*?)~~"), m => "#strike[" + m.captures.at(0) + "]")

  // 6. Resaltado: ==texto== -> #highlight[texto]
  t = t.replace(regex("==(.*?)=="), m => "#highlight[" + m.captures.at(0) + "]")

  // 7. Subrayado: <u>texto</u> o ++texto++ -> #underline[texto]
  t = t.replace(regex("<u>(.*?)</u>"), m => "#underline[" + m.captures.at(0) + "]")
  t = t.replace(regex("\+\+(.*?)\+\+"), m => "#underline[" + m.captures.at(0) + "]")

  // 8. Superíndice: ^texto^ -> #super[texto]
  t = t.replace(regex("\^([^\^\s]+?)\^"), m => "#super[" + m.captures.at(0) + "]")

  // 9. Subíndice: ~texto~ -> #sub[texto] (después de ~~tachado~~)
  t = t.replace(regex("(^|[^\~])\~([^\~\s]+?)\~([^\~]|$)"), m => m.captures.at(0) + "#sub[" + m.captures.at(1) + "]" + m.captures.at(2))

  // 10. Cursiva con asteriscos: *texto* -> #emph[texto]
  t = t.replace(regex("(^|[^\*])\*([^\*\n]+?)\*([^\*]|$)"), m => m.captures.at(0) + "#emph[" + m.captures.at(1) + "]" + m.captures.at(2))

  // 11. Cursiva con guiones bajos: _texto_ -> #emph[texto]
  t = t.replace(regex("(^|[^\w])_([^\_\n]+?)_([^\w]|$)"), m => m.captures.at(0) + "#emph[" + m.captures.at(1) + "]" + m.captures.at(2))

  // 12. Citas / Blockquotes al inicio de línea: > cita -> #quote[...]
  t = t.replace(regex("(^|\n)>\s*([^\n]+)"), m => m.captures.at(0) + "#quote[" + m.captures.at(1) + "]")

  // 13. Sanitizar asteriscos o guiones bajos huérfanos para evitar errores de delimitador
  t = t.replace("*", "\\*")
  t = t.replace(regex("(^|\s)_"), m => m.captures.at(0) + "\\_")

  eval(t, mode: "markup")
}
