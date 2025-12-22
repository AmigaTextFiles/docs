
/* *** strings.c ************************************************************
 *
 * String Manipulation Routines
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 *
 * CONFIDENTIAL and PROPRIETARY
 *
 * HISTORY      NAME            DESCRIPTION
 * -----------  --------------  --------------------------------------------
 * 4 Feb 87     RJ              Real release
 * 2 Feb 87     RJ              Added StripOuterSpace()
 * 16 May 86    RJ              Just more stuff
 * 1 June 1985  =RJ Mical=      Created this file from a weird distant echo.
 *
 * *********************************************************************** */


#include "exec/types.h"

#define FOREVER for(;;)


/* copy these and define them as 'extern' in your global include file 
 * in order to use these routines in your code.
 */
SHORT CompareUpperStrings();
UBYTE *FindSuffix();
SHORT GetAtom();
SHORT IndexString();
SHORT StringLength();
BOOL StringsEqual();
UBYTE *StripLeadingSpace();
UBYTE *StripOuterSpace();



SHORT CompareUpperStrings(s, t)
UBYTE *s, *t;
/* Compare s to t, making alphabet characters uppercase.  Return value:
 *  	s < t 		-1
 *  	s == t 		 0
 *  	s > t 		 1
 */
{
	SHORT sc, tc;

	FOREVER
		{
		sc = *s++;
		if ((sc >= 'a') && (sc <= 'z')) sc = sc - 'a' + 'A';
		tc = *t++;
		if ((tc >= 'a') && (tc <= 'z')) tc = tc - 'a' + 'A';

		if (sc < tc) return(-1);
		if (sc > tc) return(1);
		if (sc == '\0') return(0);
		}
	return(0);
}



VOID CopyString(tostring, fromstring)
UBYTE *tostring, *fromstring;
{
	while (*tostring++ = *fromstring++) ;
}



VOID ConcatString(firststring, addstring)
UBYTE *firststring, *addstring;
{
	SHORT length1;

	length1 = StringLength(firststring);
	firststring += length1;
	CopyString(firststring, addstring);
}



UBYTE *FindSuffix(string, suffix)
UBYTE *string;
UBYTE *suffix;
{
	SHORT stringlength, suffixlength;

	if ( (stringlength = StringLength(string))
			>= (suffixlength = StringLength(suffix)) )
		{
		if (StringsEqual(string + stringlength - suffixlength, suffix))
			return (string + stringlength - suffixlength);
		}
	return(NULL);
}



SHORT IndexString(lookin, lookfor)
UBYTE *lookin, *lookfor;
/* This routines looks in the lookin string for the lookfor string.
 * Returns the position of the lookfor string in lookin, or
 * returns -1 if the lookfor string was not found.
 */
{
	SHORT index;
	UBYTE *workin, *workfor;

	index = 0;

	while (*lookin)
		{
		workin = lookin;
		workfor = lookfor;
		while ((*workfor) && (*workin) && (*workfor == *workin))
			{
			workfor++;
			workin++;
			}
		if (*workfor == '\0') return(index);
		lookin++;
		index++;
		}

	return(-1);
}



SHORT StringLength(text)
UBYTE *text;
{
	SHORT length;

	length = 0;
	while (*text++) length++;
	return(length);
}



BOOL StringsEqual(text1, text2)
UBYTE *text1, *text2;
{
	while (*text1 == *text2)
		{
		if (*text1 == '\0') return(TRUE);
		text1++;
		text2++;
		}

	return(FALSE);
}



UBYTE *StripLeadingSpace(text, space)
UBYTE *text, *space;
/* This routine "strips" the leading occurrences of the space string
 * characters from the text string by finding the first character
 * of the text string that is not contained in the space string.
 * The return value is a pointer to the first non-space character in text.
 * If text is the null string or if text consists of nothing
 * but space characters, NULL is returned.
 * If space is the NULL string, text is returned.
 */
{
	if (space == NULL) return(text);
	if (*space == '\0') return(text);

	while (*text && (*text == *space)) text++;

	if (*text) return(text);
	return(NULL);
}



UBYTE *StripOuterSpace(text, space)
UBYTE *text, *space;
/* This routine "strips" the leading and trailing occurrences of the space 
 * string characters from the text string.
 * The return value is a pointer to the first non-space character in text,
 * and a null byte is stored after the text's last non-space character.
 */
{
	UBYTE *workspace, *lastspace;

	if (text == NULL) return(NULL);

	if ((workspace = StripLeadingSpace(text, space)) == NULL)
		{
		*text = '\0';
		return(text);
		}

	lastspace = workspace + StringLength(workspace) - 1;
	while ((lastspace >= workspace) && (*lastspace == *space)) lastspace--;
	*(lastspace + 1) = '\0';
	return(workspace);
}



