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

moduledir = $(libexecdir)/geomview

module_DATA = .geomview-orrery

.geomview-orrery:
	echo '(emodule-define "Orrery" "wish $$GEOMDATA/modules/orrery/orrery")' > .geomview-orrery


#install-data-local:
#	@if [ \! -d ${datadir}/geomview/modules ] ; then \
#	  echo mkdir ${datadir}/geomview/modules ; \
#	  mkdir ${datadir}/geomview/modules ; \
#	fi
#	rm -f ${datadir}/geomview/modules/orrery
#	cp -r data ${datadir}/geomview/modules/orrery

MAINTAINERCLEANFILES = .geomview-orrery

CVSCLEANFILES = aclocal.m4 configure

cvs-clean: maintainer-clean
	-rm -f ${CVSCLEANFILES}
	-rm -f *.gz
	find . -name Makefile.in -print | xargs rm
