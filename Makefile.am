top_geom_srcdir = $(top_srcdir)/../../..

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

module_DATA = .geomview-orrery

.geomview-orrery:
	echo '(emodule-define "Orrery" "wish $$GEOMROOT/data/modules/orrery/orrery")' > .geomview-orrery

all-local:
	$(top_geom_srcdir)/mkmodulesdir $(top_geom_builddir)
	echo '(emodule-define "Orrery" "wish $$GEOMROOT/data/modules/orrery/orrery")' > $(top_geom_builddir)/modules/.geomview-orrery
	@if [ \! -d ${top_geom_srcdir}/data/modules ] ; then \
	  echo mkdir ${top_geom_srcdir}/data/modules ; \
	  mkdir ${top_geom_srcdir}/data/modules ; \
	fi
	@(cwd=`pwd`; thisdir=`basename $$cwd` ;                  \
	  echo rm -f ${top_geom_srcdir}/data/modules/orrery ;    \
	  rm -f ${top_geom_srcdir}/data/modules/orrery ;         \
	  echo cd ${top_geom_srcdir}/data/modules ;              \
	  cd ${top_geom_srcdir}/data/modules ;                   \
	  echo ln -s ../../src/bin/$$thisdir/data orrery ;       \
	  ln -s ../../src/bin/$$thisdir/data orrery)


MAINTAINERCLEANFILES = .geomview-orrery

CVSCLEANFILES = aclocal.m4 configure

cvs-clean: maintainer-clean
	-rm -f ${CVSCLEANFILES}
	-rm -f *.gz
	find . -name Makefile.in -print | xargs rm
