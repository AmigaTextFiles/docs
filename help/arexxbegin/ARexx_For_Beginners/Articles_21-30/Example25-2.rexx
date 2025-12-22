/* Example25-2 */

cls = 'c'x
cd  = 'a'x

/* Following OPTIONS PROMPT used at another part of the program */

OPTIONS PROMPT cd'Press Any Key to Continue'
/* .... programming that uses options prompt */

SAY cls'This is another part of the program'
PULL Anything

/* Menu section of program */

Menu = 0
SAY cd'Select a menu item and press return'
SAY cd'1. Menu Item 1'
SAY '2. Menu Item 2'
SAY '3. Menu Item 3'
SAY cd'Q  to quit'
PULL Menu
