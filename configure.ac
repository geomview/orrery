AC_INIT(orrery, [0.9.4], Claus-Justus Heine <Claus.Heine@Mathematik.Uni-Freiburg.DE>)
AC_MSG_RESULT([configuring $PACKAGE_NAME $PACKAGE_VERSION])
AC_CANONICAL_TARGET([])
AM_INIT_AUTOMAKE([dist-bzip2 foreign 1.9])
AM_MAINTAINER_MODE
AC_CONFIG_SRCDIR([testwish.c])
AC_PREFIX_DEFAULT(/usr/local/Geomview)
AC_PROG_INSTALL

GV_INIT_GEOMVIEW

################################################################################
#
# emodule specific checks.
#

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

AC_OUTPUT(Makefile
          data/Makefile
          data/orr/Makefile)
