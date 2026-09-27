# Typst CLI & Environment Reference (v0.15+)

## 1. Comandos Esenciales

### Compilación Básica
```bash
# Compilar a PDF
typst compile main.typ documento.pdf

# Compilar a formato específico (pdf, png, svg, html, bundle)
typst compile --format svg main.typ pagina-{0p}.svg
```

### Modo Observador (Live Watch)
Recompila automáticamente al guardar cambios en cualquier archivo dependiente:
```bash
typst watch main.typ documento.pdf
```

### Evaluación e Inspección (`typst eval`)
*Nota:* En v0.15+, `typst eval` reemplaza y generaliza al antiguo `typst query`.
```bash
# Inspeccionar valores o metadatos de un documento
typst eval main.typ "<metadata-label>"
```

---

## 2. Parámetros Importantes

- `--root <DIR>`: Define la raíz del proyecto para resolver rutas absolutas iniciadas con `/`.
- `--font-path <DIR>`: Agrega directorios adicionales para escanear fuentes tipográficas (separados por `:` en Linux).
- `--input key=value`: Pasa variables al documento accesibles mediante `sys.inputs.at("key")`.
- `--pdf-standard <STANDARD>`: Valida conformidad con estándares PDF (ej. `1.7`, `a-2b`, `ua-1`).

---

## 3. Resolución de Problemas en Linux (Snap Confinement)

Cuando Typst se instala a través del gestor `snap` (`/snap/bin/typst`), se ejecuta bajo un perfil estricto de AppArmor.

### Síntoma:
`error: failed to load file (access denied)`

### Causa:
El proyecto se encuentra en un enlace simbólico que apunta fuera de `$HOME` (por ejemplo, a `/mnt/datos/...` o un disco secundario).

### Solución:
Conectar la interfaz de medios extraíbles de Snap:
```bash
sudo snap connect typst:removable-media
```
O bien ejecutar Typst pasando la raíz explícita con `--root .`.
