dnl -*- m4 -*-

##
##

dnl ads_PROG_PERL([required_perl_version])
dnl
dnl This macro tests for the existence of a perl interpreter on the
dnl target system. By default, it looks for perl version 5.005 or
dnl newer; you can change the default version by passing in the
dnl optional 'required_perl_version' argument, setting it to the perl
dnl version you want. The format of the 'required_perl_version' argument
dnl string is anything that you could legitimately use in a perl
dnl script, but see below for a note on the format of the perl version
dnl argument and compatibility with older perl interpreters.
dnl
dnl If no perl interpreter of the the required minimum version is found,
dnl then we bomb out with an error message.
dnl
dnl To use this macro, just drop it in your configure.in file as
dnl indicated in the examples below. Then use @PERL@ in any of your
dnl files that will be processed by automake; the @PERL@ variable
dnl will be expanded to the full path of the perl interpreter.
dnl
dnl Examples:
dnl     ads_PROG_PERL              (looks for 5.005, the default)
dnl     ads_PROG_PERL()            (same effect as previous)
dnl     ads_PROG_PERL([5.006])     (looks for 5.6.0, preferred way)
dnl     ads_PROG_PERL([5.6.0])     (looks for 5.6.0, don't do this)
dnl
dnl Note that care should be taken to make the required perl version
dnl backward compatible, as explained here:
dnl     http://www.perldoc.com/perl5.8.0/pod/func/require.html
dnl That is why the '5.006' form is preferred over '5.6.0', even though
dnl both are for perl version 5.6.0
dnl
dnl CREDITS
dnl     * This macro was written by Alan D. Salewksi <salewski AT worldnet.att.net>

AC_DEFUN([ads_PROG_PERL], [
    req_perl_version="$1"
    if test -z "$req_perl_version"; then
        req_perl_version="5.005"
    fi
    AC_PATH_PROG(PERL, perl)
    if test -z "$PERL"; then
        AC_MSG_ERROR([perl not found])
    fi
    $PERL -e "require ${req_perl_version};" || {
        AC_MSG_ERROR([perl $req_perl_version or newer is required])
    }
])

