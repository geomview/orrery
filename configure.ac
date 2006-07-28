AC_INIT
AM_INIT_AUTOMAKE(orrery,[0.9.3],Claus-Justus Heine <Claus.Heine@Mathematik.Uni-Freiburg.DE>)
AC_CONFIG_AUX_DIR([../../..])
AM_MAINTAINER_MODE
AC_MSG_RESULT([configuring $PACKAGE $VERSION])
AC_PREFIX_DEFAULT(/usr/local/Geomview)
AC_PROG_INSTALL

top_geom_builddir=../../..
AC_SUBST(top_geom_builddir)

GEOM_GET_CACHED_VALUE(moduledir)
AC_SUBST(moduledir)

GEOM_GET_CACHED_VALUE(geomdatadir)
AC_SUBST(geomdatadir)

########################################################################

AC_OUTPUT(Makefile
          data/Makefile
          data/orr/Makefile)
