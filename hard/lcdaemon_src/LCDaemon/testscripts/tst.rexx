/* Demonstration of all REXX commands supported by LCDaemon */
OPTIONS RESULTS            /* Use Result for some commands  */
ADDRESS 'LCDAEMON'

/* lcdmessage [time t] [pri n] message */
say 'Sending test message to LCD...'
lcdmessage time 300 pri 0 "This is a standard priority string"
lcdmessage time 200 pri 80 "Hello there, this is AREXX speaking to your LCD display..."
lcdmessage time 205 pri 10 "This is a higher-priority string"

/* getlines & getcharacters :
         return parameters supplied to LCDaemon at startup  */
getlines
lines=Result
getcharacters
chars=Result
say 'Your LCD is configured for' lines 'lines of' chars 'characters.'
