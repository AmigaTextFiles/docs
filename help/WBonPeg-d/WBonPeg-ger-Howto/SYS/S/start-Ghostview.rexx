/* $VER: Start-Ghostview.rexx 1.0 (12.02.2004) */

OPTIONS RESULTS
PARSE ARG files

oldstack=PRAGMA("STACK", 16368)

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
            ADDRESS COMMAND 'gs -sDEVICE=amiga "'file'"'
        END
    END
END 

oldstack=PRAGMA("STACK",oldstack)
