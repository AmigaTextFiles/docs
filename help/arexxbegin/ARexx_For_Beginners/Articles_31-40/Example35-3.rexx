/* Example35-3 */

TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name 'o' Address 't' Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
