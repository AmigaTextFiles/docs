Offen=OPEN(Ausgabe,"CON:20/20/620/150/BibelInfoRexx/auto/CLOSE/wait")
address command
'version SYS:Classes/DataTypes/hyperguide.datatype >env:hgvers'
hgvers=open(hgvers,'env:hgvers','R')
Offen=OPEN(Ausgabe,"CON:20/20/620/150/Die Hypertext Biebel/CLOSE/wait")
IF Offen THEN
  DO
    WRITELN(Ausgabe,"Für die volle Schönheit und Funktionalität")
    WRITELN(Ausgabe,"dieser Bibel.guides benötigt man dringend")
    WRITELN(Ausgabe," Das HyperText-Datatype-System HTDS")
    WRITELN(Ausgabe,"von Stefan Ruppert.")
    WRITELN(Ausgabe," ")
    WRITELN(Ausgabe,"Du besitzt es schon?!: " hgvers)
/* WRITELINE(Ausgabe,'version SYS:Classes/DataTypes/hyperguide.datatype') */
    WRITELN(Ausgabe," ")
    WRITELN(Ausgabe,"Wenn nicht: Zu finden ist es unter folgenden Adressen:")
    WRITELN(Ausgabe," http://home.pages.de/~Ruppert/amiga/HTDS.html ")
    WRITELN(Ausgabe," FTP: Aminet:util/dtype/HTDS.lha ")
    WRITELN(Ausgabe," http://www.amigaworld.com/support/HTDS/ ")
  END
DO I=1 TO 1000 /* KLEINE SCHLEIFE */
 zahl=I+15
call close(Ausgabe)
END
EXIT
