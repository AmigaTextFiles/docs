/* Example26-2 */

CALL PRAGMA('D','S:')
SAY 'c'x'The contents of your "S" directory are:'||'a'x
ADDRESS 'COMMAND' 'Dir'
CALL PRAGMA('D','Ram:')
SAY 'a'x'The contents of your "Ram:" disk are:'||'a'x
ADDRESS 'COMMAND' 'Dir'
