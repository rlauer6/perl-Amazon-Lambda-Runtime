AC_DEFUN([RPM_BUILD_MODE], [

    AC_MSG_CHECKING([[whether to enable build mode]])

    AC_ARG_ENABLE([rpm_build_mode],
        [[  --enable-rpm-build-mode       configure RPM build mode (disables certain checks), default: disabled]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  rpm_build_mode=true  ;;
                no)   rpm_build_mode=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-rpm-build-mode' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            rpm_build_mode=false
        ]
    )

    if ${rpm_build_mode}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([RPM_BUILD_MODE], [${rpm_build_mode}])
])
