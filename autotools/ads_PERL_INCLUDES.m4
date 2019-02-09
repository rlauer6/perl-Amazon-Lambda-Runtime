dnl -*-m4-*-

##
##

dnl This macro provides for a new 'configure' option:
dnl     --with-perl-includes=DIR[:DIR...]
dnl
dnl which provides the following semantics:
dnl
dnl     --with-perl-includes=DIR prepends DIR (or DIRs) to Perl's @INC
dnl
dnl
dnl Multiple directories may be provided by separating the directory names
dnl with a colon (:); this works in the same way as PATH in the Bourne
dnl shell.
dnl
dnl The other AX_PERL5_* macros use this macro to allow the user to
dnl specify the locations of installed Perl 5 modules that may be install
dnl in non-standard locations (that is, any locations that the 'perl'
dnl executable does not search by default).
dnl
dnl Dependencies
dnl ============
dnl 
dnl This macro is not dependent on any macros that are not part of the
dnl core autotools
dnl 
dnl Usage
dnl =====
dnl 
dnl The ads_PERL_INCLUDES macro usually works as an implicit dependency
dnl that is automatically pulled in by explicitly using one of the other
dnl ads_PERL_* macros (such as ads_PERL_MODULE).
dnl 
dnl 
dnl Output
dnl ======
dnl 
dnl     * Shell variable in 'configure':  $ax_perl5_extra_includes
dnl 
dnl         ex. /some/path:/some/other/path
dnl
dnl       Multiple values separated by a colon (':') just like PATH
dnl 
dnl     * Filtering of variable in Autotools input files: @ax_perl5_extra_includes@
dnl       (same value as $ax_perl5_extra_includes
dnl 
dnl     * Filtering of variable in Autotools input files: @ax_perl5_extra_includes@
dnl       (same value as $ax_perl5_extra_includes_opt (see below))
dnl 
dnl     * Automake conditional: USING_PERL5_EXTRA_INCLUDES
dnl       Will be true iff user specified extra include directories via
dnl       the --with-perl-includes command line opt
dnl 
dnl     * Shell variable in 'configure':  $ax_perl5_extra_includes_opt
dnl 
dnl         ex. "\"-I/some/path\" \"-I/some/o t h e r/path\""
dnl
dnl 
dnl       Note that use of this variable by Bourne shell code (or
dnl       derivatives) requires special care. In particular, this variable
dnl       provides it's own quoting for "logically" separate '-I' Perl
dnl       arguments. It must do this because we have to assume that any
dnl       directories supplied by the user may contain spaces in them. On
dnl       the other hand, if the user did not provide any additional '-I'
dnl       directories, then we do not want to pass an empty string
dnl       argument to 'perl'.
dnl
dnl       Here are some examples of naive approaches to using this
dnl       variable (that just happen to work in some circumstances):
dnl
dnl         # WRONG! -- Breaks when no '-I' include paths were provided by
dnl         #           the user (because it creates an empty string arg
dnl         #           to perl).
dnl         #
dnl         #        -- Breaks when any '-I' include paths are provided because
dnl         #           of overquoting.
dnl         MOD='AppConfig'
dnl         "${PERL}" "${ax_perl5_extra_includes_opt}" -we '
dnl             use strict;
dnl             my $m = shift;
dnl             eval "require $m";
dnl             $@ and die $@;' "${MOD}"
dnl
dnl
dnl         # WRONG! -- Works when no '-I' include paths were provided by
dnl         #           the user
dnl         #
dnl         #        -- Breaks when any '-I' include paths are provided because
dnl         #           of overquoting.
dnl         MOD='AppConfig'
dnl         "${PERL}" ${ax_perl5_extra_includes_opt} -we '
dnl             use strict;
dnl             my $m = shift;
dnl             eval "require $m";
dnl             $@ and die $@;' "${MOD}"
dnl
dnl
dnl         # WRONG! -- Breaks when no '-I' include paths were provided by
dnl         #           the user (because it creates an empty string arg
dnl         #           to perl).
dnl         #
dnl         #        -- Works when any '-I' include paths were provided by
dnl         #           user (regardless of whether or not they have
dnl         #           spaces in them)
dnl         MOD='AppConfig'
dnl         "${PERL}" "$(eval echo ${ax_perl5_extra_includes_opt})" -we '
dnl             use strict;
dnl             my $m = shift;
dnl             eval "require $m";
dnl             $@ and die $@;' "${MOD}"
dnl
dnl
dnl         # WRONG! -- Works when no '-I' include paths were provided by
dnl         #           the user
dnl         #
dnl         #        -- Works when all of the '-I' include paths provided
dnl         #           by the user do /not/ contain spaces in them.
dnl         #
dnl         #        -- Breaks when any of the '-I' include paths provided
dnl         #           by the user do contain spaces in them.
dnl         MOD='AppConfig'
dnl         "${PERL}" $(eval echo "${ax_perl5_extra_includes_opt}") -we '
dnl             use strict;
dnl             my $m = shift;
dnl             eval "require $m";
dnl             $@ and die $@;' "${MOD}"
dnl
dnl
dnl       The key is to use the shell's builtin 'eval' command with an
dnl       extra layer of quoting around its arguments such that the
dnl       resulting quoting results in $ax_perl5_extra_includes_opt
dnl       providing it's own quoting, and everything else being single
dnl       quoted:
dnl
dnl         # CORRECT!
dnl         eval "'""${PERL}""'" "${ax_perl5_extra_includes_opt}" -we "'"'
dnl             use strict;
dnl             my $m = shift;
dnl             eval "require $m";
dnl             $@ and die $@;'"'" "'""${MOD}""'"
dnl
dnl
dnl Design Notes
dnl ============
dnl
dnl     * We would have liked to use Bash or KornShell (ksh) style
dnl       arrays for storing the values of
dnl       @ax_perl5_extra_includes_opt, but shell arrays are
dnl       non-portable :-(
dnl
dnl
dnl TODO
dnl ====
dnl
dnl     * Add logic to print those directories (if any) found in PERL5LIB
dnl       that were not specified by the user on the command line (for transparency).


AC_DEFUN([ads_PERL_INCLUDES], [

    AC_ARG_WITH([perl-includes],

        [[  --with-perl-includes=DIR[:DIR:...]
                          prepend DIRs to Perl's @INC]],

        [ # AC_ARG_WITH: option if given
            AC_MSG_CHECKING([[for dirs to prepend to Perl's @INC]])

[
            if test "$withval" = "no"  || \
               test "$withval" = "yes" || \
               test -z "$withval"; then
                # The above result from one of the following spefications by the user:
                #
                #     --with-perl-includes=yes
                #     --with-perl-includes=no
                #
                # Both of the above are bogus because they are equivalent to these:
                #
                #     --with-perl-includes
                #     --without-perl-includes
                #
                # The DIR param is required.
]
                AC_MSG_ERROR([[missing argument to --with-perl-includes]])
[
            else

                # Verify that the user-specified directory (or directories) exists. Build
                # up our internal ax_perl5_* variables at the same time.
                _tmp_results_string=''
                IFShold=$IFS
                IFS=':'
                for _tdir in ${withval}; do
                    if test -d "${_tdir}"; then :; else
                        IFS=$IFShold
]
                        AC_MSG_ERROR([no such directory: ${_tdir}])
[
                    fi

                    if test -z "$ax_perl5_extra_includes"; then
                        ax_perl5_extra_includes="${_tdir}"
                        ax_perl5_extra_includes_opt="-I\"${_tdir}\""  # for passing on 'perl' command line, if needed
                        _tmp_results_string="`printf "\n    ${_tdir}"`"
                    else
                        ax_perl5_extra_includes="${ax_perl5_extra_includes}:${_tdir}"
                        ax_perl5_extra_includes_opt=${ax_perl5_extra_includes_opt}" -I\"${_tdir}\""
                        _tmp_results_string="${_tmp_results_string}`printf "\n    ${_tdir}"`"
                    fi
                done
                IFS=$IFShold
]
                AC_MSG_RESULT([${_tmp_results_string}])
[
            fi
]
        ],

        [ # AC_ARG_WITH: option if not given, same as --without-perl-includes
            AC_MSG_CHECKING([[for dirs to prepend to Perl's @INC]])
            AC_MSG_RESULT([[none]])
        ]
    )dnl end fo AC_ARG_WITH(perl-includes) macro

    AC_SUBST([ax_perl5_extra_includes])
    AC_SUBST([ax_perl5_extra_includes_opt])

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([USING_PERL5_EXTRA_INCLUDES], [test -n "${ax_perl5_extra_includes}"])
])
