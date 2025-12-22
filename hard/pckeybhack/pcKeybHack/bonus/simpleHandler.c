/* Handler qui intercepte les codes rawkey 75 a 7c */

#include <stdlib.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <devices/input.h>
#include <intuition/intuition.h>
#include <devices/inputevent.h>
#include <clib/all_protos.h>

UBYTE NameString[]="Permutation";

struct NewWindow mywin={0,0,124,15,0,1,CLOSEWINDOW,
			WINDOWDRAG|WINDOWCLOSE|SIMPLE_REFRESH|NOCAREREFRESH,
			NULL,NULL,NameString,NULL,NULL,0,0,0,0,WBENCHSCREEN};



extern struct IntuitionBase *IntuitionBase;

struct InputEvent *interceptRawKey( __A0 struct InputEvent *, __A1 APTR );


/*
 * Cette routine ouvre une fenêtre est attend le seul évènement possible
 * (CLOSEWINDOW). C'est simplement pour que l'utilisateur puisse jouer avec
 * les touches, et, quitter le programmme en cliquant...
 */

VOID WaitForUser(VOID)
{
struct Window  *win;

    if (IntuitionBase=(struct IntuitionBase *)
				    OpenLibrary("intuition.library",0L))
    {
	if (win=OpenWindow(&mywin))
	{
	    WaitPort(win->UserPort);
	    ReplyMsg(GetMsg(win->UserPort));

	    CloseWindow(win);
	}
	CloseLibrary((struct Library *)IntuitionBase);
    }
}

/*
    Routine handler qui intercepte certains codes Raw pour les changer par d'autres
    Cette routine récupère les paramètres:
	even list dans A0
	is_data   dans A1
    ET NON PAS DANS LA PILE !!!!!!
*/


struct InputEvent *interceptRawKey( inputPasse, data )
__A0 struct InputEvent *inputPasse;
__A1 APTR data;
{

    struct InputEvent *inputDonne;

	/*
	On peut recevoir une liste input event. Alors on entâme une boucle
	pour scruter cette liste. Cette liste étant unidirectionnelle, le
	chaînage ce fait uniquement a l'aide de ie_NextEvent.
	Le champ is_data n'est ici pas utilisé.
	*/
    inputDonne = inputPasse;
    do
    {

	  /* Permutation subtile voir inputEvent.h ! */

	if ( inputDonne->ie_Class == IECLASS_RAWKEY )
	{
	    switch(inputDonne->ie_Code)
		{
			/* home devient 5 ... etc */
			case 0x75 : inputDonne->ie_Code = 0x2e;
			break;
			case 0x76 : inputDonne->ie_Code = 0x2f;
			break;
			case 0x77 : inputDonne->ie_Code = 0x3d;
			break;
			case 0x78 : inputDonne->ie_Code = 0x3e;
			break;
			case 0x79 : inputDonne->ie_Code = 0x3f;
			break;
			case 0x7a : inputDonne->ie_Code = 0x10;
			break;
			case 0x7b : inputDonne->ie_Code = 0x35;
			break;
			case 0x7c : inputDonne->ie_Code = 0x33;

		}
	}

	    /* Y-a-t-il un autre input event ? */

	if ( inputDonne->ie_NextEvent != NULL )
	    inputDonne = inputDonne->ie_NextEvent;
	else
	    break;

    } while ( 1 ) ;


	/* Permet de passer l'input event aux autres handler */
    return (inputPasse);
}


main(void)
{
struct IOStdReq  *inputReqBlk;
struct MsgPort	 *inputPort;
struct Interrupt *inputHandler;
APTR donnees;

    if (inputPort = CreatePort(NULL,0L))
    {
		if (inputHandler = AllocMem( sizeof(struct Interrupt),
						    MEMF_PUBLIC|MEMF_CLEAR))
		{
	    	if (inputReqBlk = (struct IOStdReq *)CreateExtIO(inputPort,
						  sizeof(struct IOStdReq)))
	    	{
				if (!OpenDevice( "input.device", 0L,
				 (struct IORequest *)inputReqBlk, 0L ))
				{
		    		inputHandler->is_Code	  = interceptRawKey;
		    		inputHandler->is_Data	  = donnees;
		    		inputHandler->is_Node.ln_Pri  = 51;
		    		inputHandler->is_Node.ln_Name = NameString;

					/* Mise en place du handler */

		    		inputReqBlk->io_Data    = (APTR)inputHandler;
		    		inputReqBlk->io_Command = IND_ADDHANDLER;

		    		DoIO( (struct IORequest *)inputReqBlk );

		    		WaitForUser();

		       		/* Supprime le handler */

		    		inputReqBlk->io_Data    = (APTR)inputHandler;
		    		inputReqBlk->io_Command = IND_REMHANDLER;

		    		DoIO( (struct IORequest *)inputReqBlk );

		    		CloseDevice( (struct IORequest *)inputReqBlk );
				}
				DeleteExtIO( (struct IORequest *)inputReqBlk );
	    	}
	    	FreeMem( inputHandler,sizeof(struct Interrupt) );
		}
		DeletePort( inputPort );
    }
	exit(0);
}

