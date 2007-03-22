AC_PREREQ(2.59)
AC_INIT(orrery, [0.9.4], Claus-Justus Heine <Claus.Heine@Mathematik.Uni-Freiburg.DE>)
AC_MSG_RESULT([configuring $PACKAGE_NAME $PACKAGE_VERSION])
AC_CANONICAL_TARGET([])
AM_INIT_AUTOMAKE([dist-bzip2 1.9])
AM_MAINTAINER_MODE
AC_PREFIX_DEFAULT(/usr/local/Geomview)
AC_PROG_INSTALL
GV_INIT_GEOMVIEW

AC_CONFIG_SRCDIR([testwish.c])

################################################################################
#
# emodule specific checks.
#

#
# Store X library link line in XLIBS
#
AC_PATH_XTRA
XLIBS="$X_LIBS $X_PRE_LIBS -lXt -lXext -lX11 $X_EXTRA_LIBS"
AC_SUBST(XLIBS)
AC_CACHE_VAL(ac_cv_XLIBS,[ac_cv_XLIBS="XLIBS='$XLIBS'"])

# Check for Tcl/Tk with new CHECK_PACKAGE macro:

GEOMVIEW_CHECK_PACKAGE(tcl, tcl, ${x_libraries}, ${XLIBS}, tcl.h, , ,optional)
if test -n "${TCL_LIB}"; then
  GEOMVIEW_CHECK_PACKAGE(tk, tk, ${x_libraries}, ${XLIBS}, tk.h, , ,optional)
else
  AM_CONDITIONAL(HAVE_TK, [false])
fi
AM_CONDITIONAL(HAVE_TCLTK, [test -n "${TCL_LIB}" -a -n "${TK_LIB}"])

if ! test -n "${TCL_LIB}" -a -n "${TK_LIB}"; then
  GV_CHECK_PROG(wish,,,required)
else
AM_CONDITIONAL(WISH, false)
fi

#
# Also check for Perl and tclsh; if found then install some auxiliary programs
#
GV_PATH_PROG(perl)
GV_PATH_PROG(tclsh)

################################################################################

GEOMVIEW_RESULT

if test "${LOCAL_EMODULE}" = "true"; then
	ORRGEOMDATA="`eval eval eval echo $geomdatadir`"
else
	ORRGEOMDATA="'${GEOMDATA}'"
fi
AC_SUBST(ORRGEOMDATA)

AC_OUTPUT(Makefile
          data/Makefile
          data/orr/Makefile
          data/orrery)
