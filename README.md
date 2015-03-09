git-gaf-template
===========
template project for hardware design using gaf.

terminology and description
---------------------------

gaf == gEDA & friends. && gaf == an eponymous cli for use with gEDA & friends.

gEDA == 
* gschem - shematic editor that has some operational similarity to old versions of OrCAD
* pcb, aka PCB - powerful floss circuit layout program
* gnetlist outputs a number of netlist formats from gschem, part of the sim workflow 
* schdiff - works as a git difftool and uses imagemagick to generate visual diffs of gschem schematics
* refdes\_renum a tool for giving unique 'reference designations' to symbols in a sch file
* spice tools -- there's no official spice package designated for use with geda-gaf. with complete symbols, gnetlist should create
output that works with a variety of  spice packages 
* other projects anything I've forgotten

project hierarchy
-----------------
The main directory contains templates for gschem:
````
*.sch
````
and layout files for geda-gaf's layout program (PCB):
````
*.pcb
````
These all get processed using Make, with the included Makefile. Note this
Makefile hasn't been tested with more than a few versions of gnu make. 

To use the makefile, you run make and supply a goal. The following list is from
a system with tab completion, which supplies the user with the list of goals
available from the makefile.
Some of these will require user actions, like providing the correct filetypes
in the local directory, and
ensuring they use the cvs-based keywords that sed will process the files with,
and using git to tag versions.

````
clean                  gnetlist-bom          hackvana-gerbers.zip  Makefile              
schematic-template.sch osh-park-gerbers.zip  pdf                   gerbers               
hackvana-gerbers       list-gedafiles        layout-template.pcb 
osh-park-gerbers       pcb-bom               ps
````
This makefile uses the commonly available sed and echo, the less available 'gaf'
project from geda, and is intended for use by a hardware designer using gschem
for schematic capture and geda pcb for layout. 

Finally, it also uses git, specifically the git-tag comand, and templates that
contain keywords in the schematic and layout templates. The templates should be
availabe for checkout from the early revisions of the project). Versions
released for manufacturing should include annotated version tags using semver
(vXX.YY.ZZ, XX=major YY=minor ZZ=patch)

Bug reports are welcome, create issues on github or send them to miloh at
froggytoad dot net

git submodules
--------------
This project uses git submodules for libraries of schematic parts and
footprints. Update the git submodules after cloning the project and regularly
during development unless you want to freeze the schematics and parts to a
specific branch.  
````
git submodule update --init --recursive
````

Updating submodules is important to remember, because when checking out dev
branches or earlier tags of the project, you will have to update the submodules
to get the correct version of parts (symbols and footprints) used during
development. The following command should also be used after checking out
earlier versions to keep the project synced
````
git submodule update --init  --recursive
````

Using schdiff with git's difftool
---------------------------------
schdiff allows the user to compare schematics from different versions.

example showing a diff from the current HEAD to 30 commits back:
git difftool -x schdiff HEAD~30 project.sch
