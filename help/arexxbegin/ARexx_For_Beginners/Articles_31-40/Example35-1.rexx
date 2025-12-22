/* Example35-1 */

TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name ':' Address ':' Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
