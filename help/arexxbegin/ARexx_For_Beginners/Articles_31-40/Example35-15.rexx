/* Example35-15 */

TestSymbol = 'Joe Bloggs 99 Somewhere Street 123 4567'
PARSE VAR TestSymbol +31 Phone +8 -28 Address +19 -30 Name +10
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
