#include <tk.h>
#include <tcl.h>

/* This file is part of the Orrery, a solar system simulator for
   Geomview (see www.geomview.org for details).
   
   The orrery is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.
   
   The orrery is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with the Orrery; see the file COPYING.  If not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
   MA 02111-1307, USA. */
   
int
do_emodule_init(ClientData clientData, Tcl_Interp *interp,
		int argc, char **argv)
{
    if (argc != 2)
    {
	Tcl_SetResult(interp, "wrong # args", TCL_STATIC);
	return TCL_ERROR;
    }
#define INIT(initfunc,string) if(!strcmp(argv[1],string)) { if(initfunc(interp)==TCL_ERROR) return TCL_ERROR;} else
    INIT(orrery_init,"orrery")
#undef INIT
    { /* last else clause */
	Tcl_SetResult(interp, "unknown module init", TCL_STATIC);
	return TCL_ERROR;
    }
    return TCL_OK;
}


int
Tcl_AppInit(Tcl_Interp *interp)
{
    if (Tcl_Init(interp) == TCL_ERROR)
	return TCL_ERROR;
    if (Tk_Init(interp) == TCL_ERROR)
	return TCL_ERROR;
    Tcl_CreateCommand(interp, "emodule_init", do_emodule_init, 0, 0);
    return TCL_OK;
}

int
main(int argc, char **argv)
{
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}
