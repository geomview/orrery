# Determine installation paths (includes, libraries etc.) from the
# installed version of Geomview
AC_DEFUN([GV_INIT_GEOMVIEW],
[AC_ARG_WITH(geomview,
  AC_HELP_STRING([--with-geomview=PROGRAM],
[Set PROGRAM to the name of the Geomview executable, possibly including the full
path to the executable. The installed version of Geomview is used to determine
the library, include and data directories to use. (default: autodetected)]),
  [case "${withval}" in
    no)
      AC_MSG_ERROR(["--without-geomview" or "--with-geomview=no" is not an option here])
      ;;
    yes) # simply ignore that, use auto-detection
      ;;
    *) 
      GEOMVIEWOPT=$withval
    esac],
  [GEOMVIEWOPT=geomview])
  AC_PATH_PROGS(GEOMVIEW, ${GEOMVIEWOPT}, "not found")
  if test "${GEOMVIEW}" = "not found"; then
	AC_MSG_ERROR([Geomview binary not found. Check your installation.])
	exit 1
  fi
  moduledir=`geomview --print-geomview-emodule-dir`
  AC_SUBST(moduledir)
  AC_MSG_RESULT([Module will go into "${moduledir}/"])

  module_tcldir="${moduledir}/tcl"
  AC_SUBST(module_tcldir)
  AC_MSG_RESULT([TCL scripts will go into "${module_tcldir}/"])

  geomdatadir=`geomview --print-geomview-data-dir`
  AC_SUBST(geomdatadir)
  AC_MSG_RESULT([Data will go into "${geomdatadir}/"])
])
