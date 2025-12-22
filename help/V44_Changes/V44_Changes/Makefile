# $VER: V44_Changes_Makefile 1.0 (20.10.99) Bernardo Innocenti
#

DOCNAME		= V44_Changes
OUTPUTS		= $(DOCNAME).guide $(DOCNAME).doc $(DOCNAME).txt $(DOCNAME).html

MAKEINFO	= makeinfo
TEXI2HTML	= texi2html
AG2HTML		= ag2html
RM		= rm
MV		= mv
#RM		= Delete
#MV		= Rename

all: $(OUTPUTS)

clean:
	$(RM) $(OUTPUTS)

$(OUTPUTS): $(DOCNAME).texi

$(DOCNAME).guide:
	$(MAKEINFO) --amiga --no-split --output $@ $<

$(DOCNAME).doc:
	$(MAKEINFO) --amiga --no-headers --no-split --output $@ $<

$(DOCNAME).txt:
	$(MAKEINFO) --no-headers --no-split --output $@ $<

$(DOCNAME).html: $(DOCNAME).guide
	$(AG2HTML) $(DOCNAME).guide
#	$(TEXI2HTML) -verbose -menu -expandinfo -split_node $@
#	$(MV) *.html html/
