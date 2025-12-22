The A1200 (and A600?) PCMCIA-port has a bug which causes some PCMCIA-cards
(especially ethernet-cards) not to work after hardreset until you remove
the card and insert it again while power is on.

It seems as if the A1200 is not generating any reset-signal for the PCMCIA-
port. The problem is easily solved by soldering a 10uF capacitor between
CC_RESET and and Vcc. The CC_RESET is active high. The cathode (-) of the
capacitor should be at CC_RESET.

CC_RESET can be found on pin 5 of Gayle (U5) and Vcc on R715A (the end which
is near Gayle).

WARNING!
Although this is a very simple thing to solder please consult a professional
if you are not good at soldering. I take no responsibility for any damages
caused by doing anything described in this file.


Thanks to
---------
Filip Kopec	for making the A1200info series.

Author
------
Pontus Fuchs
email: pontus.fuchs@bluechoice.se
homepage: http://foo.birdnet.se/~pf/
