/* Copyright (c) 1995 The Geometry Center; University of Minnesota
   1300 South Second Street;  Minneapolis, MN  55454, USA;

This file is part of geomview/OOGL. geomview/OOGL is free software;
you can redistribute it and/or modify it only under the terms given in
the file COPYING, which you should have received along with this file.
This and other related software may be obtained via anonymous ftp from
geom.umn.edu; email: software@geom.umn.edu. */

/* The Orrery module can run either under a standard "wish" (tk 4.0 or later),
 * or in a wish that includes these functions; their presence will speed it
 * up somewhat, but the functionality is the same.
 */

/* Author: Stuart Levy */

#include <tcl.h>
#include <math.h>
#include <stdlib.h>

#define ASSERT(expr, msg)  if( !(expr) ) { error = msg; goto fail; }

#define DOT(a, b)  ((a)[0]*(b)[0] + (a)[1]*(b)[1] + (a)[2]*(b)[2])
#define CROSS(dst, a, b)  ((dst)[0] = (a)[1]*(b)[2]-(a)[2]*(b)[1], \
			   (dst)[1] = (a)[2]*(b)[0]-(a)[0]*(b)[2], \
			   (dst)[2] = (a)[0]*(b)[1]-(a)[1]*(b)[0])

static int
getvec(char *str, int len, double *v)
{
  char *p = str;
  int i;

  for(i = 0; i < len; i++) {
    char *p0 = p;
    v[i] = strtod(p, &p);
    if(p == p0) {
	return 0;
    }
  }
  while(*p == ' ' || *p == '\t' || *p == '\n')
    p++;
  return *p == '\0' ? len : 0;
}

static int	/* vsadd a s b => a + s*b */
vsaddCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double a[3], s, b[3];
  char result[3*24];

  ASSERT(argc == 4, "usage: vsadd a s b => a + s*b");

  ASSERT(getvec(argv[1], 3, a), "vsadd a s b: need 3-component a");
  ASSERT(getvec(argv[2], 1, &s), "vsadd a s b: number expected for s");
  ASSERT(getvec(argv[3], 3, b), "vsadd a s b: need 3-component b");

  sprintf(result, "%.16g %.16g %.16g",
	a[0] + s*b[0],
	a[1] + s*b[1],
	a[2] + s*b[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int	/* vsadd sa a sb b => a*s+b */
svsaddCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double sa, a[3], sb, b[3];
  char result[3*24];

  ASSERT(argc == 5, "usage: vsadd sa a sb b => sa*a + sb*b");

  ASSERT(getvec(argv[1], 1, &sa), "svsadd sa a sb b: number expected for sa");
  ASSERT(getvec(argv[2], 3, a), "svsadd sa a sb b: need 3-component a");
  ASSERT(getvec(argv[3], 1, &sb), "svsadd sa a sb b: number expected for sb");
  ASSERT(getvec(argv[4], 3, b), "svsadd sa a sb b: need 3-component b");

  sprintf(result, "%.16g %.16g %.16g",
	sa*a[0] + sb*b[0],
	sa*a[1] + sb*b[1],
	sa*a[2] + sb*b[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int	/* svmul s v => s*v */
svmulCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double s, v[3];
  char result[3*24];

  ASSERT(argc == 3, "usage: svmul s v => s*v");

  ASSERT(getvec(argv[1], 1, &s), "svmul s v: number expected for s");
  ASSERT(getvec(argv[2], 3, v), "svmul s v: need 3-component v");

  sprintf(result, "%.16g %.16g %.16g",
	s*v[0],
	s*v[1],
	s*v[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int
vmmulCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double v[3];
  double M[9];
  char result[3*24];

  ASSERT(argc == 3, "usage: vmmul v M");

  ASSERT(getvec(argv[1], 3, v), "vmmul v M: need 3-component v");
  ASSERT(getvec(argv[2], 9, M), "vmmul v M: need 9-component M");

  sprintf(result, "%.16g %.16g %.16g",
	v[0]*M[0] + v[1]*M[3] + v[2]*M[6],
	v[0]*M[1] + v[1]*M[4] + v[2]*M[7],
	v[0]*M[2] + v[1]*M[5] + v[2]*M[8]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int
mmmulCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double A[9];
  double B[9];
  char result[9*24];
  char *p;
  int i, j;

  ASSERT(argc == 3, "usage: mmmul A B");

  ASSERT(getvec(argv[1], 9, A), "mmmul A B: need 9-component A");
  ASSERT(getvec(argv[2], 9, B), "mmmul A B: need 9-component B");

  p = result;
  for(i = 0; i < 9; i += 3) {
    for(j = 0; j < 3; j++) {
	sprintf(p, "%.16g ", A[i]*B[j] + A[i+1]*B[j+3] + A[i+2]*B[j+6]);
	p += strlen(p);
    }
  }
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int
crossCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double a[3], b[3], c[3];
  char result[3*24];

  ASSERT(argc == 3, "usage: cross a b");

  ASSERT(getvec(argv[1], 3, a), "cross a b: need 3-component a");
  ASSERT(getvec(argv[2], 3, b), "cross a b: need 3-component b");

  CROSS(c, a,b);
  sprintf(result, "%.16g %.16g %.16g", c[0], c[1], c[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int
dotCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double a[3], b[3];
  char result[24];

  ASSERT(argc == 3, "usage: dot a b");

  ASSERT(getvec(argv[1], 3, a), "dot a b: need 3-component a");
  ASSERT(getvec(argv[2], 3, b), "dot a b: need 3-component b");

  sprintf(result, "%.16g", DOT(a, b));
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}

static int
magCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *av[3];

  av[1] = av[2] = argv[1];
  return dotCmd(clientdata, interp, 3, av);
}

static double
norm(double v[3])
{
  double s = sqrt(DOT(v,v));
  if(s != 0) s = 1/s;
  v[0] *= s;  v[1] *= s;  v[2] *= s;
  return s;
}

static int
normCmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double s, v[3];
  char result[3*24];

  ASSERT(argc == 2, "usage: norm v");

  ASSERT(getvec(argv[1], 3, v), "norm v: need 3-component v");

  norm(v);
  sprintf(result, "%.16g %.16g %.16g",
	s*v[0], s*v[1], s*v[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}


static int
orthog3Cmd(ClientData *clientdata, Tcl_Interp *interp, int argc, char *argv[])
{
  char *error;
  double s, xv[3], yv[3], zv[3];
  char result[9*24];

  ASSERT(argc==2 || argc==3, "usage: orthog3 xvec [zvec] => 3x3 orthogonal matrix");
  ASSERT(getvec(argv[1], 3, xv), "orthog3 xvec [zvec]: need 3-component xvec");
  ASSERT(getvec(argc>2?argv[2]:"1 0 0", 3, zv), "orthog3 xvec zvec: need 3-component zvec");

  if(xv[0] == 0 && xv[1] == 0 && xv[2] == 0)
    xv[2] = 1;
  else
    norm(xv);
  s = DOT(xv, zv);
  zv[0] -= s*xv[0]; zv[1] -= s*xv[1]; zv[2] -= s*xv[2];
  if(norm(zv) == 0) {
    if(fabs(xv[1]) < fabs(xv[2]))
	zv[1] = 1;
    else
	zv[2] = 1;
    s = DOT(xv, zv);
    zv[0] -= s*xv[0]; zv[1] -= s*xv[1]; zv[2] -= s*xv[2];
    norm(zv);
  }
  CROSS(yv, zv,xv);
  norm(yv);
  sprintf(result,
	"%.16g %.16g %.16g %.16g %.16g %.16g %.16g %.16g %.16g",
	xv[0], xv[1], xv[2],
	yv[0], yv[1], yv[2],
	zv[0], zv[1], zv[2]);
  Tcl_SetResult(interp, result, TCL_VOLATILE);
  return TCL_OK;

 fail:
  Tcl_SetResult(interp, error, TCL_STATIC);
  return TCL_ERROR;
}



int orrery_init(Tcl_Interp *interp)
{
    Tcl_CreateCommand(interp, "vsadd", vsaddCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "svsadd", svsaddCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "svmul", svmulCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "vmmul", vmmulCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "mmmul", mmmulCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "cross", crossCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "dot", dotCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "mag", magCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "norm", normCmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "orthog3", orthog3Cmd, (ClientData) NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    return TCL_OK;
}
