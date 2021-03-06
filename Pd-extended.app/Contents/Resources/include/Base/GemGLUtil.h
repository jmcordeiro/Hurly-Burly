/*-----------------------------------------------------------------
LOG
    GEM - Graphics Environment for Multimedia

    GemGLUtil.h
       - contains functions for graphics
       - part of GEM

    Copyright (c) 1997-2000 Mark Danks. mark@danks.org
    Copyright (c) G�nther Geiger. geiger@epy.co.at
    Copyright (c) 2001-2002 IOhannes m zmoelnig. forum::f�r::uml�ute. IEM. zmoelnig@iem.kug.ac.at
    For information on usage and redistribution, and for a DISCLAIMER OF ALL
    WARRANTIES, see the file, "GEM.LICENSE.TERMS" in this distribution.

-----------------------------------------------------------------*/

#ifndef INCLUDE_GEMGLUTIL_H_
#define INCLUDE_GEMGLUTIL_H_

#include "Base/GemBase.h"
#include "Base/GemExportDef.h"

GEM_EXTERN extern GLenum		glReportError (void);
GEM_EXTERN extern int           getGLdefine(const char *name);
GEM_EXTERN extern int           getGLdefine(const t_symbol *name);
GEM_EXTERN extern int           getGLdefine(const t_atom *name);
GEM_EXTERN extern int           getGLbitfield(int argc, t_atom *argv);
#endif  // for header file

