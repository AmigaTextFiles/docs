#ifndef	IFFP_DR2D_H
#	define	IFFP_DR2D_H

/* Header file describing chunk IDs and structures for FORM DR2D
 *
 * Ross Cunniff, Stylus, Inc. 9/21/91
 */

#ifndef	IFFPARSE_H_INCLUDED
#	include	<libraries/iffparse.h>
#endif

/* This typedef is to avoid using any floating point arithmetic; */
/* see the functions ieee2flt and flt2ieee for examples of */
/* conversion operations */

typedef long	IEEE;

/* The FORM and CHUNK ID definitions */
/* See dr2d.doc, included in this package, for */
/* explanations */

#define	ID_DR2D		MAKE_ID('D','R','2','D')
#define	ID_DRHD		MAKE_ID('D','R','H','D')
#define ID_PPRF		MAKE_ID('P','P','R','F')
#define ID_DASH		MAKE_ID('D','A','S','H')
#define	ID_AROW		MAKE_ID('A','R','O','W')
#define	ID_FILL		MAKE_ID('F','I','L','L')
#define	ID_LAYR		MAKE_ID('L','A','Y','R')
#define	ID_ATTR		MAKE_ID('A','T','T','R')
#define	ID_BBOX		MAKE_ID('B','B','O','X')
#define	ID_CPLY		MAKE_ID('C','P','L','Y')
#define	ID_OPLY		MAKE_ID('O','P','L','Y')
#define	ID_GRUP		MAKE_ID('G','R','U','P')
#define	ID_XTRN		MAKE_ID('X','T','R','N')
#define	ID_TPTH		MAKE_ID('T','P','T','H')
#define	ID_STXT		MAKE_ID('S','T','X','T')
#define	ID_VBM		MAKE_ID('V','B','M',' ')

#ifndef ID_CMAP
#  define ID_CMAP	MAKE_ID('C','M','A','P')
#endif
#ifndef ID_CMYK
#  define ID_CMYK	MAKE_ID('C','M','Y','K')
#endif
#ifndef ID_CNAM
#  define ID_CNAM	MAKE_ID('C','N','A','M')
#endif
#ifndef ID_FONS
#  define ID_FONS	MAKE_ID('F','O','N','S')
#endif


/* Structure for ID_DRHD - Drawing Header */
struct DRHDstruct {
    IEEE	UL_X, UL_Y,	/* Upper left corner of drawing area */
		LR_X, LR_Y;	/* Lower right corner of drawing area */
};


/* Structure for ID_FONS, font table entry - from FORM FTXT */
struct FONSstruct {
    UBYTE	FontID;
    UBYTE	Pad1;
    UBYTE	Proportional;
    UBYTE	Serif;
    /* char	Name[Size-4]; */
};


/* Structure for ID_DASH, dash table entry */
struct DASHstruct {
    USHORT	DashID;
    USHORT	NumDashes;
    /* IEEE	Dashes[NumDashes]; */
};


/* Structure for ID_AROW, arrow table entry */
#define	ARROW_FIRST	0x01		/* Draw an arrow on the first point */
#define	ARROW_LAST	0x02		/* Draw an arrow on the last point */

struct AROWstruct {
    UBYTE	Flags;		/* Flags, from ARROW_*, above */
    UBYTE	Pad0;		/* Should always be 0 */
    USHORT	ArrowID;	/* ID of the arrow head */
    USHORT	NumPoints;	/* Size of the arrow head array */
    /* IEEE	Points[NumPoints*2]; */	/* The array of points */
};


/* Structure for ID_CNAM, color name */
struct CNAMstruct {
    USHORT	First, Last;		/* First and last colors named */
    /* char	CNames[Size-4]; */	/* Names of those colors */
};


/* Structure for ID_FILL, fill table entry */
struct FILLstruct {
    USHORT	FillID;
};


/* Structure and flags for ID_LAYR, layer table entry */
#define LAYR_ACTIVE	0x01
#define LAYR_DISPLAYED	0x02

struct LAYRstruct {
    USHORT	LayerID;	/* For lookup with ATTR struct */
    char	LayerName[16];	/* Null terminated and padded */
    UBYTE	Flags;		/* From LAYR_*, above */
    UBYTE	Pad0;		/* Always 0 */
};


/* Structure and flags for ID_ATTR, object attributes */
/* Various fill types */
#define FT_NONE		0	/* No fill			*/
#define FT_COLOR	1	/* Fill with color from palette */
#define FT_OBJECTS	2	/* Fill with tiled objects	*/

/* Join types */
#define JT_NONE		0	/* No join */
#define JT_MITER	1	/* Mitered join */
#define JT_BEVEL	2	/* Beveled join */
#define JT_ROUND	3	/* Round join */


struct ATTRstruct {
    UBYTE	FillType;	/* One of FT_*, above	*/
    UBYTE	JoinType;	/* One of JT_*, above	*/
    UBYTE	EdgePattern;	/* Lookup into edge pat	*/
    UBYTE	ArrowHeads;	/* Lookup into arrows	*/
    USHORT	FillValue;	/* Color or fill index	*/
    USHORT	EdgeValue;	/* Edge color index	*/
    USHORT	WhichLayer;	/* Which layer it's in	*/
    IEEE	EdgeThick;	/* Line width		*/
};


/* Structure for ID_BBOX, object bounding box */
struct BBOXstruct {
    IEEE	XMin, YMin,
		XMax, YMax;
};


/* Structure and flags for ID_CPLY and ID_OPLY */
#define DR2D_IND	0xFFFFFFFF
#define DR2D_SPLINE	0x00000001
#define DR2D_MOVETO	0x00000002

struct POLYstruct {
    USHORT	NumPoints;
    /*IEEE	PolyPoints[2*NumPoints];*/
};


/* Structure for ID_GRUP - a group of objects */
struct GRUPstruct {
    USHORT	NumObjs;
};


/* Structure for ID_XTRN - an externally controlled object */
/* Flags for application callbacks */
#define	X_CLONE		0x0001	/* 'appl clone obj dx dy' */
#define X_MOVE		0x0002	/* 'appl move obj dx dy' */
#define	X_ROTATE	0x0004	/* 'appl rotate obj cx cy angle' */
#define	X_RESIZE	0x0008	/* 'appl size obj cx cy sx sy' */
#define X_CHANGE	0x0010	/* 'appl change obj et ev ft fv ew jt fn' */
#define	X_DELETE	0x0020	/* 'appl delete obj' */
#define X_CUT		0x0040	/* 'appl cut obj' */
#define X_COPY		0x0080	/* 'appl copy obj' */
#define X_UNGROUP	0x0100	/* 'appl ungroup obj' */

struct XTRNstruct {
    USHORT	ApplCallBacks;		/* See definitions above */
    USHORT	ApplNameLength;		/* Should ALWAYS be padded */
    /*char	ApplName[ApplNameLength];*/
};


/* Structure for ID_TPTH - text along a path */
struct TPTHstruct {
    USHORT	WhichFont;		/* Which font to use */
    IEEE	CharW, CharH;		/* W/H if an individual char */
    USHORT	NumChars;		/* Number of chars in the string */
    USHORT	NumPoints;		/* Number of points in the path */
    /* char	TextChars[NumChars]; */	/* PAD TO EVEN #! */
    /* IEEE	Path[2*NumPoints]; */	/* The path on which the text lies */
};


/* Structure for ID_STXT - simple text string */
struct STXTstruct {
    short	WhichFont;	/* Index into font table */
    IEEE	CharW, CharH,	/* W/H of an individual char	*/
		BaseX, BaseY,	/* Start of baseline */
		Rotation;	/* Angle of text (in radians) */
    USHORT	NumChars;
    /*char	TextChars[1];*/
};


/* Structure for ID_VBM - virtually positioned and sized bitmap */
struct VBMstruct {
    IEEE	XPos, YPos,		/* Virtual coords */
		XSize, YSize,		/* Virtual size */
		Rotation;		/* Ignored */
    USHORT	PathLen;		/* Length of path, in chars */
    /*char	Path[];			   Directory/file path */
};

#endif	/* DR2D_H_INCLUDED */
/*** EOF dr2d.h ***/
