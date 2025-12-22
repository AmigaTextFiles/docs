/* Example33-5 */

Start:
  SAY Testing
  SIGNAL ON NOVALUE
  SAY Testing
  SAY 'This line will never be reached!! (or will it?)'
  EXIT

NoValue:
  SAY 'Symbol has no value'
  Testing = 'Testing has a value'
  SAY 'Going back to Start'
  SIGNAL Start
