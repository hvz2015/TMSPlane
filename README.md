# Topmetal-S sensor tiled plane

## PCB

One should use pcbnew manually to setup a PCB `template' with appropriate layer structure, via and track classes etc., then run the Python script that references the template.

It is important to generate a sch containing all needed netnames.  Then generate a netlist which is then imported into the template PCB.

## Software
### KiCad
Pull source from https://github.com/KiCad/kicad-source-mirror and compile.
