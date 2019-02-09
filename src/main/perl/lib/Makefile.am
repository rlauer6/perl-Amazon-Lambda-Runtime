SUBDIRS = .

perlenv = @ENV@ perl

perlwc  = @PERL@

perl5libdir = @perl5libdir@
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

# this is where we will install these perl modules
amazondir = @datadir@/perl5/Amazon
amazon_plambdadir = @datadir@/perl5/Amazon/Plambda

PERLMODULES = \
    Amazon/Plambda.pm.in

PLAMBDACONFIGMODULE = \
    Amazon/Plambda/Config.pm.in

PLAMBDAMODULES = \
    Amazon/Plambda/Global.pm.in \
    Amazon/Plambda/Buildspec.pm.in \
    Amazon/Plambda/Runtime.pm.in \
    Amazon/Plambda/Message.pm.in

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)
GPLAMBDAMODULES = $(PLAMBDAMODULES:.pm.in=.pm)
GPLAMBDACONFIGMODULE = $(PLAMBDACONFIGMODULE:.pm.in=.pm)

amazon_DATA = \
    $(GPERLMODULES)

amazon_plambda_DATA = \
    $(GPLAMBDAMODULES) \
    $(GPLAMBDACONFIGMODULE)

dist_noinst_DATA = \
    $(PERLMODULES) \
    $(PLAMBDAMODULES) \
    $(PLAMBDACONFIGMODULE)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
   -I $(builddir) \
   $(PERL5_EXTRA_INCLUDES) \
   -I $(perl5libdir) 

$(GPERLMODULES): % : %.in $(GPLAMBDAMODULES)
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE)  $@ || { ret=$?; rm $@ && exit $ret; }

$(GPLAMBDAMODULES): % : %.in $(GPLAMBDACONFIGMODULE)
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE)  $@ || { ret=$?; rm $@ && exit $ret; }

%.pm: %.pm.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE)  $@ || { ret=$?; rm $@ && exit $ret; }

all:

CLEANFILES = \
    $(GPERLMODULES) \
    $(GPLAMBDAMODULES) \
    $(GPLAMBDACONFIGMODULE)
