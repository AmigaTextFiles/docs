/* ARexx Script to Reset Window Settings */

PortName = ADDRESS()

ADDRESS 'COMMAND'

IF LEFT(Portname,9) = 'MULTIVIEW' THEN DO

  IF EXISTS('Env:Multiview') = 0 THEN 'MAKEDIR Env:Multiview'

  'COPY >Nil: Miscellaneous/MV_Settings Env:Multiview/Workbench'

  'MULTIVIEW Miscellaneous/Demo_Of_Settings.guide'

  IF EXISTS('Envarc:Multiview/Workbench') THEN,
    'COPY >Nil: Envarc:Multiview/Workbench Env:Multiview/'

  EXIT

END


ELSE IF LEFT(Portname,10) = 'AMIGAGUIDE' THEN DO

  IF EXISTS('Env:Amigaguide') = 0 THEN 'MAKEDIR Env:Amigaguide'

  'COPY >Nil: Miscellaneous/AG_Settings Env:Amigaguide/Workbench'

  OPTIONS FAILAT 217

  'AMIGAGUIDE Miscellaneous/Demo_Of_Settings.guide'

  OPTIONS FAILAT 10

  IF EXISTS('Envarc:Amigaguide/Workbench') THEN,
    'COPY >Nil: Envarc:Amigaguide/Workbench Env:Amigaguide/'

  EXIT

END

CALL OPEN('OutWindow','CON:0/11/640/100/Demon Document Output Window')

CALL WRITELN('OutWindow','a'x'Sorry, you do not seem to be using either of',
'Amigaguide or Multiview'||'a'x'So I cannot open the window to display',
'the demonstration file')

DO UNTIL TIME('E') > 7 ; END

CALL CLOSE('OutWindow')
