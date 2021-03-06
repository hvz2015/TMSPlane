# Topmetal-S sensor tiled plane

## PCB

We use KiCad and python script to generate schematic, footprint, and PCB layout with minimal manual intervention.

### Procedure:
#### Schematic
1. Draw a Topmetal-S schematic symbol and save in a SCH library ```TMSch.lib```.  ```TMSch.lib``` is symlink-ed to every project.  When modifying the library, open the original ```.lib''' file directly instead of opening the symlinks.
2. run ```GenSch.py``` to generate desired schematic for the TMS array with correct net connectivity.  Here we save the generated file as ```array.sch```, which is a 2nd-level hierarchical schematic under ```Phi10cmBonding.sch```.
3. Open ```Phi10cmBonding.sch``` and generate a netlist.
#### PCB
1. Run ```KiPcbFp.py``` to generate a footprint ```TMS1mm.kicad_mod``` and save it under ```TMPcb.pretty``` which is a footprint library.  One may need to modify ```~/.config/kicad/fp-lib-table``` in order for KiCad to find the library: ```(lib (name Topmetal)(type KiCad)(uri ${KIPRJMOD}/TMPcb.pretty)(options "")(descr "Topmetal bonding footprints"))```.  An alternative is to save a local ```fp-lib-table``` file in the project directory.
2. Use pcbnew manually to setup a PCB `template' with appropriate layer structure, via and track classes etc.  Here we call the template ```template.kicad_pcb```.
3. Draw trace connections within a single footprint using a copy of the template PCB.  Save the single chip SCH and PCB as ```TMS1mm1chip.{sch,kicad_pcb}```.  It is preferable to place TMS1mm module's center at the very center in the unit cell.  It will be used as a reference (local origin).
4. Make a copy of the template PCB and load the netlist into it.  This step will bring all footprints into the PCB.
5. Run ```GenPcb.py``` which references the netlist-loaded PCB and ```TMS1mm1chip.pcb```, and generates the correctly laid out array.
6. **Remember to press `b' in pcbnew** to (re-)fill zones.

## Software
### KiCad

Pull source from https://github.com/KiCad/kicad-source-mirror and compile.

### KiCadScript in Hardware/PCB/KiCadScript/

#### Run scripts in Pcbnew's python shell:
```
import os, sys, runpy
scriptPath = os.environ['KIPRJMOD'] + "/../KiCadScript"
sys.path.append(scriptPath)
sys.argv = ['', '-h']
fileGlobals = runpy.run_path(scriptPath + "/GenSch2ExDAC.py", run_name="__main__")
```

#### Compile C source code to be used in python
```sh
cd KiAuto/hexlib/
python setup.py build
cd build
ln -s lib.freebsd-11.0-STABLE-amd64-2.7/hexlib.so .
```

### KiCad schematic sheets and netnames
KiCad schematic sheets are organized hierarchically.  Sheet paths are named as ```/58F9164E/58F91649``` with the numbers being timestamps in hex format.  Netnames local to a sheet start with a leading ```/```.  Global netnames do not have leading ```/```.

# PCB design and manufacturing

## Manufacturer capabilities

[Sunstone capabilities](http://www.sunstone.com/pcb-manufacturing-capabilities/detailed-capabilities)

|                     | Sunstone preferred | Sunstone capable |
| ------------------- |:------------------ |:---------------- |
| minimum drill size  | 0.008"             | 0.005"           |
| minimum trace width | 0.004" 1 oz Cu     | 0.003"           |
| trace clearance     | 0.004" 1 oz Cu     | 0.003"           |
| through-hole pad dia | 0.018" larger than finished hole dia | 0.016" larger |

Finished hole dia = drill dia - 4mil

### Typical board thickness in inch
```
0.062, 0.093, 0.125, 0.0886(14-layer), 0.0756 (16-layer)
```
1oz copper thickness is 34um (1.34mil)

### Typical drill sizes diameter in inch
```
0.008, 0.014, 0.020, 0.025, 0.029, 0.033, 0.035, 0.040, 0.043, 0.046, 0.052, 0.061,
0.067, 0.079, 0.088, 0.093, 0.100, 0.110, 0.125, 0.141, 0.150, 0.167, 0.192, 0.251
```
For boards thicker than 100mil, usually drill size cannot be smaller than board thickness / 10 (aspect ratio).

### Via
A recommendation: make the drill size diameter the same as the width of the trace, and the pad size roughly twice the diameter.

### Impedance
width/clearance 6mil/6mil and 4mil/4mil on surface layers, 4mil/7mil and 4mil/10mil inner layers are commonly used for Zo=50Ohm, Zdiff=100Ohm.
