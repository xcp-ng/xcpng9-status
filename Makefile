# Build and check the design model.  Used both locally and by CI.
#
#   make            exports and HTML site
#   make check      all checks (arclang lint, SysML v2, Capella)
#
# CAPELLAMBSE_PYTHON: the interpreter py-capellambse is installed for.

MODEL := xcpng9-status
BUILD := build
SITE := $(BUILD)/site
CAPELLAMBSE_PYTHON ?= python3

.PHONY: all export site check check-arclang check-sysml check-capella clean

all: site

export:
	arclang export -f sys-ml -o $(BUILD)/sysml/$(MODEL).sysml $(MODEL).arc
	arclang export -f capella -o $(BUILD)/capella/$(MODEL).capella $(MODEL).arc

site: export
	mkdir -p $(SITE)/exports
	arclang explorer -o $(SITE)/index.html $(MODEL).arc
	cp $(BUILD)/sysml/$(MODEL).sysml $(SITE)/exports/
	cd $(BUILD) && tar czf site/exports/$(MODEL)-capella.tar.gz capella

check: check-arclang check-sysml check-capella

check-arclang:
	arclang check --lint $(MODEL).arc

check-sysml: export
	sysml -validate -strict $(BUILD)/sysml/$(MODEL).sysml

check-capella: export
	$(CAPELLAMBSE_PYTHON) checks/validate-capella $(BUILD)/capella

clean:
	rm -rf $(BUILD)
