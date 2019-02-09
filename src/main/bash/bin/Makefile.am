SUBDIRS = .

bashrun = @BASHRUN@

aws_cli = @AWS_CLI@
jq      = @JQ@
curl    = @CURL@
unzip   = @UNZIP@
openssl = @OPENSSL@

@do_subst_command@

BASHSCRIPTS = \
    plambda.in \
    plambda-utils.in

GBASHSCRIPTS = $(BASHSCRIPTS:.in=)

dist_noinst_DATA = \
    $(BASHSCRIPTS)

bin_SCRIPTS = \
    $(GBASHSCRIPTS)

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

CLEANFILES = \
    $(GBASHSCRIPTS)

all:
