    /* Example51-2.rexx */

/*
 * A demonstration set of programs to be run from Amigaguide/Multiview
 * with both STDIN and STDOUT streams
 */

Clear = 'c'x
Down  = 'a'x

SAY Clear'This is an ARexx program started from Amigaguide/Multiview'
SAY 'by way of:-'
SAY Down'   * A link command in Amigaguide/Multiview to run an'
SAY '     ARexx program that calls:-'
SAY Down'   * An AmigaDOS script that calls:-'
SAY Down'   * This ARexx program.'
SAY Down'It has a STDOUT stream as demonstrated by the fact you are'
SAY 'reading this!'
SAY Down'It has a STDIN stream as demonstrated by you entering some'
SAY 'text here:-'Down
PARSE PULL Text
SAY Down'The text you entered was:-'
SAY Down||Text
SAY Down'Press RETURN to end this program'
PULL Anything
ADDRESS 'COMMAND' 'EndCLI'
