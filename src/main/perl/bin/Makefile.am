SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @PERL@

perlenv = @ENV@ perl

perlwc  = @PERL@

pod2man = @POD2MAN@

aws_cli = @AWS_CLI@

scandeps = @SCANDEPS@

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

PERLSCRIPTS = \
    plambda-driver.pl.in \
    command_install.pl.in \
    command_list_layers.pl.in \
    command_download.pl.in \
    command_view.pl.in \
    command_parse_config.pl.in \
    command_invoke.pl.in \
    command_publish.pl.in \
    command_clean.pl.in \
    command_list_roles.pl.in \
    command_list_versions.pl.in \
    command_delete_function.pl.in \
    command_delete_runtime_layers.pl.in \
    command_delete.pl.in \
    command_init.pl.in \
    command_list_functions.pl.in \
    command_state.pl.in \
    command_list.pl.in \
    command_set.pl.in \
    command_config.pl.in

HELP = \
    plambda-build.pod \
    plambda-clean.pod \
    plambda-config.pod \
    plambda-delete.pod \
    plambda-download.pod \
    plambda-help.pod \
    plambda-init.pod \
    plambda-invoke.pod \
    plambda-install.pod \
    plambda-list.pod \
    plambda-publish.pod \
    plambda-set.pod \
    plambda-state.pod \
    plambda-view.pod

PLAMBDA_CONFIG = \
    plambda.yml.in

GPLAMBDA_CONFIG=$(PLAMBDA_CONFIG:.yml.in=.yml)

configdir = $(datadir)/plambda
config_DATA = $(GPLAMBDA_CONFIG)

helpdir = $(datadir)/plambda

help_DATA = $(HELP)

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

libexec_SCRIPTS = \
    $(GPERLSCRIPTS)

dist_noinst_DATA = \
    $(PERLSCRIPTS) \
    $(HELP) \
    $(PLAMBDA_CONFIG)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

$(GPLAMBDA_CONFIG): $(PLAMBDA_CONFIG)
	$(do_subst) $< > $@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

%.pl: %.pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

$(G1MANPAGES): %.1man : %.pl
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)"  $< \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true

all:

CLEANFILES = \
   $(GPLAMBDA_CONFIG)

MOSTLYCLEANFILES = \
    $(GPERLSCRIPTS) \
    $(G1MANPAGES)

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	rm -f "$${mpath}" ;\
	test $$? -eq 0 || exit 1 ;\
	done
