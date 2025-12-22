
// ===============================================================
// OFFLINE-SUCHMASCHINE in JAVASCRIPT 1.1
//
// Datum:     15.04.1998
//
// Autor:     Stefan Mueller (S_Mueller@public.uni-hamburg.de)
//            http://www.rrz.uni-hamburg.de/philsem/stefan_mueller/
// CoAutorin: Christine Kuehnel
//            http://screenExa.net/
//
// getestet:  MSIE 4.0 (Win95/NT)
//	      Netscape 3.1 (Win95/NT)
//	      Netscape 4.04 (Win95/NT)
//


// --------------------------------------------------------------
// Der Uebersicht wegen, wird der Suchstring zur Laufzeit
// der Variablen "query" uebergeben.

 var query = "";


// --------------------------------------------------------------
// Voraussetzung sind zwei frames  [ INPUTFRAME, OUTPUTFRAME ]
// Beide koennen hier geaendert werden, was deren Name betrifft.
// Eingerichtet werden die Frames durch die Datei "index.html"

 var INPUTFRAME  = parent.frames['Suche'];
 var OUTPUTFRAME = parent.frames['Anzeige'];

// Zur uebersichtlicheren Handhabung wird gleich auf die
// jeweiligen Dokumente zugegriffen

 var INPUT  = INPUTFRAME.document;
 var OUTPUT = OUTPUTFRAME.document;


// Ersetzung von dt.spr. Umlauten in ISO 8859-1 Entities

function noumlaut( str )
{
	var l = 0; 		// Laenge des Strings
	var i = 0; 		// Index im Strings
	var newstr = ""; 	// Rueckgabestring
	var a = "";		// aktuelles Zeichen

	l = str.length;
	for (i=0; i<l;i++)
	{

		// i-tes Zeichen gegebfalls aendern
		a = str.charAt(i);

		// ISO 8859-1 Entities
		if ( a == "ä") { a = "&auml;" };
		if ( a == "ö") { a = "&ouml;" };
		if ( a == "ü") { a = "&uuml;" };
		if ( a == "Ä") { a = "&Auml;" };
		if ( a == "Ö") { a = "&Ouml;" };
		if ( a == "Ü") { a = "&Uuml;" };
		if ( a == "ß") { a = "&szlig;" };
		
		// Neuen String zusammensetzen
		newstr = newstr + a ;
	}
	
	return newstr;
}



// --------------------------------------------------------------
// Abfrage, ob der Suchstring "query" in dem Datenstring "str"
// enthalten ist.
// INPUT:  String
// OUTPUT: Boolean

 function found( str )
 {

	// Variablen-Deklaration
	 var isfound = false;
	 var s = "";
	 var q = "";
	
	// Gross/Kleinschreibung ignorieren
	 s = str.toLowerCase();	
	 q = query.toLowerCase();


	// Umlaute beseitigen
	 // s = noumlaut( s );
	 q = noumlaut( q );

	// Leerzeichen anfuegen, falls ganzer Ausdruck
	 s = " " + s + " ";	

	
	// true, falls q Teil von s ist, sonst false
	 isfound = ( s.indexOf( q ) > -1 ) 

	 return( isfound );
}

// ==============================================================
//
// Ausgabe-Prozeduren
//
// Voraussetzung sind zwei Frames (siehe: Deklaration oben)
//

// --------------------------------------------------------------
// Ausgabe des HTML-Headers

function HTMLHeader()
{
	with ( OUTPUT )
	{
		writeln("<head>");
		writeln("<title>");
		writeln("</title>");
		writeln("</head>");
	}
}

// --------------------------------------------------------------
// Ausgabe des BODY-Tags mit den Benutzerangaben (Diese Benutzerangaben
// erfolgen in den hidden-Elementen der QueryForm und werden inhaltlich
// nicht ueberprueft)

function HTMLOpenBody()
{
	with ( OUTPUT )
	{
		with( INPUT.QueryForm )
		{

		write("<body");
		
		// BGCOLOR
		 if (bgcolor.value)
		  write(" bgcolor=\""+bgcolor.value+"\"");

		// TEXT
		 if (text.value)
		  write(" text=\""+text.value+"\"");
		  
		// LINK
		 if (link.value)
		  write(" link=\""+link.value+"\"");
		  
		// ALINK
		 if (alink.value)
		  write(" alink=\""+alink.value+"\"");

		// VLINK
		 if (vlink.value)
		  write(" vlink=\""+vlink.value+"\"");

		// BACKGROUND
		 if (background.value)
		  write(" background=\""+background.value+"\"");

		writeln(">");

		}  // INPUT.QueryForm
		
	} // OUTPUT
}

// --------------------------------------------------------------
// Ausgabe der HTML-BODY-Schliessung
// (Nur aus programm-optischen Gruenden)

function HTMLCloseBody()
{
	with ( OUTPUT )
	{
		writeln("</body>");
	}
}



// --------------------------------------------------------------
// Ausgabe der HTML-FONT-Eroeffnung mit Benutzer-Angaben
// (siehe: HTMLOpenBody() )

function HTMLOpenFont()
{
	with ( OUTPUT )
	{
		with( INPUT.QueryForm )
		{
		 write("<font" );
		
		// FACE		
		 if (font_face.value)
		  write(" face=\""+font_face.value+"\"");
		  
		// SIZE  
		 if (font_size.value)
		  write(" size=\""+font_size.value+"\"");

		writeln(">" );
		}  // INPUT.QueryForm
		
	} // OUTPUT
}

// --------------------------------------------------------------
// Ausgabe der HTML-FONT-Schliessung
// (Nur aus programm-optischen Gruenden)

function HTMLCloseFont()
{
	with ( OUTPUT )
	{
		writeln("</font>");
	}
}




// --------------------------------------------------------------
// Ermitteln und Ausgabe der Suchergebnisse
//

function ListSearch()
{

	var count = 0;

	query = INPUT.QueryForm.query.value;

	with ( OUTPUT )
	{
		open();
		writeln("<html>");

		HTMLHeader();
		HTMLOpenBody();
		HTMLOpenFont();
		

		writeln("<b>Suche nach: ", query, "</b>" );
		
		writeln("<ol>");
		
		for (var i=1 ; i<Entry.length; i++)
		{

			if ( found( Entry[i].Title )
			||   found( Entry[i].Keywords )
			||   found( Entry[i].Description )
			   ) 
			{
				writeln("<li><p>");
				writeln( Entry[i].Format() );
				writeln("</p></li>");
				count++;
			}
		}
   		writeln("</ol>");


		if ( count == 0 )
	   	{
			writeln("<p>Es wurde kein Eintrag gefunden");
		}

		writeln("<p><b>Die Suche ist abgeschlossen</b>" );
		HTMLCloseFont();
		HTMLCloseBody();
		writeln('</html>');
		close();
   	}
}

// --------------------------------------------------------------
// Validieren der Abfrage
//
// Hier muss nachgesehen werden, ob die Suche gueltig ist.
// Wenn ja, wird das Suchergebnis ausgegeben, sonst wird eine
// Fehlermeldung ueber einen kleinen Dialog angezeigt.
//
// Zugriff ueber die HTML-Form QueryForm bei "Suchen"

function Validator()
{


	// Laengen-Ueberpruefung der Abfrage
	if ( INPUT.QueryForm.query.value.length < 3 )
	{
		alert( "Es müssen mehr als 2 Zeichen eingegeben werden" );
		INPUT.QueryForm.query.focus();
	}
	else
	{
		ListSearch();
	}
	
}

// --------------------------------------------------------------
// In den Editierfeldern der HTML-Form wird beim Druck der
// Entertaste ein submit ausgeloest. Dabei werden auch die
// Javascript-Module neugeladen, was nicht so sinnig ist.
// Dies wird hiermit unterbunden, aber dennoch die Suche
// validiert und gegebenfalls ausgefuehrt.
//
// Zugriff ueber die HTML-Form QueryForm bei "OnSubmit"

function QueryEnter()
{
	Validator();
	return (false);
}


// Verweis auf eine Hilfe-Seite
function Help( url )
{
	OUTPUT.location = url;
}



// ===========================================================
//
// Objekt-Typ "Element" nach einem Entwurf von Christine Kühnel
//
// Eigenschaften:
//
//  Url            Internet-Adresse des entsprechenden Eintrages
//  Title          Titel der Webseite, oder DatenQuelle
//  Description    Kurze Beschreibung der Datei
//  Keywords       Stichworte fuer das Auffinden der Datei
//
// Methoden:
//
//  new Element( Url, Title, Description, Keywoerds )
//  Initialisieren eines neuen Elementes z.b.: Entry[i]
//
//  Format()
//  Formatiert den Eintrag fuer die HTML-Ausgabe
//

// ----------------------------------------------------------
// Definition der Methode "Format()" 
// ist zunaechst nur eine ganz gewoehnliche Standard-Funktion,
// Zur Methode wird sie erst bei der Definition des Objektes
// gemacht (kommt weiter unten)
//
// Aufruf der Methode mit Element.Format()

 function Format() 
 {

	with( this )  // mit dem Element tue das Folgende
	{

	// Deklaration des RueckgabeStrings
	// (enthaelt die HTML-formatierte Ausgabe des Eintrages)
	var e = "";

	// 1. Zeile, der Titel und Hyperlink (bold)	

	e = e + "<a href=\"" + this.Url + "\" target=_top>";
	e = e + "<b>" + Title + "</b>\n";
	e = e + "</a>\n";
	
	// 2. Zeile, Beschreibung (kursiv), wenn vorhanden
	if ( Description && ( Description != "-" ))
		
	 e = e + "<br>" + Description + "\n";
	 
	}
	return(e);
}


// ----------------------------------------------------------
// Definition des Objektes "Element" inkl. Eigenschaften
// und Methoden 
//

function Element(Url,Title,Description,Keywords) 
{

	// Eigenschaften
	this.Url           = Url;
	this.Title         = Title;
	this.Description   = Description;
	this.Keywords      = Keywords;
	
	// Methoden
	this.Format        = Format;
}

// ----------------------------------------------------------
// Initialisieren eines Arrays von Element, auf das dann
// mit Entry[1], Entry[2] etc zugegriffen werden kann.
// Gueltig sind auch die Array-Methoden und Eigenschaften
// wie Entry.length, um etwa die Anzahl der Elemente festzu-
// stellen (siehe: ListSearch).

Entry    = new Array();


