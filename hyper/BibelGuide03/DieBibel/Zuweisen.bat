echo "Dies erledigt die nötigen Zuweisungen für DieBibel: im aktuellen Verzeichnis!"
assign DieBibel: ""
assign BibelPics: DieBibel:pics
assign EgyptPics: DieBibel:pics defer
echo "EgyptPics: sollte noch auf das richtige Verzeichnis umgeleitet werden..."
assign BibelGenealogie: DieBibel:Genealogien
assign BibelGenealogien: DieBibel:Genealogien
cd DieBibel:
dir
wait 5 secs
SetEnv HYPERPATH "DieBibel: DieBibel:Genealogien BibelGenealogie: Help:"
LoadXref "BIBEL.xref"
ask "Fenster schließen? (Y)>"
if warn
   endcli
endif

