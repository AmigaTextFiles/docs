/* Example15-3.rexx */

/* Illustration of using escape sequences in SAY instructions */

/* Miscellaneous Codes */

Clear = 'c'x       /* Clears window & resets all modes to defaults */
LFeed = 'a'x       /* line feed to give blank line */
Esc   = '1b'x      /* Escape code */
Reset = Esc'[0m'   /* Resets graphics modes to defaults */

/* Text Styles */

Bold      = Esc'[1m'  /* Boldface on */
Italics   = Esc'[3m'  /* Italics on  */
Underline = Esc'[4m'  /* Underline on */
Reverse   = Esc'[7m'  /* Reverse Video on */

/* Text Colours */

TCol0  = Esc'[30m'     /* Text Colour 0 */
TCol1  = Esc'[31m'     /* Text Colour 1 */
TCol2  = Esc'[32m'     /* Text Colour 2 */
TCol3  = Esc'[33m'     /* Text Colour 3 */

/* Background Colours */

BCol0  = Esc'[40m'     /* Background Colour 0 */
BCol1  = Esc'[41m'     /* Background Colour 1 */
BCol2  = Esc'[42m'     /* Background Colour 2 */
BCol3  = Esc'[43m'     /* Background Colour 3 */

SAY Clear||LFeed||CENTRE(Bold||Underline'MY HEADING IS BOLD AND UNDERLINED'Reset,80)
SAY LFeed||Italics||BCol2||TCol3'I am in italics with background colour 2 and text colour 3'Reset
SAY LFeed||TCol2||BCol1'I am in text colour 2, background colour 1'
SAY LFeed||TCol2||BCol1||reverse'I am in text colour 2, background colour 1 and in reverse video.'
SAY 'Because it is reverse video the text colour surrounds the text  '
SAY 'and the background colour comes through the letters.           ' Reset
