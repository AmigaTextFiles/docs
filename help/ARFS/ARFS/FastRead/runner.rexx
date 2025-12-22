
/* For instructions on what this topic is for, and how to use it, you
should have read the first topic in this database.  Once you have
confirmed that this FULL version works, you may prefer to use the SLIM
version instead. It does the same job, but is a quarter the size, and
may run slightly faster.    */

/* Runner.rexx builds a new program called Ram:patch.rexx from the
   relevant patch of the current FastRead screen, and then runs it. */

/* Runner.rexx must be run in a CLI window. A click on the [ Macro ]
   button will see to all of that automatically if you have followed
   the instructions in Topic 1.       */

/* We need 'rexxsupport.library' to be online. If it is not already
   so, we try to add it.  */

   if ~show("L",'rexxsupport.library') then
      call AddLib('rexxsupport.library',0,-30,0)

/* If that fails (e.g. because the library doesn't exist), a system
   error message will appear, and the program will end abruptly.

   Hint : If you put the next line in your startup-sequence
      RXLIB rexxsupport.library 0 -30 0
   then the library will always be online, and you could remove the 
   pair of lines above which do the check, and/or remove the similar 
   entry from the SLIM version of  Runner.rexx. */

olddir = pragma('d','ram:')      /* Set current directory to Ram:  */

/* Clean out previous version */
   if exists('patch.rexx') then b = delete('patch.rexx')

/* Check that we have a 'guide.txt'  */
if ~(exists('guide.txt')) then do
   say 'Guide.txt not found.' ; exit
   end

/* All checks completed.  We can start ... */

op = open(gt,'guide.txt','r') 
startfound = 0

/* Find the first line of the example. It expects a comment line
  containing " Example ",  and will keep on looking until it finds
  it, or end-of-file is true. */

do until (startfound) | (eof(gt))
  rd = readln(gt) 
  startfound = (index(rd,'/* Example */') ~= 0)
  end

/* No example found? */
if ~startfound then do
    cl = close(gt) 
    say 'No example in this topic'
    exit
    end

/* Okay. We've found an example. We're going to save that first
   line - the one we've just found - and the following lines to
   'patch.rexx'.*/

    op = open(ap,'patch.rexx','w') 
    wr = writeln(ap,rd)
    endfound = 0

/* Read until end-of-file. That assumes that the examples are at
   the end of the topic which includes them, which they are! */
   do forever
        rd = readln(gt)
        if eof(gt) then leave
        wr = writeln(ap,rd)
        end

/* Close the source file and the destination file. */
    cl = close(ap) ; cl = close(gt)

/* Wait for all the above to come to a tidy conclusion. There is no
point continuing until the new 'patch.rexx' exists and is ready to
use. Any previously existing version of 'patch.rexx' has already been
deleted precisely so that this check can be made before continuing.
 */
do until exists('patch.rexx') 
   call delay(1)             /* About 0.02 of a second */
   end

/* Run the new program */
address command 'sys:rexxc/rx ram:patch.rexx'

/* Reset directory to original */
call pragma('d',olddir)
    
