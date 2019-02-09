SUBDIRS = .

include $(top_srcdir)/directories.inc
include $(top_srcdir)/aws-cli.inc
include $(top_srcdir)/programs.inc

bashrun = @BASHRUN@

# system perl?
perlrun = @PERL@

# perl env
perlenv = @ENV@ perl

PERL_LAYER_VERSION = @PERL_LAYER_VERSION@

USER_DEFINED_LAMBDA = @USER_DEFINED_LAMBDA@

# check modules/scripts against desired Perl env
if PERL_SYNTAX_CHECK
perlwc = $(perlenv) -wc
else
perlwc = \#
endif

runtime_package_version = @PACKAGE_VERSION@
runtime_package         = @PACKAGE@

# this needs more explanation...
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

role_arn = arn:aws:iam::@AWS_ACCOUNT@:role/@LAMBDA_ROLE@

# the handler value should correspond to the module & method you are calling.
# e.g. Lambda.handler

handler = @LAMBDA_HANDLER@
lambda_module_name = @LAMBDA_HANDLER_PREFIX@

perl_layer_version = @PERL_LAYER_VERSION@

# 8<----- Your Lambda Here -----

LAMBDA_MODULE_VERSION = @LAMBDA_MODULE_VERSION@

FUNCTION_LAYERS = \
    layers

$(FUNCTION_LAYERS): $(abs_top_srcdir)/buildspec.yml
	plambda parse-config layers > $(abs_builddir)/$@

LAMBDA = \
    lib/$(lambda_module_name).pm.in

GLAMBDA = \
    $(LAMBDA:.pm.in=.pm)

PLAMBDA = \
    plambda.pl.in

LAMBDA_FUNCTION = \
    $(GLAMBDA:.pm=)

LAMBDA_FUNCTION_NAME = \
    $(patsubst lib/%,%,$(LAMBDA_FUNCTION))

LAMBDA_FUNCTION_PKG = \
    $(patsubst lib/%,%, $(LAMBDA_FUNCTION:=.zip))

# 8<----- Lambda Layer & Custom Runtime -----
PERL_RUNTIME_NAME = \
   perl-runtime

LAMBDA_RUNTIME_MODULES = \
    lib/Amazon/Lambda/Runtime.pm.in

LAMBDA_RUNTIME_CONTEXT_MODULE = \
    lib/Amazon/Lambda/Context.pm.in

GLAMBDA_RUNTIME_CONTEXT_MODULE = $(LAMBDA_RUNTIME_CONTEXT_MODULE:.pm.in=.pm)

GLAMBDA_RUNTIME_MODULES = \
    $(LAMBDA_RUNTIME_MODULES:.pm.in=.pm)

amazon_lambdadir = Amazon/Lambda

dist_noinst_DATA = \
    $(LAMBDA_RUNTIME_MODULES) \
    $(LAMBDA_RUNTIME_CONTEXT_MODULE) \
    $(BOOTSTRAP) \
    $(PLAMBDA)

# this is an output from the 'publish-layer' API
RUNTIME_LAYER_ARN_STORE = \
    runtime_layer_arn

# this is our driver stub (does not do much of anything other than call your method)
BOOTSTRAP = \
    bootstrap.in

GBOOTSTRAP = $(BOOTSTRAP:.in=)

GPLAMBDA = $(PLAMBDA:.pl.in=.pl)

$(GPLAMBDA): % :%.in
	$(do_subst) $< > $@

PERL_RUNTIME = \
    $(GBOOTSTRAP) \
    $(GPLAMBDA)

PERL_RUNTIME_PKG = \
   $(PERL_RUNTIME_NAME:=.zip)

@do_subst_command@

$(LAMBDA): $(abs_top_srcdir)/$(lambda_module_name).pm $(abs_top_srcdir)/buildspec.yml
	$(CP) $< $@

$(GLAMBDA_RUNTIME_MODULES): % : %.in $(GLAMBDA_RUNTIME_CONTEXT_MODULE)

$(GLAMBDA): $(GLAMBDA_RUNTIME_MODULE)

$(GBOOTSTRAP): % : %.in
	$(do_subst) $< > $@
	chmod +x $@

LAMBDA_LIBS = \
    lambda-libs

$(LAMBDA_LIBS): $(abs_top_srcdir)/buildspec.yml
	plambda parse-config extra-libs > $(abs_builddir)/$@

RUNTIME_LIBS = \
    runtime-libs

$(RUNTIME_LIBS): $(abs_top_srcdir)/runtime-buildspec.yml
	plambda --runtime parse-config extra-libs > $(abs_builddir)/$@

# By default, the system does not include either a cpanfile for your
# Lambda or a cpanfile for the runtime layer. This is on purpose, to
# allow the cpanfiles to be part of your project and therefore under
# source control.
#
# If no cpanfile.in is found, then it is created by using scandeps.pl
# to detect dependencies.  If it is found, it is either the result of
# a previous run or the user may have included a 'cpanfile'
# specification in the buildspec.  Likewise, users can override the
# framework generated cpanfile in their 'plambda.yml' configuration
# file.

# Normally, any change to your Lambda will result in re-running
# scandeps.pl, however you may have been editing this and now have it
# locked down...use the --no-scandeps option to prevent re-running
# scandeps.pl...caveat emptor.

CPANFILE = \
    $(abs_top_srcdir)/cpanfile

$(CPANFILE): $(GLAMBDA) $(GLAMBDA_RUNTIME_MODULES)
	set -o pipefail; \
	test -n "$$DEBUG" && set -x; \
	if test -z "$$NO_SCANDEPS"; then \
	  PERL5LIB=lib $$SCANDEPS $$SCANDEPS_ARGS $(GLAMBDA)  2>/dev/null | $(perlenv) -npe 's/=>/,/; s/,$$/;/; s/^(.*)$$/requires $$1/;' > $@ || { rm -f $@; exit 1; }; \
	fi

RUNTIME_CPANFILE = \
    $(abs_top_srcdir)/runtime-cpanfile

$(RUNTIME_CPANFILE):  $(GLAMBDA_RUNTIME_MODULES)
	set -o pipefail; \
	test -n "$$DEBUG" && set -x; \
	if test -z "$$NO_SCANDEPS"; then \
	  PERL5LIB=lib $$SCANDEPS $$SCANDEPS_ARGS $(GLAMBDA_RUNTIME_MODULES)  2>/dev/null | grep -v backport | $(perlenv) -npe 's/=>/,/; s/,$$/;/; s/^(.*)$$/requires $$1/;' > $@ || { rm -f $@; exit 1; }; \
	fi

# **********************************************************************
# Note: We always create a cache directory here. It gets populated and
# continually updated by `cpanm` when it resolves dependencies and
# installs things under $(abs_builddir)/cache/runtime/local.
# **********************************************************************

$(PERL_RUNTIME_PKG): \
    $(PERL_RUNTIME) \
    $(RUNTIME_CPANFILE) \
    $(GLAMBDA_RUNTIME_MODULES) \
    $(GLAMBDA_RUNTIME_CONTEXT_MODULE) \
    $(RUNTIME_LIBS)
	test -n "$$DEBUG" && set -x; \
	cpan_builddir=$(abs_builddir)/cache/runtime; \
	$(MKDIR) -p $$cpan_builddir; \
	for a in $(GLAMBDA_RUNTIME_MODULES) $(GLAMBDA_RUNTIME_CONTEXT_MODULE); do \
	  test -d $$cpan_builddir/local/lib/perl5/$(amazon_lambdadir) || mkdir -p $$cpan_builddir/local/lib/perl5/$(amazon_lambdadir); \
	  $(CP) $$a $$cpan_builddir/local/lib/perl5/$(amazon_lambdadir); \
	done; \
	for a in $(RUNTIME_CPANFILE) $(abs_top_srcdir)/runtime-buildspec.yml; do \
	  $(MKDIR) -p $$cpan_builddir/plambda; \
	  $(CP) $$a $$cpan_builddir/plambda/; \
	done; \
	if ! $(CPANM) $$CPAN_MIRROR -n --no-man-pages -L $$cpan_builddir/local --cpanfile $(RUNTIME_CPANFILE) --installdeps .; then \
	  echo "ERROR: cpanm failures detected - check $$HOME/.cpanm/build.log"; \
	  exit 1; \
	fi; \
	if $(GREP) -q '^\-> FAIL' $$HOME/.cpanm/build.log; then \
	  echo "WARNING: possible cpanm failures detected - check $$HOME/.cpanm/build.log"; \
	fi; \
	for a in $(PERL_RUNTIME); do \
	  $(CP) $(abs_builddir)/$$a $$cpan_builddir; \
	done; \
	mkdir -p $(abs_builddir)/cache/runtime/lib; \
	if test -e "$(RUNTIME_LIBS)"; then \
	  for a in $$($(CAT) $(RUNTIME_LIBS)); do \
	    echo $$a; \
	    test -e $$a || test -L $$a && $(CP) -L $$a $$cpan_builddir/lib/$$(basename $$a); \
	  done; \
	fi; \
	ls -alrt; \
	pushd $$cpan_builddir; \
	$(ZIP) -r $(abs_builddir)/$@ *; \
	if test -e $(abs_builddir)/$@; then \
	  test -d "$$PLAMBDA_HOME/.plambda" || mkdir -p $$PLAMBDA_HOME/.plambda; \
	  $(CP) $(abs_builddir)/$@ $$PLAMBDA_HOME/.plambda/; \
	fi; \
	popd;

$(RUNTIME_LAYER_ARN_STORE): $(PERL_RUNTIME_PKG)
	set -x; \
	AWS_PROFILE="$(AWS_PROFILE)"; \
	if test -z "$(AWS_PROFILE)"; then \
	  echo "no AWS_PROFILE set...aborting."; { rm -f $@ && exit 1; }; \
	fi; \
	plambda publish runtime > $@

# The Lambda package you deploy will have Perl library dependencies in
# addition to the dependencies of the custom Perl runtime harness.
# These may change as your Lambda evolves and it use additional Perl
# modules.  Each time your Lambda is changed, this section of the
# makefile will use cpanm to install a CPAN distribution of your
# Lambda and resolve new dependencies by adding them to the local
# cache.  Dependencies that are unique to your Lambda are zipped up in
# the package that will be deployed to the AWS Lambda service.

# 1. copy all of the dependencies from the runtime layer to the cache/lambda directory
# 2. diff the runtime dependencies your lambda's dependencies

$(LAMBDA_FUNCTION_PKG): \
    $(PERL_RUNTIME_PKG) \
    $(CPANFILE) \
    $(GLAMBDA) \
    $(GLAMBDA_RUNTIME_MODULES) \
    $(LAMBDA_LIBS)
	test -n "$$DEBUG" && set -x; \
	set -o pipefail; \
	lambda_builddir=$(abs_builddir)/cache/lambda; \
	$(MKDIR) -p $$lambda_builddir; \
	$(CP) -rf $(abs_builddir)/cache/runtime/* $(abs_builddir)/cache/lambda/; \
	$(MKDIR) -p $(abs_builddir)/cache/lambda/local/lib/perl5; \
	$(CP) $(GLAMBDA) $(abs_builddir)/cache/lambda/local/lib/perl5/; \
	cd $(abs_builddir)/cache/runtime; \
	$(FIND) local | $(SORT) > $$lambda_builddir/before; \
	cd $$lambda_builddir; \
	if ! $(CPANM) $$CPAN_MIRROR -n --no-man-pages -L $$lambda_builddir/local --cpanfile $(CPANFILE) --installdeps .; then \
	  echo "ERROR: cpanm failures detected - check $$HOME/.cpanm/build.log"; \
	  exit 1; \
	fi; \
	if $(GREP) -q '^\-> FAIL' $$HOME/.cpanm/build.log; then \
	  echo "WARNING: possible cpanm failures detected - check $$HOME/.cpanm/build.log"; \
	fi; \
	$(FIND) local | $(SORT) > after; \
	$(COMM) -23 after before > deps; \
	mkdir -p $$lambda_builddir/lib; \
	if test -e "$(abs_builddir)/$(LAMBDA_LIBS)"; then \
	  for a in $$($(CAT) $(abs_builddir)/$(LAMBDA_LIBS)); do \
	    echo lib/$$(basename $$a) >> deps; \
	    test -e $$a || test -L $$a && $(CP) -L $$a $$lambda_builddir/lib/$$(basename $$a); \
	  done; \
	else \
	  echo "not found!"; \
	fi; \
	$(CAT) deps | $(ZIP) $(abs_builddir)/$@ -@;
	if test -e $(abs_builddir)/$@; then \
	  test -d "$$PLAMBDA_HOME/.plambda" || mkdir -p $$PLAMBDA_HOME/.plambda; \
	  $(CP) $(abs_builddir)/$@ $$PLAMBDA_HOME/.plambda/; \
	fi

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir) \
    -I $(builddir)/lib \
    -I cache/lambda/local/lib/perl5 \
    -I cache/runtime/local/lib/perl5

# pattern rules
%.pm: %.pm.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	test -n "$$DEBUG" && set -x; \
	$(perlwc) $(PERLINCLUDE) -M$$(echo $@ | $(perlrun) -np -e 's/\//\:\:/g; s/\.pm$$//;') -e 1  || { rm $@ && exit 1; }

%.pl: %.pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

# 8<------ make targets -------
#
# Typically the two targets below are the ones you will use in practice
# - use `make runtime-layer` when you want to create a new custom Perl runtime layer
# - use `make lambda` when you want to create or update a Lambda

runtime-module: $(GLAMBDA_RUNTIME_MODULES) $(PERL_RUNTIME)

runtime-cpanfile: $(RUNTIME_CPANFILE)

runtime-pkg: $(PERL_RUNTIME_PKG)

runtime-layer: $(RUNTIME_LAYER_ARN_STORE)

lambda-func: $(GLAMBDA)

lambda-pkg: $(LAMBDA_FUNCTION_PKG)

$(LAMBDA_FUNCTION_NAME): $(LAMBDA_FUNCTION_PKG) $(RUNTIME_LAYER_ARN_STORE) $(FUNCTION_LAYERS)
	test -n "$$DEBUG" && set -x; \
	if test -z "$(LAMBDA_ROLE)"; then \
	  echo "no role for Lambda set...aborting" && { rm -f $(abs_builddir)/$@ && exit 1; }; \
	fi; \
	if ! $(AWS_CLI_LIST_FUNCTIONS) | $(JQ) -r '.Functions[]|.FunctionName' | $(GREP) -qi '^$(LAMBDA_FUNCTION_NAME)'; then \
	  $(AWS_CLI_CREATE_FUNCTION) \
	  --function-name $(LAMBDA_FUNCTION_NAME)  \
	  --zip-file fileb://$(LAMBDA_FUNCTION_PKG) \
	  --handler $(handler) \
	  --runtime provided \
	  --role $(role_arn); \
	else \
	  $(AWS_CLI_UPDATE_FUNCTION) \
	  --function-name $(LAMBDA_FUNCTION_NAME) \
	  --zip-file fileb://$(LAMBDA_FUNCTION_PKG); \
	fi
	test -n "$$DEBUG" && set -x; \
	if ! $(GREP) -q 'perl-runtime' $(FUNCTION_LAYERS); then \
	  layer_arns=$$($(CAT) $(FUNCTION_LAYERS) $(RUNTIME_LAYER_ARN_STORE) | sort -u | tr '\n' ' '); \
	else \
	  layer_arns=$$($(CAT) $(FUNCTION_LAYERS)); \
	fi; \
	if ! [ "$(VPC_CONFIG)" = "none" ]; then \
	  vpc_config="--vpc-config $(VPC_CONFIG)"; \
	fi; \
	if ! [ "$(ENVIRONMENT)" = "none" ]; then \
	  environment="--environment $(ENVIRONMENT)"; \
	fi; \
	$(AWS_CLI_UPDATE_FUNCTION_CONFIGURATION) \
	  --function-name $(LAMBDA_FUNCTION_NAME) \
	  $$vpc_config \
	  $$environment \
	  --timeout $(TIMEOUT) \
	  --role $(role_arn) \
	  --memory-size $(MEMORY_SIZE) \
	  --layers $$layer_arns > $(LAMBDA_FUNCTION_NAME) || { rm -f $(LAMBDA_FUNCTION_NAME); exit 1; }

lambda: $(LAMBDA_FUNCTION_NAME)

CLEANFILES = \
    $(GBOOTSTRAP) \
    $(GPLAMBDA) \
    $(FUNCTION_LAYERS) \
    $(RUNTIME_CPANFILE) \
    $(RUNTIME_LIBS) \
    $(GLAMBDA_RUNTIME_MODULES) \
    $(GLAMBDA_RUNTIME_CONTEXT_MODULE) \
    $(PERL_RUNTIME_PKG) \
    $(RUNTIME_LAYER_ARN_STORE) \
    $(abs_top_srcdir)/runtime-buildspec.yml

# just clean up Lambda artifacts, not custom Perl runtime
MOSTLYCLEANFILES = \
    $(LAMBDA) \
    $(LAMBDA_LIBS) \
    $(GLAMBDA) \
    $(LAMBDA_FUNCTION_PKG) \
    $(LAMBDA_FUNCTION_NAME) \
    $(LAMBDA)

.PHONY: check-config

check-config:
	@if [ "$(AWS_ACCOUNT)" = "missing-account" ]; then \
	  echo "no account - run plambda config first"; \
	  exit 1; \
	fi; \
	if [ "$(LAMBDA_ROLE)" = "missing-role" ]; then \
	  echo "no role - run plambda config first";  \
	  exit 1; \
	fi;

clean-local:
	rm -rf cache/*
