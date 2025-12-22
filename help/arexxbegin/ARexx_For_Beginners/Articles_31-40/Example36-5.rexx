/* Example36-5 */

SAY 'Enter your Name, Address and Phone Number with a space between each item.'

PARSE PULL Name Address Phone .
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
