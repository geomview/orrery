#include <tk.h>
#include <tcl.h>

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
