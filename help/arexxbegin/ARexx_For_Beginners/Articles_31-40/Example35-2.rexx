/* Example35-2 */

TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name '99' Address '123' Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
