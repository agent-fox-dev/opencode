.PHONY: install build build-skip-web dev clean distclean smoke-test sync-upstream

BUN      ?= bun
PKG_DIR   = packages/opencode
CLI_DIR   = packages/cli
DIST      = $(PKG_DIR)/dist
BINARY    = $(shell find $(DIST) -name opencode -type f 2>/dev/null | head -1)

install:
	$(BUN) install
	$(BUN) run --cwd packages/core fix-node-pty

build: install
	cd $(PKG_DIR) && $(BUN) run script/build.ts --single

build-skip-web: install
	cd $(PKG_DIR) && $(BUN) run script/build.ts --single --skip-embed-web-ui

dev:
	$(BUN) dev

clean:
	rm -rf $(PKG_DIR)/dist $(CLI_DIR)/dist

clean-all: clean
	rm -rf node_modules .sst .turbo
	find packages sdks -maxdepth 2 -name node_modules -type d -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 4 -name dist -type d -not -path '*/node_modules/*' -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 4 -name out -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 3 -name .turbo -type d -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 3 -name .astro -type d -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 3 -name .artifacts -type d -exec rm -rf {} + 2>/dev/null || true
	find . -maxdepth 3 -name gen -type d -not -path '*/node_modules/*' -exec rm -rf {} + 2>/dev/null || true
	find . -name '*.tsbuildinfo' -not -path '*/node_modules/*' -delete 2>/dev/null || true
	find . -name '*.bun-build' -not -path '*/node_modules/*' -delete 2>/dev/null || true
	rm -rf packages/desktop/out packages/desktop/resources/opencode-cli*
	rm -rf packages/web/.astro
	rm -rf bun.lock

smoke-test: build
	$(BINARY) --version
