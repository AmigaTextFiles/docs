/* Example33-1 */

SAY 'c'x'Testing SIGNAL'
SIGNAL First

SAY 'This line will never be reached!!'

Third:
  SAY 'I am the line in the "Third:"  Label'
  SIGNAL Fourth

Second:
  SAY 'I am the line in the "Second:" Label'
  SIGNAL Third

Fourth:
  SAY 'I am the line in the "Fourth:" Label'
  EXIT

First:
  SAY 'I am the line in the "First:"  Label'
  SIGNAL Second
 