/* Demonstration of all REXX commands supported by LCDaemon */
OPTIONS RESULTS            /* Use Result for some commands  */
ADDRESS 'LCDAEMON.1'

/* lcdmessage [time t] [pri n] message */
say 'Sending test message to LCD...'
lcdmessage time 300 pri 0 "Standard priority"
lcdmessage time 200 pri 80 "Mega priority"
lcdmessage time 205 pri 10 "higher-priority string"

/* getlines & getcharacters :
         return parameters supplied to LCDaemon at startup  */
getlines
lines=Result
getcharacters
chars=Result
say 'Your LCD is configured for' lines 'lines of' chars 'characters.'
