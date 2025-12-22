/* Arexx.guide für Wordworth 6 installieren */
/* Heiko Kuschel 18.11.96                   */

options results
DO Num = 1 to 20
	    WwPort = "WORDWORTH." || Num
	    IF SHOW(PORTS, WwPort) THEN DO
		    Address Value WwPort
		    leave Num
	    end
    end
    if num=21 then do
      address command 'echo "Konnte Wordworth nicht finden. Bitte zuerst Wordworth starten."'
      Exit
    end

Erfolg=Open("Path","Env:Wordworth/WwFonts","R")
if Erfolg then do
    Pfad=Readln("Path")||"//Help/"           
    Erfolg=Open("SchonDa",Pfad"ARexx.guide","R")
    if Erfolg then do
	address command 'echo "Datei ARexx.guide ist schon vorhanden. Installation wurde offenbar schon durchgeführt."'
	exit
    end
    Erfolg=Close("SchonDa")

    address command copy "ARexx.guide" Pfad

    New
    Address Value Result
       Document "50cm" "30cm"
       open Filename Pfad"Editing.guide" Force
	Find "Editing.guide/ARexxCommands"
	Text "ARexx.guide/Main"
	Find "Editing.guide/ARexxCommands"
	Text "ARexx.guide/Main"
	/*Findchange ist unständlicher, da sich der Requester "2 ersetzt" nicht abschalten läßt.*/
	saveas ASCII Name Pfad"Editing.guide"

	open Filename Pfad"Trouble.guide"
	Find "Editing.guide/ARexxCommands"
	Text "ARexx.guide/Main"
	saveas ASCII Name Pfad"Trouble.guide"

	open Filename Pfad"WW6.guide"
	Find "Editing.guide/ARexxCommands"
	Text "ARexx.guide/Main"
	ctrldown
	cursor up
	ctrlup

	Find Text "Ww6.guide/WwIndex"
	ctrldown
	cursor left
	ctrlup
	cursor down
	newparagraph
	newparagraph
	cursor up
	Text ' @{" ARexx-Kommandos                    " Link "ARexx.guide/Main"}'
	saveas ASCII Name Pfad"WW6.guide"
	close
	address value WWPort
	Wizardreq Title "ARexx.guide" Label "Installation der ARexx-Anleitung abgeschlossen." LABEL "Im Hilfe-Inhaltsverzeichnis finden Sie ein neues" LABEL "Feld mit der Bezeichnung 'ARexx-Kommandos'" Button 1 "_Hilfe anzeigen" Button "-1" "_Ende"
	if result then help
end
else do
    address command 'echo "Konnte den Pfad für Wordworth nicht finden. Ist WW6 installiert?"'
end
