/************************************************\
*       dalf.rexx - Dumps Amiga Load Files.      *
* C 1990 Mikael Karlsson (micke@slaka.sirius.se) *
* 2012 Wei-ju Wu, V37 enhancements               *
\************************************************/

parse arg file              /* File to examine */

signal on break_c           /* We want a nice clean break */

pl. = "s"                   /* This is how to handle plurals the ince way */
pl.1 = ""

temp = '00'x
flagtext.temp = ""
temp = '40'x                /* Bit 30 means 'Load to CHIPMEM' */
flagtext.temp = " (CHIP)"
bits. = '00'x

type. = "Unknown"
isexe = 0

/* These are the hunk types we know about (so far) */

Hunk_unit    = '03E7'x; type.Hunk_unit    = "Hunk_unit    "
Hunk_name    = '03E8'x; type.Hunk_name    = "Hunk_name    "
Hunk_code    = '03E9'x; type.Hunk_code    = "Hunk_code    "
Hunk_data    = '03EA'x; type.Hunk_data    = "Hunk_data    "
Hunk_bss     = '03EB'x; type.Hunk_bss     = "Hunk_bss     "
Hunk_reloc32 = '03EC'x; type.Hunk_reloc32 = "Hunk_reloc32 "
Hunk_reloc16 = '03ED'x; type.Hunk_reloc16 = "Hunk_reloc16 "
Hunk_reloc8  = '03EE'x; type.Hunk_reloc8  = "Hunk_reloc8  "
Hunk_ext     = '03EF'x; type.Hunk_ext     = "Hunk_ext     "
Hunk_symbol  = '03F0'x; type.Hunk_symbol  = "Hunk_symbol  "
Hunk_debug   = '03F1'x; type.Hunk_debug   = "Hunk_debug   "
Hunk_end     = '03F2'x; type.Hunk_end     = "Hunk_end     "
Hunk_header  = '03F3'x; type.Hunk_header  = "Hunk_header  "
Hunk_overlay = '03F5'x; type.Hunk_overlay = "Hunk_overlay "
Hunk_break   = '03F6'x; type.Hunk_break   = "Hunk_break   "
Hunk_drel32  = '03F7'x; type.Hunk_drel32  = "Hunk_drel32  "
Hunk_drel16  = '03F8'x; type.Hunk_drel16  = "Hunk_drel16  "
Hunk_drel8   = '03F9'x; type.Hunk_drel8   = "Hunk_drel8   "
Hunk_libhunk = '03FA'x; type.Hunk_libhunk = "Hunk_libhunk "
Hunk_libindx = '03FB'x; type.Hunk_libindx = "Hunk_libindx "
Hunk_reloc32short = '03FC'x; type.Hunk_reloc32short = "Hunk_reloc32short "

/* These are subtypes in Hunk_ext */

Hunk_def     =   '01'x; type.Hunk_def     = "Hunk_def    "
Hunk_abs     =   '02'x; type.Hunk_abs     = "Hunk_abs    "
Hunk_res     =   '03'x; type.Hunk_res     = "Hunk_res    "
Hunk_ext32   =   '81'x; type.Hunk_ext32   = "Hunk_ext32  "
Hunk_ext16   =   '83'x; type.Hunk_ext16   = "Hunk_ext16  "
Hunk_ext8    =   '84'x; type.Hunk_ext8    = "Hunk_ext8   "
Hunk_dext32  =   '85'x; type.Hunk_dext32  = "Hunk_dext32 "
Hunk_dext16  =   '86'x; type.Hunk_dext16  = "Hunk_dext16 "
Hunk_dext8   =   '87'x; type.Hunk_dext8   = "Hunk_dext8  "

if ~open(lf, file, 'R') then do     /* Open load file */
    say "Can't open" file
    exit 10
end

index = 0
size. = 0

loop:
    type = readch(lf, 4)            /* Read hunk type */
    if type == "" then do           /* End of file */
        signal done
    end
    bits.index = bitor(bits.index, left(type, 1))   /* Check flag bits */
    type = right(type, 2)                           /* Remove flag bits */
    if type.type = "Unknown"  then do
        say "Unknown hunk type ("c2x(type)")"
        exit 10
    end
    id = type.type "("c2x(type)")"
    signal value trim(type.type)    /* Jump to hunk display routine */

Hunk_header:
    say id
    dummy = c2d(readch(lf, 4))         /* What's this? */
    count = c2d(readch(lf, 4))
    low   = c2d(readch(lf, 4))
    high  = c2d(readch(lf, 4))
    say "      "count "hunk"pl.count "("low "to" high")"
    do i=low to high
        size = readch(lf, 4)
        bits.i = left(size, 1)
        size.i = c2d(right(size, 3))*4
        bits = bits.i
        say "      Size hunk" i":" size.i "bytes" flagtext.bits
    end
    index = low
    isexe = 1
    signal loop

Hunk_end:
    say "    "id
    signal loop

Hunk_code:
    size = readch(lf, 4)
    bits = bitor(bits.index, left(size, 1))
    size = c2d(right(size, 3))*4
    temp = right(index, 2)
    temp = temp":" id
    temp = temp "("size "bytes)"flagtext.bits
    say temp
    do while size>32768
        data = readch(lf, 32768)
        size = size-32768
    end
    data = readch(lf, size)
    index = index+1
    signal loop

Hunk_reloc32:
Hunk_reloc16:
Hunk_reloc8:
    say "    "id
    count = c2d(readch(lf, 4))
    do while count~=0
        ref = c2d(readch(lf, 4))
        say "      "count "item"pl.count "for hunk" ref
        refs = readch(lf, count*4)
        count = c2d(readch(lf, 4))
    end
    signal loop

Hunk_ext:
    say "    "id
    sym_type = readch(lf, 1)
    sym_length = c2d(readch(lf, 3))*4
    do until sym_type == "00"x
        symbol = strip(readch(lf, sym_length), 'T', '00'x)
        select
            when sym_type == hunk_def |,
                 sym_type == hunk_abs |,
                 sym_type == hunk_res then do
                offset = strip(c2x(readch(lf, 4)), 'T', '00'x)
                temp = "     " type.sym_type
                temp = temp left(symbol, 32)":" "0x"offset
                say temp
            end
            when sym_type == hunk_ext32  |,
                 sym_type == hunk_ext16  |,
                 sym_type == hunk_ext8   |,
                 sym_type == hunk_dext32 |,
                 sym_type == hunk_dext16 |,
                 sym_type == hunk_dext8 then do
                count = c2d(readch(lf, 4))
                refs = readch(lf, count*4)
                temp = "     " type.sym_type
                temp = temp left(symbol, 32)":"
                temp = temp right(count, 2) "item"pl.count
                say temp
            end
            otherwise do
                say "      Unknown definition"
            end
        end
        sym_type = readch(lf, 1)
        sym_length = c2d(readch(lf, 3))*4
    end
    signal loop

Hunk_drel32:
    if isexe == 1 then do
      say "V37 HACK: treat drel32 as reloc32short in load files"
      id = "Hunk_reloc32short"
      signal Hunk_reloc32short
    end
Hunk_drel16:
Hunk_drel8:
    say "    "id
    count = c2d(readch(lf, 4))
    do while count~=0
        ref = c2d(readch(lf, 4))
        say "      "count "item"pl.count "for hunk" ref
        refs = readch(lf, count*4)
        count = c2d(readch(lf, 4))
    end
    signal loop

Hunk_reloc32short:
    say "    "id
    count = c2d(readch(lf, 2))
    total = count
    do while count~=0
        ref = c2d(readch(lf, 2))
        say "      "count "item"pl.count "for hunk" ref
        refs = readch(lf, count*2)
        count = c2d(readch(lf, 2))
        total = total+count
    end
    /* align to 4-byte boundary if necessary */
    say "total ="total
    if (total // 2) == 0 then pad = readch(lf, 2)
    signal loop

Hunk_data:
    size = readch(lf, 4)
    bits = bitor(bits.index, left(size, 1))
    size = c2d(right(size, 3))*4
    temp = right(index, 2)
    temp = temp":" id
    temp = temp "("size "bytes"
    if size.index-size>0 then do
        temp = temp"," size.index-size "BSS"
    end
    temp = temp")"flagtext.bits
    say temp
    data = readch(lf, size)
    index = index+1
    signal loop

Hunk_bss:
    size = readch(lf, 4)
    bits = bitor(bits.index, left(size, 1))
    size = c2d(right(size, 3))*4
    temp = right(index, 2)
    temp = temp":" id
    temp = temp "("size "bytes)"flagtext.bits
    say temp
    index = index+1
    signal loop

Hunk_unit:
Hunk_name:
    say right(index, 2)":"id
    size = c2d(readch(lf, 4))*4
    data = readch(lf, size)
    say "    " type.type":" data
    index = index+1
    signal loop

Hunk_symbol:
    say right(index, 2)":"id
    size = c2d(readch(lf, 4))*4
    do while size~=0
        data = strip(readch(lf, size), 'T', '00'x)
        say "    " left(data, 32)":" c2x(readch(lf, 4))
        size = c2d(readch(lf, 4))*4
    end
    signal loop

Hunk_libhunk:
    size = readch(lf, 4)
    bits = bitor(bits.index, left(size, 1))
    size = c2d(right(size, 3))*4
    say "    "id "("size "bytes)"flagtext.bits
    signal loop

Hunk_libindx:
    size = c2d(readch(lf, 4))*4
    say "    "id "("size "bytes)"
    count = c2d(readch(lf, 2))
    say "    " count "bytes in string block"
    string = readch(lf, count)
    do forever
        nameoffset = c2d(readch(lf, 2))
        if nameoffset=0 then leave
        parse value substr(string, nameoffset+1) with name "00"x .
        say "    PUNIT '"name"'"
        unitoffset = c2d(readch(lf, 2))
        say "     offset" unitoffset "longword"pl.unitoffset
        hunkcount = c2d(readch(lf, 2))
        say "    " hunkcount "hunk"pl.hunkcount
        do for hunkcount
            nameoffset = c2d(readch(lf, 2))
            parse value substr(string, nameoffset+1) with name "00"x .
            hunksize = c2d(readch(lf, 2))
            hunktype = readch(lf, 2)
            say "    " type.hunktype "'"name"' of" hunksize "longword"pl.hunksize
            refcount = c2d(readch(lf, 2))
            say "    " refcount "ref"pl.refcount":"
            do for refcount
                nameoffset = c2d(readch(lf, 2))
                if substr(string, nameoffset+1, 1)="00"x then do
                    nameoffset = nameoffset+1
                    temp = "16"
                end
                else do
                    temp = "32"
                end
                parse value substr(string, nameoffset+1) with name "00"x .
                say "      " temp"-bit ref '"name"'"
            end
            defcount = c2d(readch(lf, 2))
            say "    " defcount "def"pl.defcount":"
            do for defcount
                nameoffset = c2d(readch(lf, 2))
                parse value substr(string, nameoffset+1) with name "00"x .
                defoffset = readch(lf, 2)
                defdata = readch(lf, 2)
                deftype = c2d(right(defdata, 2))
                defdata = left(defdata, 2)
                select
                    when deftype=1 then do
                        say "       Define def '"name"' at" c2d(defoffset)
                    end
                    when deftype=2 then do
                        defoffset = defdata || defoffset
                        say "       Define abs '"name"' at" c2d(defoffset)
                    end
                    when deftype=3 then do
                        say "       Define res '"name"' at" c2d(defoffset)
                    end
                    when deftype=66 then do
                        defoffset = "FF"x || defdata || defoffset
                        say "       Define abs '"name"' at" c2d(defoffset)
                    end
                    otherwise do
                        say "Error in object file"
                        exit 10
                    end
                end
            end
        end
    end
    signal loop

Hunk_debug:
    size = c2d(readch(lf, 4))*4
    say "    "id "("size "bytes)"
    say "       Offset:" c2d(readch(lf, 4))
    say "       Type:  " readch(lf, 4)
    data = readch(lf, size-8)
    signal loop

Hunk_break:
    size = c2d(readch(lf, 4))*4
    say "    "id "("size "bytes)"
    data = readch(lf, size)
    index = index+1
    signal loop

Hunk_overlay:
    size = c2d(readch(lf, 4))*4
    say "    "id "("size "bytes) - Not supported"
    data = readch(lf, size)
    index = index+1
    signal loop


break_c:
done:
exit 0
