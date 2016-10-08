gEDA-git-template
=================
Template project for hardware design using gEDA and gEDA's PCB 


Using the template to start a project
-------------------------------------

Clone the project and skip ahead, or from github you can fork the template, grab
a copy of the repo and use it as follows: (github, my account 'miloh', and the
throwaway name 'newproject' are used as examples)

````
git clone git@github.com:miloh/git-gaf-template.git newproject
cd newproject
````
edit this README.md and the Makefile
make a commits,
go to your remote  git server an create newproject. 

````
git remote rm origin
git remote add origin URL
git push -u origin master
```` 

gEDA Terminology & Description
------------------------------

gEDA is a suite of tools 
* gschem - electronic schematic editor that has some operational similarity to old versions of OrCAD
* gnetlist outputs a number of netlist formats from gschem, part of the sim workflow 
* schdiff - works as a git difftool and uses imagemagick to generate visual diffs of gschem schematics
* refdes\_renum a tool for giving unique 'reference designations' to symbols in a sch file
* gaf stands for gschem & friends, an eponymous cli for use with gschem & friends.
* spice tools -- thofficial spice package for use with geda-gaf. with complete symbols, gnetlist creates spice compatible netwlist
* pcb, aka PCB or what I'll call gEDA's PCB - a powerful and fun floss circuit layout program
* other projects are anything I've forgotten

Project Hierarchy and using gnu Make
------------------------------------
The main directory contains templates for a schematic built using gschem: and
layout files for geda's PCB:

````
*.sch
````
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

Finally, it also uses git, specifically the git-tag comand to template the
keywords in the schematic and layout templates. The templates should be availabe
for checkout from the early revisions of the project). Versions released for
manufacturing should include annotated version tags using semver (vXX.YY.ZZ,
XX=major YY=minor ZZ=patch)

Bug reports are welcome, create issues on github or send them to miloh at
froggytoad dot net

Git submodules
--------------
This project uses git submodules for libraries of schematic parts and
footprints. 

First, update the git submodules after cloning the project and regularly during
development unless you want to freeze the schematics and parts to a specific
branch (which may totally make sense for some completed projects).

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

Note that gschem should use a local file 'gafrc' with a line in scheme that
configures the directory for local symbol libraries.

PCB preferences must be changed to find local footprints, I do this in the PCB
gui currently but I imagine there are other ways.

Using schdiff with git's difftool
---------------------------------
schdiff allows the user to compare schematics from different versions.

example showing a diff from the current HEAD to 30 commits back:

````
git difftool -x schdiff HEAD~30 project.sch
````

Squashing the history after copying the template
------------------------------------------------

The history of this template project doesn't need to be part of the history a specific project that uses it
To squash the history, you can rebase back to the first commit.

````
git rebase -i `git rev-list --max-parents=0 HEAD` 
````
Squash everything but the top, change the comments as you see fit. Read up on git rebase 

````
git rebase --help
````
