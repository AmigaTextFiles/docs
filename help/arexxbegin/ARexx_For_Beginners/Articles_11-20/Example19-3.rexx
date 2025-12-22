/* Example19-3.rexx */

ECHO "Enter a decimal number"
PULL Number
SAY 'Decimal' Number '=' D2B(Number) 'Binary'

ECHO "Enter a binary number"
PULL Number
SAY 'Binary' Number '=' B2D(Number) 'Decimal'

ECHO "Enter a Hexadecimal number"
PULL Number
SAY 'HexaDecimal' Number '=' X2B(Number) 'Binary'

ECHO "Enter a binary number"
PULL Number
SAY 'Binary' Number '=' B2X(Number) 'Hexadecimal'

EXIT

D2B:

  PROCEDURE
  ARG Number

RETURN C2B(D2C(Number))

B2D:

  PROCEDURE
  ARG Number

RETURN C2D(B2C(Number))

X2B:

  PROCEDURE
  ARG Number

RETURN C2B(X2C(Number))

B2X:

  PROCEDURE
  ARG Number

RETURN C2X(B2C(Number))
