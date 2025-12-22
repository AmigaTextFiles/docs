/* aminet-on-disk-calculator V1.1 */
/* (C) by Martin Steigerwald      */

/* V1.1 bug-fix Diskettenzahl wird nun korrekt gerundet
                auf Minus-Zeichen wird extra geachtet
   V1.2 bug-fix Diskettenzahl wird nun korrekt berechnet
                (Das Runden macht keinen Sinn, da eine angebrochene
                Disk eine angebrochene Disk ist, egal ob sie nur
                halbvoll ist
*/

call addlib("rexxreqtools.library", 0, -30)

NL= "0a"x

Call rtezrequest("AmiNet-On-Disk-Calculator" || NL ||,
                 "(W) by Martin Steigerwald", "OK|Abbruch")

tags = "rtfi_flags=freqf_multiselect"

call rtfilerequest("TEXTE:Bestellungen/AmiNet/Best",,"Wähle bitte AmiNet-Liste(n)!", ,tags ,dateiliste)

overallsize=0

Do i=1 to Dateiliste.count

  Open(In,Dateiliste.i,"read")

  Do Until Eof(In)
    line=ReadLn(In)
    If Index(line,"-",1)~=1 Then Do
      If Index(line,"K",36)=36 Then Do
        size=SubStr(line,33,3)
        overallsize=overallsize+size
      End
      Else If Index(line,"M",36)=36 Then Do
        size=SubStr(line,33,3)
        size=size*1000
        overallsize=overallsize+size
      End
    End
  End
  Close(In)
End

ddsize=820
hdsize=1700

dds=overallsize%ddsize+2
hds=overallsize%hdsize+2

call RtEzRequest(" Größe: " || overallsize || " KB" || NL,
                 "DDs:   " || dds || " Disks" || NL,
                 "HDs:   " || hds || " Disks", "OK")

Open(out,"Bestellinfo","write")
WriteLn(out,"AmiNet-On-Disk-Calculator")
WriteLn(out,"a small ARexx-utility by Martin Steigerwald (Public Domain)")
WriteLn(out,NL || NL || "Die angebenen Files belegen " || overallsize ||,
            " Kilobytes")
WriteLn(out,"auf " || dds || " DD-Disketten oder " || hds || " HD-Disketten.")
WriteLn(out,NL || NL || "So long, your AmiDisk-Calcer!")
Close(out)

