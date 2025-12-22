/* Example35-13 */

N1 = 1
N2 = 12
N3 = 32
N4 = 40

TestSymbol = 'Joe Bloggs 99 Somewhere Street 123 4567'
PARSE VAR TestSymbol =N1 Name =N2 Address =N3 Phone =N4
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
