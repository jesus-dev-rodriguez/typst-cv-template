#!/usr/bin/env python3
"""
scripts/bundle.py — Empaquetador Monolítico de Producción para Typst CV Engine

Toma el código fuente modular de `src/` (core y templates) y genera un único
archivo autocontenido en `dist/cv-engine.typ` listo para distribución y uso en
servidores, SPAs web sin servidor o funciones Lambda.

Uso:
    python3 scripts/bundle.py [--src SRC_DIR] [--out OUT_FILE]
"""

import os
import sys
import re
import argparse
from datetime import datetime

BANNER = """// =============================================================================
// CV Engine — Single-File Bundled Distribution
// Generated automatically by scripts/bundle.py on {date}
// Engine compatible with Typst v0.15+
// =============================================================================
"""

def clean_file_content(content, to_code_mode=False):
    """
    Extrae paquetes @preview externos y elimina imports relativos locales.
    Si to_code_mode es True, convierte '#let ' al inicio de línea en 'let '
    para ser embebido dentro de un bloque de diccionario Typst { ... }.
    Retorna (cleaned_content, list_of_external_packages).
    """
    external_pkgs = []
    cleaned_lines = []

    for line in content.splitlines():
        # Captura imports de Typst Universe (@preview/...)
        pkg_match = re.match(r'^\s*#import\s+["\'](@preview/[^"\']+)["\']\s*:\s*(.+)$', line)
        if pkg_match:
            external_pkgs.append(line.strip())
            continue

        # Elimina imports relativos internos (#import "..." o #import '../...)
        if re.match(r'^\s*#import\s+["\'][^@]', line):
            continue

        # Si estamos dentro de un bloque de código Typst, '#let' al inicio de línea es inválido
        if to_code_mode and line.startswith("#let "):
            line = "let " + line[5:]

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines).strip(), external_pkgs

def read_and_clean(file_path, to_code_mode=False):
    if not os.path.isfile(file_path):
        return "", []
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    return clean_file_content(content, to_code_mode=to_code_mode)

def bundle(src_dir="src", out_file="dist/cv-engine.typ"):
    print(f"📦 Iniciando empaquetado desde '{src_dir}' hacia '{out_file}'...")
    all_external_pkgs = []
    bundle_parts = []

    # 1. Procesar Core (media.typ, inputs.typ, markdown.typ)
    core_dir = os.path.join(src_dir, "core")
    core_files = ["media.typ", "inputs.typ", "markdown.typ"]
    core_contents = []

    for cf in core_files:
        path = os.path.join(core_dir, cf)
        if os.path.exists(path):
            cleaned, pkgs = read_and_clean(path)
            all_external_pkgs.extend(pkgs)
            core_contents.append(f"// --- Core: {cf} ---\n{cleaned}")

    # 2. Descubrir y procesar templates
    templates_dir = os.path.join(src_dir, "templates")
    template_names = []

    if os.path.exists(templates_dir):
        # Orden alfabético determinista
        for tmpl_name in sorted(os.listdir(templates_dir)):
            tmpl_path = os.path.join(templates_dir, tmpl_name)
            if not os.path.isdir(tmpl_path):
                continue

            template_names.append(tmpl_name)
            tmpl_parts = []

            # Orden de resolución de dependencias dentro de la plantilla
            ordered_files = [
                os.path.join(tmpl_path, "theme.typ"),
                os.path.join(tmpl_path, "components", "section_title.typ"),
                os.path.join(tmpl_path, "components", "entry.typ"),
                os.path.join(tmpl_path, "components", "header.typ"),
                os.path.join(tmpl_path, "renderers", "text_renderer.typ"),
                os.path.join(tmpl_path, "renderers", "entries_renderer.typ"),
                os.path.join(tmpl_path, "renderers", "grouped_renderer.typ"),
                os.path.join(tmpl_path, "renderers", "list_renderer.typ"),
                os.path.join(tmpl_path, "template.typ"),
            ]

            for tf in ordered_files:
                if os.path.exists(tf):
                    rel = os.path.relpath(tf, tmpl_path)
                    cleaned, pkgs = read_and_clean(tf, to_code_mode=True)
                    all_external_pkgs.extend(pkgs)
                    tmpl_parts.append(f"  // [{rel}]\n" + "\n".join("  " + l if l.strip() else "" for l in cleaned.splitlines()))

            # Encapsulado del template en un módulo de diccionario
            wrapped_template = (
                f"// =============================================================================\n"
                f"// Template: {tmpl_name.upper()}\n"
                f"// =============================================================================\n"
                f"#let {tmpl_name} = {{\n"
                + "\n\n".join(tmpl_parts) + "\n\n"
                f"  (cv: {tmpl_name}_cv)\n"
                f"}}"
            )
            bundle_parts.append(wrapped_template)

    # 3. Router Universal
    router_map = ",\n".join(f'  "{t}": {t}.cv' for t in template_names)
    default_template = "harvard" if "harvard" in template_names else template_names[0]

    router_code = (
        "// =============================================================================\n"
        "// Universal Dispatcher & Router\n"
        "// =============================================================================\n"
        "#let cv-data = load_cv_data()\n"
        "#let plantilla = get_template_name(cv-data)\n"
        "#let paper = get_paper_format()\n\n"
        "#let available_templates = (\n"
        f"{router_map},\n"
        ")\n\n"
        f'#let runner = available_templates.at(plantilla, default: {default_template}.cv)\n'
        "#(runner)(cv-data, paper: paper)\n"
    )

    # 4. Ensamble final
    dedup_pkgs = list(dict.fromkeys(all_external_pkgs))
    
    final_output = []
    final_output.append(BANNER.format(date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
    
    if dedup_pkgs:
        final_output.append("// External Packages\n" + "\n".join(dedup_pkgs) + "\n")

    final_output.append("// Core Utilities\n" + "\n\n".join(core_contents) + "\n")
    final_output.append("\n\n".join(bundle_parts) + "\n")
    final_output.append(router_code)

    # 5. Escribir archivo de salida
    out_dir = os.path.dirname(out_file)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    with open(out_file, "w", encoding="utf-8") as f:
        f.write("\n".join(final_output))

    size_kb = os.path.getsize(out_file) / 1024
    print(f"✅ Bundle generado exitosamente en '{out_file}' ({size_kb:.1f} KB).")
    print(f"   Templates integrados: {', '.join(template_names)}")

def main():
    parser = argparse.ArgumentParser(description="Empaquetador de CV Engine para Typst")
    parser.add_argument("--src", default="src", help="Directorio raíz de fuentes (default: src)")
    parser.add_argument("--out", default="dist/cv-engine.typ", help="Ruta del archivo de salida (default: dist/cv-engine.typ)")
    args = parser.parse_args()

    bundle(src_dir=args.src, out_file=args.out)

if __name__ == "__main__":
    main()
