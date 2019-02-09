# system directories
crondir        = $(sysconfdir)/cron.d
logrotatedir   = $(sysconfdir)/logrotate.d
init_ddir      = $(sysconfdir)/init.d

# Apache Virtual Host site directories
apache_vhost_dir          = @tbc_coredir@
apache_sitedir            = $(apache_vhost_dir)
apache_site_bedrockdir    = $(apache_sitedir)/htdocs/bedrock
apache_site_cloud_imgdir  = $(apache_sitedir)/htdocs/cloud-img
apache_site_bedrocklogdir = $(apache_sitedir)/logs/html
apache_site_cachedir      = $(apache_sitedir)/cache
apache_site_cgibindir     = $(apache_sitedir)/cgi-bin
apache_site_configdir     = $(apache_sitedir)/config
apache_site_config_ddir   = $(apache_sitedir)/config.d/startup
apache_site_htdocsdir     = $(apache_sitedir)/htdocs
apache_site_imgdir        = $(apache_sitedir)/htdocs/img
apache_site_javascriptdir = $(apache_sitedir)/htdocs/javascript
apache_site_cssdir        = $(apache_sitedir)/htdocs/css
apache_site_admindir      = $(apache_sitedir)/htdocs/admin
apache_site_admin_cgibindir = $(apache_sitedir)/htdocs/admin/cgi-bin
apache_site_includedir    = $(apache_sitedir)/include
apache_site_logdir        = $(apache_sitedir)/logs
apache_site_pebblesdir    = $(apache_sitedir)/pebbles
apache_site_reportsdir    = $(apache_sitedir)/reports
apache_site_sessiondir    = $(apache_sitedir)/session
apache_site_spooldir      = $(apache_sitedir)/spool
apache_site_workdir       = $(apache_sitedir)/work
apache_site_perl5libdir   = $(apache_sitedir)/share/perl5
site_perl5libdir          = $(apache_sitedir)/share/perl5
apache_handlersdir        = $(apache_sitedir)/share/perl5/Bedrock/Apache

# Bedrock
bedrockdir          = @bedrockdir@
bedrock_libdir      = $(bedrockdir)/lib/bedrock
bedrock_configdir   = $(bedrockdir)/lib/bedrock/config
bedrock_perl5libdir = $(bedrockdir)/lib/bedrock/perl5
bedrock_htdocsdir   = $(bedrockdir)/share/bedrock/htdocs
bedrock_imgdir      = $(bedrockdir)/share/bedrock/img
bedrock_pebblesdir  = $(bedrockdir)/share/bedrock/pebbles

# resources
resourcesdir    = $(datadir)/@PACKAGE@

# perl modules (web only)
blmdir        = $(apache_site_perl5libdir)/BLM
startupblmdir = $(blmdir)/Startup

# perl modules (common)
perl5libdir    = @perl5libdir@
