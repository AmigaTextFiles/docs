/* Example25-1 */

OPTIONS PROMPT 'Enter your First Name: '
PARSE PULL First
OPTIONS PROMPT 'Enter you Surname:     '
PARSE PULL Surname
OPTIONS PROMPT 'Enter your Age:        '
PARSE PULL Age
SAY 'Hi' First Surname'. You will be 100 in' 100 - Age 'years.'
