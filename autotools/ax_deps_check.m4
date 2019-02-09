AC_DEFUN([AX_PERLDEPS_CHECK],[
    AC_MSG_CHECKING([[whether to disable perl dependency requirement]])

    AC_ARG_ENABLE([perldeps],
        [[  --disable-perldeps don't abort if dependencies missing ]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  ax_perldeps_disabled=false  ;;
                no)   ax_perldeps_disabled=true ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--disable-perldeps' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            ax_perldeps_disabled=false
        ]
    )

    if ${ax_perldeps_disabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([PERLDEPS_DISABLED], [test "${ax_perldeps_disabled}" = "true"])
])


AC_DEFUN([AX_DEPS_CHECK],[
    AC_MSG_CHECKING([[whether to disable  dependency requirement]])

    AC_ARG_ENABLE([deps],
        [[  --disable-deps don't abort if dependencies missing ]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  ax_deps_disabled=false  ;;
                no)   ax_deps_disabled=true ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--disable-deps' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            ax_deps_disabled=false
        ]
    )

    if ${ax_deps_disabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([DEPS_DISABLED], [test "${ax_deps_disabled}" = "true"])
])
