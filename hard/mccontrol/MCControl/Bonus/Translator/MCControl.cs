## languages english,deutsch,français,español,português,polski
## version $VER: MCControl.catalog 1.69 (13.05.2002)
## codeset 0
## autonum 1
## asmfile english,MCControl:Sources/SRC.MC_Locale
## localepath MCControl:Catalogs/
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; You need "SimpleCat" from Aminet "dev/misc/simplecat.lha"
; to add your own Language or make any modifications
;
; Simple adjust "## localepath" to your MCControl installation path.
; E.G. "## localepath work:tools/MCControl/Catalogs"
;
; After that it is required to add the correct language name!
; E.G. "## language english,deutsch,français,español,português,polski,NewLanguage"
;
; The next to do is to add your translation.
; Make sure, that all labels contain a translation for each language.
;
; At last simple call SimpleCat: "SimpleCat MCControl.cs LOCALEONLY"
;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;
MSG_ScreenTitle
PSX Memory Card Control V%ld.%ld by Guido Mersmann
PSX MemoryCard Control V%ld.%ld von Guido Mersmann
PSX MemoryCard Control V%ld.%ld par Guido Mersmann
PSX MemoryCard Control V%ld.%ld por Guido Mersmann
PSX MemoryCard Control V%ld.%ld por Guido Mersmann
PSX MemoryCard Control V%ld.%ld napisaî Guido Mersmann
;
;----------------------------------------------------------------------------
; MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN
;----------------------------------------------------------------------------
MSG_Flag_Invalid
I
I
I
I
I
I
;
MSG_Flag_Free
-
-
-
-
-
-
;
MSG_Flag_Used
U
B
U
U
U
U
;
MSG_Flag_Linked
L
L
L
L
L
L
;
MSG_Flag_Deleted
-
-
-
-
-
-
;
MSG_Comment_Free
Free
Frei
Libre
Libre
Livre
Puste
;
MSG_Comment_Invalid
Entry Invalid
Eintrag fehlerhaft
Entrée invalide
Entrada no válida
Entrada inválida
Wpis jest bîëdny
;
MSG_Region_EUR (//3)
EUR
EUR
EUR
EUR
EUR
EUR
;
MSG_Region_US (//3)
US
US
US
USA
EUA
USA
;
MSG_Region_JAP (//3)
JAP
JAP
JAP
JAP
JAP
JAP
;
MSG_Region_Unknown (//3)
UKN
UKN
UKN
UK
DES
???
;
MSG_Region_DEU (//3)
DEU
DEU
DEU
DEU
ALE
NIE
;
MSG_Region_ENG (//3)
ENG
ENG
ENG
ENG
ING
ANG
;
MSG_Region_FRA (//3)
FRA
FRA
FRA
FRA
FRA
FRA
;
MSG_Region_ESP (//3)
ESP
ESP
ESP
ESP
ESP
HIS
;
MSG_Region_SVE (//3)
SVE
SVE
SVE
SVE
SVE
SZW
;
MSG_Region_ITA (//3)
ITA
ITA
ITA
ITA
ITA
WÎO
;
MSG_Region_JPN (//3)
JAP
JAP
JAP
JAP
JAP
JAP
;
MSG_Region_NED (//3)
NED
NED
NED
NED
NED
HOL
;
;----------------------------------------------------------------------------
; Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult Mult
;----------------------------------------------------------------------------
MSG_Mult_WindowTitle
Memory Card Control !!
MemoryCard Control !!
Contrôle de la carte mémoire !!
MemoryCard Control
Controlo do MemoryCard !!
MemoryCard Control !!
;
MSG_Mult_Directory_GAD
Directory
Karteninhalt
Contenu
Directorio
Directório
Katalog
;
MSG_Mult_CardSlot_GAD
Slo_t
Slo_t
Slo_t
Slo_t
Slo_t
Gnia_zdo
;
MSG_Mult_CardType_GAD
T_ype
T_yp
T_ype
T_ipo
T_ipo
T_yp
;
MSG_Mult_Page1Up_GAD
Page: +_1
Seite: +_1
Page: +_1
Page: +_1
Página: +_1
Strona: +_1
;
MSG_Mult_Page10Up_GAD
Page: +1_0
Seite: +1_0
Page: +1_0
Page: +1_0
Página: +1_0
Strona: +1_0
;
MSG_Mult_Page1Down_GAD
P_age: -1
Se_ite: -1
P_age: -1
P_age: -1
Pá_gina: -1
Stron_a: -1
;
MSG_Mult_Page10Down_GAD
Pa_ge: -10
S_eite: -10
Pa_ge: -10
Pa_ge: -10
Pá_gina: +10
Stro_na: +10
;
MSG_Mult_ReadDirectory_GAD
Read _Directory
_Verzeichnis lesen
Lecture _contenu
Cargar _Directorio
Carregar o _Directório
W_czytaj Katalog
;
MSG_Mult_DownloadCard_GAD
Read _Card
_Karte lesen
Lecture c_arte
DesCargar _tarjeta
Carregar o Memory_Card
Wczytaj _Kartë
;
MSG_Mult_UploadCard_GAD
_Write Card...
Karte _schreiben...
_Ecriture carte...
_Escibir en la tarjeta...
_Escrever no MemoryCard...
Zapi_sz Na Karcie
;
MSG_Mult_MemoryCard_WindowTitle
Memory Card in Card slot %ld
MemoryCard im Karteneinschub %ld
Carte mémoire dans slot %ld
MemoryCard en el slot %ld
O MemoryCard está no slot %ld
MemoryCard w gnieúdzie %ld
;
MSG_Mult_File_WindowTitle
Memory Card from '%s'!
MemoryCard von '%s'!
Carte mémoire '%s'!
MemoryCard de '%s'
MemoryCard de '%s'
MemoryCard z '%s'!
;
MSG_Mult_Formatted_WindowTitle
Formatted Memory Card Buffer!
Formatierter MemoryCard Puffer!
Tampon de la carte mémoire formaté!
Buffer de la MemoryCard formateado
Buffer do MemoryCard formatado
Sformatowany Bufor MemoryCard!
;
;----------------------------------------------------------------------------
; Mult MENU Mult MENU Mult MENU Mult MENU Mult MENU Mult MENU Mult MENU Mult
;----------------------------------------------------------------------------
MSG_MENU_Mult_Project
Project
Projekt
Projet
Proyecto
Projecto
Projekt
;
MSG_MENU_Mult_NewWindow
New Window...
Neues Fenster...
Nouvelle fenêtre...
Ventana nueva...
Nova Janela...
Nowe Okno...
;
MSG_MENU_Mult_NewWindow_Key
N
N
N
N
N
N
;
MSG_MENU_Mult_Preferences
Preferences...
Voreinstellungen...
Préférences...
Preferencias...
Preferências...
Preferencje...
;
MSG_MENU_Mult_Preferences_Key
P
P
P
P
P
P
;
MSG_MENU_Mult_About
About...
Über...
A propos...
Sobre
Acerca...
O Programie...
;
MSG_MENU_Mult_About_Key
?
?
?
?
?
?
;
MSG_MENU_Mult_Quit
Quit
Beenden
Quitter
Quitar
Sair
Wyjôcie
;
MSG_MENU_Mult_Quit_Key
Q
Q
Q
Q
S
Q
;
MSG_MENU_Mult_MemoryCard
Memory Card
MemoryCard
Carte mémoire
MemoryCard
MemoryCard
MemoryCard
;
MSG_MENU_Mult_LoadImage
Load...
Laden...
Charger...
Cargar...
A carregar...
Wczytaj...
;
MSG_MENU_Mult_LoadImage_Key
O
O
O
O
A
O
;
MSG_MENU_Mult_SaveImage
Save...
Speichern...
Sauver...
Grabar...
A gravar...
Zapisz...
;
MSG_MENU_Mult_SaveImage_Key
S
S
S
S
G
S
;
MSG_MENU_Mult_Export
Export
Exportieren
Exporter
Exportar
Exportar
Eksportuj
;
MSG_MENU_Mult_AsImageFile
As Image (.mcd)...
als Image (.mcd)...
en tant qu'image (.mcd)...
Como imagen (.mcd)...
Como uma imagem (.mcd)...
Jako Obraz (.mcd)...
;
MSG_MENU_Mult_AsImageFile_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_AsGameFile
As Game (.gme)...
als Game (.gme)...
en tant que Game (.gme)...
Como Juego (.gme)...
Como um Jogo (.gme)...
Jako Grë (.gme)...
;
MSG_MENU_Mult_AsGameFile_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_AsVgsFile
As VideoGameStrategies (.vgs)...
als VideoGameStrategies (.vgs)...
en tant que VideoGameStrategies (.vgs)...
Como VideoGameStrategies (.vgs)...
Como Jogos de Video de Estratégia (.vgs)...
Jako VideoGameStrategies (.vgs)...
;
MSG_MENU_Mult_AsVgsFile_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Directory
Directory (ASCII)...
Verzeichnis (ASCII)...
Contenu (ASCII)...
Directorio (ASCII)...
Directório (ASCII)...
Katalog (ASCII)...
;
MSG_MENU_Mult_Directory_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_ReadDirectory
Read Directory
Verzeichnis lesen
Lecture contenu
Leer Directorio
Ler o Directório
Wczytaj Katalog
;
MSG_MENU_Mult_ReadDirectory_Key
D
D
D
D
D
D
;
MSG_MENU_Mult_DownloadCard
Read Card
Karte lesen
Lecture carte
Cargar Tarjeta
Carregar o MemoryCard
Wczytaj Kartë
;
MSG_MENU_Mult_DownloadCard_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_UploadCard
Write Card...
Karte schreiben...
Ecriture carte...
Grabar Tarjeta...
Gravar o MemoryCard
Zapisz na Karcie...
;
MSG_MENU_Mult_UploadCard_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_FormatBuffer
Complete Format
Komplett formatieren
Formatage complet
Formateado completo
Formatação completada
Formatuj Bufor
;
MSG_MENU_Mult_FormatBuffer_Key
F
F
F
F
F
F
;
MSG_MENU_Mult_QuickFormatBuffer
Quick Format
Schnell formatieren
Formatage rapide
Formateado rápido
Formatação rápida
Szybki Format
;
MSG_MENU_Mult_QuickFormatBuffer_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Optimize
Clean Up
Aufräumen
Réorganiser
Clean Up
Organizar
Optymalizuj
;
MSG_MENU_Mult_Optimize_Key
C
C
C
C
O
C
;
MSG_MENU_Mult_Repair
Repair
Reparieren
Réparation
Repair
Reparar
Napraw
;
MSG_MENU_Mult_Repair_Key
R
R
R
R
R
R
;
MSG_MENU_Mult_MultiPageNext1
Card page: next
Kartenseite: nächste
Page de la carte: suivante
Card page: next
Página seguinte do MemoryCard:
Strona: nastëpna
;
MSG_MENU_Mult_MultiPageNext1_Key
2
2
2
2
2
2
;
MSG_MENU_Mult_MultiPagePrev1
Card page: previous
Kartenseite: vorherige
Page de la carte: précédente
Card page: previous
Página anterior do MemoryCard:
Strona: poprzednia
;
MSG_MENU_Mult_MultiPagePrev1_Key
1
1
1
1
1
1
;
MSG_MENU_Mult_MultiPageNext10
Card page: +10
Kartenseite: +10
Page de la carte: +10
Card page: +10
Página do MemoryCard: +10
Strona: +10
;
MSG_MENU_Mult_MultiPageNext10_Key
4
4
4
4
4
4
;
MSG_MENU_Mult_MultiPagePrev10
Card page: -10
Kartenseite: -10
Page de la carte: -10
Card page: -10
Página do MemoryCard: -10
Strona: -10
;
MSG_MENU_Mult_MultiPagePrev10_Key
3
3
3
3
3
3
;
MSG_MENU_Mult_SaveGames
Save Games
Spielstände
Sauvegardes de jeux
Partidas
Jogos Gravados
Stany Gier
;
MSG_MENU_Mult_LoadSGame
Load...
Laden...
Charger...
Cargar...
Carregar...
Wczytaj...
;
MSG_MENU_Mult_LoadSGame_Key
L
L
L
L
C
L
;
MSG_MENU_Mult_SaveSGame
Save...
Speichern...
Sauver...
Grabar...
Gravar...
Zapisz...
;
MSG_MENU_Mult_SaveSGame_Key
K
K
K
K
K
K
;
MSG_MENU_Mult_SaveAllSGames
Save all Files...
Speichere alles...
Sauver tous les fichiers...
Grabar todos los ficheros...
Gravar todos os Ficheiros...
Zapisz wszystkie Pliki...
;
MSG_MENU_Mult_SaveAllSGames_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_AsPSX
As PSX File (.psx)...
als PSX-Datei (.psx)...
en tant que fichier PSX (.psx)...
Como fichero PSX (.psx)...
Como um Ficheiro (.psx)...
Jako plik PSX (.psx)...
;
MSG_MENU_Mult_AsPSX_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_AsMEM
As MEM File (.mem & .txt)...
als MEM-Datei (.mem & .txt)...
en tant que fichier MEM (.mem & .txt)...
Como fichero MEM (.mem & .txt)...
Como um Ficheiro (.mem & .txt)...
Jako plik MEM (.mem i .txt)...
;
MSG_MENU_Mult_AsMEM_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_DeleteSGame
Delete File
Datei löschen
Effacer fichier
Borrar fichero
Apagar o Ficheiro
Usuï Plik
;
MSG_MENU_Mult_DeleteSGame_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_UndeleteSGame
Undelete File
Datei wiederherstellen
Récupérer fichier
Recuperar fichero
Recuperar o Ficheiro
Przywróê Plik
;
MSG_MENU_Mult_UndeleteSGame_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_DeleteAllSGames
Delete all Files
Alle Dateien löschen
Effacer tous les fichiers
Borrar todos los ficheros
Apagar todos os Ficheiros
Usuï wszystkie Pliki
;
MSG_MENU_Mult_DeleteAllSGames_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_UndeleteAllSGames
Undelete all Files
Alle Dateien wiederherstellen
Récupérer tous les fichiers
Recuperar todos los ficheros
Recuperar todos os Ficheiros
Przywróê wszystkie Pliki
;
MSG_MENU_Mult_UndeleteAllSGames_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_ConvertSGame
Patch File...
Datei manipulieren...
Patcher le fichier...
Parchear fichero...
Configurar o Ficheiro...
Konwersja Plików...
;
MSG_MENU_Mult_ConvertSGame_Key
M
M
M
M
M
M
;
MSG_MENU_Mult_Bonus
Bonus
Bonus
Bonus
Bonus
Bonus
Dodatki
;
MSG_MENU_Mult_SavePSXImage
Save PSX Image
PSX Piktogramm speichern
Save PSX Image
Save PSX Image
Gravar a imagem da PSX
Zapisz Obrazek PSX
;
MSG_MENU_Mult_AspectAuto
Aspect: Auto
Seitenverhältniss: Auto
Aspect: Auto
Aspect: Auto
Aspecto: Automático
Rozmiar: Automatyczny
;
MSG_MENU_Mult_AspectAuto_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Aspect11
Aspect: 1:1
Seitenverhältniss: 1:1
Aspect: 1:1
Aspect: 1:1
Aspecto: 1:1
Rozmiar: 1:1
;
MSG_MENU_Mult_Aspect11_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Aspect22
Aspect: 2:2
Seitenverhältniss: 2:2
Aspect: 2:2
Aspect: 2:2
Aspecto: 2:2
Rozmiar: 2:2
;
MSG_MENU_Mult_Aspect22_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Aspect21
Aspect: 2:1
Seitenverhältniss: 2:1
Aspect: 2:1
Aspect: 2:1
Aspecto: 2:1
Rozmiar: 2:1
;
MSG_MENU_Mult_Aspect21_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_Aspect12
Aspect: 1:2
Seitenverhältniss: 1:2
Aspect: 1:2
Aspect: 1:2
Aspecto: 1:2
Rozmiar: 1:2
;
MSG_MENU_Mult_Aspect12_Key
§
§
§
§
§
§
;
MSG_MENU_Mult_EditHex
Edit Hex...
Hex Editor...
Edit Hex...
Edit Hex...
Edit Hex...
Edit Hex...
;
MSG_MENU_Mult_EditHex_Key
E
E
E
E
E
E
;
;----------------------------------------------------------------------------
; SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT SETT
;----------------------------------------------------------------------------
MSG_Sett_WindowTitle
MCControl Preferences
MCControl Voreinstellungen
Préférences pour MCControl
Preferencias de MCControl
Preferências do MCControl
MCControl - Preferencje
;
MSG_Sett_Hardware_GAD
Hardware
Hardware
Hardware
Hardware
Hardware
Hardware
;
MSG_Sett__Hardware_GAD
_Hardware
_Hardware
_Hardware
_Hardware
_Hardware
_Hardware
;
MSG_Sett_Driver_GAD
_Driver
_Treiber
_Pilote
_Driver
_Gestor
_Sterownik
;
MSG_Sett_DriverInfo_GAD
Driver info
Treiberinfo
Info pilote
Driver info
Info do Gestor
Informacje
;
MSG_Sett_Device_GAD
Dev_ice
_Device
Pé_riphérique
_Dispositivo
_Dispositivo
Urzâdzen_ie
;
MSG_Sett_Retries_GAD
_Retries:\x20\x20\x20
V_ersuche:\x20\x20\x20
_Ré-essais:\x20\x20\x20
_Retries:\x20\x20\x20
_Reentradas:\x20\x20\x20
P_róby:\x20\x20\x20
;
MSG_Sett_MultiReader_GAD
_Number of Slots:
Anzahl der E_inschübe:
_Nombre de Slots:
_Number of Slots:
Número de Slots:
Liczba g_niazd:
;
MSG_Sett_QuickFrames_GAD
_Quick Access
S_chneller Zugriff
A_ccès rapide
Acceso _rápido
Acesso _rápido
Szy_bki dostëp
;
MSG_Sett_YourCards_GAD
Your Cards
Ihre Karten
Vos cartes
Tus tarjetas
O seu MemoryCard
Twoje Karty
;
MSG_Sett_OtherCards_GAD
Default Cards
Kartenstapel
Cartes par défaut
Tarjetas por defecto
MemoryCard Pré-definido
Karty Domyôlne
;
MSG_Sett_EditCard_GAD
_Edit Card...
_Karte editieren...
_Editer carte...
_Editar Tarjeta...
_Editar o MemoryCard
_Edycja Karty...
;
MSG_Sett_XPK_GAD
XPK
XPK
XPK
XPK
XPK
XPK
;
MSG_Sett__XPK_GAD
_XPK
_XPK
_XPK
_XPK
_XPK
_XPK
;
MSG_Sett_XPKPacking_GAD
_XPK compression
_XPK Komprimierung
_Compression XPK
Compresión _XPK
Compressão _XPK
Kompresuj _XPK
;
MSG_Sett_XPKPackMethod_GAD
M_ethod
_Methode
_Méthode
_Método
_Método
_Metoda
;
MSG_Sett_GUI_GAD
GUI
Oberfläche
GUI
GUI
GUI
GUI
;
MSG_Sett__GUI_GAD
_GUI
_Oberfläche
_GUI
_GUI
_GUI
_GUI
;
MSG_Sett_GUIFont_GAD
_GUI Font
_Oberflächenschrift
_Fonte interface
_Fuente del GUI
_Tipos de letra da GUI
Font _GUI
;
MSG_Sett_Directory_GAD
_Directory entry
Ver_zeichnisaufbau
_Contenu
_Directorio
_Directório de registo
Wyôwietlaj
;
MSG_Sett_DisplayPSXImage_GAD
Display PSX _Image
_PSX Piktogramm anzeigen
Afficher Image PSX
Display PSX _Image
Display PSX _Image
Pokazuj _Ikonkë PSX
;
MSG_Sett_NamesFromDataBase_GAD
_Names from Database
_Namen aus Datenbank
_Noms d'après les BdD
_Names from Database
_Nomes da Base-de-dados
_Nazwy z Bazy Danych
;
MSG_Sett_RegionsFromDataBase_GAD
_Regions from Database
_Regionen aus Datenbank
Régions d'après les _BdD
Regions from _Database
_Regiões da Base-de-dados
_Regiony z Bazy Danych
;
MSG_Sett_FileNamesFromDataBase_GAD
_Filenames from Database
_Dateinamen aus Datenbank
No_ms de fichiers des BdD
_Filenames from Database
Nomes _Fich. da Base-de-dados
Nazwy _Plików z Bazy Danych
;
MSG_Sett_LinkBlockRegionID_GAD
_Link block information
_Link Block Informationen
_Information blocs de lien
_Link block information
Info. do bloco de _Ligação
Info o b_lokach îâczonych
;
MSG_Sett_ShowPageGadgets_GAD
Show _Page Flip Gadgets
Seiten_wechselknöpfe zeigen
Montrer les options de _page
Show _Page Flip Gadgets
Mostrar as opções da página
_Pokaû klawisze stron
;
MSG_Sett_Misc_GAD
Miscellaneous
Verschiedenes
Divers
Varios
Diversos
Róûne
;
MSG_Sett__Misc_GAD
_Miscellaneous
_Verschiedenes
_Divers
_Varios
_Diversos
_Róûne
;
MSG_Sett_SetFileNote_GAD
Se_t Filenote
_Dateikommentar setzen
A_jouter commentaire
Set _Filenote 
Pôr um _Comentário
Dodaj Kom_entarz
;
MSG_Sett_Editor_GAD
Hex _Editor
Hex _Editor
Hex _Editor
Hex _Editor
Hex _Editor
Hex Editor
;
MSG_Sett_Icons_GAD
_Icons
_Piktogramme
Résolution _icônes
_Icons
_Ícones
_Ikonki
;
MSG_Sett_Save_GAD
_Save
_Speichern
_Sauver
_Grabar
_Gravar
_Zapisz
;
MSG_Sett_Cancel_GAD
_Cancel
_Abbrechen
_Annuler
_Cancelar
_Cancelar
_Anuluj
;
MSG_Sett_Use_GAD
_Use
_Benutzen
_Utiliser
_Utilizar
_Usar
_Uûyj
;
;----------------------------------------------------------------------------
; SETT MENU SETT MENU SETT MENU SETT MENU SETT MENU SETT MENU SETT MENU SETT
;----------------------------------------------------------------------------
MSG_MENU_Sett_Project
Project
Projekt
Projet
Proyecto
Projecto
Projekt
;
MSG_MENU_Sett_Open
Open...
Öffnen...
Ouvrir...
Abrir...
Abrir...
Otwórz...
;
MSG_MENU_Sett_Open_Key
O
O
O
O
A
O
;
MSG_MENU_Sett_Save
Save...
Speichern...
Sauver...
Grabar...
Gravar...
Zapisz...
;
MSG_MENU_Sett_Save_Key
S
S
S
S
G
S
;
MSG_MENU_Sett_SaveAs
Save As...
Speichern Als...
Sauver en...
Grabar Como...
Gravar Como...
Zapisz Jako...
;
MSG_MENU_Sett_SaveAs_Key
A
A
A
A
C
A
;
MSG_MENU_Sett_Edit
Edit
Vorgaben
Editer
Editar
Editar
Edycja
;
MSG_MENU_Sett_ResetToDefault
Reset to Default
Auf Vorgaben zurücksetzen
Valeurs par défaut
Valores por defecto
Voltar à configuração Pré-Definida
Przywróê domyôlne
;
MSG_MENU_Sett_ResetToDefault_Key
Z
Z
Z
Z
Z
Z
;
MSG_MENU_Sett_LastSaved
Last saved
Auf zuletzt gespeichertes
Dernières valeurs sauvées
Últimos valores grabados
Última Configuração Gravada
Ostatnio zapisane
;
MSG_MENU_Sett_LastSaved_Key
L
L
L
L
U
L
;
MSG_MENU_Sett_LastUsed
Last used
Auf zuletzt benutztes
Dernières valeurs utilisées
Útlimos valores utilizados
Última Configuração utilizada
Ostatnio uûywane
;
MSG_MENU_Sett_LastUsed_Key
R
R
R
R
R
R
;
MSG_MENU_Sett_SaveCardAsDefault
Save Card...
Karte Speichern...
Sauver carte...
Grabar Tarjeta...
Gravar o MemoryCard...
Zapisz Kartë...
;
MSG_MENU_Sett_SaveCardAsDefault_Key
§
§
§
§
§
§
;
;----------------------------------------------------------------------------
; ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU ABOU
;----------------------------------------------------------------------------
MSG_Abou_WindowTitle
About...
Über...
A propos...
Sobre...
Acerca...
O Programie...
;
MSG_Abou_Ok_GAD
_OK
_Ok
_Ok
_OK
_Certo
_OK
;
;----------------------------------------------------------------------------
; PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC PATC
;----------------------------------------------------------------------------
MSG_Patc_WindowTitle
Save Game Patcher...
Der Spieldatei Manipulierer...
Patcheur...
Grabar parche...
Gravar a Configuração do Jogo
Konwersja Pliku...
;
MSG_Patc_GameName_GAD
Game
Spiel
Jeu
Juego
Jogo
Gra
;
MSG_Patc_AuthorName_GAD
Author
Autor
Auteur
Autor
Autor
Autor
;
MSG_Patc_SelectID_GAD
Select ID
ID Auswahl
Sélection ID
Elige ID
Seleccione o ID
Wybierz ID
;
MSG_Patc_ProductID_GAD
Product ID
Produkt ID
ID Produit
ID del Producto
ID do Produto
ID Produktu
;
MSG_Patc_Patch_GAD
Patch
Manipulieren
Patcher
Parchear
Configurar
Dalej!
;
MSG_Patc_Cancel_GAD
Cancel
Abbrechen
Annuler
Cancelar
Cancelar
Anuluj
;
;----------------------------------------------------------------------------
; Card Card Card Card Card Card Card Card Card Card Card Card Card Card Card
;----------------------------------------------------------------------------
MSG_Card_WindowTitle
The Card Wizard
Der Karteneditor
Assistant pour cartes
Editor de Tarjetas
Editor de MemoryCards
Edycja Karty
;
MSG_Card_Name_GAD
_Name
N_ame
_Nom
_Nombre
_Nome
_Nazwa
;
MSG_Card_MultiPageStart_GAD
_Start
_Start
Dé_marrer
Iniciar
_Iniciar
_Start
;
MSG_Card_MultiPageUp_GAD
_Page Up
_nächste Seite
Page _Haut
Subir página
_Subir uma Página
_Strona wyûej
;
MSG_Card_MultiPageDown_GAD
Page _Down
_vorherige Seite
Page Ba_s
Bajar página
_Descer uma Página
Strona _Niûej
;
MSG_Card_MultiPageEnd_GAD
_End
_Ende
_Fin
_Fin
_Fim
_Koniec
;
MSG_Card_Use_GAD
_Use
_Benutzen
_Utiliser
_Utilizar
_Usar
_Uûyj
;
MSG_Card_Cancel_GAD
_Cancel
_Abbrechen
_Annuler
_Cancelar
_Cancelar
_Anuluj
;
MSG_Card_Bark_MultiPage
\x20Multipage Support\x20
\x20Multipage Unterstützung\x20
\x20Support Multipage\x20
\x20Soporte Multipage\x20
\x20Suporte para Multi-página\x20
\x20Multipage Support\x20
;
;----------------------------------------------------------------------------
; REQUESTER REQUESTER REQUESTER REQUESTER REQUESTER REQUESTER REQUESTER
;----------------------------------------------------------------------------
MSG_REQ_Title
MCControl Request
MCControl Meldung
Requête de MCControl
Petición de MCControl
Petição do MCControl
Requester MCControl
;
MSG_REQ_Ok
Ok
Ok
Ok
Ok
Certo
Ok
;
MSG_REQ_WriteCancel
Write|Cancel
Schreiben|Abbrechen
Ecrire|Annuler
Grabar|Cancelar
Gravar|Cancelar
Zapisz|Anuluj
;
MSG_REQ_ProceedCancel
Proceed|Cancel
Fortfahren|Abbrechen
Continuer|Annuler
Proceder|Cancelar
Continuar|Cancelar
Kontynuuj|Anuluj
;
MSG_REQ_YesNo
Yes|No
Ja|Nein
Oui|Non
Yes|No
Sim|Não
Tak|Nie
;
MSG_REQ_ProceedAllSelectAbort
Proceed|All|Select|Cancel
Fortfahren|Alle|Auswählen|Abbrechen
Continuer|Tous|Choisir|Annuler
Proceder|All|Elegir|Cancelar
Continuar|Todos|Seleccionar|Cancelar
Kontynuuj|Wszystkie|Wybierz|Anuluj
;
MSG_REQ_LibNotFound
Unable to open '%s'!
Kann die '%s' nicht öffnen!
Impossible d'ouvrir '%s'!
No puedo abrir '%s'
Não foi possivel abrir '%s'!
Nie mogë otworzyê '%s'!
;
;----------------------------------------------------------------------------
; REAL USED Messages
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
MSG_REQ_OpenError
Unable to open\n'%s'!
Kann die Datei\n'%s' nicht öffnen!
Impossible d'ouvrir\n'%s'!
No puedo abrir\n'%s'
Não foi possivel abrir\n'%s'!
Nie mogë otworzyê\n'%s'!
;
MSG_REQ_XPKLoadError
Error while reading\n'%s'!
Fehler beim Laden der Datei\n'%s'!
Erreur en lisant\n'%s'!
Error leyendo\n'%s'
Erro ao ler\n'%s'!
Bîâd podczas odczytu\n'%s'!
;
MSG_REQ_XPKSaveError
Error while writing\n'%s'!
Fehler beim Speichern der Datei\n'%s'!
Erreur en écrivant\n'%s'!
Error grabando\n'%s'
Erro ao gravar\n'%s'
Bîâd podczas zapisu\n'%s'!
;
MSG_REQ_NotaMemoryCardFile
'%s' is not a Memory Card Image!
'%s' ist kein MemoryCard Abbild!
'%s' n'est pas une image de carte mémoire!
'%s' no es una imagen de MemoryCard
'%s' não é uma Imagem de MemoryCard!
'%s' nie jest Obrazem Karty!
;
MSG_REQ_NotaPSXSaveGameFile
'%s' is not a valid .PSX file!
'%s' ist keine gültige .PSX Datei!
'%s' n'est pas un fichier .PSX valide!
'%s' no es un fichero .PSX válido
'%s' não é um ficheiro .PSX válido!
'%s' nie jest plikiem .PSX!
;
MSG_REQ_XPKSystemRequired
'%s' is compressed!\n\nPlease install XPK the system!
'%s' ist komprimiert!\n\nBitte installieren Sie das XPK Paket!
'%s' is compressed!\n\nPlease install XPK the system!
'%s' is compressed!\n\nPlease install XPK the system!
'%s' is compressed!\n\nPlease install XPK the system!
'%s' jest skompresowany!\n\nMusisz zainstalowac pakiet XPK w swoim systemie!
;
MSG_REQ_ReadError
Error while reading\n'%s'!
Fehler beim Lesen von\n'%s'!
Erreur en lisant\n'%s'!
Error leyendo\n'%s'
Erro ao ler\n'%s'!
Bîâd podczas odczytu\n'%s'!
;
MSG_REQ_WriteError
Error while writing\n'%s'!
Fehler beim Schreiben\nvon '%s'!
Erreur en écrivant '%s'!
Error grabando\n'%s'
Erro ao gravar\n'%s'!
Bîâd podczas zapisu\n'%s'!
;
MSG_REQ_CardReadError
Card reading failed!\nPlease check your hardware\nand your preferences!
Lesen der Karte fehlgeschlagen!\nPrüfen Sie die Hardware\nund die Voreinstellungen!
La lecture de la carte a échoué!\nVérifiez votre lecteur ou\naugmentez les préférences!
Fallo de lectura!\nComprueba el hardware y\nlas preferencias!
Falha ao ler o MemoryCard!\nPor favor verifique o hardware\ne as preferências?
Nie mogë odczytaê karty!\nSprawdú swój sprzët\noraz preferencje!
;
MSG_REQ_CardWriteError
Card writing failed!\nPlease check your hardware\nand your preferences!
Beschreiben der Karte fehlgeschlagen!\nPrüfen Sie die Hardware\nund die Voreinstellungen!
L'écriture de la carte a échoué!\nVérifiez votre lecteur ou\naugmentez les préférences!
Fallo de escritura!\nComprueba el hardware y\nlas preferencias
Falha ao escrever no MemoryCard!\nPor favor verifique o hardware\ne as preferências?
Nie mogë zapisaê karty!\nSprawdú swój sprzët\noraz preferencje!
;
MSG_REQ_NoBlocksFree
This card is full!
Auf dieser Karte ist\nkein Block frei!
Il n'y a aucun bloc libre sur cette carte!
!La tarjeta está llena¡
Este MemoryCard está cheio!
Brak pustych bloków na karcie!
;
MSG_REQ_NotEnoughBlocksFree
The file to copy is bigger than the amount of space!
Die Länge der Datei ist größer als der freie Platz!
Il n'y a pas assez de place pour copier le fichier!
!El fichero es demasiado grande¡
O ficheiro a copiar é maior que o espaço disponível!
Kopiowany plik jest wiëkszy niû\nniû dostëpna iloôê wolnych bloków!
;
MSG_REQ_LinkBlockInvalid
Unable to find the link\ntop of this block!
Kann den ersten Block dieser Kette nicht finden!
Impossible de trouver le lien supérieur de ce bloc!
!No encuentro el enlace\nsuperior del bloque¡
Foi impossivel encontrar a ligação\nna parte superior deste bloco!
Nie mogë znaleúê pierwszego bloku tego pliku!
;
MSG_REQ_LinkBlockOutOfRange
Link block out of Range!
Verkettungsnummer zu groß!
Bloc de lien hors d'atteinte!
!Bloque de enlace fuera de rango¡
Bloco de ligação fora de Alcance!
Doîâczony blok jest poza zakresem!
;
MSG_REQ_LinkToTopBlock
Top block linked!
Kopfblock wurde verkettet!
Bloc supérieur relié!
Bloque superior enlazado
Bloco Superior ligado!
Górny blok doîâczony!
;
MSG_REQ_LinkLoop
Link Loop detected!
Verkettungsschleife gefunden!
Lien en boucle détecté!
Pista de enlace detectada
Pista de ligação detectada!
Wykryîem pëtle îâczenia!
;
MSG_REQ_UnknownBlockType
Unknown block type!
Unbekannter Block Typ!
Bloc de type inconnu!
Tipo de bloque desconocido
Tipo de bloco desconhecido!
Nieznany rodzaj bloku!
;
MSG_REQ_UnexpectedLinkEnd
Unexpected link end!
Unerwartetes Verkettungsende!
Fin du lien inattendue!
Fin de enlace inesperado
Fim inesperado da ligação!
Niespodziewane zakoïczenie pliku!
;
MSG_REQ_AreYouSureToSaveChangesToCard
Do you want to save\nchanges to Memory Card?
Wollen Sie die MemoryCard\nwirklich aktualisieren?
Voulez-vous enregistrer les changements\nsur la carte mémoire ?
¿Quieres grabar los cambios\nen la tarjeta?
Deseja gravar as configurações\nno MemoryCard?
Czy chcesz zapisaê\nzmiany na Kartë?
;
MSG_REQ_AreYouSureToOverwriteYourCard
Do you wan´t to\noverwrite whole Memory Card?
Wollen Sie wirklich die\nganze MemoryCard überschreiben?
Voulez-vous réécrire la carte mémoire complète ?
¿Quieres sobreescribir\n toda la tarjeta?
Deseja substituir\ntodo o MemoryCard?
Czy chcesz zapisaê\ncaîâ Kartë?
;
MSG_REQ_CardRepairedQuickAccess
The card buffer is repaired, but the\n'quick access' feature is activated!\nIt's required to deactivate this feature\nbefore you write back the card data!\n\nDeactivate 'quick access' now?
Der Kartenpuffer wurde repariert, aber der\n'schnelle Zugriff' ist aktiviert! Es ist\nnötig diesen Modus abzuschalten, bevor Sie\ndie Karte zurückschreiben!\n\n'Schnellen Zugriff' jetzt abschalten?
Le tampon de la carte est réparé mais\nl'accès rapide est activé!\nVous devez désactiver cette option avant\n d'écrire sur la carte!\n\nVoulez-vous désactiver l'accès rapide maintenant?
The card buffer is repaired, but the\n'quick access' feature is activated!\nIt's required to deactivate this feature\nbefore you write back the card data!\n\nDeactivate 'quick access' now?
O buffer do MemoryCard foi reparado, mas a\ncaracterística ´acesso rápido´ está activada!\nTem que desactivar esta característica\nantes de poder escrever de novo dados no MemoryCard!\n\nDesactivar o 'acesso rápido' agora?
Bufor jest naprawiony, ale opcja\n'szybki dostëp' jest wîâczona!\nMusisz jâ wyîâczyê zanim\nzapiszesz swojâ Kartë!\n\nWyîâczyê teraz 'szybki dostëp'?
;
MSG_UnexpectedBracket
Unexpected Bracket!
Unerwartete Klammer!
Accolade inattendue
Paréntesis inseperado
Paréntesis inseperado
Niespodziewany nawias!
;
MSG_UnexpectedEnd
Unexpected End!
Unerwartetes Ende!
Fin inattendue!
Final inesperado
Fim inesperado!
Niespodziewany koniec!
;
MSG_REQ_FileAlreadyExists
File '%s'\nalready exists!
Datei '%s'\nexistiert bereits!
Le fichier '%s'\nexiste déjà!
El fichero '%s'\ya existe
O ficheiro '%s'\njá existe!
Plik '%s'\njuû istnieje!
;
;----------------------------------------------------------------------------
; ASL ASL ASL ASL ASL ASL ASL
;----------------------------------------------------------------------------
MSG_ASL_SelectFileToSaveAs
Select File to Save As
Zu speichernde Datei angeben
Choisissez le fichier à sauver
Elige nombre del fichero a grabar
Seleccione o Ficheiro a Gravar Como
Wybierz Plik aby zapisaê jako...
;
MSG_ASL_SelectDrawerToSaveAs
Select destination drawer
Wählen Sie das Zielverzeichnis
Choisissez le répertoire de destination
Elige el cajón de destino
Seleccione a gaveta de destino
Wybierz docelowy Katalog
;
MSG_ASL_SelectFileToOpen
Select File to Open
Zu öffnende Datei angeben
Choisissez le fichier à ouvrir
Elige el fichero
Seleccione o Ficheiro a Abrir
Wybierz Plik do wczytania
;
MSG_UnableToCreatePort
Unable to create port!
Kann keinen Port öffnen!
Impossible de créer le port!
No puedo crear puerto
Não foi possivel criar a porta!
Nie mogë otworzyê Portu!
;
MSG_UnableToCreateIORequest
Unable to create IO request!
Kann keinen IO Request erzeugen!
Impossible de créer la requête IO!
No puedo crear petición I/O
Não foi possivel criar petição ID!
Nie mogë rozpoczâê operacji WE/WY!
;
MSG_UnableToOpenDevice
Unable to open device\n'%s'!
Kann Gerät '%s' nicht öffnen!
Impossible d'ouvrir le périphérique\'%s'!
No puedo abrir dispositivo\n'%s'
Não foi possivel abrir o dispositivo\n'%s'!
Nie mogë otworzyê urzâdzenia\n'%s'!
;
MSG_REQ_OutOfMemory
Out of Memory!
Nicht genügend Speicherplatz vorhanden!
Mémoire insuffisante!
No hay memoria
Não há memória suficiente!
Brak Pamiëci!
;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
MSG_Time_ReadWholeCard
Reading whole Card...
Lese die ganze Karte...
Lecture de la carte complète...
Leyendo la tarjeta completamente...
A ler todo o Memorycard...
Wczytujë caîâ Kartë...
;
MSG_Time_WriteWholeCard
Writing whole Card...
Schreibe die ganze Karte...
Ecriture de la carte complète...
Grabando toda la tarjeta...
A gravar todo o MemoryCard...
Zapisujë caîâ Kartë...
;
MSG_Time_ReadDirectory
Reading Card Directory...
Lese Kartenverzeichnis...
Lecture du contenu de la carte...
Leyendo directorio de tarjeta...
A ler o directório do MemoryCard...
Wczytujë Katalog Karty...
;
MSG_Time_ReadingNeededBlocks
Reading needed Data...
Lese benötigte Daten...
Lecture des données requises...
Leyendo datos necesarios...
A ler os dados necessários...
Wczytujë potrzebne Dane...
;
MSG_Time_WritingNeededBlocks
Writing changed Data...
Schreibe die veränderten Daten...
Ecriture des données modifiées...
Grabando datos modificados...
A gravar os dados que foram modificados...
Zapisujë zmienione Dane...
;
MSG_Time_ReadingFrame
Reading Frame %ld/%ld (Errors: %ld)
Lese Bereich %ld/%ld (Fehler: %ld)
Lecture de la structure %ld/%ld (Erreurs: %ld)
Leyendo Bloque %ld/%ld (Errores: %ld)
A ler o Bloco %ld/%ld (Erros: %ld)
Wczytujë komórkë %ld/%ld (Bîëdy: %ld)
;
MSG_Time_WritingFrame
Writing Frame %ld/%ld (Errors: %ld)
Schreibe Bereich %ld/%ld (Fehler: %ld)
Ecriture de la structure %ld/%ld (Erreurs: %ld)
Grabando Bloque %ld/%ld (Errores: %ld)
A gravar o Bloco %ld/%ld (Erros: %ld)
Zapisujë komórkë %ld/%ld (Bîëdy: %ld)
;
MSG_Time_ReadingDir
Reading Directory %ld/%ld (Errors: %ld)
Lese Directory %ld/%ld (Fehler: %ld)
Lecture du contenu %ld/%ld (Erreurs: %ld)
Leyendo directorio %ld/%ld (Errores: %ld)
A ler o directório %ld/%ld (Erros: %ld)
Wczytujë Katalog %ld/%ld (Bîëdy: %ld)
;
MSG_Time_ReadingImages
Reading Images %ld/%ld (Errors: %ld)
Lese Bilder %ld/%ld (Fehler: %ld)
Reading Images %ld/%ld (Errors: %ld)
Reading Images %ld/%ld (Errors: %ld)
Reading Images %ld/%ld (Errors: %ld)
Wczytujë Obrazki %ld/%ld (Bîëdy: %ld)
;
MSG_Time_Abort_GAD
_Abort
_Abbrechen
_Annuler
_Abortar
_Abortar
_Anuluj
;
MSG_Time_Aborted
Card access aborted by user!
Der Kartenzugriff wurde manuell abgebrochen!
Accès à la carte suspendu par l'utilisateur!
Acceso a tarjeta abortado por el usuario
Acesso ao MemoryCard abortado pelo utilizador!
Dostëp do Karty anulowany przez uûytkownika!
;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYCLE CYC
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
MSG_CY_1
1
1
1
1
1
1
;
MSG_CY_2
2
2
2
2
2
2
;
MSG_CY_3
3
3
3
3
3
3
;
MSG_CY_4
4
4
4
4
4
4
;
MSG_CY_Name
Name
Name
Nom
Name
Nome
Nazwë
;
MSG_CY_NameProductID
Name,ProductID
Name,ProduktID
Nom,ID produit
Name,ID producto
Nome,ID do Produto
Nazwë, ID Produktu
;
MSG_CY_NameRegion
Name,Region
Name,Region
Nom,Région
Name,Región
Nome,Região
Nazwë, Region
;
MSG_CY_NameProductIDRegion
Name,ProductID,Region
Name,ProduktID,Region
Nom,ID produit,Région
Name,ID producto,Región
Nome,ID do produto,Região
Nazwë, ID Produktu, Region
;
MSG_CY_NameRegionProductID
Name,Region,ProductID
Name,Region,ProduktID
Nom,Région,ID produit
Name,Región,ID producto
Nome,Região,ID do produto
Nazwë, Region, ID Produktu
;
MSG_CY_ProductIDNameRegion
ProductID,Name,Region
ProduktID,Name,Region
ID produit,Nom,Région
ID producto,Name,Región
ID do produto,Nome,Região
ID Produktu, Nazwë, Region
;
MSG_CY_RegionNameProductID
Region,Name,ProductID
Region,Name,ProduktID
Région,Nom,ID produit
Región,Name,ID producto
Região,Nome,ID do produto
Region, Nazwë, ID Produktu
;
MSG_CY_ProductIDRegionName
ProductID,Region,Name
ProduktID,Region,Name
ID produit,Région,Nom
ID producto,Región,Name
ID do produto,Região,Nome
ID Produktu, Region, Nazwë
;
MSG_CY_RegionProductIDName
Region,ProductID,Name
Region,ProduktID,Name
Région,ID produit,Nom
Región,ID producto,Name
Região,ID do produto,Nome
Region, ID Produktu, Nazwë
;
MSG_CY_Icon11
Save, aspect 1:1
Speichern, Seitenverhältnis 1:1
Sauver en 1:1
Save, aspect 1:1
Gravar, com o tamanho 1:1
Zapisuj, rozmiar 1:1
;
MSG_CY_Icon22
Save, aspect 2:2
Speichern, Seitenverhältnis 2:2
Sauver en 2:2
Save, aspect 2:2
Gravar, com o tamanho 2:2
Zapisuj, rozmiar 2:2
;
MSG_CY_Icon21
Save, aspect 2:1
Speichern, Seitenverhältnis 2:1
Sauver en 2:1
Save, aspect 2:1
Gravar, com o tamanho 2:1
Zapisuj, rozmiar 2:1
;
MSG_CY_DefaultIcons
Save, use def_PSX#?.info
Speichern, def_PSX#?.info benutzen
Sauver en utilisant def_PSX#?.info
Save, use def_PSX#?.info
Gravar. usando o ícone def_PSX#?.info
Zapisuj, uûyj def_PSX#?.info
;
MSG_CY_NoIcons
Don´t save
nicht erzeugen
Pas d'icônes
Don´t save
Não gravar
Nie zapisuj
;
MSG_CY_PSXImageNo
No
Nein
Non
No
No
Nie
;
MSG_CY_PSXImageAuto
auto aspect
Automatisches Seitenverhältnis
Proportions auto
auto aspect
auto aspect
automatyczny rozmiar
;
MSG_CY_PSXImage11
aspect 1:1
Seitenverhältnis 1:1
Proportions 1:1
aspect 1:1
aspect 1:1
rozmiar 1:1
;
MSG_CY_PSXImage22
aspect 2:2
Seitenverhältnis 2:2
Proportions 2:2
aspect 2:2
aspect 2:2
rozmiar 2:2
;
MSG_CY_PSXImage21
aspect 2:1
Seitenverhältnis 2:1
Proportions 2:1
aspect 2:1
aspect 2:1
rozmiar 2:1
;
MSG_CY_PSXImage12
aspect 1:2
Seitenverhältnis 1:2
Proportions 1:2
aspect 1:2
aspect 1:2
rozmiar 1:2
;
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; PATCH ERRORS PATCH ERRORS PATCH ERRORS PATCH ERRORS PATCH ERRORS PATCH ERRO
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
MSG_Patch_Global
Unable to convert save game:\n\n%s
Kann Spielstand nicht konvertieren:\n\n%s
Impossible de convertir la sauvegarde du jeu:\n\n%s
No puedo convertir la partida:\n\n%s
Não é possivel converter o jogo gravado:\n\n%s
Nie mogë skonwertowaê pliku:\n\n%s
;
MSG_Patch_SupportMissing
Missing matching 'Support' command!
Passendes 'Support'-Kommando fehlt!
Impossible de trouver la commande 'Support' correspondante!
!No encuentro el comando 'Support'¡
O comando 'Support' não foi encontrado!
Brakuje pasujâcej komendy 'Support'!
;
MSG_Patch_SupportInvalid
'Support' command: Line invalid!
'Support' Kommando: Zeile ungültig!
Commande 'Support': Ligne incorrecte!
Comando 'Support': Línea incorrecta!
Linha inválida do comando 'Support':
Komenda 'Support': bîëdna linia!
;
MSG_Patch_GadgetInvalid
'Gadget' command: Line invalid!
'Gadget' Kommando: Zeile ungültig!
Commande 'Gadget': Ligne incorrecte!
!Comando 'Gadget': Línea incorrecta¡
Linha inválida do comando 'Gadget':
Komenda 'Gadget': bîëdna linia!
;
MSG_Patch_GadgetUnknown
'Gadget' command: Type unknown!
'Gadget' Kommando: Typ unbekannt!
Commande 'Gadget': Type inconnu!
!Comando 'Gadget': Tipo desconocido¡
Tipo desconhecido do comando 'Gadget':
Komenda 'Gadget': nieznany typ!
;
MSG_Patch_ChecksumInvalid
'Checksum' command: Line invalid!
'Checksum' Kommando: Zeile ungültig!
Commande 'Checksum': Ligne incorrecte!
!Comando 'Checksum': Línea incorrecta¡
Linha inválida do comando 'Checksum':
Komenda 'Checksum': bîëdna linia!
;
MSG_Patch_ToolInvalid
'Tool' command: Line invalid!
'Tool' Kommando: Zeile ungültig!
Commande 'Tool': Ligne incorrecte!
!Comando 'Tool': Línea incorrecta¡
Linha inválida do comando 'Tool':
Komenda 'Tool': bîëdna linia!
;
MSG_Patch_UnableToFindSGT
Unable to find patch\ntool for this SGP!
Kann das PatchProgramm für\ndiese SGP Datei nicht finden!
Impossible de trouver\n de patcheur pour ce fichier SGP!
!No encuentro el parche para este SGP¡
Não foi possivel encontrar a\nferramenta de configuração para este SGP!
Nie mogë znaleúê narzëdzia\npatchujâcego ten SGP!
;
MSG_Patch_Unknown
Unknown
Unbekannt
Inconnu
Desconocido
Desconhecido
Nieznane
;
MSG_BAR_ProductID
\x20ProductID Setup\x20
\x20ProduktID Einstellungen\x20
\x20Réglages ID Produit\x20
\x20Ajuste de ID del producto\x20
\x20Definir o ID do produto\x20
\x20Ustawienia ID Produktu\x20
;
MSG_BAR_CheckPatches
\x20Cheat Setup\x20
\x20Schummel Einstellungen\x20
\x20Réglages Cheat\x20
\x20Ajuste de trucos\x20
\x20Definir os Truques\x20
\x20Ustawienia Cheatów\x20
;
;----------------------------------------------------------------------------
; SGP GADGETS SGP GADGETS SGP GADGETS SGP GADGETS SGP GADGETS SGP GADGETS SGP
;----------------------------------------------------------------------------
; *** Don´t use the hotkey char "_" for SGP gadgets !!!!! ***
;----------------------------------------------------------------------------
MSG_SGP_Level
Level
Runde
Niveau
Nivel
Nível
Plansza
;
MSG_SGP_Lives
Lives
Leben
Vies
Vidas
Vidas
Ûycia
;
MSG_SGP_Money
Money
Geld
Argent
Dinero
Dinheiro
Pieniâdze
;
MSG_SGP_Gold
Gold
Gold
Or
Gold
Ouro
Zîoto
;
MSG_SGP_Ammo
Ammo
Munition
Munitions
Munición
Munições
Amunicja
;
MSG_SGP_FullAmmo
Full Ammo
Volle Munition
Full Munitions
Full Munition
Toda a Munições
Peîna Amunicja
;
MSG_SGP_Coins
Coins
Münzen
Pièces
Monedas
Moedas
Monety
;
MSG_SGP_Pieces
Pieces
Stücke
Morceaux
Piezas
Peças
Czëôci
;
MSG_SGP_Moons
Moons
Monde
Moons
Moons
Luas
Ksiëûyce
;
MSG_SGP_Symbols
Symbols
Symbole
Symboles
Symbols
Simbolos
Symbole
;
MSG_SGP_Stars
Stars
Sterne
Etoiles
Stars
Estrelas
Gwiazdy
;
MSG_SGP_Energy
Energy
Energie
Energie
Energy
Energia
Energia
;
MSG_SGP_FullEnergy
Full Energy
Volle Energie
Energie complète
Full Energy
Toda a Energia
Peîna Energia
;
MSG_SGP_AllWeapons
All Weapons
Alle Waffen
Toutes les armes
All Weapons
Todas as Armas
Wszystkie Bronie
;
MSG_SGP_AllKeys
All Keys
Alle Schlüssel
Toutes les clés
All Keys
Todas as Chaves
Wszytkie Klucze
;
MSG_SGP_Slot
\x20Save slot %ld\x20
\x20Speicherplatz %ld\x20
\x20Slot de sauvegarde %ld\x20
\x20Grabar slot %ld\x20
\x20Gravar o slot %ld\x20
\x20Zapisz w gnieúdzie %ld\x20
;
;----------------------------------------------------------------------------
; Module Errors Module Errors Module Errors Module Errors Module Errors Modul
;----------------------------------------------------------------------------
MSG_Error_ModuleUnableToLoad
Unable to load driver module\n'%s'! Please check your installation.
Kann das Treibermodul '%s' nicht finden!\nBitte prüfen Sie Ihre Installation!
Impossible de charger le pilote\n'%s'! Veuillez vérifier votre installation.
Imposible cargar el controlador\n'%s' Por Favor, comprueba tu instalación
Não foi possivel carregar o gestor do módulo\n'%s'! Por favor verifica a sua instalação!
Nie mogë wczytaê moduîu sterownika\n'%s'! Sprawdú swojâ instalacjë.
;
MSG_Error_ModuleNotaDriver
The file '%s' isn´t a MCControl driver!
Die Datei '%s' ist kein MCControl-Treiber!
Le fichier '%s' n'est pas un pilote #?.mcm!
El fichero '%s' no es un driver #?.mcm
O ficheiro '%s' não é um gestor do MCControl (#?.mcm)!
Plik '%s' nie jest sterownikiem MCControl!
;
MSG_Error_ModuleNotValid
The driver version isn´t supported by this MCControl version!
Die Treiberversion wird nicht von MCControl unterstützt!
Cette version du pilote n'est pas encore supportée par MCControl!
La versión del driver no está soportada por esta versión de MCControl
A versão do gestor não é suportada por esta versão do MCControl!
Wersja sterownika nie jest obsîugiwana przez tâ wersjë MCControl!
;
MSG_Error_ModuleIdentifyNo
Not supported!!!
Wird nicht unterstützt!!!
Non supporté!!!
Not supported!!!
Não suportada!!!
Nie obsîugiwane!
;
MSG_Error_ModuleIdentifyNoDriver
Failed on startup!
Konnte nicht gestartet werden!
Erreur au démarrage!
Failed on startup!
Falha ao inicializar!
Bîâd przy starcie!
;
MSG_Error_ModuleNoDevice
Unable to open specified device!
Kann das eingestellte Gerät\n(Device) nicht öffnen!
Impossible d'ouvrir le périphérique spécifié!
!No puedo abrir el dispositivo¡
Não foi possivel abrir o dispositivo!
Nie mogë otworzyê urzâdzenia!
;
MSG_Error_ModuleNotCompatible
No compatible hardware detected!
Konnte keine kompatible Hardware finden!
Aucun lecteur compatible détecté!
No encuentro hardware compatible!
Não encontro o hardware compativel!
Brak kompatybilnego gniazda!
;
MSG_Error_ModuleNoTimerDevice
Unable to open timer device!
Kann das 'Timer.device'\nnicht öffnen!
Impossible d'ouvrir le timer.device!
!No puedo abrir timer device¡
Não foi possivel abri o timer device!
Nie mogë otworzyê 'timer.device'!
;
MSG_Error_ModuleNoParallelPort
Parallel port not available!
Parallelport ist nicht verfügbar!
Le port parallèle n'est pas disponible!
Parallel port not available!
A porta paralela não está disponível!
Nie dostëpny port równolegîy!
;
MSG_Error_ModuleNoResources
Not enough resources available!
Nicht genug Resourcen verfügbar!
Pas assez de ressources disponibles!
Not enough resources available!
Não há recursos disponíveis!
Brak wystarczajâcych Resourców
