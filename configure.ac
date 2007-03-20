AC_INIT(orrery, [0.9.4], Claus-Justus Heine <Claus.Heine@Mathematik.Uni-Freiburg.DE>)
AC_MSG_RESULT([configuring $PACKAGE_NAME $PACKAGE_VERSION])
AC_CANONICAL_TARGET([])
AM_INIT_AUTOMAKE([dist-bzip2 foreign 1.9])
AM_MAINTAINER_MODE
AC_CONFIG_SRCDIR([mktxmesh])
AC_PREFIX_DEFAULT(/usr/local/Geomview)
AC_PROG_INSTALL

GV_INIT_GEOMVIEW

########################################################################

AC_OUTPUT(Makefile
          data/Makefile
          data/orr/Makefile)
