dnl -*-m4-*-
dnl 
dnl ##
dnl ##
dnl 
dnl This file provides the 'ads_PERL_MODULE' autoconf macro, which may be
dnl used to add checks in your 'configure.ac' file for a specific Perl
dnl module.
dnl 
dnl By default, the specified module is "required"; if it is not found,
dnl the 'configure' program will print an error message and exit with an
dnl error status (via AC_MSG_ERROR). However, you may pass a parameter
dnl indicating that the module is optional; in that case 'configure' will
dnl simply print a message indicating that the module was not found and
dnl continue on.
dnl 
dnl Dependencies
dnl ============
dnl 
dnl This macro contains an automatic dependency on the 'ads_PROG_PERL'
dnl autoconf macro to set the $PERL shell variable to the path of the
dnl configured Perl interpreter.
dnl 
dnl Usage
dnl =====
dnl 
dnl ads_PERL_MODULE(PERL_MODULE_NAME, [REQUIRED|OPTIONAL], [PERL_MODULE_VERSION])
dnl 
dnl     * The PERL_MODULE_NAME param is required.
dnl 
dnl     * The second param is optional, and defaults to the constant 'REQUIRED'.
dnl 
dnl     * The PERL_MODULE_VERSION param is optional. If not specified,
dnl       then 'configure' will be satisfied if /any/ version of the
dnl       module is found. Note that the specified version is /not/
dnl       absolute; we use the Perl interpreter to determine whether or
dnl       not the version requirement is satisfied (which checks the
dnl       module's $VERSION property), so it is essentially a check for
dnl       "the specified version number or newer". See the perlmodlib(1)
dnl       in the Perl documentation for all the details.
dnl 
dnl Examples
dnl ========
dnl 
dnl The following examples show snippets that would be placed in your
dnl 'configure.ac' file.
dnl 
dnl Example 1
dnl ---------
dnl 
dnl     ## Module 'Foo::Bar::Baz' is required (any version)
dnl     ads_PERL_MODULE([Foo::Bar::Baz])
dnl 
dnl Example 2
dnl ---------
dnl 
dnl     ## Same as Example 1, only more explicit
dnl     ads_PERL_MODULE([Foo::Bar::Baz], [REQUIRED])
dnl 
dnl Example 3
dnl ---------
dnl 
dnl     ## Version 0.02 of module 'Foo::Bar::Baz' is required
dnl     ads_PERL_MODULE([Foo::Bar::Baz], [REQUIRED], [0.02])
dnl 
dnl 
dnl Design Notes
dnl ============
dnl
dnl Required/Optional Param
dnl -----------------------
dnl Note that in order to specify the module version number, you must
dnl specify either 'REQUIRED' or 'OPTIONAL' as the second macro parameter.
dnl 
dnl An alternative interface design would make the version number the
dnl second param, and the 'REQUIRED' or 'OPTIONAL' param would always be
dnl optional.
dnl 
dnl The existing interface was decided on in order to optimize for the
dnl common case. The presumption, obviously, is that users of the macro
dnl will need to specify that a module is required or optional more often
dnl than they will need to specify a dependency on a particular version of
dnl the module. Moreover, users probably do /not/ want to specify a
dnl version number (or use hacks such as '0.00') when all they really want
dnl to do is indicate that a module is required or optional.
dnl
dnl
dnl Module Version Number Output
dnl ----------------------------
dnl 
dnl If the user requests a specifc version number of the specified module,
dnl then we display both the requested version number (as part of the
dnl "checking for" message) and the version actually found (as part of the
dnl result message). For these modules, a version number is required, and
dnl 'configure' will bomb out even if the module is found, but does not
dnl specify a version number (note that in this case, 'configure' actually
dnl stops as a result of 'perl' exiting with an error status when we
dnl request such a module, so we're behaving consistently with
dnl Perl). Here's some example output:
dnl 
dnl     checking for for LWP::UserAgent 2.000... (2.033) /usr/share/perl5/LWP/UserAgent.pm
dnl 
dnl If the user did not request a specific version number, we still print
dnl out the version number found if we're able to determine it:
dnl 
dnl     checking for for LWP::UserAgent ... (2.033) /usr/share/perl5/LWP/UserAgent.pm
dnl 
dnl If the usre did not request a specific version number, and the module
dnl doesn't provide a version number (according to Perl's Exporter module
dnl conventions), then we simply show '???' for the version number:
dnl 
dnl     checking for for CJ::Util::MakeMod... (???) /some/path/to/perl/lib/CJ/Util/MakeMod.pm
dnl 
dnl 
dnl 
dnl TODO
dnl ====
dnl     * Add use of (not yet existing) facility to include maintainer
dnl       name and email address information for inclusion in error
dnl       messages that detect bugs in the macro.
dnl 
dnl     * Maybe set HAVE_PERL5_MODULE_FOO_BAR_BAZ automake conditional
dnl 
dnl     * Maybe set @HAVE_PERL5_MODULE_FOO_BAR_BAZ@ automake variable
dnl 


AC_DEFUN([ads_PERL_MODULE], [

    AC_REQUIRE([ads_PROG_PERL])
    AC_REQUIRE([ads_PERL_INCLUDES])
    AC_REQUIRE([AX_PERLDEPS_CHECK])
    AC_REQUIRE([AX_DEPS_CHECK])

[
    _tmp_macro_name='ads_PERL_MODULE.m4'

    # (required) This should be something like Foo::Bar::Baz
    _tmp_perl_mod_name=$1
    if test -z "${_tmp_perl_mod_name}"; then
        # This is almost certainly a programmer error
]
        AC_MSG_ERROR([[
    ${_tmp_macro_name} ERROR: required 'PERL_MODULE_NAME' param not provided

    Usage:
        ${_tmp_macro_name}(PERL_MODULE_NAME, [REQUIRED|OPTIONAL], [PERL_MODULE_VERSION])
]])
[
    fi

    # (optional) If not provided, then we assume that the Perl
    # module is required. Valid values are 'REQUIRED' or 'OPTIONAL'.
    _tmp_perl_mod_required_or_optional=$2
    if test -z "${_tmp_perl_mod_required_or_optional}"; then
        _tmp_perl_mod_required_or_optional='REQUIRED'  # dflt
        ( ${ax_perldeps_disabled} || ${ax_deps_disabled} ) && _tmp_perl_mod_required_or_optional='OPTIONAL'  # dflt

    fi
    if test "${_tmp_perl_mod_required_or_optional}" = 'REQUIRED' ||
       test "${_tmp_perl_mod_required_or_optional}" = 'OPTIONAL'; then :; else
]
        AC_MSG_ERROR([[
    ${_tmp_macro_name} ERROR: second macro param must be either 'REQUIRED' or 'OPTIONAL' (got "${_tmp_perl_mod_required_or_optional}")

    Usage:
        ${_tmp_macro_name}(PERL_MODULE_NAME, [REQUIRED|OPTIONAL], [PERL_MODULE_VERSION])
]])
[
    fi

    # (optional) If provided, this should be the perl module version
    _tmp_perl_mod_version=$3

    _tmp_check_msg="for ${_tmp_perl_mod_name}"
    if test -n "${_tmp_perl_mod_version}"; then
        _tmp_check_msg="${_tmp_check_msg} ${_tmp_perl_mod_version}"
    fi

    _tmp_perl_mod_msg_version="${_tmp_perl_mod_version}"
    if test -z "${_tmp_perl_mod_version}"; then
        _tmp_perl_mod_msg_version='(any version)'
    fi
]
    AC_MSG_CHECKING([[for ${_tmp_check_msg}]])
[
    # Invoking perl twice is inefficient, but better isolates our test

    # Only redirect stderr to /dev/null if module is optional. This prevents
    # Perl's error messages from cluttering up the 'configure' output with
    # error messages that may look to the user as though something is wrong.
    #
    if test "${_tmp_perl_mod_required_or_optional}" = 'REQUIRED'; then
        eval "'""${PERL}""'" "${ax_perl5_extra_includes_opt}" \
                  -we "'""use strict; use ${_tmp_perl_mod_name} ${_tmp_perl_mod_version};""'"
    else

        eval "'""${PERL}""'" "${ax_perl5_extra_includes_opt}" \
                  -we "'""use strict; use ${_tmp_perl_mod_name} ${_tmp_perl_mod_version};""'" 2>/dev/null
    fi
    if test $? -eq 0; then
        # Great, we have the module. Now print where it was found:
        _tmp_perl_mod_path="$( eval "'""${PERL}""'" "${ax_perl5_extra_includes_opt}" \
          -MFile::Spec -wle "'"'
            use strict;
            my $modname = shift;
            eval "require ${modname}";
            ${@} and die qq{Was unable to require module "$modname": ${@}};
            $modname .= q{.pm};
            my $found = undef;
            my $shortpath = File::Spec->catdir( split(q{::}, $modname) );
            my $fullpath;
            if (exists $INC{ $shortpath } && defined $INC{ $shortpath }) {
                $found = 1;
                $fullpath = $INC{ $shortpath };
            }
            $fullpath = q{<path unavailable in %INC}
                unless defined $fullpath && length $fullpath;
            print $fullpath;
            exit ($found ? 0 : 1);  # parens required
        '"'" "'""${_tmp_perl_mod_name}""'")"
        if test $? -ne 0; then
]

dnl FIXME: provide macro maintainer email address in error message

            AC_MSG_ERROR([[
    Perl module ${_tmp_perl_mod_name} exists, but 'configure' was unable to
    determine the path to the module. This is likely a bug in the ${_tmp_macro_name}
    autoconf macro; please report this as a bug.
]])
[
        fi

        # Always attempt to determine the version number of the module
        # that was acutally found and display it to the user. Not all
        # Perl modules provide a $VERSION variable, but if the one
        # we're testing for does, then we'll show it.
        #
        # Note that we do this even for those modules for which the
        # user has requested a specific version because the
        # user-specified version is understood as "this version or
        # newer", so may be different from the version of the module
        # actually found on the system.

        _tmp_found_mod_version="$(
          eval "'""${PERL}""'" "'""-M${_tmp_perl_mod_name}""'" \
            "${ax_perl5_extra_includes_opt}" -wle "'"'
               my $modname = shift;
               my $ver = "${modname}::VERSION";
               print $$ver if defined $$ver && length $$ver;
            '"'" "'""${_tmp_perl_mod_name}""'"
        )"
        if test $? -ne 0; then
]
                AC_MSG_ERROR([[
    Perl module ${_tmp_perl_mod_name} exists, but 'configure' was unable to
    test whether or not the module specifies a version number. This is likely
    a bug in the ${_tmp_macro_name} autoconf macro; please report this as a bug.
]])
[
        fi

        if test "${_tmp_found_mod_version}x" = 'x'; then
            # Module does not provide version info, so use bogon string
            _tmp_perl_mod_path="(???) ${_tmp_perl_mod_path}"
        else
            # Prepend the value to the module path for display to the user
            _tmp_perl_mod_path="(${_tmp_found_mod_version}) ${_tmp_perl_mod_path}"
        fi
]
        AC_MSG_RESULT([[${_tmp_perl_mod_path}]])
[
    else
        if test "${_tmp_perl_mod_required_or_optional}" = 'REQUIRED'; then
]
            AC_MSG_ERROR([[
    Was unable to locate Perl module ${_tmp_perl_mod_name} ${_tmp_perl_mod_msg_version}
]])
[
        else  # presence of module was optional
]
            AC_MSG_RESULT([[no (ok)]])
[
        fi
    fi
]
])

dnl FIXME: Maybe provide an autoconf flag indicating whether or not
dnl        the Perl module was found.
