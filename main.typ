#import "src/core/inputs.typ": load_cv_data, get_template_name, get_paper_format
#import "src/templates/harvard/template.typ": harvard_cv
#import "src/templates/modern/template.typ": modern_cv

// Carga polimórfica de los datos del candidato (disco, memoria o fallback)
#let cv-data = load_cv_data()

// Resolución de plantilla y formato de papel (con soporte de sobreescritura vía CLI)
#let plantilla = get_template_name(cv-data)
#let paper = get_paper_format()

#if plantilla == "modern" {
  modern_cv(cv-data, paper: paper)
} else {
  harvard_cv(cv-data, paper: paper)
}
