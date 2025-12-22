#ifndef IFFP_OBJ2D_H
#	define	IFFP_OBJ2D_H

/* This header file defines the structure of a display
 * list; that is, a list of objects to be read from a file,
 * displayed, modified, and written back to a file.
 *
 * Ross Cunniff, Stylus, Inc. 9/21/91
 */

#ifndef IFFP_IFF_H
#	include	"iffp/iff.h"
#endif

#ifndef IFFP_DR2D_H
#	include	"iffp/dr2d.h"
#endif

/* Type of a coordinate, either a floating point number or a
 * scaled integer.  See also ieee2flt and flt2ieee.
 */

#ifdef	FLT_COORD
#	define	FLT_IND		DR2D_IND
	typedef float Coord;
#else
#	define	FIXOFFS	10		/* Power of 2 to multiply by */
#	define	FLT_IND		0x80000000
	typedef long Coord;
#endif


/* Everything necessary to display a list of objects */

struct Proj2D {
    Coord
	UL_X, UL_Y,	/* Upper left corner of display */
	LR_X, LR_Y;	/* Lower right corner of display */

    struct FONSstruct
	*FontTable;	/* List of fonts used */
    char
	**FontNames;	/* Names of the fonts */
    int
	MaxFont,	/* Allocated size of above table */
	NumFont;	/* Actual size of the above table */

    int
	*DashCounts;	/* List of line patterns used */
    Coord
	**DashPatts;
    int
	MaxDash,	/* Allocated size of above table */
	NumDash;	/* Actual size of the above table */

    UBYTE
	*RGB_Table,	/* List of RGB colors used */
	*CMYK_Table;	/* List of CMYK colors used */
    char
	**CNAM_Table;	/* List of color names used */
    int
	NumColor;	/* Size of the above 3 tables */

    struct Obj2D
	**FillTable;	/* List of object-oriented fill patterns */
    int
	MaxFills,	/* Allocated size of above table */
	NumFills;	/* Actual size of the above table */

    struct LAYRstruct
	*LayerTable;	/* List of layer attributes */
    struct Obj2D
	**Objects,	/* List of objects in each layer */
	**LastObjs;	/* Tail of each list */
    int
	MaxLayer,	/* Allocated size of above table */
	NumLayer;	/* Actual size of above table */
};

/* A single object (or one of a list of objects) */
struct Obj2D {

    struct Obj2D
	*Next;		/* Next object in a list of objects */

    ULONG
	Type;		/* One of CPLY, OPLY, STXT, TPTH, XTRN, GRUP, VBM */

    struct ATTRstruct
	Attrs;		/* Fill, join, etc. */

    Coord
	XMin, YMin,	/* Bounding box of object */
	XMax, YMax;

    union {

	/* Data if a CPLY or OPLY */
	struct {
	    USHORT
		NumPoints;	/* Size of polygon */
	    Coord
		*Coords;	/* Coordinates of polygon */
	}   POLYdata;

	/* Data if a TPTH */
	struct {
	    USHORT
		WhichFont;	/* Which font to display string with */
	    Coord
		Width, Height;	/* Size of an individual char */
	    USHORT
		NumChars;	/* Length of string */
	    char
		*String;	/* String to display */
	    short
		NumPath;	/* Length of path */
	    Coord
		*Path;		/* Path along which to display */
	}   TPTHdata;

	/* Data if an STXT */
	struct {
	    USHORT
		WhichFont;	/* Which font to display string with */
	    Coord
		XPos, YPos,	/* Where to draw it */
		Rotation,	/* How to rotate it */
		Width, Height;	/* Size of an individual character */
	    USHORT
		NumChars;	/* Number of characters in string */
	    char
		*String;	/* String of characters */
	}   STXTdata;

	/* Data if a GRUP */
	struct {
	    USHORT
		NumObjs;	/* # of objects in group */
	    struct Obj2D
		*Objs,		/* List of objects in group */
		*Tail;		/* Tail of the list */
	}   GRUPdata;

	/* Data if an XTRN */
	struct {
	    USHORT
		ApplCallBacks,	/* X_* from dr2d.h */
		ApplNameLength;	/* Length of the callback name */
	    char
		*ApplName;	/* Name of the macro to call */
	    struct Obj2D
		*Obj;		/* Object attached to the macro */
	}   XTRNdata;

	/* Data if a VBM */
	struct {
	    Coord
		XPos, YPos,	/* Where the bitmap is to be displayed */
		Width, Height,	/* How big to make it */
		Rotation;	/* Angle to rotate it */
	    USHORT
		PathLen;	/* Length of the filename */
	    char
		*Path;		/* Filename where to find it */
	}   VBMdata;

    }	Data;
};

/* Definition of the dr2d reader and writer */
extern int
    ReadDR2D( struct ParseInfo *PI, long GotForm, struct Proj2D **Conts ),
    WriteDR2D( struct ParseInfo *PI, struct Proj2D *Conts );

/* Definition of some utility routines */
extern void
    ieee2flt( IEEE *, Coord * ),
    flt2ieee( Coord *, IEEE * ),
    FreeObj( struct Obj2D * ),
    FreConts( struct Proj2D * );

#endif	/* OBJ2D_H_INCLUDED */

/*** EOF obj2d.h ***/
