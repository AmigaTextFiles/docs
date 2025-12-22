#include "iffp/obj2d.h"

/* This definition has to go somewhere so ReadDR2D can resolve it */
struct Library
    *IFFParseBase;

/* Forward declarations for device driver functions */
void
    InitDevice( struct Proj2D * ),
    DisplayObject( struct Obj2D * ),
    TermDevice( void );

int main( int argc, char **argv )
{
    struct Proj2D
	*Conts;
    struct Obj2D
	*Obj;
    int
	i,
	Error;
    struct ParseInfo
	PI;

    /* Check the argument count */
    if( argc != 2 ) {
	fprintf( stderr, "Usage: %s src\n", argv[0] );
	fprintf( stderr, "	src is a file or -c for the clipboard\n" );
	return 1;
    }

    /* Open iffparse.library */
    IFFParseBase = OpenLibrary( "iffparse.library", 0L );
    if( !IFFParseBase ) {
	fprintf( stderr, "Can't open iffparse.library\n" );
	exit( 1 );
    }

    /* Get an IFF handle */
    PI.iff = AllocIFF();
    if( !PI.iff ) {
	fprintf( stderr, "Can't allocate an IFF structure\n" );
	CloseLibrary( IFFParseBase );
	exit( 1 );
    }

    /* Open a file for reading */
    Error = openifile( &PI, argv[1], IFFF_READ );
    if( Error ) {
	fprintf( stderr, "Can't open file %s\n", argv[1] );
	CloseLibrary( IFFParseBase );
	exit( 1 );
    }

    Error = ReadDR2D( &PI, 0, &Conts );
    closeifile( &PI );
    if( Error != 0 ) {
	fprintf( stderr, "Read Error: %d\n", Error );
	CloseLibrary( IFFParseBase );
	exit( 1 );
    }

    /* Set up page, etc. */
    InitDevice( Conts );

    /* Display all objects in each layer */
    for( i = 0; i < Conts->NumLayer; i++ ) {
	/* If this layer is not displayed, ignore it */
	if( !(Conts->LayerTable[i].Flags & LAYR_DISPLAYED) )	continue;

	/* Display each object */
	for( Obj = Conts->Objects[i]; Obj; Obj = Obj->Next ) {
	    DisplayObject( Obj );
	}
    }

    /* Write any epilogue stuff needed */
    TermDevice();

    /* All done! Clean up. */
    FreeConts( Conts );
    CloseLibrary( IFFParseBase );
    exit( 0 );
}


/* Forward references for display routines */
void
    SetAttrs( struct ATTRstruct * ),
    DisplayPoly( Coord *, int, int ),
    DisplaySTXT( struct Obj2D * ),
    DisplayTPTH( struct Obj2D * ),
    DisplayVBM( struct Obj2D * );


/* Generic object displayer */
void DisplayObject( struct Obj2D *Obj )
{
    switch( Obj->Type ) {
    case ID_CPLY :
	SetAttrs( &Obj->Attrs );
	DisplayPoly(	Obj->Data.POLYdata.Coords,
			Obj->Data.POLYdata.NumPoints, 1 );
	break;
    case ID_OPLY :
	SetAttrs( &Obj->Attrs );
	DisplayPoly(	Obj->Data.POLYdata.Coords,
			Obj->Data.POLYdata.NumPoints, 0 );
	break;
    case ID_STXT :
	SetAttrs( &Obj->Attrs );
	DisplaySTXT( Obj );
	break;
    case ID_TPTH :
	SetAttrs( &Obj->Attrs );
	DisplayTPTH( Obj );
	break;
    case ID_VBM :
	DisplayVBM( Obj );
	break;
    case ID_XTRN :
	DisplayObject( Obj->Data.XTRNdata.Obj );
	break;
    case ID_GRUP :
	for( Obj = Obj->Data.GRUPdata.Objs; Obj; Obj = Obj->Next ) {
	    DisplayObject( Obj );
	}
	break;
    }
}


/*** Replace the following with your favorite device driver ***/

/* These are coded for a generic PostScript printer, with a */
/* portrait page */

#define	PWIDTH		8.5
#define	PHEIGHT		11.0

static struct Proj2D
    *Proj;
static struct ATTRstruct
    CurrAttr;			/* Current attributes */
static int
    SwapX, SwapY,		/* Is the coordinate system reversed? */
    Rot90;			/* Is the project a landscape page? */

void InitDevice( struct Proj2D *Conts )
{
    Coord
	TX, TY;

    Proj = Conts;
    SwapX = Conts->UL_X > Conts->LR_X;
    SwapY = Conts->UL_Y < Conts->LR_Y;
    TX = Conts->UL_X - Conts->LR_X;
    TY = Conts->UL_Y - Conts->LR_Y;
    if( TX < 0 )	TX = -TX;
    if( TY < 0 )	TY = -TY;
    Rot90 = TX > TY;
}


void TermDevice( void )
{
    puts( "showpage" );
    /* Some PS devices need a ^D to terminate the job */
    puts( "\004" );
}


void SetAttrs( struct ATTRstruct *Attr )
{
    CurrAttr = *Attr;
}


static void Coord2PS( Coord X, Coord Y, float *FX, float *FY )
{
    float
	t;

#ifdef FLT_COORD
    *FX = X * 72.0;
    *FY = Y * 72.0;
#else
    *FX = (72.0*X) / (1<<FIXOFFS);
    *FY = (72.0*Y) / (1<<FIXOFFS);
#endif

    if( SwapX ) {
	*FX = (PWIDTH*72.0) - *FX;
    }
    if( SwapY ) {
	*FY = (PHEIGHT*72.0) - *FY;
    }
    if( Rot90 ) {
	t = *FX; *FX = (PHEIGHT*72.0) - *FY; *FY = t;
    }
}


void DisplayPoly( Coord *Points, int NumPoints, int Closed )
{
    int
	i, n, NeedMove;
    float
	PX, PY;

    /* Print out the polygon */
    NeedMove = 1;
    for( i = 0; i < NumPoints; i++ ) {
	if( ((long *)Points)[2*i] == FLT_IND ) {
	    if( ((long *)Points)[2*i+1] & DR2D_MOVETO ) {
		/* Need a moveto... */
		if( Closed ) {
		    /* Close the current path */
		    puts( "closepath" );
		}
		NeedMove = 1;
	    }
	    if( ((long *)Points)[2*i+1] & DR2D_SPLINE ) {
		/* Do a curveto */
		Coord2PS( Points[2*i+2], Points[2*i+3], &PX, &PY );
		if( NeedMove ) {
		    printf( "%g %g moveto\n", PX, PY );
		}
		else {
		    printf( "%g %g lineto\n", PX, PY );
		}
		Coord2PS( Points[2*i+4], Points[2*i+5], &PX, &PY );
		printf( "%g %g ", PX, PY );
		Coord2PS( Points[2*i+6], Points[2*i+7], &PX, &PY );
		printf( "%g %g ", PX, PY );
		Coord2PS( Points[2*i+8], Points[2*i+9], &PX, &PY );
		printf( "%g %g curveto\n", PX, PY );
		NeedMove = 0;
		i += 4;	/* Skip the curveto points */
	    }
	}
	else {
	    Coord2PS( Points[2*i], Points[2*i+1], &PX, &PY );
	    if( NeedMove ) {
		printf( "%g %g moveto\n", PX, PY );
	    }
	    else {
		printf( "%g %g lineto\n", PX, PY );
	    }
	    NeedMove = 0;
	}
    }

    if( Closed ) {
	puts( "closepath" );
    }

    if( Closed && (CurrAttr.FillType == FT_COLOR) ) {
	/* Fill the polygon */
	if( CurrAttr.EdgePattern ) {
	    /* Save the path for the later stroke */
	    puts( "gsave" );
	}
	n = CurrAttr.FillValue;
	printf( "%g %g %g setrgbcolor eofill\n",
			Proj->RGB_Table[3*n] / 255.0,
			Proj->RGB_Table[3*n+1] / 255.0,
			Proj->RGB_Table[3*n+2] / 255.0 );
	if( CurrAttr.EdgePattern ) {
	    /* Restore the path */
	    puts( "grestore" );
	}
    }

    if( CurrAttr.EdgePattern ) {
	/* Stroke the polygon */
	/* First, establish the dash pattern */
	n = CurrAttr.EdgePattern;
	NumPoints = Proj->DashCounts[n];
	putchar( '[' );
#ifdef FLT_COORD
	PX = CurrAttr.EdgeThick * 72.0;
#else
	PX = (72.0*CurrAttr.EdgeThick) / (1<<FIXOFFS);
#endif
	printf( "%g setlinewidth\n", PX );
#ifndef FLT_COORD
	PX /= (1<<FIXOFFS);
#endif
	for( i = 0; i < NumPoints; i++ ) {
	    printf( " %g", Proj->DashPatts[n][i] * PX );
	}
	puts( " ] 0 setdash" );

	/* Now, establish the line join */
	printf( "%d setlinejoin\n", CurrAttr.JoinType );

	/* Finally, set the color and stroke the line */
	n = CurrAttr.EdgeValue;
	printf( "%g %g %g setrgbcolor stroke\n",
			Proj->RGB_Table[3*n] / 255.0,
			Proj->RGB_Table[3*n+1] / 255.0,
			Proj->RGB_Table[3*n+2] / 255.0 );
    }
}

void DisplaySTXT( struct Obj2D *Obj )
{
    /* TBD someday */
}

void DisplayTPTH( struct Obj2D *Obj )
{
    /* TBD someday */
}

void DisplayVBM( struct Obj2D *Obj )
{
    /* TBD someday */
}

/*** EOF DR2DtoPS.c ***/
