/*

						LCDaemon	©1995-97 VOMIT,inc.
						Email: hendrik.devloed@barco.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

/*	LCD object methods for driver writers	*/

/********************	The error codes to return to LCDaemon	*/

#define	LCDOMERR_FALSE	0	/*	BOOL FALSE return value	*/
#define	LCDOMERR_TRUE		1	/*	BOOL TRUE return value	*/
#define	LCDOMERR_OK		2	/*	Method accepted.	*/
#define	LCDOMERR_UNKNOWN	3	/*	Unknown command received	*/
#define	LCDOMERR_QUIT		4	/*	method=LCDOM_USERMESSAGE: request to quit LCDaemon	*/

/********************	The values of the method parameter.
**	The necessity for implementation is specified between parentheeses. If a
**	unimplemented method is called, LCDOMERR_UNKNOWN must be returned.
*/

/*
**	Query the library compliance level. The library version number corresponds with the
**	LCDaemon version number times 10 plus the revision. As the external library concept
**	has been introduced as of LCDaemon V2.2, the library should return 22. The
**	parameter is an (ULONG *) to store the version in. This implies revisions run from 0-9 only!
*/
#define	LCDOM_LIBVERSION		1	/*	(optional)	*/
/*
**	Query the library defined message port, if any. By doing this the library can have its
**	own port included in the main signal processing loop. The parameter value is
**	the struct MsgPort **) to store the library's port in.
*/
#define	LCDOM_GETUSERPORT	2	/*	(optional)	*/
/*
**	If the library's message port is present, this method will be called whenever a
**	message arrives. The param value is the (struct Message *) that arrived.
*/
#define	LCDOM_USERMESSAGE	3	/*	(required if LCDOM_GETUSERPORT is defined)	*/

