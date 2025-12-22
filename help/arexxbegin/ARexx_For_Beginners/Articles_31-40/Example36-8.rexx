/* Example 36-8 */

CALL MyFunction 'Joe Bloggs:99 Somewhere St:123 4567'
EXIT

MyFunction:

PARSE ARG Name':'Address':'Phone
SAY 'Name    =' Name
SAY 'Address =' Address
SAY 'Phone   =' Phone
RETURN
