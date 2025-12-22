/* Example36-11 */

ADDRESS 'COMMAND' TCO
SAY 'Enter your Name, Address and Phone Number. Press RETURN after each item.'

PARSE EXTERNAL Name,Address,Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone

ADDRESS 'COMMAND' TCC
