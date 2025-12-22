/* -------------------------------------------------------------------------- */
/* Using PAR: as a ~VOLUME~ in write mode to send 8 bit binary data, from a   */
/* ~user buffer~, to the parallel port without needing any knowledge of the   */
/* parallel port direct access of the hardware or device offsets at all.      */
/* Original copyright goes to (C)2006, B.Walker, G0LCU, (now Public Domain).  */
/* Compiled under Dice-C V3.16, from the CLI/Shell prompt.                    */
/* Use "dcc -o PAR_Write_Single PAR_Write_Single.c" without the quotes inside */
/* the Shell. This requires NO special compiler directives.                   */
/* There are NO prototype(s), define(s) or struct(ures) in this code at all.  */
/* -------------------------------------------------------------------------- */
/* Now tested with the vbccm68k V0.810 C compiler, from the CLI/Shell prompt. */
/* Use "vc PAR_Write_Single.c" without the quotes inside the Shell to give a  */
/* running file ~a.out~.                                                      */
/* -------------------------------------------------------------------------- */
/* This extremely simple source sends a single 8 bit byte to the parallel     */
/* port and holds it there until the ~BUSY~ line pin 11 is grounded, (pulled  */
/* to the 0 Volt rail). The ~-ACK~ line is NOT used for a single byte send so */
/* it can be ignored. Decimal value 170 is used as a test, binary 10101010.   */
/* -------------------------------------------------------------------------- */

/* Standard includes. */
#include <stdio.h>

/* Main program start. */
main()
{
	/* Variable list. */
	void *par_in_write_mode;
	/* Set the binary byte to 10101010, decimal 170. */
	unsigned char byteval = 170;

	/* Print the value to the screen. */
	printf("Value of character written is:- %u.\n", byteval);

	/* Open the parallel port in PAR: ~volume~, write mode. */
	par_in_write_mode = fopen("PAR:", "wb");

	/* Write the byte to the ~port~. */
	fwrite(&byteval, 1, 1, par_in_write_mode);

	/* Immediately close the opened PAR: ~volume~ WHEN pin 11 */
	/* of the parallel port is grounded. */
	fclose(par_in_write_mode);

	/* Ensure a successful return code of 0. */
	return(0);
}
/* Can it be any simpler I wonder?... */
