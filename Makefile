# Makefile
GO := go
GO_BUILD := $(GO) build
GO_ENV := CGO_ENABLED=0 GOOS=linux
GO_FLAGS := \
	-ldflags="-s -w"
SUFFIX := .go

.PHONY: all
all: handlers

DEPFILES :=

LIBS := \

DEPFILES += $(LIBS:%=%/*$(SUFFIX))

LAMBDA_HANDLER_DIR := handler
LAMBDA_HANDLERS := \
	csvimporter
DEPFILES += $(addprefix $(LAMBDA_HANDLER_DIR)/, $(LAMBDA_HANDLERS:%=%/*$(SUFFIX)))
DIST_DIR := dist
TARGETS := $(LAMBDA_HANDLERS:%=$(DIST_DIR)/%)

$(DIST_DIR)/%: $(LAMBDA_HANDLER_DIR)/% $(DEPFILES) go.sum
	$(GO_ENV) $(GO_BUILD) $(GO_FLAGS) -o $@ ./$<

.PHONY: handlers
handlers: $(TARGETS)

.PHONY: clean
clean:
	$(GO) clean
	rm -rf $(DIST_DIR)