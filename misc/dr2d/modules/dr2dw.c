#include "iffp/obj2d.h"

/* Forward declarations */
static int
    WriteDRHD( struct IFFhandle *, struct Proj2D * ),
    WriteDASH( struct IFFhandle *, struct Proj2D * ),
    WriteLAYR( struct IFFhandle *, struct Proj2D * ),
    WriteFILL( struct IFFhandle *, struct Proj2D * ),
    WriteFONS( struct IFFhandle *, struct Proj2D * ),
    WriteCMAP( struct IFFhandle *, struct Proj2D * ),
    WriteObj( struct IFFhandle *, struct Obj2D * ),
    WriteATTR( struct IFFhandle *, struct ATTRstruct * ),
    WriteGRUP( struct IFFhandle *, struct Obj2D * ),
    WriteXTRN( struct IFFhandle *, struct Obj2D * ),
    WritePOLY( struct IFFhandle *, struct Obj2D * ),
    WriteTPTH( struct IFFhandle *, struct Obj2D * ),
    WriteSTXT( struct IFFhandle *, struct Obj2D * ),
    WriteVBM( struct IFFhandle *, struct Obj2D * );

/* Data area for chunk writing */
static union {
    struct DRHDstruct
	DRHDdata;
    struct FONSstruct
	FONSdata;
    struct GRUPstruct
	GRUPdata;
    struct XTRNstruct
	XTRNdata;
    struct FILLstruct
	FILLdata;
    struct ATTRstruct
	ATTRdata;
    struct BBOXstruct
	BBOXdata;
    struct DASHstruct
	DASHdata;
    struct LAYRstruct
	LAYRdata;
    struct POLYstruct
	POLYdata;
    struct TPTHstruct
	TPTHdata;
    struct STXTstruct
	STXTdata;
    struct VBMstruct
	VBMdata;
}   Data;



int WriteDR2D( struct ParseInfo *PI, struct Proj2D *Conts )
{
    int
	i;
    struct IFFHandle
	*IFF;
    long
	Error;
    struct Obj2D
	*Curr;			/* Current object */

    IFF = PI->iff;

    /************* Write the file ****************/
    Error = PushChunk( IFF, ID_DR2D, ID_FORM, IFFSIZE_UNKNOWN );
    if( Error ) {
	goto ErrorExit;
    }

    /* Write the DRHD chunk */
    Error = WriteDRHD( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write the FONS chunks */
    Error = WriteFONS( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write the DASH chunks */
    Error = WriteDASH( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write the CMAP/CMYK/CNAM chunks */
    Error = WriteCMAP( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write the FILL chunks */
    Error = WriteFILL( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write the LAYR chunks */
    Error = WriteLAYR( IFF, Conts );
    if( Error )	goto ErrorExit;

    /* Write all of the objects */
    for( i = 0; i < Conts->NumLayer; i++ ) {
	for( Curr = Conts->Objects[i]; Curr; Curr = Curr->Next ) {
	    Error = WriteObj( IFF, Curr );
	    if( Error )	goto ErrorExit;
	}
    }

    /* Pop out of the final context */
    Error = PopChunk( IFF );
    if( Error ) {
	goto ErrorExit;
    }

    /************* Normal exit *****************/
    return 0;

    /************* Error exit *****************/
ErrorExit :
    return Error;
}


static int WriteATTR( struct IFFhandle *IFF, struct ATTRstruct *Attr )
{
    struct ATTRstruct
	Attrs;
    int
	Error;

    Attrs = *Attr;
    flt2ieee( &Attr->EdgeThick, &Attrs.EdgeThick );

    Error = PushChunk( IFF, 0, ID_ATTR, sizeof(struct ATTRstruct) );
    if( Error != 0 )	return Error;

    Error = WriteChunkRecords( IFF, &Attrs, sizeof(struct ATTRstruct), 1 );
    if( Error != 1 )	return Error;

    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteObj( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    switch( Obj->Type ) {
    case ID_CPLY :	case ID_OPLY :
	return WritePOLY( IFF, Obj );

    case ID_TPTH :
	return WriteTPTH( IFF, Obj );

    case ID_STXT :
	return WriteSTXT( IFF, Obj );

    case ID_VBM :
	return WriteVBM( IFF, Obj );

    case ID_GRUP :
	return WriteGRUP( IFF, Obj );

    case ID_XTRN :
	return WriteXTRN( IFF, Obj );

    default :
	return IFFERR_MANGLED;
    }
}


static int WriteGRUP( struct IFFhandle * IFF, struct Obj2D *Obj )
{
    struct Obj2D
	*Curr;
    int
	Error;

    /* Groups are a nested FORM DR2D */
    Error = PushChunk( IFF, ID_DR2D, ID_FORM, IFFSIZE_UNKNOWN );
    if( Error < 0 )	return Error;

    /* The first chunk must be a GRUP chunk */
    Error = PushChunk( IFF, 0, ID_GRUP, sizeof(struct GRUPstruct) );
    if( Error < 0 )	return Error;

    Data.GRUPdata.NumObjs = Obj->Data.GRUPdata.NumObjs;
    Error = WriteChunkRecords( IFF, &Data.GRUPdata, sizeof(struct GRUPstruct), 1 );
    if( Error != 1 )	return Error;

    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    /* Then follow all of the objects in the group */
    for( Curr = Obj->Data.GRUPdata.Objs; Curr; Curr = Curr->Next ) {
	Error = WriteObj( IFF, Curr );
	if( Error != 0 )	return Error;
    }

    /* Exit the nested FORM DR2D */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteXTRN( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	n, Error;

    Data.XTRNdata.ApplCallBacks = Obj->Data.XTRNdata.ApplCallBacks;
    Data.XTRNdata.ApplNameLength = n = Obj->Data.XTRNdata.ApplNameLength;

    /* External objects are a nested FORM DR2D */
    Error = PushChunk( IFF, ID_DR2D, ID_FORM, IFFSIZE_UNKNOWN );
    if( Error < 0 )	return Error;

    /* The first chunk must be an XTRN chunk */
    Error = PushChunk( IFF, 0, ID_XTRN, sizeof(struct XTRNstruct) + n );
    if( Error < 0 )	return Error;

    Error = WriteChunkRecords( IFF, &Data.XTRNdata, sizeof(struct XTRNstruct), 1 );
    if( Error != 1 )	return Error;
    Error = WriteChunkRecords( IFF, Obj->Data.XTRNdata.ApplName, n, 1 );
    if( Error != 1 )	return Error;

    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    /* Then follows the object */
    Error = WriteObj( IFF, Obj->Data.XTRNdata.Obj );
    if( Error != 0 )	return Error;

    /* Exit the nested FORM DR2D */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WritePOLY( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	i, n,
	Error;
    Coord
	*Coords;
    IEEE
	Pts[2];

    Error = WriteATTR( IFF, &Obj->Attrs );
    if( Error != 0 )	return Error;

    Data.POLYdata.NumPoints = n = Obj->Data.POLYdata.NumPoints;

    /* Enter the CPLY or OPLY context */
    Error = PushChunk( IFF, 0, Obj->Type,
			sizeof(struct POLYstruct) + n*2*sizeof(IEEE) );
    if( Error != 0 )	return Error;

    /* Write the number of points */
    Error = WriteChunkRecords( IFF, &Data, sizeof(struct POLYstruct), 1 );
    if( Error != 1 )	return Error;

    /* Write the points */
    Coords = Obj->Data.POLYdata.Coords;
    for( i = 0; i < n; i++ ) {
	if( ((long *)Coords)[2*i] == FLT_IND ) {
	    ((long *)Pts)[0] = DR2D_IND;
	    ((long *)Pts)[1] = ((long *)Coords)[2*i+1];
	}
	else {
	    flt2ieee( Coords + 2*i,     Pts );
	    flt2ieee( Coords + 2*i + 1, Pts + 1 );
	}
	Error = WriteChunkRecords( IFF, Pts, 2*sizeof(IEEE), 1 );
	if( Error != 1 )	return Error;
    }

    /* Exit the context */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteTPTH( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	i, nc, np, pad,
	Error;
    char
	c = 0;
    Coord
	*Coords;
    IEEE
	Pts[2];

    Error = WriteATTR( IFF, &Obj->Attrs );
    if( Error != 0 )	return Error;

    np = Obj->Data.TPTHdata.NumPath;
    nc = Obj->Data.TPTHdata.NumChars;
    pad = nc & 1;

    /* Push the TPTH context */
    Error = PushChunk( IFF, 0, ID_TPTH,
			sizeof(struct TPTHstruct) + nc + pad + np*2*sizeof(IEEE) );
    if( Error != 0 )	return Error;

    /* Write TPTH information */
    Data.TPTHdata.WhichFont = Obj->Data.TPTHdata.WhichFont;
    flt2ieee( &Obj->Data.TPTHdata.Width, &Data.TPTHdata.CharW );
    flt2ieee( &Obj->Data.TPTHdata.Height, &Data.TPTHdata.CharH );
    Data.TPTHdata.NumChars = nc;
    Data.TPTHdata.NumPoints = np;
    Error = WriteChunkRecords( IFF, &Data, sizeof(struct TPTHstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Write text string */
    Error = WriteChunkRecords( IFF, Obj->Data.TPTHdata.String, nc, 1 );
    if( Error != 1 )	return Error;

    /* Write pad character if necessary */
    if( pad ) {
	Error = WriteChunkRecords( IFF, &c, 1, 1 );
	if( Error != 1 )	return Error;
    }

    /* Write text path */
    Coords = Obj->Data.TPTHdata.Path;
    for( i = 0; i < np; i++ ) {
	if( ((long *)Coords)[2*i] == FLT_IND ) {
	    ((long *)Pts)[0] = DR2D_IND;
	    ((long *)Pts)[1] = ((long *)Coords)[2*i+1];
	}
	else {
	    flt2ieee( Coords + 2*i,     Pts );
	    flt2ieee( Coords + 2*i + 1, Pts + 1 );
	}
	Error = WriteChunkRecords( IFF, Pts, 2*sizeof(IEEE), 1 );
	if( Error != 1 )	return Error;
    }

    /* Exit the context */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteSTXT( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	n,
	Error;

    Error = WriteATTR( IFF, &Obj->Attrs );
    if( Error != 0 )	return Error;

    n = Obj->Data.STXTdata.NumChars;

    /* Push the STXT context */
    Error = PushChunk( IFF, 0, ID_STXT,
			sizeof(struct STXTstruct) + n );
    if( Error != 0 )	return Error;

    /* Write STXT information */
    Data.STXTdata.WhichFont = Obj->Data.STXTdata.WhichFont;
    Data.STXTdata.NumChars = n;
    flt2ieee( &Obj->Data.STXTdata.Width, &Data.STXTdata.CharW );
    flt2ieee( &Obj->Data.STXTdata.Height, &Data.STXTdata.CharH );
    flt2ieee( &Obj->Data.STXTdata.XPos, &Data.STXTdata.BaseX );
    flt2ieee( &Obj->Data.STXTdata.YPos, &Data.STXTdata.BaseY );
    flt2ieee( &Obj->Data.STXTdata.Rotation, &Data.STXTdata.Rotation );
    Error = WriteChunkRecords( IFF, &Data, sizeof(struct STXTstruct), 1 );
    if( Error != 1 )	return Error;

    /* Write text string */
        Error = WriteChunkRecords( IFF, Obj->Data.STXTdata.String, n, 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Exit the context */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteVBM( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	n,
	Error;

    n = Obj->Data.VBMdata.PathLen;

    /* Push the VBM context */
    Error = PushChunk( IFF, 0, ID_VBM,
			sizeof(struct VBMstruct) + n );
    if( Error != 0 )	return Error;

    /* Write VBM information */
    Data.VBMdata.PathLen = n;
    flt2ieee( &Obj->Data.VBMdata.XPos, &Data.VBMdata.XPos );
    flt2ieee( &Obj->Data.VBMdata.YPos, &Data.VBMdata.YPos );
    flt2ieee( &Obj->Data.VBMdata.Width, &Data.VBMdata.XSize );
    flt2ieee( &Obj->Data.VBMdata.Height, &Data.VBMdata.YSize );
    flt2ieee( &Obj->Data.VBMdata.Rotation, &Data.VBMdata.Rotation );
    Error = WriteChunkRecords( IFF, &Data, sizeof(struct VBMstruct), 1 );
    if( Error != 1 )	return Error;

    /* Write path to bitmap */
    Error = WriteChunkRecords( IFF, Obj->Data.VBMdata.Path, n, 1 );
    if( Error != 1 )	return Error;

    /* Exit the context */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


static int WriteDRHD( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	Error;

    flt2ieee( &Conts->UL_X, &Data.DRHDdata.UL_X );
    flt2ieee( &Conts->UL_Y, &Data.DRHDdata.UL_Y );
    flt2ieee( &Conts->LR_X, &Data.DRHDdata.LR_X );
    flt2ieee( &Conts->LR_Y, &Data.DRHDdata.LR_Y );

    Error = PushChunk( IFF, 0, ID_DRHD, sizeof(struct DRHDstruct) );
    if( Error != 0 )	return Error;

    Error = WriteChunkRecords( IFF, &Data.DRHDdata, sizeof(struct DRHDstruct), 1 );
    if( Error != 1 )	return Error;

    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;
    return 0;
}


static int WriteDASH( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i, j, n,
	Error;
    IEEE
	Point;

    for( i = 0; i < Conts->NumDash; i++ ) {
	Data.DASHdata.DashID = i;
	Data.DASHdata.NumDashes = n = Conts->DashCounts[i];

	/* Enter a new chunk */
	Error = PushChunk( IFF, 0, ID_DASH,
			sizeof(struct DASHstruct) + n*sizeof(IEEE) );
	if( Error != 0 )	return Error;

	/* Write the DASH chunk */
	Error = WriteChunkRecords( IFF, &Data.DASHdata,
				sizeof(struct DASHstruct), 1 );
	if( Error != 1 )	return Error;
	for( j = 0; j < n; j++ ) {
	    flt2ieee( Conts->DashPatts[i] + j, &Point );
	    Error = WriteChunkRecords( IFF, &Point, sizeof(IEEE), 1 );
	    if( Error != 1 )	return Error;
	}

	/* Exit the chunk */
	Error = PopChunk( IFF );
	if( Error != 0 )	return Error;
    }

    return 0;
}



static int WriteLAYR( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i,
	Error;

    for( i = 0; i < Conts->NumLayer; i++ ) {
	/* Enter a new chunk */
	Error = PushChunk( IFF, 0, ID_LAYR, sizeof(struct LAYRstruct) );
	if( Error != 0 )	return Error;

	/* Write the LAYR chunk */
	Error = WriteChunkRecords( IFF, Conts->LayerTable + i,
				sizeof(struct LAYRstruct), 1 );
	if( Error != 1 )	return Error;

	/* Exit the chunk */
	Error = PopChunk( IFF );
	if( Error != 0 )	return Error;
    }

    return 0;
}


static int WriteFILL( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i,
	Error;

    for( i = 0; i < Conts->NumFills; i++ ) {
	/* Fills are a nested FORM DR2D */
	Error = PushChunk( IFF, ID_DR2D, ID_FORM, IFFSIZE_UNKNOWN );
	if( Error < 0 )	return Error;

	/* The first chunk must be a FILL chunk */
	Error = PushChunk( IFF, 0, ID_FILL, sizeof(struct GRUPstruct) );
	if( Error < 0 )	return Error;

	Data.FILLdata.FillID = i;
	Error = WriteChunkRecords( IFF, &Data.FILLdata, sizeof(struct FILLstruct), 1 );
	if( Error != 1 )	return Error;

	Error = PopChunk( IFF );
	if( Error != 0 )	return Error;

	/* Then the object of the fill */
	Error = WriteObj( IFF, Conts->FillTable[i] );
	if( Error != 0 )	return Error;

	/* Exit the nested FORM DR2D */
	Error = PopChunk( IFF );
	if( Error != 0 )	return Error;
    }
    return 0;
}


static int WriteFONS( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i, n,
	Error;

    for( i = 0; i < Conts->NumFont; i++ ) {
	/* Enter a new chunk */
	n = strlen( Conts->FontNames[i] ) + 1;
	Error = PushChunk( IFF, 0, ID_FONS, sizeof(struct FONSstruct) + n );
	if( Error != 0 )	return Error;

	/* Write the FONS chunk */
	Error = WriteChunkRecords( IFF, Conts->FontTable + i,
				sizeof(struct FONSstruct), 1 );
	if( Error != 1 )	return Error;
	Error = WriteChunkRecords( IFF, Conts->FontNames[i], n, 1 );
	if( Error != 1 )	return Error;

	/* Exit the chunk */
	Error = PopChunk( IFF );
	if( Error != 0 )	return Error;
    }

    return 0;
}


static int WriteCMAP( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	Error;

    /* Enter a new chunk */
    Error = PushChunk( IFF, 0, ID_CMAP, 3*Conts->NumColor );
    if( Error != 0 )	return Error;

    /* Write the CMAP chunk */
    Error = WriteChunkRecords( IFF, Conts->RGB_Table, 3*Conts->NumColor, 1 );
    if( Error != 1 )	return Error;

    /* Exit the chunk */
    Error = PopChunk( IFF );
    if( Error != 0 )	return Error;

    return 0;
}


/*** EOF dr2dw.c ***/
