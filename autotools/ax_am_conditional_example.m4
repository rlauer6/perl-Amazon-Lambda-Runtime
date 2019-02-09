AC_DEFUN([AX_SOME_THINGY], [

    AC_MSG_CHECKING([[whether to enable some_thingy]])

    AC_ARG_ENABLE([some-thingy],
        [[  --enable-some-thingy      configure some_thingy, exposes $SOME_THINGY_ENABLED]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  SOME_THINGY_ENABLED=true  ;;
                no)   SOME_THINGY_ENABLED=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-some-thingy' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            SOME_THINGY_ENABLED=false
        ]
    )

    if ${SOME_THINGY_ENABLED}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([SOME_THINGY_ENABLED], [${SOME_THINGY_ENABLED}])
])

