			Remote Volume Control
			=====================


Door:		Edwin  van  den Oosterkamp (eto@icns.nl).

Bijlagen:	Het schema in IFF/ILBM "Diagram.IFF".
		Docs in engels en nederlands.
		Source code 8051 software "RVC.a51".
		Object 8051 software "RVC.obj".
		8051 Hex file in Intel formaat "RVC.hex".
		VolumeControl executable voor de Amiga.

Inleiding
----------

Een van mijn grote hobby's is het programmeren van mijn trouwe Amiga.
Hierbij is een bepaalde dosis muziek onontbeerlijk. Helaas komt (in 
mijn geval) deze dosis erg nauw. Is het volume te zacht dan erger ik
mij groen-en-geel en kan daardoor niet concentreren. Is het volume te
hard dan besteed ik meer aandacht aan de muziek dan aan de Amiga, die
dan ongeduldig met de cursor knippert. Het tweede probleem is het feit
dat mijn stereo aan de andere zijde van mijn kamer staat...
Handig zou het pas zijn wanneer ik mijn stereo kon bedienen vanaf mijn
computer.

Er waren meedere oplossingen: Ik kon een versterker met afstandsbediening
kopen. Nu heb ik mijn versterker al een tijdje, maar hij bevalt mij heel
erg en ik heb totaal geen behoefte om hem te vervangen.
Ik kon ook zelf een afstands bediening bouwen en met een servo de volume
knop draaien. Hiervoor zou ik mijn versterker moeten openen, waarin
trouwens toch geen plaats voor een servo is.
De uiteindelijke oplossing was: Het volume regelen via mijn computer
(RS232) en zonder bewegende delen. Ik wilde een kastje ontwerpen met
AudioIn/AudioUit en RS232. Meer zooi niet.


De Oplossing
------------

De Firma Crystal levert (onder andere) een chip die het beste kan worden
beschreven als een PGA (Programmable Gain Amplifier). Deze chip is stereo
uitgevoerd en bedoeld voor het regelen van volume in High-End apparatuur.
De chip in kwestie is de CS3310 (kost ongeveer drie tientjes). De CS3310
bezit een software-mute waarbij er totaal geen geluid wordt doorgegeven.
Hieronder volgt een tabel met wat karakteristieke (typical) waarden voor
enkele audio-parameters en zie waarom dat deze chip in High-End
toepassingen wordt gebruikt...

Tabelletje met de CS3310 eigenschappen

Stapgrootte:		  0.5   dB
Minimale versterking:	-95.5   dB
Maximale versterking:	 31.5   dB
Fout bij 31.5 dB:	+-0.05  dB
Verschil tussen R en L:	+-0.05  dB
Vervorming (2Vrms 1kHz):  0.001 dB
Dynamic range:		116     dB
Kanaalscheiding:	110     dB
Uitgangsruis:		  4.2   microVrms

Uiteraard wordt het dingetje niet via RS232 aangesproken. (De paralelle
poort van de Amiga zou ook heel goed voldoen ware het noet dat de kabel te
lang zou worden voor een goede communicatie).
De makkelijkste oplossing om RS232 om te zetten naar een digitaal signaal
dat de CS3310 begrijpt is het gebruiken van een 80C31 microcontroller.
Deze bezit namelijk standaard een RS232 poort (mits juist geprogrammeerd)
en een aantal parallele I/O poorten.
Om het ding met een snelheid van 9600 Baud aan te kunnen spreken gebruik
ik een klokkristal met een frequentie van 11.0592MHz. Aangezien ik niet
de eerste ben die deze waarde nodig heeft, is dit een standaard kristal
en daardoor relatief goedkoop (een gulden of acht tegen tegen een aantal
tientjes voor niet standaard kristallen).
Dit geldt trouwens ook voor de microcontroller. Display levert het kreng
voor het luttele bedrag van f8,95 (!). Hij is dan wel in DIL-40 behuizing
maar dat maakt verder geen ene moer uit.

RS232 maakt gebruik van spanningen rond de 10V (positief en negatief). Deze
spanningen zijn uiteraard te groot voor de microcontroller. Daarom moet
er tussen de controller en de computer nog een RS232 Line-Driver worden
geplaatst.
Hiervan zijn er verschillende in de handel, en de keus komt niet zo nauw.
Omdat ik een betrouwbaar en degelijk exemplaar wilde koos ik voor de MAX232
van de firma Maxim. Deze kost ongeveer een tientje.
Een van de eigenschappen van de Max232 is dat deze aan een voedingsspanning
van 5 Volt voldoende heeft om de +10V/-10V RS232 spanningen te creeren.
Hiervoorheeft de Max232 intern een soort schakelende voeding.

Terug naar de controller. Om het programma vast te houden gebruik ik
uiteraard een EPROM. Het is ook mogelijk om van de 80C31 een versie te
verkrijgen die je maar een maal kunt programmeren (OTP - Once Time
Programmable). Deze controller gaat als 80C51 door het leven en is
duurder dan zijn ROMloze broer. Er bestaat ook nog een 87C51. Deze heeft
een ingebouwde 4k EPROM inclusief stukje kwartsglas voor het wissen. 
Deze bestaat alleen in CLCC behuizing en kost rond de honderd piek.
Tikje associaal geprijst vergeleken met de 80C31 in DIL-14. Naast de
EPROM moet er ook nog een adres latch in de schakeling worden opgenomen
omdat de databus en de adresbus gemultiplexed zijn. Deze latch kan gewoon
uit de HCT serie worden genomen (bijvoorbeeld de 74HCT573) en zal
waarschijnlijk maar een paar gulden kosten.


Software
--------

De microcontroller moet uiteraard van software worden voorzien. Bij
deze tekst zit de source van de 8051 software zoals ik dat op het ogenblik
gebruik.
Zodra de controller van voedingsspanning wordt voorzien initialiseerd
deze de RS232 poort voor gebruik met 9600 Baud, 8 databits, 1 stopbit
en geen parariteitsbit.
Om de CS3310 wakker te schudden rammelt de controller wat met de /Mute
van de CS3310. Nadat de controller zichzelf heeft geinitialiseerd stuurt
hij via RS232 een string weg met daarin een simpele gebruiksaanwijzing.
Met behulp van een terminal(programma) kan deze string worden ontvangen
en opdrachten aan de controller worden verstuurd.
Na het verzenden van de string wordt de CS3310 zowel links als rechts met
de waarde $C0 geinitialiseerd. Dit staat gelijk met een versterking 
van 0 dB.

De 8051 blijkt een instructieset te bezitten die erg lijkt op die van
de z80. Vergeleken met de 68000 mnemonics is het oppassen geblazen voor
de programmeur: in plaats van "BSET.B #.,.." gebruikt de 8051 "SETB .."
maar dat is nog niets vergeleken de MOV instructie...
Vergelijken we deze met de MOVE van de 68000 dan wordt het helemaal
leuk: Source en Destination zijn verwisseld!
Dus in plaats van "MOVE.B #0,Accu" moet de 8051 worden verteld dat hij
"MOV A,#0".


Voeding
-------

Alle onderdelen hebben genoeg aan een 5V voedingsspanning behalve de
CS3310. Deze heeft namelijk een symetrische voeding nodig van +/-5V.
Om een goede (adapter)voeding te verkrijgen wilde ik de totale
voedingsspanning zo laag mogelijk houden. Uiteraard is het zonde een
onderdeel als de CS3310 met een slechte voeding op te zadelen. Om een
stabiele voeding met een lage ingangsspanning te kunnen realiseren heb
ik de relatief dure oplossing gekozen met een schakelende voeding van
het type NMH505S. Deze zet een spanning van 5V om in een symmetrisch 5V
zoals die voor de CS3310 nodig is.

Omdat ik van een adapter voedt en deze dingen zelden fatsoenlijk zijn
gestabiliseerd, heb ik het ontwerp een knaak duurder gemaakt door de
7805 toe te voegen. Hierdoor kan de ingangsspanning varieren zonder
de schakelende voeding op te blazen.
De diode in serie heb ik standaard in al mijn ontwerpen als een soort
standaard veiligheids maatregel. Ik ben van mening dat een apparaat
tegen foutieve pooling moet kunnen/beveiligd zijn.

Rond de CS3310 is een zut aan condensatoren gevestigd. De fabrikant
geeft deze onder andere op in een application note. Dat geldt ook
voor de weerstand van 10 Ohm. Zowel de Weerstanden als de condensatoren
moeten de digitale storingen op de voeding smoren. Deze dienen dan ook
zo dicht mogelijk bij de CS3310 gemonteerd te worden.

Het is anders met de condensatoren rond de Max232. Deze dienen louter
en alleen voor de schakelende voeding in de Max232. Het is uiteraard
wenselijk om deze zo dicht mogelijk bij het IC te plaatsen, doch vanwege
stoorsignalen wel zo ver mogelijk van de andere onderdelen.
Uiteraard moet ieder IC een condensator van 100nF over de voedingslijnen
hebben als voorzorgsmaatregel. Deze zijn in het schema niet ingetekend!


AmigaSoftware
-------------

Om het spul vanaf de Amiga aan te kunnen sturen moet er aan die kant
natuurlijk ook software worden geschreven. Omdat het flauwekul is een
hele source in dit artikel op te nemen geef ik alleen de basis-routines.					    »

Eerst moeten we serieel informatie versturen. Dit kan met behulp van het
serial.device. natuurlijk had ik ook voor het device "SER:" kunnen kiezen,
maar ik wil wel wat rappere communicatie.

Openen van het serial.device (KS2.0):

OpenSer:		MOVE.L	4.w,a6			;a6 = Execbase.
			JSR	CREATEMSGPORT(a6)	;Maak een MsgPort aan.
			MOVE.L	d0,SerMsg		;Bewaar het resultaat.
			BEQ.B	Ser_Fout		;Zekere voor het onzekere.
			MOVE.L	d0,a0			;Verpoot APTR MsgPort.
			MOVEQ	#82,d0			;ULONG lengte IOReq-struct.
			JSR	CREATEIOREQUEST(a6)	;Maak IOReq structuur aan.
			MOVE.L	d0,SerReq		;Bewaar de structuur.
			BEQ.B	Ser_Fout		;Zekere voor het onzekere.

;Maak alvast wat voor-instellingen en open het device.

			MOVE.L	SerReq(PC),a1		;APTR  StdIOReq.
			MOVE.L	#9600,io_BAUD(a1)	;ULONG Baudrate.
			MOVE.B	#$80,io_SerFlags(a1)	;UBYTE Vlaggen (Geen protocol)
			LEA.L	SerName(PC),a0		;APTR  naam van het device.
			MOVEQ	#1,d0			;Unit nummer.
			MOVEQ	#0,d1			;Geen vlaggen.
			JSR	OPENDEV(a6)		;Uiteindelijk geopend.
			TST.L	d0			;Test het resultaat.
			BNE.B	Ser_Bezet		;Geen device?

Uiteraard kunnen er meer voor-instellingen worden gemaakt. Niet
gespecificeerde instellingen worden uit de preferences gehaald.						    »

Al wat open is moet je ook weer sluiten:

SluitSer:		MOVE.L	4.w,a6			;a6 = Execbase.

;Sluit het device en wis de StdIOReq van de serial.

			TST.L	SerReq			;Test StdIOReq van serial.
			BEQ.B	Ser_NoReq		;Geen req? Niet wissen!
			MOVE.L	SerReq(PC),a1		;APTR  StdIOReq van serial.
			JSR	CLOSEDEV(a6)		;En weg is het device.
			MOVE.L	SerReq(PC),a0		;APTR  StdIOReq van serial.
			JSR	DELETEIOREQUEST(a6)	;En weg is de IORequest.
			CLR.L	SerReq			;Wis voor alle zekerheid.
		
;Wis de messagepoort van de serial.

Ser_NoReq:		TST.L	SerMsg			;Test MsgPort van serial.
			BEQ.B	Ser_NoMsg		;Geen MsgPort? Niet wissen!
			MOVE.L	SerMsg(PC),a0		;APTR  MsgPort van serial.
			JSR	DELETEMSGPORT(a6)	;En weg is de Messagepoort.
Ser_NoMsg:		CLR.L	SerMsg			;Wis voor alle zekerheid.

Zowel de routine voor het openen als de routine voor het sluiten van
"serial" zijn alleen geschikt voor Kickstart 2.0 en hoger. Uiteraard
moeten dingen als de devicenaam etc nog worden gespecificeerd evenals
opslagplaatsen voor de resultaten van de verschillende systeem-routines.

Na het openen van "serial" (en uiteraard nog voor het sluiten ervan)
gebruiken we serial. Dit is niet anders dan het doen van eeen DOIO-tje...

ChangeVol:		MOVE.L	4.w,a6			;a6 = ExecBase.
			MOVE.L	SerReq(PC),a1		;APTR  Serial-IOReq.
			MOVE.L	#4,io_Length(a1)	;ULONG Aantal bytes(4).
			MOVE.L	#SerFile,io_Data(a1)	;APTR  Buffer.
			MOVE.W	#CMD_WRITE,io_Command(a1);Schrijf commando.
			JSR	DOIO(a6)		;Stuur commandos naar RVC.

SerFile:		DC.B	$1b,'1',192,192		;Instellen: 0 dB.

Volgens het protocol van de Remote Volume Control (zie de 8051 assembly
source) moet er eerst <esc> en '1' worden ontvangen voordat het volume
worst ontvangen. De vier te versturen bytes laten dit nog eens zien.



Beschouwend
-----------

Het door mij gebouwde prototype trekt een stroom van 100mA. Zoals al
eerder werd gemeld kan dit nog worden teruggedrongen door de controller
na initialisatie in de idle-mode te zetten. In de praktijk is er van
Digitale storingen niets terug te vinden in de audiosignalen.
De CS3310 belast wanneer hij geen voedingsspanning heeft het 
ingangssignaal. Het is dus niet zondermeer mogelijk met een schakelaar
een soort bypass te maken om de CS3310 te omzeilen.

Wanneer iemand meer intresse heeft in dit onderwerp/ontwerp of vragen
heeft, dan hoeft deze persoon zich alleen maar met mij in verbinding
te stellen...

Hartelijk dank voor de aandacht...

Edwin. Th. van den oosterkamp
E-Mail:	eto@icns.nl
WWW:	http://www.icns.nl/users/eto/

