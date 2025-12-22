/* Example37-4 */

SAY 'Caculate Fuel Consumption in  Miles Per Gallon'||'a'x

SAY 'Enter Number of Kilometres'
PULL Kilometres

SAY 'Enter Number of Litres'
PULL Litres

Miles = GETCLIP('kmTOmile') * Kilometres
Gallons = GETCLIP('litreTOgallon') * Litres

SAY 'a'x'Distance in Miles =' Miles
SAY 'Petrol in Gallons =' Gallons
SAY 'Miles Per Gallon  =' Miles/Gallons
SAY 'Litres Per 100km  =' Litres * 100 / Kilometres
