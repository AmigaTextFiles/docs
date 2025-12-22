
/* *** hsl.c ****************************************************************
 *
 * ColorWindow Routine  --  HSL Translation Routines
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Any or all of this code can be used in any program as long as this
 * entire copyright notice is retained, ok?  Thanks.
 *
 * The Amiga Programmer's Suite Book 1 is copyrighted but freely distributable.
 * All copyright notices and all file headers must be retained intact.
 * The Amiga Programmer's Suite Book 1 may be compiled and assembled, and the 
 * resultant object code may be included in any software product.  However, no 
 * portion of the source listings or documentation of the Amiga Programmer's 
 * Suite Book 1 may be distributed or sold for profit or in a for-profit 
 * product without the written authorization of the author, RJ Mical.
 * 
 * HISTORY      NAME            DESCRIPTION
 * -----------  --------------  --------------------------------------------
 * 3 Jan 87     RJ >:-{)*       Clean-up for release      
 * 27 Feb 86    =RJ Mical=      Modified these routines for Zaphod
 * January 86   =RJ=            Modified the originals for Mandelbrot
 * Late 85      =RJ=            Created the color window for Graphicraft
 *
 * *********************************************************************** */


#include "color.h"


SHORT HSLToRGB(hue, saturation, luminance)
USHORT hue, saturation, luminance;
/* This actually doesn't do true HSL to RGB conversion, but it works
 * close enough.  Also, this code could be optimized quite a bit, but
 * I've left it spread out like this so that several years from now 
 * I will be able to figure out what the heck is going on.
 */
{
	LONG red, green, blue;
	LONG reddiff, greendiff, bluediff;
	LONG sixth, rising, falling, invertsaturation;

	/* We're going to hold one color off, a second at full, and ramp  
	 * the third.  This allows us to visit all two-color combinations.
	 * By modifying saturation, all three-color combinations can be seen.
	 */
	sixth = hue / 0x2AAB;
	rising = (hue - (sixth * 0x2AAB)) * 6;
	falling = 0xFFFF - rising;

	switch (sixth)
		{
		case 0:
			red = 0xFFFF;
			green = rising;
			blue = 0;
			break;
		case 1:
			red = falling;
			green = 0xFFFF;
			blue = 0;
			break;
		case 2:
			red = 0;
			green = 0xFFFF;
			blue = rising;
			break;
		case 3:
			red = 0;
			green = falling;
			blue = 0xFFFF;
			break;
		case 4:
			red = rising;
			green = 0;
			blue = 0xFFFF;
			break;
		case 5:
			red = 0xFFFF;
			green = 0;
			blue = falling;
			break;
		}

	red = (red * luminance) >> 16;
	green = (green * luminance) >> 16;
	blue = (blue * luminance) >> 16;

	/* The closer saturation is to zero, the closer red, green and blue should
	 * be to luminance.
	 */
	invertsaturation = 0xFFFF - saturation;
	reddiff = luminance - red;
	red = red + ((reddiff * invertsaturation) >> 16);
	greendiff = luminance - green;
	green = green + ((greendiff * invertsaturation) >> 16);
	bluediff = luminance - blue;
	blue = blue + ((bluediff * invertsaturation) >> 16);

	red = (red >> 12) & 0xF;
	green = (green >> 12) & 0xF;
	blue = (blue >> 12) & 0xF;

	return( (SHORT)((red << 8) | (green << 4) | (blue)) );
}



VOID RGBToHSL(rgb, returnhue, returnsat, returnlum)
USHORT rgb;
USHORT *returnhue, *returnsat, *returnlum;
{
	LONG min, max, hue, saturation, luminance, differential;
	LONG redpart, greenpart, bluepart;
	LONG workred, workgreen, workblue;

	workred = ((rgb >> 8) & 0xF) * 0x111;
	workgreen = ((rgb >> 4) & 0xF) * 0x111;
	workblue = (rgb & 0xF) * 0x111;

	if (workred < workgreen) min = workred;
	else min = workgreen;
	if (workblue < min) min = workblue;

	if (workred > workgreen) max = workred;
	else max = workgreen;
	if (workblue > max) max = workblue;

	luminance = max;
	luminance <<= 4;
	differential = max - min;

	if (max != 0)
		{
		saturation = (differential << 16) / max;
		if (saturation > 0xFFFF) saturation = 0xFFFF;
		}
	else 
		saturation = 0;

	if (saturation == 0)
		hue = 0;
	else
		{
		redpart = (((max - workred) << 16) / differential) >> 4;
		greenpart = (((max - workgreen) << 16) / differential) >> 4;
		bluepart = (((max - workblue) << 16) / differential) >> 4;

		if (workred == max) hue = bluepart - greenpart;
		else if (workgreen == max) hue = 0x2000 + redpart - bluepart;
		else if (workblue == max) hue = 0x4000 + greenpart - redpart;
		if (hue < 0) hue += 0x6000;
		hue = (hue * 2667) / 1000;
		}

	*returnhue = hue;
	*returnsat = saturation;
	*returnlum = luminance;
}





