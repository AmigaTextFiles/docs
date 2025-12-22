<HTML>
<HEAD>
<TITLE> DIY CDDA Mixer! </TITLE>
<META NAME="description" CONTENT="Phil's website">
<META NAME="keywords"    CONTENT="amiga, irc, software, redwall, #Redwall, ARCNet, CDDA Mixer, Philip Edwards">
<META NAME="author"      CONTENT="Philip Edwards">
<META NAME="generator"   CONTENT="webPlug by Exteve Boix">
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<B> <FONT COLOR="#FF4300" SIZE="+2">DIY CDDA Mixer</FONT></B> 
<TABLE BGCOLOR="#76EEC6" ALIGN="RIGHT">
<B>DISCLAIMER: </B>I take no responsibilty for your cat or you motherboard being toasted<BR>
</TABLE><BR>
<BR>
<FONT COLOR="#000000" SIZE="+0">In the February 1998 edtion of CU Amiga there was an article by Simon Archer on how to build a CDDA Mixer. This gadget merges the audio signal from your CD-ROM drive with the audio from your Amiga, and amplifies the weak CD audio at the same time. This project allows you to listen to your favourite music CDs when you are web browsing, typing out a letter or doing anything on your Amiga.</FONT><BR>
<BR>
<BR>
<B><FONT COLOR="#000000" SIZE="+1">HOW DIFFICULT ?</FONT></B><BR>
<FONT COLOR="#000000" SIZE="+0">The actual project isn't difficult to build, but the original instructions weren't very clear, which is why I have done this article.
I'd just bought Wordworth 7 at the time, so I wanted to try it out before converting it into HTML.</FONT><BR><BR>
<BR>
<BR>
<B><FONT COLOR="#000000" SIZE="+1">WHAT DO I NEED ?</FONT></B><BR>
I bought all the components for the project at my local Maplins who have branches throughout the country. The basics you will require are: A soldering iron, multimeter, stanley knife, long-nosed pliers and a mole wrench and a car cleaning sponge :)<BR>
<BR>
<TABLE BGCOLOR="#FFEFDB" WIDTH="60%" CELLSPACING="4">
<B><TR><TH>QUANTITY<TH>DESCRIPTION<TH>ORDER No.<TH>COST £ </B><BR>
<TR><TD>1<TD> Box<TD> FK73<TD>1.09 <BR>
<TR><TD>1<TD>Stripboard<TD>JP47<TD>1.60<BR>
<TR><TD>1 metre<TD>Heat Shrink CP16<TD>BF86T<TD>1.14<BR>
<TR><TD>1<TD>CDDA Header Socket<TD>YW11<TD>0.38<BR>
<TR><TD>1<TD>TDA2822M chip<TD>UJ38<TD>1.26<BR>
<TR><TD>1<TD>DIL Socket 8 pin<TD>33-AD<TD>0.10<BR>
<TR><TD>2<TD>Resistors 4.7R<TD>M4R7<TD>0.11<BR>
<TR><TD>2<TD>Resistors 1R<TD>M1R<TD>0.11<BR>
<TR><TD>2<TD>Resistors 47K<TD>M47K<TD>0.11<BR>
<TR><TD>2<TD>Resistors 1K2<TD>M1K2<TD>0.11<BR>
<TR><TD>2<TD>Resistors 100R<TD>M100R<TD>0.11<BR>
<TR><TD>1<TD>Polyester disc 100NF<TD>YR75<TD>0.17<BR>
<TR><TD>2<TD>Electrolytic 100uF<TD>AT40<TD>0.20<BR>
<TR><TD>2<TD>Electrolytic 470uF<TD>AT43<TD>0.32<BR>
<TR><TD>2<TD>Polyester layer 100NF<TD>WW41<TD>0.51<BR>
</TR></TABLE>
<BR>
<BR>
<B><FONT COLOR="#000000" SIZE="+1">OPTIONAL ITEMS</FONT></B><BR>
<I>To take the power from a spare hard drive lead :-</I><BR>
<BR>
<TABLE BGCOLOR="#FFEFDB" WIDTH="60%" CELLSPACING="4">
<TR><TD>10metres<TD>Power cable(black)<TD>BL00A<TD>0.58<BR>
<TR><TD>10metres<TD>Power cable(red)<TD>BI07H<TD>0.58<BR>
<TR><TD>1<TD>0.2inch Power conn.(female)<TD>JW65V<TD>0.67<BR>
</TR></TABLE><BR>
<BR>
<FONT COLOR="#000000"><I> To take the Amiga audio in and the combined audio out (you will have to think about this) I used these items for my custom A1200 desktop setup:- </I></FONT><BR>
<BR>
<TABLE BGCOLOR="#FFEFDB" WIDTH="60%" CELLSPACING="4">
<TR><TD>1 metre<TD>Cable twin<TD>XR21<TD>0.41<BR>
<TR><TD>2<TD>Phono plugs (red)<TD>FJ88V<TD>0.66<BR>
<TR><TD>2<TD>Phono plugs(black)<TD>FJ88W<TD>0.66<BR>
<TR><TD>1<TD>Line socket (black)<TD>FJ90X<TD>0.33<BR>
<TR><TD>1<TD>Line socket (red)<TD>JK23A<TD>0.33<BR>
</TR></TABLE><BR>
TOTAL COST ex VAT&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp£11.92<BR>
TOTAL COST INCLUDING VAT &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp£14.01<BR>
<BR>
<BR>
<FONT COLOR="#FF0000" SIZE="+2">CONSTRUCTION DETAILS</FONT><BR>
<BR>
<B><FONT COLOR="#000000" SIZE="+1">1.The Stripboard</FONT></B><BR>
<BR>
<B>First cut the PCB</B><BR>
You will probably have 4 times as much stripboard than you need. First of all you need to cut yourself a bit 19 holes wide (along the strip) and 7 strips high. To cut, the best technique is to use a ruler and a Stanley knife and repeatedly score along a line of the next line of holes. You should then be able to snap the board where you want to using gentle pressure between your finger and thumb.<BR>
<BR>
<B>Next mark it up and remove the traces</B><BR>
With the copper strips uppermost, going from side to side in front of you, mark the top left hand corner with a tiny blob of white typex, including the edges and underneath. By doing this you should not loose track of where you are.When you flip the board over the dot should always be on the left hand side. You might also want to mark the holes where you are going to drill into the copper strips to break the continuity. as per <B> Fig. 1</B> below. I used a 6cm drill in a chuck in an electric screwdriver to break the traces. Examine the holes carefully, or even better check with a multimeter to make to make sure there is no current flowing from one side of the cut to the other.<BR>
<BR>
<B>Fig. 1</B><BR>
<BR>
<IMG SRC="images/board.png" ALT="Fig. 1" ALIGN="CENTER"><BR>
<BR>
<FONT COLOR="#000000" SIZE="+1"><B>2. The Wire Links</B></FONT><BR>
Now flip the board over and insert the wire links in accordance with Figure 2 below. I rested my board on an old car cleaning sponge and stopped it moving around by holding it <U>gently</U> along the edges using a mole grip wrench. The reason for the sponge is to stop components dropping out of the board when you have to flip it over to put a blob of solder on the strip side to make a connection. The wire links were surplus wire from the resistors except for link 1 where I used a loop of insulated wire about 4 or 5 cm long so that it didn't get in the way of R6 or the CDDA Header socket.<BR>
<BR>
<B> Fig. 2</B><BR>
<BR>
<IMG SRC="images/wirelinks.png" ALT="Fig. 2" ALIGN="MIDDLE"><BR>
<BR>
<B><FONT COLOR="#000000" SIZE="+1">3. The Components </FONT></B><BR>
Now starting with the smallest items first, you can solder things onto the board. Again I have modified the design this time to include a chip holder. It only costs 10p but it means you do not have to worry about the chip getting hot. Like the chip itself, the chip holder has a scallop on the bottom edge if the CDDA socket is on the left hand side. Things can be a very tight fit particularly with the capacitors C5 and C6 where the wires have to be bent under to allow them to fit. You should read the original article again if you have any doubts, get it wrong  and its back to Maplins for another chip !<BR>
The electrolytic capacitors (C3-C6) only work properly the right way round. The ones I bought had a stripe down the side indicating a negative connection (see my colour picture following or the reversed one over the original article).<BR>
<BR>
<FONT COLOR="#FF0000" SIZE="+2">THE FINISHED ARTICLE</FONT><BR>
<TABLE BGCOLOR="#FFE682">
PLAN VIEW OF STRIPBOARD
</TABLE><BR>
<BR>
<IMG SRC="images/diagram.png" ALT="Components diagram" ALIGN="MIDDLE"><BR>
<BR>
<BR>
<B>The Finished Article</B><BR>
<BR>
All you have to do now is to push the chip into place (if you used a chip socket) making sure the scallop is in the right place, and solder the external connections to suit your Amiga.<BR>
If you are not certain where things go, the diagram above should help. In the diagram you are looking down on the stripboard and the copper strips are on the underside. Components are shown as if they were semi-transparent so you can see the holes in the board which are shown in 3 different ways :<BR>
<IMG SRC="images/holes.png"><BR>
<BR>
Finally, put your CDDA Mixer into the plastic box. You could use a Velcro pad to hold it down in the box if you want to stop it rattling around.<BR>
<BR>
If you are considering constructing a CDDA Mixer and have queries, or are half way through building one and you need help, please feel free to email <A HREF="mailto:phil@edwards98.u-net.com?subject=CDDA Mixer">me.</A><BR> 
<BR>
<B>Future Projects</B><BR>
I would like to build my own scandoubler/flicker fixer, so if anyone has a quite simple and inexpensive design, I would be grateful if that person could forward them to me and i will consider making another guide for building one.<BR>
</BODY>
</HTML>