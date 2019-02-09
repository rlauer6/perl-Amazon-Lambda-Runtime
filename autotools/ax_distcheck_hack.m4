AC_DEFUN([AX_DISTCHECK_HACK], [

    AC_MSG_CHECKING([[whether to enable distcheck hack]])

    AC_ARG_ENABLE([distcheck-hack],
        [[  --enable-distcheck-hack enable distcheck hack]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  ax_distcheck_hack_enabled=true  ;;
                no)   ax_distcheck_hack_enabled=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-distcheck-hack' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            ax_distcheck_hack_enabled=false
        ]
    )

    if ${ax_distcheck_hack_enabled}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([DISTCHECK_HACK], [${ax_distcheck_hack_enabled}])
])

