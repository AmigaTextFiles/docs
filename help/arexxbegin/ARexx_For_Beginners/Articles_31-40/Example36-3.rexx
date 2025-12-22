/* Example36-3 */

SAY 'Enter your Name, Address and Phone Number, separating each with a semicolon (;)'

PARSE PULL Name';'Address';'Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
