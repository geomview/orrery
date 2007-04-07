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
endif
if TCLSH
bin_SCRIPTS += peri2elem
endif

module_tcldir = $(moduledir)/tcl

DEFS = -DHAVE_CONFIG_H

if HAVE_TCLTK
INCLUDES =\
 $(default_includes)\
 $(TK_ALL_INCLUDES)

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
  tclpath = $(module_tcldir)
  modulepath = $(moduledir)/
else
  module_DATA = $(EMODULES)
  tclpath = $$GEOMVIEW_EMODULE_DIR/tcl
if !GEOMVIEW_QUERY
    modulepath = $(moduledir)/
else
    modulepath =
endif
endif

.geomview-orrery: Makefile
	echo '(emodule-define "Orrery" "$(modulepath)$(INTERPRETER) $(tclpath)/orrery")' > .geomview-orrery

CLEANFILES = $(EMODULES)

CVSCLEANFILES = aclocal.m4 configure

cvs-clean: maintainer-clean
	-rm -f ${CVSCLEANFILES}
	-rm -f *.gz
	find . -name Makefile.in -print | xargs rm

clean-local:
	rm -f $(bin_SCRIPTS)
