# JRE - Jolly Ratter Engine Pascal
# Requires: fpc >= 3.2, SDL2 >= 2.0.10, SDL2_image, SDL2_mixer, SDL2_ttf
# Pascal SDL2 bindings: make vendor-get  (fetches SDL2-for-Pascal)

FPC       := fpc
SRC_DIR   := src
BUILD_DIR := build
BIN_DIR   := bin
VENDOR    := vendor/sdl2-for-pascal/units

FPC_FLAGS := \
  -Fu$(SRC_DIR) \
  -Fu$(VENDOR) \
  -FU$(BUILD_DIR) \
  -O2 \
  -gl \
  -k--allow-shlib-undefined

.PHONY: all hello dirs clean vendor-get run-hello

all: dirs hello

dirs:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)

hello: dirs
	$(FPC) $(FPC_FLAGS) -FE$(BIN_DIR) examples/hello/hello.pas

vendor-get:
	@mkdir -p vendor
	@if [ ! -d vendor/sdl2-for-pascal ]; then \
		git clone --depth 1 \
		  https://github.com/PascalGameDevelopment/SDL2-for-Pascal.git \
		  vendor/sdl2-for-pascal; \
	else \
		echo "SDL2-for-Pascal already present"; \
	fi

run-hello: hello
	$(BIN_DIR)/hello

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
