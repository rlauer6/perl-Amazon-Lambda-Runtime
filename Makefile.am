SUBDIRS = . src

perlenv = @ENV@ perl
lambdadir = src/main/perl/lambda

ACLOCAL_AMFLAGS = -I autotools

.PHONY: check-config

check-config: config.log

config.log: buildspec.yml
	@ls config.log

dist_noinst_DATA = \
    install-framework

EXTRA_DIST = \
    gitignore

LAMBDA_FILES = \
    runtime-buildspec.yml \
    runtime-buildspec.yml

README = README.md.in

GREADME = $(README:.md.in=.md)

README_HTML = $(GREADME:.md=.html)

$(GREADME): % : %.in $(README)
	md-utils $< > $@

$(README_HTML): $(GREADME)
	md-utils --render $< > $@

readme: $(GREADME)

html: $(README_HTML)

clean-local:
	rm -rf $(LAMBDA_FILES)
