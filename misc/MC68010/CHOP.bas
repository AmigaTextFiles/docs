10    '+
20    '    Program to chop off the end of files that Xmodem padded;
30    '-
40    '
50    input% = 1
60    output% = 2
65    count% = 0
70    legalchars$ = chr$(9) + chr$(10) + chr$(13)
100   input "Input file ";infile$
110   input "Output file ";outfile$
115   input "number of bytes to copy";total%
120   open "i", #input%, infile$
130   open "o", #output%, outfile$
200   if eof(input%) then goto 990
201   if (count% = total%) then goto 990
210   get #input%, char$
220   print #output%, using "&"; char$;
221   count% = count% + 1
222   if ( (count% mod 1024) = 0 ) then print ".";
223   if ( (count% mod (10*1024) ) = 0 ) then print
500   goto 200
990   close #input%
991   close #output%
999   end

