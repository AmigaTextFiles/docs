#include "iffp/obj2d.h"

/* This definition has to go somewhere so ReadDR2D can resolve it */
struct Library
    *IFFParseBase;

int main( int argc, char **argv )
{
    struct Proj2D
	*Conts;
    int
	Error;
    struct ParseInfo
	PI;

    /* Check the argument count */
    if( argc != 3 ) {
	fprintf( stderr, "Usage: %s src dst\n", argv[0] );
	fprintf( stderr, "	src and dst are files or -c for the clipboard\n" );
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

    Error = openifile( &PI, argv[2], IFFF_WRITE );
    if( Error ) {
	fprintf( stderr, "Can't open file %s\n", argv[2] );
	CloseLibrary( IFFParseBase );
	exit( 1 );
    }

    Error = WriteDR2D( &PI, Conts );
    closeifile( &PI );
    if( Error != 0 ) {
	fprintf( stderr, "Write error: %d\n", Error);
	CloseLibrary( IFFParseBase );
	exit( 1 );
    }

    FreeConts( Conts );
    CloseLibrary( IFFParseBase );
    exit( 0 );
}

/*** EOF test.c ***/
