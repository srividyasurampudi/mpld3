VERSION = $(shell python -c "import mpld3; print(mpld3.__version__)")

GENERATED_FILES = \
	src/start.js \
	mpld3/js/mpld3.v$(VERSION).js \
	mpld3/js/mpld3.v$(VERSION).min.js

javascript: $(GENERATED_FILES)

test:
	@npm test

src/start.js: 
	@node bin/start $(VERSION) > $@

mpld3/js/mpld3.v$(VERSION).js: $(shell node_modules/.bin/smash --ignore-missing --list src/mpld3.js) package.json
	@rm -f $@
	node_modules/.bin/smash src/mpld3.js | node_modules/.bin/uglifyjs - -b indent-level=2 -o $@
	@chmod a-w $@

mpld3/js/mpld3.v$(VERSION).min.js: mpld3/js/mpld3.v$(VERSION).js bin/uglify
	@rm -f $@
	bin/uglify $< > $@

clean:
	rm -f -- $(GENERATED_FILES)

sync_current : mplexporter
	rsync -r mplexporter/mplexporter mpld3/

submodule : mplexporter
	python setup.py submodule

build : javascript submodule
	python setup.py build

inplace : build
	python setup.py build_ext --inplace

install : build
	python setup.py install
