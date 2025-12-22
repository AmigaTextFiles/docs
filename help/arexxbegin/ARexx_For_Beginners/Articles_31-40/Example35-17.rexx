/* Example35-17 */

TestSymbol = 'Joe Bloggs:99 Somewhere Street:123 4567'
PARSE VAR TestSymbol Name '99' Address '123' Phone,=1 x =12 y =32 z =40

SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
SAY 'X       =' x
SAY 'Y       =' y
SAY 'Z       =' z
