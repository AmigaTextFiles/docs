#include "iffp/obj2d.h"

static int
    NestLevel = 0;		/* Depth of the stack */
static struct Obj2D
    *ObjStack = 0;		/* Stack of objects for nested GRUPs */

/* Forward declarations */
static struct Obj2D
    *MakeObj( struct IFFhandle *, struct ContextNode * );
static int
    ReadPOLY( struct IFFhandle *, struct Obj2D * ),
    ReadTPTH( struct IFFhandle *, struct Obj2D * ),
    ReadSTXT( struct IFFhandle *, struct Obj2D * ),
    ReadVBM( struct IFFhandle *, struct ContextNode *, struct Obj2D * ),
    ReadDASH( struct IFFhandle *, struct Proj2D * ),
    ReadLAYR( struct IFFhandle *, struct Proj2D * ),
    ReadFONS( struct IFFhandle *, struct ContextNode *, struct Proj2D * ),
    ReadCMAP( struct IFFhandle *, struct ContextNode *, struct Proj2D * ),
    AddObj( struct Obj2D *, struct Proj2D * ),
    DefineFill( struct Obj2D *, struct Proj2D * );

/* Data area for chunk reading */
static union {
    struct GRUPstruct
	GRUPdata;
    struct XTRNstruct
	XTRNdata;
    struct FILLstruct
	FILLdata;
    struct DASHstruct
	DASHdata;
    struct LAYRstruct
	LAYRdata;
    struct FONSstruct
	FONSdata;
    struct POLYstruct
	POLYdata;
    struct TPTHstruct
	TPTHdata;
    struct STXTstruct
	STXTdata;
    struct VBMstruct
	VBMdata;
}   Data;



int ReadDR2D( struct ParseInfo *PI, long GotForm, struct Proj2D **Conts )
{
    static long
	ChunkList[] = {
	    ID_FORM, ID_DASH, ID_FILL, ID_LAYR,
	    ID_CMAP, ID_CMYK, ID_CNAM, ID_FONS,
	    ID_CPLY, ID_OPLY, ID_GRUP, ID_XTRN,
	    ID_TPTH, ID_STXT, ID_VBM,  0
	},
	DR2Dprops[] = {
	    ID_DR2D, ID_ATTR,
	    ID_DR2D, ID_BBOX,
	    ID_DR2D, ID_DRHD,
	    ID_DR2D, ID_PPRF
	};
    int
	i, n,
	NewNest = 0;
    char
	*s;
    struct IFFHandle
	*IFF;

    struct StoredProperty
	*Drhd;
    struct DRHDstruct
	*DRHDdata;

    struct Proj2D
	*Res;
    long
	Error;
    struct ContextNode
	*Chunk;
    struct Obj2D
	*Curr;			/* Current object */


    Res = malloc( sizeof(struct Proj2D) );
    if( !Res ) {
	Error = IFFERR_NOMEM;
	goto ErrorExit;
    }

    /* Initialize the object environment */
    Res->FontTable = 0;
    Res->NumFont = Res->MaxFont = 0;
    Res->DashCounts = 0;
    Res->DashPatts = 0;
    Res->NumDash = Res->MaxDash = 0;
    Res->RGB_Table = 0;
    Res->CMYK_Table = 0;
    Res->CNAM_Table = 0;
    Res->NumColor = 0;
    Res->FillTable = 0;
    Res->NumFills = Res->MaxFills = 0;
    Res->LayerTable = 0;
    Res->Objects = 0;
    Res->LastObjs = 0;
    Res->NumLayer = Res->MaxLayer = 0;

    /* Get the IFF handle */
    IFF = PI->iff;

    /* Declare things we're interested in */
    for( i = 0; ChunkList[i]; i++ ) {
	Error = StopChunk( IFF, ID_DR2D, ChunkList[i] );
	if( Error ) {
	    goto ErrorExit;
	}
    }

    Error = PropChunks( IFF, DR2Dprops, 4 );
    if( Error ) {
	goto ErrorExit;
    }

    /* Tell IFFparse that we're interested in when the FORM terminates */
    Error = StopOnExit( IFF, ID_DR2D, ID_FORM );
    if( Error ) {
	goto ErrorExit;
    }

    NestLevel = GotForm != 0L;

    /* Actually read the file */
    do {
	Error = ParseIFF( IFF, IFFPARSE_SCAN );
	switch( Error ) {
	case 0 :
	    Chunk = CurrentChunk( IFF );

	    switch( Chunk->cn_ID ) {
	    case ID_FORM :
		if( NestLevel ) {
		    /* Nested FORM DR2D - must be GRUP, XTRN, or FILL */
		    NewNest = 1;
		}
		NestLevel++;
	        break;

	    /* The following chunks must be the first in a nested FORM DR2D */
	    /* A FILL must not be nested inside any other chunk. */
	    case ID_FILL :
		if( NestLevel > 2 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}
		/* FALLTHROUGH */
	    case ID_GRUP :
	    case ID_XTRN :
		if( NestLevel < 2 || !NewNest ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}
		NewNest = 0;

		Curr = MakeObj( IFF, Chunk );
		if( !Curr ) {
		    Error = IFFERR_NOMEM;
		    goto ErrorExit;
		}

		switch( Chunk->cn_ID ) {
		case ID_FILL :
		    Error = ReadChunkRecords( IFF, &Data,
				sizeof(struct FILLstruct), 1 );
		    if( Error != 1 ) {
			goto ErrorExit;
		    }

		    /* This is a kludge; we're going to store
		     * the FILL ID in the GRUP.NumObjs and the
		     * fill object in the GRUP.Objs
		     */
		    Curr->Data.GRUPdata.NumObjs = Data.FILLdata.FillID;
		    break;

		case ID_GRUP :
		    Error = ReadChunkRecords( IFF, &Data,
				sizeof(struct GRUPstruct), 1 );
		    if( Error != 1 ) {
			goto ErrorExit;
		    }
		    Curr->Data.GRUPdata.NumObjs = Data.GRUPdata.NumObjs;
		    Curr->Data.GRUPdata.Tail = 0;
		    break;

		case ID_XTRN :
		    Error = ReadChunkRecords( IFF, &Data,
				sizeof(struct XTRNstruct), 1 );
		    if( Error != 1 ) {
			goto ErrorExit;
		    }

		    Curr->Data.XTRNdata.ApplCallBacks =
				Data.XTRNdata.ApplCallBacks;
		    Curr->Data.XTRNdata.ApplNameLength = n =
				Data.XTRNdata.ApplNameLength;

		    Curr->Data.XTRNdata.ApplName = s = malloc( n );
		    if( !s ) {
			Error = IFFERR_NOMEM;
			goto ErrorExit;
		    }

		    Error = ReadChunkRecords( IFF, s, n, 1 );
		    if( Error != 1 ) {
			goto ErrorExit;
		    }
		    break;
		}

		/* Stack the context we need */
		Curr->Next = ObjStack;
		ObjStack = Curr;
		break;

	    /* The following chunks must not be in a nested FORM DR2D */
	    case ID_DASH :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}

		Error = ReadDASH( IFF, Res );
		if( Error != 0 )	goto ErrorExit;

		break;

	    case ID_LAYR :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}

		Error = ReadLAYR( IFF, Res );
		if( Error != 0 )	goto ErrorExit;

		break;

	    case ID_CMAP :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}

		Error = ReadCMAP( IFF, Chunk, Res );
		if( Error != 0 )	goto ErrorExit;

		break;

	    case ID_CMYK :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}
		/* TBD */
		break;

	    case ID_CNAM :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}
		/* TBD */
		break;

	    case ID_FONS :
		if( NestLevel > 1 ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}

		Error = ReadFONS( IFF, Chunk, Res );
		if( Error != 0 )	goto ErrorExit;

		break;

	    /* The following chunks can occur anywhere */
	    case ID_CPLY :
	    case ID_OPLY :
	    case ID_TPTH :
	    case ID_STXT :
	    case ID_VBM :
		if( NewNest ) {
		    Error = IFFERR_MANGLED;
		    goto ErrorExit;
		}

		Curr = MakeObj( IFF, Chunk );
		if( !Curr ) {
		    Error = IFFERR_NOMEM;
		    goto ErrorExit;
		}

		/* Read the object specific data */
		switch( Curr->Type ) {
		case ID_CPLY :
		case ID_OPLY :
		    Error = ReadPOLY( IFF, Curr );
		    if( Error != 0 )	goto ErrorExit;
		    break;

		case ID_TPTH :
		    Error = ReadTPTH( IFF, Curr );
		    if( Error != 0 )	goto ErrorExit;

		    break;

		case ID_STXT :
		    Error = ReadSTXT( IFF, Curr );
		    if( Error != 0 )	goto ErrorExit;
		    break;

		case ID_VBM :
		    Error = ReadVBM( IFF, Chunk, Curr );
		    if( Error != 0 )	goto ErrorExit;
		    break;
		}

		/* Put the object in the correct place */
		Error = AddObj( Curr, Res );
		if( Error != 0 )	goto ErrorExit;

		break;

	    /* This should never happen */
	    default :
		Error = IFFERR_MANGLED;
		goto ErrorExit;

	    }
	    break;

	case IFFERR_EOC :
	    /* Leaving FORM DR2D */

	    /* Pop the stack */
	    Curr = ObjStack;
	    if( ObjStack )	ObjStack = ObjStack->Next;

	    NestLevel--;

	    if( !Curr )	 break;

	    if( Curr->Type == ID_FILL ) {
		/* Define the fill */
		Error = DefineFill( Curr, Res );
		if( Error != 0 )	goto ErrorExit;

	    }
	    else {
		Error = AddObj( Curr, Res );
		if( Error != 0 )	goto ErrorExit;
	    }
	    break;

	default :
	    /* Error reading the file */
	    goto ErrorExit;
	}
    } while( NestLevel );

    /* Get the final attributes */
    Drhd = FindProp( IFF, ID_DR2D, ID_DRHD );
    if( !Drhd ) {
	Error = IFFERR_MANGLED;
	goto ErrorExit;
    }
    DRHDdata = (struct DRHDstruct *)Drhd->sp_Data;
    ieee2flt( &DRHDdata->UL_X, &Res->UL_X );
    ieee2flt( &DRHDdata->UL_Y, &Res->UL_Y );
    ieee2flt( &DRHDdata->LR_X, &Res->LR_X );
    ieee2flt( &DRHDdata->LR_Y, &Res->LR_Y );

    *Conts = Res;
    return 0;

    /************* Error exit *****************/
ErrorExit :
    if( Res )			free( Res );

    *Conts = 0;
    return Error;
}


static struct Obj2D *MakeObj(	struct IFFhandle *IFF,
				struct ContextNode *Chunk	)
{
    struct Obj2D
	*Res;
    struct StoredProperty
	*Bbox,
	*Attr;
    struct BBOXstruct
	*BBOXdata;

    Res = malloc( sizeof( struct Obj2D ) );
    if( !Res ) {
	return 0;
    }

    Res->Type = Chunk->cn_ID;

    Bbox = FindProp( IFF, ID_DR2D, ID_BBOX );
    if( Bbox ) {
	BBOXdata = (struct BBOXstruct *)Bbox->sp_Data;
	ieee2flt( &BBOXdata->XMin, &Res->XMin );
	ieee2flt( &BBOXdata->YMin, &Res->YMin );
	ieee2flt( &BBOXdata->XMax, &Res->XMax );
	ieee2flt( &BBOXdata->YMax, &Res->YMax );
    }
    else {
	Res->XMin = Res->YMin = Res->XMax = Res->YMax = 0;
    }

    Attr = FindProp( IFF, ID_DR2D, ID_ATTR );
    if( Attr ) {
	Res->Attrs = *(struct ATTRstruct *)Attr->sp_Data;
	ieee2flt( &Res->Attrs.EdgeThick, &Res->Attrs.EdgeThick );
    }
    else {
	Res->Attrs.FillType = FT_NONE;
	Res->Attrs.JoinType = JT_NONE;
	Res->Attrs.EdgePattern = 0;
	Res->Attrs.ArrowHeads = 0;
	Res->Attrs.FillValue = 0;
	Res->Attrs.EdgeValue = 0;
	Res->Attrs.WhichLayer = 0;
	Res->Attrs.EdgeThick = 0;	/* 0 must always be 0! */
    }

    Res->Next = 0;

    return Res;
}


static int ReadPOLY( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	i, n,
	Error;
    Coord
	*Pts;
    
    Error = ReadChunkRecords( IFF, &Data,
				sizeof(struct POLYstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }
    Obj->Data.POLYdata.NumPoints = n = Data.POLYdata.NumPoints;

    Obj->Data.POLYdata.Coords = Pts = malloc( n * 2 * sizeof(Coord) );
    if( !Pts ) {
	return IFFERR_NOMEM;
    }

    Error = ReadChunkRecords( IFF, Pts, n*2*sizeof(Coord), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Convert from IEEE to internal form */
    for( i = 0; i < n; i++ ) {
	if( ((long *)Pts)[2*i] == DR2D_IND ) {
	    ((long *)Pts)[2*i] = FLT_IND;
	}
	else {
	    ieee2flt( (long *)Pts + 2*i, Pts + 2*i );
	    ieee2flt( (long *)Pts + 2*i + 1, Pts + 2*i + 1 );
	}
    }
    return 0;
}


static int ReadTPTH( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	i, n,
	Error;
    char
	c, *s;
    Coord
	*Pts;

    /* Read TPTH information */
    Error = ReadChunkRecords( IFF, &Data, sizeof(struct TPTHstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Read text string */
    Obj->Data.TPTHdata.WhichFont = Data.TPTHdata.WhichFont;
    Obj->Data.TPTHdata.NumChars = n = Data.TPTHdata.NumChars;
    Obj->Data.TPTHdata.String = s = malloc( n );
    if( !s ) {
	return IFFERR_NOMEM;
    }
    Error = ReadChunkRecords( IFF, s, n, 1 );
    if( Error != 1 ) {
	return Error;
    }
    /* Read pad byte, if needed */
    if( n & 1 ) {
	Error = ReadChunkRecords( IFF, &c, 1, 1 );
	if( Error != 1 )	return Error;
    }


    /* Read text path */
    Obj->Data.TPTHdata.NumPath = n = Data.TPTHdata.NumPoints;
    Obj->Data.TPTHdata.Path = Pts = malloc( n * 2 * sizeof(Coord) );
    if( !Pts ) {
	return IFFERR_NOMEM;
    }
    Error = ReadChunkRecords( IFF, Pts, n*2*sizeof(Coord), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Convert from IEEE to internal form */
    ieee2flt( &Data.TPTHdata.CharW, &Obj->Data.TPTHdata.Width );
    ieee2flt( &Data.TPTHdata.CharH, &Obj->Data.TPTHdata.Height );

    for( i = 0; i < n; i++ ) {
	if( ((long *)Pts)[2*i] == DR2D_IND ) {
	    ((long *)Pts)[2*i] = FLT_IND;
	}
	else {
	    ieee2flt( (long *)Pts + 2*i, Pts + 2*i );
	    ieee2flt( (long *)Pts + 2*i + 1, Pts + 2*i + 1 );
	}
    }
    return 0;
}


static int ReadSTXT( struct IFFhandle *IFF, struct Obj2D *Obj )
{
    int
	n,
	Error;
    char
	*s;

    /* Read STXT information */
    Error = ReadChunkRecords( IFF, &Data, sizeof(struct STXTstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Read text string */
    Obj->Data.STXTdata.WhichFont = Data.STXTdata.WhichFont;
    Obj->Data.STXTdata.NumChars = n = Data.STXTdata.NumChars;
    Obj->Data.STXTdata.String = s = malloc( n );
    if( !s ) {
	return IFFERR_NOMEM;
    }
    Error = ReadChunkRecords( IFF, s, n, 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Convert from IEEE to internal form */
    ieee2flt( &Data.STXTdata.CharW, &Obj->Data.STXTdata.Width );
    ieee2flt( &Data.STXTdata.CharH, &Obj->Data.STXTdata.Height );
    ieee2flt( &Data.STXTdata.BaseX, &Obj->Data.STXTdata.XPos );
    ieee2flt( &Data.STXTdata.BaseY, &Obj->Data.STXTdata.YPos );
    ieee2flt( &Data.STXTdata.Rotation, &Obj->Data.STXTdata.Rotation );

    return 0;
}


static int ReadVBM(	struct IFFhandle *IFF,
			struct ContextNode *Chunk,
			struct Obj2D *Obj	)
{
    int
	n, Bytes,
	Error;
    char
	*s;

    /* Read VBM information */
    Error = ReadChunkRecords( IFF, &Data, sizeof(struct VBMstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Kludge to get around ProVector 2.0 erroneous writing of VBM chunks */
    n = Bytes = Data.VBMdata.PathLen;
    if( (Chunk->cn_Size - Chunk->cn_Scan) < n ) {
	Bytes = Chunk->cn_Size - Chunk->cn_Scan;
    }

    /* Read path to bitmap */
    Obj->Data.VBMdata.PathLen = n;
    Obj->Data.VBMdata.Path = s = malloc( n );
    if( !s ) {
	return IFFERR_NOMEM;
    }

    Error = ReadChunkRecords( IFF, s, Bytes, 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Make sure string is null terminated; gets around PV2.0 bug */
    s[n-1] = 0;

    /* Convert from IEEE to internal form */
    ieee2flt( &Data.VBMdata.XPos, &Obj->Data.VBMdata.XPos );
    ieee2flt( &Data.VBMdata.YPos, &Obj->Data.VBMdata.YPos );
    ieee2flt( &Data.VBMdata.XSize, &Obj->Data.VBMdata.Width );
    ieee2flt( &Data.VBMdata.YSize, &Obj->Data.VBMdata.Height );
    ieee2flt( &Data.VBMdata.Rotation, &Obj->Data.VBMdata.Rotation );

    return 0;
}



static int ReadDASH( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i, n, m,
	Error;
    Coord
	*Pts;

    Error = ReadChunkRecords( IFF, &Data, sizeof(struct DASHstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    n = Data.DASHdata.DashID;
    if( n >= Conts->MaxDash ) {
	/* Extend the dash table */
	if( Conts->MaxDash ) {
	    Conts->MaxDash *= 2;
	    m = Conts->MaxDash;
	    Conts->DashCounts = realloc( Conts->DashCounts, m * sizeof(int) );
	    Conts->DashPatts = realloc( Conts->DashPatts, m * sizeof(Coord *) );
	}
	else {
	    Conts->MaxDash = m = 2;
	    Conts->DashCounts = malloc( m * sizeof(int) );
	    Conts->DashPatts = malloc( m * sizeof(Coord *) );
	}

	if( !Conts->DashCounts || !Conts->DashPatts ) {
	    return IFFERR_NOMEM;
	}

	/* Initialize the dash lists */
	for( i = Conts->NumDash; i < m; i++ ) {
	    Conts->DashCounts[i] = 0;
	    Conts->DashPatts[i] = 0;
	}
    }

    if( n >= Conts->NumDash ) {
	Conts->NumDash = n + 1;
    }

    /* Read the dash pattern */
    Conts->DashCounts[n] = i = Data.DASHdata.NumDashes;

    if( i ) {
	/* Note that a count of 0 is possible here! */
	Conts->DashPatts[n] = Pts = malloc( i * sizeof(Coord) );
	if( !Pts ) {
	    return IFFERR_NOMEM;
	}
	Error = ReadChunkRecords( IFF, Pts, i * sizeof(Coord), 1 );
	if( Error != 1 ) {
	    return Error;
	}

	/* Convert to internal numeric rep */
	for( i--; i >= 0; i-- ) {
	    ieee2flt( Pts + i, Pts + i );
	}
    }

    return 0;
}



static int ReadLAYR( struct IFFhandle *IFF, struct Proj2D *Conts )
{
    int
	i, n, m,
	Error;

    Error = ReadChunkRecords( IFF, &Data, sizeof(struct LAYRstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    n = Data.LAYRdata.LayerID;
    if( n >= Conts->MaxLayer ) {
	/* Extend the layer table */
	if( Conts->MaxLayer ) {
	    Conts->MaxLayer *= 2;
	    m = Conts->MaxLayer;
	    Conts->LayerTable = realloc( Conts->LayerTable,
					m * sizeof(struct LAYRstruct) );
	    Conts->Objects = realloc( Conts->Objects,
					m * sizeof(struct Obj2D *) );
	    Conts->LastObjs = realloc( Conts->LastObjs,
					m * sizeof(struct Obj2D *) );
	}
	else {
	    Conts->MaxLayer = m = 2;
	    Conts->LayerTable = malloc( m * sizeof(struct LAYRstruct) );
	    Conts->Objects = malloc( m * sizeof(struct Obj2D *) );
	    Conts->LastObjs = malloc( m * sizeof(struct Obj2D *) );
	}

	if( !Conts->LayerTable || !Conts->Objects || !Conts->LastObjs ) {
	    return IFFERR_NOMEM;
	}

	/* Initialize the layer lists */
	for( i = Conts->NumLayer; i < m; i++ ) {
	    Conts->Objects[i] = 0;
	    Conts->LastObjs[i] = 0;
	    Conts->LayerTable[i].LayerID = i;
	    Conts->LayerTable[i].LayerName[0] = 0;
	    Conts->LayerTable[i].Flags = 0;
	    Conts->LayerTable[i].Pad0 = 0;
	}
    }

    if( n >= Conts->NumLayer ) {
	Conts->NumLayer = n + 1;
    }

    /* Copy the pertinent data */
    Conts->LayerTable[n] = Data.LAYRdata;

    return 0;
}


static int ReadFONS(	struct IFFhandle *IFF,
			struct ContextNode *Chunk,
			struct Proj2D *Conts	)
{
    int
	i, n, m,
	Error;

    Error = ReadChunkRecords( IFF, &Data, sizeof(struct FONSstruct), 1 );
    if( Error != 1 ) {
	return Error;
    }

    n = Data.FONSdata.FontID;

    if( n >= Conts->MaxFont ) {
	/* Extend the layer table */
	if( Conts->MaxFont ) {
	    Conts->MaxFont *= 2;
	    m = Conts->MaxFont;
	    Conts->FontTable = realloc( Conts->FontTable,
					m * sizeof(struct FONSstruct) );
	    Conts->FontNames = realloc( Conts->FontNames,
					m * sizeof(char *) );
	}
	else {
	    Conts->MaxFont = m = 2;
	    Conts->FontTable = malloc( m * sizeof(struct FONSstruct) );
	    Conts->FontNames = malloc( m * sizeof(char *) );
	}

	if( !Conts->FontTable || !Conts->FontNames ) {
	    return IFFERR_NOMEM;
	}

	/* Initialize the font table */
	for( i = Conts->NumLayer; i < m; i++ ) {
	    Conts->FontTable[i].FontID = 0;
	    Conts->FontTable[i].Pad1 = 0;
	    Conts->FontTable[i].Proportional = 0;
	    Conts->FontTable[i].Serif = 0;
	    Conts->FontNames[i] = 0;
	}
    }

    if( Conts->NumFont >= n ) {
	Conts->NumFont = n + 1;
    }

    /* Read the font name */
    m = Chunk->cn_Size - Chunk->cn_Scan;
    Conts->FontTable[n] = Data.FONSdata;
    Conts->FontNames[n] = malloc( m );
    if( !Conts->FontNames[n] ) {
	return IFFERR_NOMEM;
    }

    Error = ReadChunkRecords( IFF, Conts->FontNames[n], m, 1 );
    if( Error != 1 ) {
	return Error;
    }

    return 0;
}


static int ReadCMAP(	struct IFFhandle *IFF,
			struct ContextNode *Chunk,
			struct Proj2D *Conts	)
{
    int
	i, n,
	Error;

    /* Allocate tables */
    Conts->NumColor = n = Chunk->cn_Size / 3;
    Conts->RGB_Table = malloc( n * 3 );
    Conts->CMYK_Table = malloc( n * 4 );
    Conts->CNAM_Table = malloc( n * sizeof(char *) );

    if( !Conts->RGB_Table || !Conts->CMYK_Table || !Conts->CNAM_Table ) {
	return IFFERR_NOMEM;
    }

    /* Read the RGB data */
    Error = ReadChunkRecords( IFF, Conts->RGB_Table, n * 3, 1 );
    if( Error != 1 ) {
	return Error;
    }

    /* Initialize the CMYK and CNAM tables */
    for( i = 0; i < n; i++ ) {
	Conts->CMYK_Table[4*i  ] = 255 - Conts->RGB_Table[3*i  ];
	Conts->CMYK_Table[4*i+1] = 255 - Conts->RGB_Table[3*i+1];
	Conts->CMYK_Table[4*i+2] = 255 - Conts->RGB_Table[3*i+2];
	Conts->CMYK_Table[4*i+3] = 0;
	Conts->CNAM_Table[i] = 0;
    }

    return 0;
}



static int AddObj( struct Obj2D *Obj, struct Proj2D *Conts )
{
    int
	n;

    Obj->Next = 0;

    if( NestLevel > 1 ) {
	/* Add the current object to a group, etc. */
	switch( ObjStack->Type ) {
	case ID_GRUP :
	    if( ObjStack->Data.GRUPdata.Tail ) {
		ObjStack->Data.GRUPdata.Tail->Next = Obj;
	    }
	    else {
		ObjStack->Data.GRUPdata.Objs = Obj;
	    }
	    ObjStack->Data.GRUPdata.Tail = Obj;
	    break;
	case ID_FILL :
	    ObjStack->Data.GRUPdata.Objs = Obj;
	    break;
	case ID_XTRN :
	    ObjStack->Data.XTRNdata.Obj = Obj;
	    break;
	}
    }
    else {
	/* Add it to the object table */
	n = Obj->Attrs.WhichLayer;
	if( n >= Conts->NumLayer ) {
	    return IFFERR_MANGLED;
	}
	if( Conts->LastObjs[n] ) {
	    Conts->LastObjs[n]->Next = Obj;
	}
	else {
	    Conts->Objects[n] = Obj;
	}
	Conts->LastObjs[n] = Obj;
    }

    return 0;
}


static int DefineFill( struct Obj2D *Obj, struct Proj2D *Conts )
{
    int
	i, n, m;

    n = Obj->Data.GRUPdata.NumObjs;

    if( n >= Conts->MaxFills ) {
	/* Extend the fill table */
	if( Conts->MaxFills ) {
	    Conts->MaxFills *= 2;
	    m = Conts->MaxFills;
	    Conts->FillTable = realloc( Conts->FillTable, m * sizeof(struct Obj2D *) );
	}
	else {
	    Conts->MaxFills = m = 2;
	    Conts->FillTable = malloc( m * sizeof(struct Obj2D *) );
	}
	if( !Conts->FillTable ) {
	    return IFFERR_NOMEM;
	}

	for( i = Conts->NumFills; i < m; i++ ) {
	    Conts->FillTable[i] = 0;
	}
    }

    if( Conts->NumFills >= n ) {
	Conts->NumFills = n + 1;
    }

    /* Save the fill pattern */
    Conts->FillTable[n] = Obj->Data.GRUPdata.Objs;

    /* Free this dummy object */
    free( Obj );

    return 0;
}


/*** EOF dr2dr.c ***/
