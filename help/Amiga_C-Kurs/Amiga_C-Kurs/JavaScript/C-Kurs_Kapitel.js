/*  C-Kurs_Kapitel.js
 *  Erzeugt Kapitelübersicht
 *  Autor: Norman Walter
 *  Letzte Änderung: 24.8.2006
 */

function Eintrag(Link,Beschriftung)
{
  document.write('<TR>\n<TD></TD><TD>\n');
  document.write('<small>\n');
  document.write('<A HREF=\"');
  document.write(Link);
  document.write('\">');
  document.write(Beschriftung)
  document.write('</A><BR>\n');
  document.write('<small>\n');
  document.write('</TD>\n</TR>\n');
}

function Kapitel_Link(Nummer)
{
   document.write('<TD bgcolor=\"lightgrey\">\n');
   document.write('<A HREF=\"');

   if (Nummer==1)
   {
     document.write('C-Kurs_1_1.html');
   }
   else if (Nummer==2)
   {
     document.write('C-Kurs_2_1.html');
   }
   else if (Nummer==3)
   {
     document.write('C-Kurs_3_1.html');
   }
   else if (Nummer==4)
   {
     document.write('C-Kurs_4_1.html');
   }
   else if (Nummer==5)
   {
     document.write('C-Kurs_5_1.html');
   }
   else if (Nummer==6)
   {
     document.write('C-Kurs_6_1.html');
   }
   else if (Nummer==7)
   {
     document.write('C-Kurs_7_1.html');
   }
   else if (Nummer==8)
   {
     document.write('C-Kurs_8_1.html');
   }
   else if (Nummer==9)
   {
     document.write('C-Kurs_9_1.html');
   }
   else if (Nummer==10)
   {
     document.write('C-Kurs_10_1.html');
   }
   else if (Nummer==999)
   {
     document.write('C-Kurs_Datentypen.html');
   }

   document.write('\">');
   document.write('<img src=\"close.png\" border=0>');
   document.write('</A>');
   document.write('</TD>\n');
}

function Kapitel(Nummer,Kapitel,Beschriftung)
{
  document.write('<TR>');

  if (Nummer == Kapitel)
  {
    document.write('<TD bgcolor=\"lightgrey\">\n');
    document.write('<img src=\"open.png\" border=0>');
    document.write('</TD>\n');
  }
  else
  {
    Kapitel_Link(Kapitel);
  }

  document.write('<TD bgcolor=\"lightgrey\">\n');
  document.write('<B>');
  document.write(Beschriftung);
  document.write('</B>');
  document.write('</TD>\n</TR>\n');
}

function erzeuge_Kapitel(n)
{

  document.write('<table border=\"0\" cellpadding=\"5\" cellspacing=\"0\" bgcolor=\"#225588\">\n');
  Eintrag('C-Kurs.html','Einleitung');

  Kapitel(n,1,'Kapitel 1: Grundlagen');

  if (n==1)
  {
    Eintrag('C-Kurs_1_1.html','Erste Schritte');
    Eintrag('C-Kurs_1_2.html','Bezeichner, Datentypen und Variablen');
    Eintrag('C-Kurs_1_3.html','Formatierte Textausgabe mit printf');
    Eintrag('C-Kurs_1_4.html','Arithmetische Operatoren');
    Eintrag('C-Kurs_1_5.html','Verzweigungen mit if else');
    Eintrag('C-Kurs_1_6.html','Verzweigungen mit switch');
    Eintrag('C-Kurs_1_7.html','Schleifen mit for');
    Eintrag('C-Kurs_1_8.html','Schleifen mit while');
    Eintrag('C-Kurs_1_9.html','Schleifen mit do-while');
    Eintrag('C-Kurs_1_10.html','Funktionen');
    Eintrag('C-Kurs_1_11.html','Aussagelogische Operatoren');
    Eintrag('C-Kurs_1_12.html','Der sizeof Operator');
  }

  Kapitel(n,2,'Kapitel 2: Pr&auml;prozessor-Direktiven');

  if (n==2)
  {
    Eintrag('C-Kurs_2_1.html','Makros als symbolische Konstanten');
    Eintrag('C-Kurs_2_2.html','Makros statt Funktionen');
    Eintrag('C-Kurs_2_3.html','Modularisierung');
    Eintrag('C-Kurs_2_4.html','Bedingte Compilierung');
  }

  Kapitel(n,3,'Kapitel 3: Abgeleitete Datentypen');

  if (n==3)
  {
    Eintrag('C-Kurs_3_1.html','Aufz&auml;hlungstypen');
    Eintrag('C-Kurs_3_2.html','Synonyme mit typedef');
    Eintrag('C-Kurs_3_3.html','Strukturen');
  }

  Kapitel(n,4,'Kapitel 4: Zeiger');

  if (n==4)
  {
    Eintrag('C-Kurs_4_1.html','Zeiger und Adressen');
    Eintrag('C-Kurs_4_2.html','Zeiger auf Strukturen');
    Eintrag('C-Kurs_4_3.html','Zeiger auf Vektoren');
    Eintrag('C-Kurs_4_4.html','Zeiger als Funktionsargumente');
    Eintrag('C-Kurs_4_5.html','Zeiger als R&uuml;ckgabewerte');
  }

  Kapitel(n,5,'Kapitel 5: Vermischtes');

  if (n==5)
  {
    Eintrag('C-Kurs_5_1.html','Lokale Variablen');
    Eintrag('C-Kurs_5_2.html','Globale Variablen');
    Eintrag('C-Kurs_5_3.html','Rekursive Funktionen');
    Eintrag('C-Kurs_5_4.html','Argumente aus der Kommandozeile');
    Eintrag('C-Kurs_5_5.html','Typumwandlung (Cast)');
  }

  Kapitel(n,6,'Kapitel 6: Standard-Bibliothek');

  if (n==6)
  {
    Eintrag('C-Kurs_6_1.html','Standard-Definitionsdateien');
  }

  Kapitel(n,7,'Kapitel 7: Einf&uuml;hrung in die AmigaOS API');

  if (n==7)
  {
    Eintrag('C-Kurs_7_1.html','Shared Libraries');
    Eintrag('C-Kurs_7_2.html','Das erste Fenster');
    Eintrag('C-Kurs_7_3.html','Elemente eines Fensters');
    Eintrag('C-Kurs_7_4.html','Nachricht von Intuition');
    Eintrag('C-Kurs_7_5.html','Screens');
  }

  Kapitel(n,8,'Kapitel 8: Grafik');

  if (n==8)
  {
    Eintrag('C-Kurs_8_1.html','Grundlagen der Rastergrafik');
    Eintrag('C-Kurs_8_2.html','Grafikprimitiven');
    Eintrag('C-Kurs_8_3.html','&Uuml;bungen zur graphics.library');
    Eintrag('C-Kurs_8_4.html','Polarkoordinaten');
    Eintrag('C-Kurs_8_5.html','Licht, Farben und Pen-Sharing');
    Eintrag('C-Kurs_8_6.html','Images');
    Eintrag('C-Kurs_8_7.html','Text ist auch Grafik');
    Eintrag('C-Kurs_8_8.html','Colortables');
    Eintrag('C-Kurs_8_9.html','Mit dem Blitter arbeiten');
    Eintrag('C-Kurs_8_10.html','Das Mandelbrot Fraktal');
  }

  Kapitel(n,9,'Kapitel 9: Rekursive Strukturen');

  if (n==9)
  {
    Eintrag('C-Kurs_9_1.html','Verkettete Listen');
  }

  Kapitel(n,10,'Kapitel 10: GUI Programmierung mit GadTools');

  if (n==10)
  {
    Eintrag('C-Kurs_10_1.html','Der erste Button');
    Eintrag('C-Kurs_10_2.html','Gadgets unterscheiden');
  }

  Kapitel(n,999,'Anhang');

  if (n==999)
  {
    Eintrag('C-Kurs_Datentypen.html','Datentypen');
    Eintrag('C-Kurs_Operatoren.html','Operatoren');
    Eintrag('C-Kurs_ASCII.html','Die ASCII Tabelle');
    Eintrag('C-Kurs_Literatur.html','Literatur');
  }

  document.write('</TABLE>\n');

}

