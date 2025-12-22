/*	Routines to convert to and from IEEE single precision
 *	numbers.  These use no floating point operations; rather,
 *	they do bit-twiddling to do their work.
 *
 *	Ross Cunniff, Stylus, Inc. September 22, 1991
 */

#include "iffp/obj2d.h"

void ieee2flt( long *ieee, Coord *flt )
{
#ifdef FLT_COORD
    *flt = *(Coord *)ieee;
#else
    union {
	long
	    Number;
	struct {
	    unsigned
		Sign : 1,
		Exp  : 8,
		Mant : 23;
	}   Bits;
    }   IeeeBits;

    long
	RealMant,
	RealExp;

    IeeeBits.Number = *ieee;
    RealExp = IeeeBits.Bits.Exp;

    if( RealExp ) {
	RealExp -= 127;		/* Exponent biased by 127 */
	RealExp += FIXOFFS; 	/* FIXOFFS digit accuracy */
	RealExp -= 23;		/* Originally 23 digit accuracy */

	if( RealExp < 0 ) {
	    RealMant = (0x00800000 | IeeeBits.Bits.Mant) >> -RealExp;
	}
	else {
	    RealMant = (0x00800000 | IeeeBits.Bits.Mant) << RealExp;
	}

	if( IeeeBits.Bits.Sign ) {
	    RealMant = -RealMant;
	}
    }
    else {
	RealMant = 0;
    }

    *flt = RealMant;
#endif
}


void flt2ieee( Coord *flt, long *ieee )
{
#ifdef FLT_COORD
    *ieee = *(long *)flt;
#else
    union {
	long
	    Number;
	struct {
	    unsigned
		Sign : 1,
		Exp  : 8,
		Mant : 23;
	}   Bits;
    }   IeeeBits;

    long
	RealMant,
	RealMask,
	RealExp;

    RealMant = *flt;

    if( RealMant ) {
	/* Get the sign */
	if( RealMant < 0 ) {
	    IeeeBits.Bits.Sign = 1;
	    RealMant = -RealMant;
	}
	else {
	    IeeeBits.Bits.Sign = 0;
	}

	/* Get the exponent */
	for(	RealMask = 0x40000000, RealExp = 31;
		RealMask;
		RealMask >>= 1, RealExp-- )
	{
	    if( RealMant & RealMask )	break;
	}

	if( RealExp > 24 ) {
	    RealMant >>= RealExp - 24;
	}
	else {
	    RealMant <<= 24 - RealExp;
	}
	RealExp -= FIXOFFS;
	RealExp += 126;

	IeeeBits.Bits.Mant = RealMant & 0x007FFFFF;
	IeeeBits.Bits.Exp = RealExp;
	*ieee = IeeeBits.Number;
    }
    else {
	*ieee = 0;
    }
#endif
}

/* Free all memory associated with an object */
void FreeObj( struct Obj2D *Obj )
{
    struct Obj2D
	*Curr, *Next;

    switch( Obj->Type ) {
    case ID_CPLY :	case ID_OPLY :
	free( Obj->Data.POLYdata.Coords );
	break;
    case ID_TPTH :
	free( Obj->Data.TPTHdata.String );
	free( Obj->Data.TPTHdata.Path );
	break;
    case ID_STXT :
	free( Obj->Data.STXTdata.String );
	break;
    case ID_GRUP :
	for( Curr = Obj->Data.GRUPdata.Objs; Curr; Curr = Next ) {
	    Next = Curr->Next;
	    FreeObj( Curr );
	}
	break;
    case ID_XTRN :
	FreeObj( Obj->Data.XTRNdata.Obj );
	break;
    case ID_VBM :
	free( Obj->Data.VBMdata.Path );
	break;
    }
    free( Obj );
}


/* Free all memory associated with a DR2D file contents */
void FreeConts( struct Proj2D *Conts )
{
    int
	i;
    struct Obj2D
	*Curr, *Next;

    if( Conts->MaxFont ) {
	free( Conts->FontTable );
	for( i = 0; i < Conts->MaxFont; i++ ) {
	    if( Conts->FontNames[i] )	free( Conts->FontNames[i] );
	}
	free( Conts->FontNames );
    }

    if( Conts->MaxDash ) {
	free( Conts->DashCounts );
	for( i = 0; i < Conts->MaxDash; i++ ) {
	    if( Conts->DashPatts[i] )	free( Conts->DashPatts[i] );
	}
	free( Conts->DashPatts );
    }

    if( Conts->NumColor ) {
	free( Conts->RGB_Table );
	free( Conts->CMYK_Table );
	for( i = 0; i < Conts->NumColor; i++ ) {
	    if( Conts->CNAM_Table[i] )	free( Conts->CNAM_Table[i] );
	}
	free( Conts->CNAM_Table );
    }

    if( Conts->MaxFills ) {
	for( i = 0; i < Conts->MaxFills; i++ ) {
	    if( Conts->FillTable[i] )	FreeObj( Conts->FillTable[i] );
	}
	free( Conts->FillTable );
    }

    if( Conts->MaxLayer ) {
	free( Conts->LayerTable );
	free( Conts->LastObjs );
	for( i = 0; i < Conts->MaxLayer; i++ ) {
	    for( Curr = Conts->Objects[i]; Curr; Curr = Next ) {
		Next = Curr->Next;
		FreeObj( Curr );
	    }
	}
    }

    free( Conts );
}


/*** EOF util.c ***/
