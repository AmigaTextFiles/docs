/* $VER: Start-Wordpad.rexx 1.0 (22.02.2004) */

OPTIONS RESULTS
PARSE ARG files

oldstack=PRAGMA("STACK", 50000)

DO WHILE files~=="" 
    files=STRIP(files)
    IF files~=="" THEN DO
        IF left(files,1)='"' THEN DO
            PARSE VAR files '"'file'"' files
        END
        ELSE DO
            PARSE VAR files file" "files
        END

        IF EXISTS(file) THEN DO
            ADDRESS COMMAND 'Wordpad:Wordpad >NIL: "'file'"'
        END
    END
END 

oldstack=PRAGMA("STACK",oldstack)
