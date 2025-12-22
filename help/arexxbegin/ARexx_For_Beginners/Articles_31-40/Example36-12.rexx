/* Example36-12 */

PARSE NUMERIC Digits Fuzz Form .
SAY 'Default Digits setting =' Digits
SAY 'Default Fuzz   setting =' Fuzz
SAY 'Default Form   setting =' Form

NUMERIC DIGITS 5
NUMERIC FUZZ 3
NUMERIC FORM Engineering

PARSE NUMERIC Digits Fuzz Form .
SAY 'New Digits setting =' Digits
SAY 'New Fuzz   setting =' Fuzz
SAY 'New Form   setting =' Form

