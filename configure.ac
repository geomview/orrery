AC_INIT(orrery, [0.9.6], Claus-Justus Heine <Claus.Heine@Mathematik.Uni-Freiburg.DE>)

AC_CONFIG_SRCDIR([testwish.c])

GV_INIT_GEOMVIEW(=,1,>=,9)

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

GEOMVIEW_CHECK_PACKAGE([tcl],[tcl],[],[],[tcl.h],[],[],[required enabled])
GEOMVIEW_CHECK_PACKAGE([tk],[tk],[${x_libraries}],[${XLIBS}],[tk.h],[],[${TCL_INCLUDES} ${X_CFLAGS}],[required enabled])
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
# TCL env access
	ORRGEOMDATA="\$GEOMDATA"
fi
AC_SUBST(ORRGEOMDATA)

AC_CONFIG_FILES(Makefile
                data/Makefile
                data/orr/Makefile
                data/orrery
                mktxmesh:mktxmesh.pl
                quick2elem:quick2elem.pl
                stargv:stargv.pl
                tailcone:tailcone.pl
                peri2elem:peri2elem.tcl)

AC_OUTPUT
