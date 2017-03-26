#makefile for gaf-geda

# Input DIR using this directory structure cleans things up
NAME= project-template
#
SHELL=/bin/bash
SCH=sch
PCB=pcb
SYM=geda-symbols
FP=gpcb-footprints
SS=subcircuits
FORCE=NO
# variables using the Make builtin shell expression/expansion
# not sure if = is a good assignment operator or if =! or =: would be better
DATE = $(shell date +"%b-%d-%Y")
AUTHOR = $(shell git config --global -l | grep user.name | cut -d "=" -f2)
LONGREV = $(shell git describe --tags --long)
SHORTREV = $(shell git describe --tags)
STATUS = $(shell git status -z -uno)
CHECKINS = $(shell git status --porcelain *.pcb *.sch)

pcb-files = $(wildcard *.pcb)
schematic-files = $(wildcard *.sch)
schematic-ps = $(patsubst %.sch, $(SHORTREV)-%.sch.ps, $(schematic-files))
layout-ps = $(patsubst %.pcb, $(SHORTREV)-%.pcb.ps, $(pcb-files))
# $@  is the automatic variable for the prerequisite
# $<  is the automatic variable for the target
.PHONY: list-gedafiles 
list-gedafiles:
	#Nothing requested, default goal is to list details
	# project name 
	@$(foreach asset, $(NAME), echo $(NAME);)
	# geda files in the top directory level
	@$(foreach asset, $(pcb-files), echo $(asset);)
	@$(foreach asset, $(schematic-files), echo $(asset);)
.PHONY: ps gerbers osh-park-gerbers clean
ps:
	#Check if FORCE is set
ifneq ($(FORCE),YES)
	#FORCE is not set, proceeding with repo checks...
	#Check that schematic and pcb content is clean
ifneq ($(CHECKINS),)
	$(error error: untracked schematic or pcb content, check with 'git status *pcb *sch', add content or override)
endif
	#working state of pcb and sch files is clean
	#Check for tags in the git repo
ifeq ($(LONGREV),)
	$(error error: revision history has no tags to work with, add one and try again)
endif
	#Tags found, proceeding
endif
	# the following target exports postscript assets from *.sch and *.pcb files in HEAD using a tags 
	# exporting layout as postscript using pcb...
	@$(foreach asset, $(pcb-files), sed -i "s/\$$ver=/$(SHORTREV)/"
	$(asset); pcb -x ps --psfile $(SHORTREV)-$(asset).$@ $(asset); git checkout -- $(asset);) 
	# pcb layout to postscript export complete
	# processing titleblock keywords, exporting schematic as postscript using gaf, and restoring  HEAD
	# DANGER, we will discard changes to the schematic file in the working directory now.  
	# This assumes that the working dir was clean before make was called and should be rewritten as an atomic operation
	$(foreach asset, $(schematic-files),
	sed -i "s/\(date=\).*/\1$\$(DATE)/" $(asset);
	sed -i "s/\(auth=\).*/\1$\$(AUTHOR)/" $(asset);
	sed -i "s/\(fname=\).*/\1$\$(asset)/" $(asset);
	sed -i "s/\(rev=\).*/\1$\$(SHORTREV) $\$(TAG)/" $(asset);
	gaf export -c -o $(REV)-$(asset).$@  -- $(asset); git checkout -- $(asset);)
	# gschem schematic to postscript export complete
#PDF EXPORT
pdf: ps
	@$(foreach asset, $(schematic-ps), ps2pdf $(asset);)
	@$(foreach asset, $(layout-ps), ps2pdf $(asset);)
	# pdf exported
#BOM export
pcb-bom:  $(NAME).pcb
	pcb -x bom --bomfile $(SHORTREV)-$(NAME)-pcb-bom.csv $<
# assembly bom is column seperated
gnetlist-bom: $(NAME).sch
	gnetlist -g bom $< -o $(SHORTREV)-$(NAME)-assembly-bom.csv $<
# GERBERS (props to https://github.com/bgamari)
gerbers: $(NAME).pcb 
	rm -Rf gerbers
	mkdir gerbers
	# use shell to edit version string with values from 'git describe'
	$(foreach asset, $(pcb-files), sed -i "s/\$$ver=/$(SHORTREV)/" $(asset);)
	pcb -x gerber --gerberfile gerbers/$(NAME) $<
	$(foreach asset, $(pcb-files), git checkout -- $(asset);)
osh-park-gerbers: gerbers
	rm -Rf $@
	mkdir -p $@
	cp gerbers/$(NAME).top.gbr "$@/Top Layer.ger"
	cp gerbers/$(NAME).bottom.gbr "$@/Bottom Layer.ger"
	cp gerbers/$(NAME).topmask.gbr "$@/Top Solder Mask.ger"
	cp gerbers/$(NAME).bottommask.gbr "$@/Bottom Solder Mask.ger"
	cp gerbers/$(NAME).topsilk.gbr "$@/Top Silk Screen.ger"
	cp gerbers/$(NAME).bottomsilk.gbr "$@/Bottom Silk Screen.ger"
	cp gerbers/$(NAME).outline.gbr "$@/Board Outline.ger"
	cp gerbers/$(NAME).plated-drill.cnc "$@/Drills.xln"

osh-park-gerbers.zip : osh-park-gerbers
	rm -f $@
	zip -j $@ osh-park-gerbers/*
hackvana-gerbers : gerbers
	rm -Rf $@
	mkdir -p $@
	cp gerbers/$(NAME).top.gbr $@/$(NAME).front.gtl
	cp gerbers/$(NAME).bottom.gbr $@/$(NAME).back.gbl
	cp gerbers/$(NAME).topmask.gbr $@/$(NAME).frontmask.gts
	cp gerbers/$(NAME).bottommask.gbr $@/$(NAME).backmask.gbs
	cp gerbers/$(NAME).topsilk.gbr $@/$(NAME).frontsilk.gto
	cp gerbers/$(NAME).bottomsilk.gbr $@/$(NAME).backsilk.gbo
	cp gerbers/$(NAME).outline.gbr $@/$(NAME).outline.gbr
	cp gerbers/$(NAME).plated-drill.cnc $@/$(NAME).plated-drill.cnc
hackvana-gerbers.zip : hackvana-gerbers
	rm -f $@
	zip -j $@ hackvana-gerbers/*
	@echo "Be sure to add a version number to the zip file name"
archive: 
	#Check if FORCE is set
ifneq ($(FORCE),YES)
	#FORCE is not set, proceeding with repo checks...
	#Check that schematic and pcb content is clean
ifneq ($(CHECKINS),)
	$(error error: untracked schematic or pcb content, check with 'git status *pcb *sch', add content or override)
endif
	#working state of pcb and sch files is clean
	#Check for tags in the git repo
ifeq ($(LONGREV),)
	$(error error: revision history has no tags to work with, add one and try again)
endif
	#Tags found, proceeding
endif
	# this target archives the repo from the current tag
	git archive HEAD --format=zip --prefix=$(LONGREV)/  > $(LONGREV).zip
clean:
	rm -f *~ *- *.backup *.new.pcb *.png *.bak *.gbr *.cnc *.ps *{pcb,sch}.pdf *.csv *.xy
