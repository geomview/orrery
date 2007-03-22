ACLOCAL_AMFLAGS = -I gvm4

EXTRA_DIST =        \
  peri2elem.tcl     \
  mktxmesh.pl       \
  quick2elem.pl     \
  stargv.pl         \
  tailcone.pl       \
  reconf            \
  yale.star.gz

SUBDIRS = data

bin_SCRIPTS =

if PERL
bin_SCRIPTS += mktxmesh quick2elem stargv tailcone
%: %.pl Makefile
	sed -e 's|\@PERL\@|$(PERL)|g' $< > $@
	chmod +x $@
endif
if TCLSH
bin_SCRIPTS += peri2elem
%: %.tcl Makefile
	sed -e 's|\@TCLSH\@|$(TCLSH)|g' $< > $@
	chmod +x $@
endif

if HAVE_TCLTK
LDADD = $(TK_LIB) $(TCL_LIB) $(XLIBS)

module_PROGRAMS = orrery
orrery_SOURCES = orrery_funcs.c testwish.c

INTERPRETER = orrery
else
INTERPRETER = wish
endif

EMODULES = .geomview-orrery

if LOCAL_EMODULE
homedir = $(HOME)
home_DATA = $(EMODULES)
modulepath = $(moduledir)/
moduleprogpath = $(moduledir)/
else
if !GEOMVIEW_QUERY
modulepath = $(moduledir)/
moduleprogpath = $(moduledir)/
module_DATA = $(EMODULES)
else
modulepath = $${GEOMVIEW_EMODULE_DIR}/
moduleprogpath =
module_DATA = $(EMODULES)
endif
endif

.geomview-orrery: Makefile
	echo '(emodule-define "Orrery" "$(moduleprogpath)$(INTERPRETER) $(modulepath)tcl/orrery")' > .geomview-orrery

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

clean-local:
	rm -f $(bin_SCRIPTS)