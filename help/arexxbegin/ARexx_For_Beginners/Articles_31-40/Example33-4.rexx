/* Example33-4 */

SIGNAL ON ERROR

ADDRESS 'COMMAND'
'COPY >nil: Ram:What_a_lot_of_garbage Sys:'
SAY 'This line will not be reached!!'

EXIT

Error:

SAY 'there is no such file in Ram:'
