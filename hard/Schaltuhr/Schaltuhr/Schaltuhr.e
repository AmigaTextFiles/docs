-> »»» COMPILE AS: ram:

MODULE 'intuition/intuition'

PROC main()
DEF myargs:PTR TO LONG,
    margs :PTR TO LONG,
    rdargs,argcount,
    time

  myargs:=[0,0]

  PutChar($bfe001,Char($bfe001) AND $7f)

  IF rdargs:=ReadArgs('TIME/A,PATTERN/M',myargs,NIL)

    time:=Val(myargs[0])
    IF(margs:=myargs[1])<>NIL

      argcount:=0

      WHILE(margs[argcount]<>NIL)

        IF Char(margs[argcount])="S"
          switch(time)
        ELSE
          pause(Val(margs[argcount]))
        ENDIF
        INC argcount

      ENDWHILE

    ENDIF

    FreeArgs(rdargs)
  ELSE
    WriteF('Bad Args!\n')
  ENDIF
ENDPROC

PROC switch(time)
  PutChar($bfe201,Char($bfe201) OR $80)
  Delay(time)
  PutChar($bfe201,Char($bfe201) AND $7f)
ENDPROC

PROC pause(wait)
  Delay(wait)
ENDPROC

