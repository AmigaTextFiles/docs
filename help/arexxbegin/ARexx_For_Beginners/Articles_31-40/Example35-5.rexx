/* Example35-5 */

P1 = '99'
P2 = '123'
TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name (P1) Address (P2) Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
