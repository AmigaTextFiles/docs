/* Example35-4 */

P = ':'
TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name (P) Address (P) Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
