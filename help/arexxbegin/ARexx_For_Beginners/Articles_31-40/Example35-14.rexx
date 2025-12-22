/* Example35-14 */

TestSymbol = 'Joe Bloggs 99 Somewhere Street 123 4567'
PARSE VAR TestSymbol Name +11 Address +20 Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
