/* $VER: BibelInfo.rexx V0.1 */
/* con: als Ausgabe */
Offen=OPEN(Ausgabe,"CON:20/20/620/150/BibelInfoRexx/auto/CLOSE/wait")
IF Offen = 1 THEN
  DO
    WRITELN(Ausgabe,"Ich bin nicht hyperaktiv,")
    WRITELN(Ausgabe,"sondern interaktiv.....")
    WRITELN(Ausgabe,show('p'))
  END
DO I=1 TO 1000 /* KLEINE SCHLEIFE */
END
EXIT
IF ~Offen  THEN
do
say "Die Bibel als HyperText"
say "benötigt wird ein Assign DieBibel:"
say "versuche dies jetzt einzurichten..."
address command
'die DieBibel: dirs'
'requestchoice frage Antwort OK NO'
'echo >t:bibel.temp "assign DieBibel: exists" NEWLINE'
'echo >>t:bibel.temp "if warn" NEWLINE'
'echo >>t:bibel.temp "echo einwarn" NEWLINE'
'echo >>t:bibel.temp "assign DieBibel: """ NEWLINE'
'echo >>t:bibel.temp "else" NEWLINE'
'echo >>t:bibel.temp "echo Keinwarn" NEWLINE'
'echo >>t:bibel.temp "assign DieBibel: """ NEWLINE'
'echo >>t:bibel.temp "endif" NEWLINE'
address command
'execute t:bibel.temp'
/*
commandline='echo >t:bibel.temp "assign DieBibel: exists"'
commandline=commandline|' echo >t:bibel.temp "if warn"'
commandline=commandline|' echo >t:bibel.temp "assign DieBibel: ""'
commandline=commandline|' echo >t:bibel.temp "else"'
commandline=commandline|' echo >t:bibel.temp "echo Keinwarn"'
commandline=commandline|' echo >t:bibel.temp "assign DieBibel: ""'
commandline=commandline|' echo >t:bibel.temp "endif"'
*/
