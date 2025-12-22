/*  Herbex.rexx */
/*  ©May 2001 C.Dawson */
/*  convert the herbs.txt database into a usable printable ascii form   */
address command                                   /* talk to arexx */


                                                  /* CHANGABLE ITEMS */

inname  = "ram:herbs.txt"                         /* input file */
outname = "ram:HERBS.ASCII"                       /* output file */
pwidth  = 80                                      /* desired page width BE CAREFULL */
tlines  = 994                                     /* number of database records to convert */
hdext   = "_"                                     /* the fill char for headings */

                                                  /* END CHANGABLE ITEMS */


spacer  = ": "
tab0    = copies(" ",17)||spacer
tab1    = copies(hdext,17)||spacer
cr      = "0a"x


fwidth  = pwidth - 19                             /* page width minus length of header name */

h0 =  "Name"||copies(hdext,13)||spacer            /* all the header names */
h1 =  "Botanical Name"||copies(hdext,3)||spacer
h2 =  "Systems Affected"||copies(hdext,1)||spacer
h3 =  "Properties"||copies(hdext,7)||spacer
h4 =  "Description"||copies(hdext,6)||spacer
h5 =  "Origin"||copies(hdext,11)||spacer
h6 =  "Notes"||copies(hdext,12)||spacer
h7 =  "Toxicity"||copies(hdext,9)||spacer
h8 =  "Dosage"||copies(hdext,11)||spacer
h9 =  "Type"||copies(hdext,13)||spacer

call open(infile,inname,'r')                      /* open main data input file (read mode)*/
call open(outfile,outname,'w')                    /* open main data output file (write mode)*/

do loop = 1 to tlines                             /*tlines = do all lines of database file */

 say "Reading line #" loop
 data = readln(infile)                            /* read in a line of data */

 data = translate(data," ","¤")                   /* replace any '¤' with a space */

 f0 = h0||strip(substr(data,1,36),B,)||cr         /* get each field of 1 data line */
 f1 = h1||strip(substr(data,37,60),B,)||cr        /* strip all trailing spaces and */
 f2 = h2||strip(substr(data,98,50),B,)||cr        /* add a carridge return */
 f3 = h3||strip(substr(data,149,500),B,)||cr      /* this is the BIG string */
 f4 = h4||strip(substr(data,650,40),B,)||cr
 f5 = h5||strip(substr(data,691,30),B,)||cr
 f6 = h6||strip(substr(data,722,55),B,)||cr       /* perhaps a loop would be more elegant */
 f7 = h7||strip(substr(data,778,40),B,)||cr
 f8 = h8||strip(substr(data,819,50),B,)||cr
 f9 = h9||strip(substr(data,870,15),B,)||cr

 if length(f3) > pwidth then                      /* check if 'properties' needs to be wrapped */
  do                                              /* this is the ONLY field LONGER than 80 chars */
    wrapstr = f3
    call linewrap wrapstr
    f3 = wrapstr
  end

 outstr = f0||f1||f2||f3||f4||f5||f6||f7||f8||f9  /* put it all together */

 say "Writing Record #" loop
 call writeln(outfile,outstr)                     /* save 1 full herb entry to new file */

end

call close(outfile)                               /* close main data out file */
call close(infile)                                /* close main data in file */

exit                                              /* end of this rubbish */

/*================================================*/

linewrap:                                         /* linewrap routine */

say "***** Ajusting line *****"

temp        = wrapstr                             /* set all the linewrap variables */
newstr      = ""
workstr     = ""
wloop       = 1
instr       = cr||tab0                            /* a big tab */
linstr      = length(instr)                       /* length of tab */
numchars    = length(wrapstr)                     /* count chars in string to wrap */
numwords    = words(wrapstr)                      /* count chars in string to wrap */

do until wloop >= numwords                        /* check all words in long string */

wordlen = wordlength(temp,wloop)
templen = length(newstr) + wordlen
charpos = wordindex(temp,wloop + 1)
charsleft = numchars - charpos

if templen >  pwidth then                         /* if this word won't fit then new line */
 do
  workstr = workstr || newstr                     /* save the string so far and then... */
  newstr = instr                                  /* add a cr plus tab for next line */
 end

if templen <= pwidth then                         /* check if we can add this word */
 do
  newstr = newstr || word(temp,wloop) || " "      /* yes - add this word plus a space */
  willitfit = length(newstr) + wordlength(temp,wloop+1)

  if willitfit >= pwidth then

   if charsleft + linstr <= pwidth then           /* will remainder of main string fit into */
    do                                            /* 1 line */
     workstr = workstr || newstr
     workstr = workstr || instr
     workstr = workstr || subword(temp,wloop+1,)
     wloop = numwords
    end
  wloop = wloop + 1                               /* point to next word to check */
 end

end

wrapstr = workstr

return
