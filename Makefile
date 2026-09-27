.PHONY: all pdf watch png clean help

BUILD_DIR = build
SRC = main.typ
OUTPUT_PDF = $(BUILD_DIR)/cv.pdf
OUTPUT_PNG = $(BUILD_DIR)/preview-{p}.png

# Variables de entrada configurables
DATA ?= data/cv.json
TEMPLATE ?=
PLANTILLA ?= $(TEMPLATE)
PAPER ?= a4

# Resolución amigable de la ruta del archivo de datos dentro de data/
RESOLVED_DATA = $(shell if [ -f "$(DATA)" ]; then echo "$(DATA)"; \
	elif [ -f "data/$(DATA)" ]; then echo "data/$(DATA)"; \
	elif [ -f "data/$(DATA).json" ]; then echo "data/$(DATA).json"; \
	elif [ -f "data/cv.$(DATA).json" ]; then echo "data/cv.$(DATA).json"; \
	else echo "$(DATA)"; fi)

INPUT_FLAGS = --input data="$(RESOLVED_DATA)" --input paper="$(PAPER)"
ifneq ($(strip $(PLANTILLA)),)
  INPUT_FLAGS += --input plantilla="$(PLANTILLA)"
endif

all: pdf

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

pdf: $(BUILD_DIR)
	typst compile $(INPUT_FLAGS) $(SRC) $(OUTPUT_PDF)

watch: $(BUILD_DIR)
	typst watch $(INPUT_FLAGS) $(SRC) $(OUTPUT_PDF)

png: $(BUILD_DIR)
	typst compile --format png --ppi 150 $(INPUT_FLAGS) $(SRC) $(OUTPUT_PNG)

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Comandos disponibles:"
	@echo "  make                                - Compila con data/cv.json a $(OUTPUT_PDF)"
	@echo "  make pdf                            - Igual que 'make'"
	@echo "  make watch                          - Modo live-reload al guardar cambios"
	@echo "  make png                            - Exporta vista previa en PNG (150 PPI)"
	@echo "  make clean                          - Elimina la carpeta $(BUILD_DIR)"
	@echo ""
	@echo "Variables configurables (flags):"
	@echo "  DATA=<ruta|nombre>                  - Archivo de datos JSON (ej: DATA=cv.example.json)"
	@echo "  TEMPLATE=<harvard|modern>           - Fuerza la plantilla visual deseada"
	@echo "  PAPER=<a4|us-letter>                - Formato de papel (por defecto: a4)"
	@echo ""
	@echo "Ejemplos:"
	@echo "  make pdf DATA=cv.example.json"
	@echo "  make pdf TEMPLATE=modern"
	@echo "  make pdf DATA=cv.example.json TEMPLATE=modern"
	@echo "  make watch DATA=cv.example.json"
	@echo "  make png DATA=cv.example.json TEMPLATE=modern"
