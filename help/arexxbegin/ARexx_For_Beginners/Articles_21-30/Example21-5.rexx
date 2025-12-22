/* Example21-5 */

/* Check what seeding does if used in every use of random */

CALL RANDOM(,,TIME('S'))
Number. = 0


DO FOR 30000

/* Use the following line for the first test series  */
/* but delete it, or make it a comment, for the second test series */

Number = RANDOM(1,6,TIME('S'))

/* Use the following line for the second test series */
/* after removing its comment indicators */

/* Number = RANDOM(1,6) */


Number.Number = Number.Number + 1

END

DO Count = 1 TO 6

Say 'Number' Count '=' Number.Count TRUNC(((Number.Count*100/30000)*10**2+.5)/10**2,2)||'%'

END
