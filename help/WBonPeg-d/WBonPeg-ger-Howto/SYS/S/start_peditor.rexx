/* $VER: Start-pEditor.rexx 1.0 (22.02.2004) */

OPTIONS RESULTS
PARSE ARG files

oldstack=PRAGMA("STACK", 12000)

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
            ADDRESS COMMAND 'C:pEditor >NIL: "'file'"'
        END
    END
END 

oldstack=PRAGMA("STACK",oldstack)
