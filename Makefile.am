ACLOCAL_AMFLAGS = -I gvm4

EXTRA_DIST =        \
  mktxmesh          \
  orrery_funcs.c    \
  peri2elem         \
  quick2elem        \
  reconf            \
  stargv            \
  tailcone          \
  testwish.c        \
  yale.star.gz

SUBDIRS = data

if HAVE_TCLTK
LDADD = $(TK_LIB) $(TCL_LIB) $(XLIBS)

module_PROGRAMS = orrery
orrery_SOURCES = orrery_funcs.c testwish.c

INTERPRETER = orrery
else
INTERPRETER = wish
endif

module_DATA = .geomview-orrery

.geomview-orrery: Makefile
	echo '(emodule-define "Orrery" "$(INTERPRETER) $${GEOMVIEW_EMODULE_DIR}/tcl/orrery")' > .geomview-orrery


#install-data-local:
#	@if [ \! -d ${datadir}/geomview/modules ] ; then \
#	  echo mkdir ${datadir}/geomview/modules ; \
#	  mkdir ${datadir}/geomview/modules ; \
#	fi
#	rm -f ${datadir}/geomview/modules/orrery
#	cp -r data ${datadir}/geomview/modules/orrery

CLEANFILES = .geomview-orrery

CVSCLEANFILES = aclocal.m4 configure

cvs-clean: maintainer-clean
	-rm -f ${CVSCLEANFILES}
	-rm -f *.gz
	find . -name Makefile.in -print | xargs rm

