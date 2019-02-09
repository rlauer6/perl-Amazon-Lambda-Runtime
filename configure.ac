AC_INIT([perl-Amazon-Lambda-Runtime], [0.0.1], [rlauer6@comcast.net], [perl-Amazon-Lambda-Runtime])

__poor_mans_expand_file_name () {
    _tmp_name=$1
    _tmp_last="`eval echo '${'"${_tmp_name}"'}'`"
    if test -z "${_tmp_last}"; then
        printf "__poor_mans_expand_file_name() (WARNING): var \"%s\" is empty\n" \
          "${_tmp_name}" 1>&2
        return 0;  # nothing to do
    fi
    _tmp_last_expanded="`eval echo ${_tmp_last}`"
    while test "${_tmp_last_expanded}" != "${_tmp_last}"; do

        # Set 'last' hold var to most recently expanded version...
        _tmp_last="${_tmp_last_expanded}"

        # ...and try to expand further.
        _tmp_last_expanded="`eval echo ${_tmp_last_expanded}`"
    done
    printf "%s\n" "${_tmp_last_expanded}"
    unset _tmp_last_expanded
    unset _tmp_last
    unset _tmp_name
    return 0;
}


[
do_subst_command='do_subst = sed \
  -e '"'"'s,[@]PACKAGE[@],$(PACKAGE),g'"'"' \
  -e '"'"'s,[@]VERSION[@],$(VERSION),g'"'"' \
  -e '"'"'s,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g'"'"' \
  -e '"'"'s,[@]PATH_SEPARATOR[@],$(PATH_SEPARATOR),g'"'"' \
  -e '"'"'s~[@]configure_input[@]~Generated from $@.in; do not edit by hand.~g'"'"' \
  -e "s,[@]BUILD_DATE[@],$$(date '"'"'+%Y-%m-%d %H:%M:%S'"'"'),g" \
  \
  -e '"'"'s,[@]bindir[@],$(bindir),g'"'"' \
  -e '"'"'s,[@]datadir[@],$(datadir),g'"'"' \
  -e '"'"'s,[@]exec_prefix[@],$(exec_prefix),g'"'"' \
  -e '"'"'s,[@]includedir[@],$(includedir),g'"'"' \
  -e '"'"'s,[@]infodir[@],$(infodir),g'"'"' \
  -e '"'"'s,[@]libdir[@],$(libdir),g'"'"' \
  -e '"'"'s,[@]libexecdir[@],$(libexecdir),g'"'"' \
  -e '"'"'s,[@]localstatedir[@],$(localstatedir),g'"'"' \
  -e '"'"'s,[@]mandir[@],$(mandir),g'"'"' \
  -e '"'"'s,[@]oldincludedir[@],$(oldincludedir),g'"'"' \
  -e '"'"'s,[@]prefix[@],$(prefix),g'"'"' \
  -e '"'"'s,[@]sbindir[@],$(sbindir),g'"'"' \
  -e '"'"'s,[@]sharedstatedir[@],$(sharedstatedir),g'"'"' \
  -e '"'"'s,[@]sysconfdir[@],$(sysconfdir),g'"'"' \
  \
  -e '"'"'s,[@]abs_builddir[@],$(abs_builddir),g'"'"' \
  -e '"'"'s,[@]abs_srcdir[@],$(abs_srcdir),g'"'"' \
  -e '"'"'s,[@]abs_top_builddir[@],$(abs_top_builddir),g'"'"' \
  -e '"'"'s,[@]abs_top_srcdir[@],$(abs_top_srcdir),g'"'"' \
  -e '"'"'s,[@]srcdir[@],$(srcdir),g'"'"' \
  -e '"'"'s,[@]top_builddir[@],$(top_builddir),g'"'"' \
  -e '"'"'s,[@]top_srcdir[@],$(top_srcdir),g'"'"' \
\
  -e '"'"'s,[@]perl5libdir[@],$(perl5libdir),g'"'"' \
  -e '"'"'s,[@]perlrun[@],$(perlrun),g'"'"' \
  -e '"'"'s,[@]perlenv[@],$(perlenv),g'"'"' \
  -e '"'"'s,[@]pod2man[@],$(pod2man),g'"'"' \
  -e '"'"'s,[@]ksh[@],$(ksh),g'"'"' \
  -e '"'"'s,[@]bashrun[@],$(bashrun),g'"'"' \
  -e '"'"'s,[@]logdir[@],$(logdir),g'"'"' \
\
  -e '"'"'s,[@]perl_layer_version[@],$(perl_layer_version),g'"'"' \
  -e '"'"'s,[@]aws_cli[@],$(aws_cli),g'"'"' \
  -e '"'"'s,[@]jq[@],$(jq),g'"'"' \
  -e '"'"'s,[@]curl[@],$(curl),g'"'"' \
  -e '"'"'s,[@]openssl[@],$(openssl),g'"'"' \
  -e '"'"'s,[@]unzip[@],$(unzip),g'"'"' \
  -e '"'"'s,[@]scandeps[@],$(scandeps),g'"'"' \
  -e '"'"'s,[@]lambda_module_name[@],$(lambda_module_name),g'"'"' \
  -e '"'"'s,[@]MAKE[@],$(MAKE),g'"'"' \
'
]

AC_SUBST([do_subst_command])

AC_CONFIG_AUX_DIR([autotools])
AC_CONFIG_MACRO_DIR([autotools])

AM_INIT_AUTOMAKE([-Wall -Wno-portability  -Wno-override foreign tar-ustar])

AC_PATH_PROG([BASHRUN],
	[bash])

if test -z "$BASHRUN" ; then 
  AC_MSG_ERROR([bash not found?])
fi

AC_PATH_PROG([POD2MAN],
	[pod2man])

if test -z "$POD2MAN" ; then 
  AC_MSG_ERROR([pod2man not found?])
fi

AC_PATH_PROG([PERL],
	[perl])

if test -z "$PERL" ; then 
  AC_MSG_ERROR([perl not found?])
fi

AC_PATH_PROG([AWS_CLI],[aws],[],[$PATH$PATH_SEPARATOR/usr/local/bin])

if test -z "$AWS_CLI"; then
  AC_MSG_ERROR([aws cli not found?])
fi

AC_PATH_PROG([CPANM],[cpanm],[],[$PATH$PATH_SEPARATOR/usr/local/bin])

if test -z "$CPANM"; then
  AC_MSG_ERROR([cpanm not found?])
fi

AC_PATH_PROG([JQ],[jq],[],[$PATH$PATH_SEPARATOR/usr/local/bin])

if test -z "$JQ"; then
  AC_MSG_ERROR([jq not found?])
fi

AC_PATH_PROG([GREP],[grep])

if test -z "$GREP"; then
  AC_MSG_ERROR([grep not found?])
fi

AC_PATH_PROG([MAKE],[make])

if test -z "$MAKE"; then
  AC_MSG_ERROR([make not found?])
fi

AC_SUBST([MD5SUM])

AC_PATH_PROG([MD5SUM],[md5sum])

if test -z "$MD5SUM"; then
  AC_MSG_ERROR([md5sum not found?])
fi

AC_SUBST([MD5SUM])

AC_PATH_PROG([MKDIR],[mkdir])

if test -z "$MKDIR"; then
  AC_MSG_ERROR([mkdir not found?])
fi

AC_SUBST([MKDIR])

AC_PATH_PROG([MKTEMP],[mktemp])

if test -z "$MKTEMP"; then
  AC_MSG_ERROR([mktemp not found?])
fi

AC_SUBST([MKTEMP])

AC_PATH_PROG([AWK],[awk])

if test -z "$AWK"; then
  AC_MSG_ERROR([awk not found?])
fi

AC_SUBST([AWK])

AC_PATH_PROG([CUT],[cut])

if test -z "$CUT"; then
  AC_MSG_ERROR([cut not found?])
fi

AC_SUBST([CUT])

AC_PATH_PROG([CURL],[curl])

if test -z "$CURL"; then
  AC_MSG_ERROR([curl not found?])
fi

AC_SUBST([CURL])

AC_PATH_PROG([OPENSSL],[openssl])

if test -z "$OPENSSL"; then
  AC_MSG_ERROR([openssl not found?])
fi

AC_SUBST([OPENSSL])

AC_PATH_PROG([ENV],[env])

if test -z "$ENV"; then
  AC_MSG_ERROR([env not found?])
fi

AC_SUBST([ENV])

AC_PATH_PROG([RM],[rm])

if test -z "$RM"; then
  AC_MSG_ERROR([rm not found?])
fi

AC_SUBST([RM])

AC_PATH_PROG([CP],[cp])

if test -z "$CP"; then
  AC_MSG_ERROR([cp not found?])
fi

AC_SUBST([CP])

AC_PATH_PROG([SORT],[sort])

if test -z "$SORT"; then
  AC_MSG_ERROR([sort not found?])
fi

AC_SUBST([SORT])

AC_PATH_PROG([COMM],[comm])

if test -z "$COMM"; then
  AC_MSG_ERROR([comm not found?])
fi

AC_SUBST([COMM])

AC_PATH_PROG([FIND],[find])

if test -z "$FIND"; then
  AC_MSG_ERROR([find not found?])
fi

AC_SUBST([FIND])

AC_PATH_PROG([ZIP],[zip])

if test -z "$ZIP"; then
  AC_MSG_ERROR([zip not found?])
fi

AC_SUBST([ZIP])

AC_PATH_PROG([UNZIP],[unzip])

if test -z "$UNZIP"; then
  AC_MSG_ERROR([unzip not found?])
fi

AC_SUBST([UNZIP])

AC_PATH_PROG([SCANDEPS],[scandeps.pl],[],[$PATH$PATH_SEPARATOR/usr/local/bin])

if test -z "$SCANDEPS"; then
  AC_MSG_ERROR([scandeps.pl not found?])
fi

AC_SUBST([SCANDEPS])  

AC_PATH_PROG([CAT],[cat])

if test -z "$CAT"; then
  AC_MSG_ERROR([cat not found?])
fi

AC_SUBST([CAT])

AC_ARG_WITH([aws_profile],[  --with-aws-profile (defaults to $AWS_PROFILE)],
	[
    if test -n "$withval"; then
       AWS_PROFILE="${withval}"
    fi
        ]
)

if test -z "$AWS_PROFILE"; then
   AWS_PROFILE='default'
fi

AC_SUBST([AWS_PROFILE])  

AC_ARG_WITH([aws_account],[  --with-aws-account],
	[
    if test -n "$withval"; then
       AWS_ACCOUNT="${withval}"
    fi
        ]
)

if test -z "$AWS_ACCOUNT"; then
   AWS_ACCOUNT='missing-account'
fi

AC_SUBST([AWS_ACCOUNT])  

AC_ARG_WITH([aws_region],[  --with-aws-region],
	[
    if test -n "$withval"; then
       AWS_REGION="${withval}"
    fi
        ], [AWS_REGION=us-east-1]
)

if test -z "$AWS_REGION"; then
   AWS_REGION='missing-region'
fi

AC_SUBST([AWS_REGION])  


AC_ARG_WITH([role],[  --with-role],
	[
    if test -n "$withval"; then
       LAMBDA_ROLE="${withval}"
    fi
        ]
)

if test -z "$LAMBDA_ROLE"; then
   LAMBDA_ROLE='missing-role'
fi

AC_SUBST([LAMBDA_ROLE])  

AC_ARG_WITH([vpc_config],[  --with-vpc-config],
	[
    if test -n "$withval"; then
       VPC_CONFIG="${withval}"
    fi
        ], [VPC_CONFIG="none"]
)

AC_SUBST([VPC_CONFIG])  

AC_ARG_WITH([memory_size],[  --with-memory-size],
	[
    if test -n "$withval"; then
       MEMORY_SIZE="${withval}"
    fi
        ], [ MEMORY_SIZE="128"]
)

AC_SUBST([MEMORY_SIZE])  

AC_ARG_WITH([timeout],[  --with-timeout],
	[
    if test -n "$withval"; then
       TIMEOUT="${withval}"
    fi
        ], [TIMEOUT=3]
)

AC_SUBST([TIMEOUT])  

AC_ARG_WITH([environment],[  --with-environment],
	[
    if test -n "$withval"; then
       ENVIRONMENT="${withval}"
    fi
        ], [ENVIRONMENT="none"]
)

AC_SUBST([ENVIRONMENT])  

AC_ARG_WITH([handler],[  --with-handler],
	[
    if test -n "$withval"; then
       LAMBDA_HANDLER="${withval}"
    fi
        ], [LAMBDA_HANDLER="Lambda.handler"]
)

AC_SUBST([LAMBDA_HANDLER])  

LAMBDA_HANDLER_PREFIX=${LAMBDA_HANDLER%%.*}

AC_SUBST([LAMBDA_HANDLER_PREFIX])  

AC_ARG_WITH([lambda_module_version],[  --with-lambda-module-version],
	[
    if test -n "$withval"; then
       LAMBDA_MODULE_VERSION="${withval}"
    fi
        ]
)

AC_SUBST([LAMBDA_MODULE_VERSION])  

AC_ARG_WITH([perl_layer_version],[  --with-perl-layer-version],
	[
    if test -n "$withval"; then
       PERL_LAYER_VERSION="${withval}"
    fi
        ]
)

AC_SUBST([PERL_LAYER_VERSION])

PERL_VERSION=$(perl -e 'print sprintf("%vd\n", $^V);')

AC_ARG_WITH([perl_version],[  --with-perl-version],
	[
    if test -n "$withval"; then
       PERL_VERSION="${withval}"
    fi
        ]
)

AC_SUBST([PERL_VERSION])

perl5libdir=\${datadir}/perl5

AC_ARG_WITH(
	[perl5libdir],[  --with-perl5libdir (defaults to [DATAROOTDIR]/perl5)],
	[
    if test "${withval}" = 'no'; then
        true
    elif test "$withval" = 'yes'; then
        perl5libdir=$($PERL -MConfig -wle 'print $Config{sitelib};')
    else
        perl5libdir=$withval    
    fi
        ]
)

AC_SUBST([perl5libdir])

dnl something just to make autoconf include the autotools/ads_ stuff in the distribution
ads_PERL_MODULE([Getopt::Long])

dnl example using the PERL_MODULE check with a version number
dnl ads_PERL_MODULE([Bedrock], [REQUIRE], [1.3])

AX_DISTCHECK_HACK
AX_DEPS_CHECK
AX_PERLDEPS_CHECK

AC_ARG_ENABLE([perl-syntax-check],
     [  --enable-perl-syntax-check indicate that perl modules and scripts should be syntax checked (perl -wc)],
     [case "${enableval}" in
       yes) syntax=true ;;
       no)  syntax=false ;;
       *) AC_MSG_ERROR([bad value ${enableval} for --enable-perl-syntax-check]) ;;
     esac],[syntax=true])
     AM_CONDITIONAL([PERL_SYNTAX_CHECK], [test x$syntax = xtrue])

AC_CONFIG_FILES([
    Makefile
    src/Makefile
    src/main/Makefile
    src/main/bash/Makefile
    src/main/bash/bin/Makefile
    src/main/perl/Makefile
    src/main/perl/lib/Makefile
    src/main/perl/bin/Makefile
    src/main/perl/lambda/Makefile
])

AC_OUTPUT

printf "\n"
printf "                   AWS_PROFILE: %s\n" "`__poor_mans_expand_file_name AWS_PROFILE`"
printf "                   AWS_ACCOUNT: %s\n" "`__poor_mans_expand_file_name AWS_ACCOUNT`"
printf "                    AWS_REGION: %s\n" "`__poor_mans_expand_file_name AWS_REGION`"
printf "                          ROLE: %s\n" "`__poor_mans_expand_file_name LAMBDA_ROLE`"
printf "                       HANDLER: %s\n" "`__poor_mans_expand_file_name LAMBDA_HANDLER`"
printf "                    VPC_CONFIG: %s\n" "`__poor_mans_expand_file_name VPC_CONFIG`"
printf "                   MEMORY_SIZE: %s\n" "`__poor_mans_expand_file_name MEMORY_SIZE`"
printf "                       TIMEOUT: %s\n" "`__poor_mans_expand_file_name TIMEOUT`"
printf "                  PERL_VERSION: %s\n" "`__poor_mans_expand_file_name PERL_VERSION`"
printf "                   ENVIRONMENT: %s\n" "`__poor_mans_expand_file_name ENVIRONMENT`"
printf "\n"
