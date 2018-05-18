# Standard Digital Design Flow
This is a complete tutorial for you to get familiar with the standard digital design flow.
It contains a complete skeleton (the `SKELETON` directory, using umc065 process as an example) for
you to do your own digital design, from RTL HDL design all the way to physical layout for tape-out.

## Disclaimer
This so-called *"standard digital design flow"* is not for fully-digital design like CPU or others.
Instead this digital design flow works for mixed-signal design where the digital part finally has
to be integrated with the analog part. So the ultimate production of this flow would be a compact
digital layout with specified ports to be integrated with other analog layout.

## Standard digital design flow
A standard digital design flow consists of
1. RTL HDL design
2. Behavior simulation (platform: Synopsys&reg; VCS)
3. Logic synthesis (platform: Synopsys&reg; Design Compiler)
4. Post-synthesis simulation (platform: Synopsys&reg; VCS)
5. Place & route (platform: Cadence&reg; Encounter Digital Implementation)
6. Post-layout simulation (platform: Synopsys&reg; VCS)
7. Integration with analog part (platform: Cadence&reg;)

Note that the above steps are iterative. For example, after logic synthesis, it is possible
that the design no longer meets the design specification, thus you need to fall back to
step 3 or even step 2 and 1 to find the reason and fix the problem.

## SKELETON working directory
The provided directory named `SKELETON` is a sample working directory for your digital design
flow. Within this directory all the steps mentioned in previous section will be performed, 6
directories are set for 6 steps respectively. The structure of `SKELETON` working directory is
shown below.

![SKELETON directory structure](dir_layout.png "SKELETON directory structure")

Now we can establish the relationships of each directory to each step (from step 1 to step 6) in
the flow above.
- RTL HDL design &mdash; `SKELETON/verilog`
- Behavior simulation &mdash; `SKELETON/pre_sim`
- Logic synthesis &mdash; `SKELETON/syn`
- Post-synthesis simulation &mdash; `SKELETON/syn_sim`
- Place & route &mdash; `SKELETON/soc`
- Post-layout simulation &mdash; `SKELETON/post_sim`
- Integration with analog part &mdash; Inside Cadence

Whereas `SKELETON/Makefile` is used for easier operation of each step. There are other resources
used during each process but not included here. They will be declared at prerequisite section
for each step if necessary.

It is strongly recommended that you keep everything the same way. You can change the names and
paths according to your flavor but you must modify `SKELETON/Makefile` accordingly. To start,
change the current working directory to the same directory as `Makefile`. Type `make init` in
terminal to check the environment configurations.
```console
[SKELETON]$ make init
```

## Prerequisite
In order to ensure that this tutorial works the best for you, a few prerequisites must be met.
If you are not [IPEL](http://www.ece.ust.hk/~ipel) members or are not using the same process
as in this tutorial, it should still be adequate enough for you to establish everything
accordingly.

### Linux command line environment
First of all, it is very important for users to get used to the Linux development
environment, especially the Linux command line. A lot of the operations in the design flow
are done with Linux command line and sometimes only possible to be done with command line.
Thus, you must get familiar with the command line working environment.

Another prerequisite would be that you have all your tool chains properly set up and necessary
resources regarding digital design provided by the foundry. For example, this tutorial is for
[IPEL](http://www.ece.ust.hk/~ipel) members, and the tool chains are specified according to
IPEL Linux servers. Furthermore, umc065 process is used as example, so if you are using
other process, you are on your own to find out all the corresponding resources vital for
digital design flow.

### Tool chain setup
As mentioned above, we have to use different sets of tool chains to complete each step. For
[ipel](http://www.ece.ust.hk/~ipel) members, all the required tools are available on the Linux
server.
- Synopsys&reg; VCS
- Synopsys&reg; Design Compiler
- Cadence&reg; Encounter Digital Implementation

To setup the tools properly, you should put the following lines to your `~/.cshrc_user` so that
they could be loaded by default each time you start a terminal.
```sh
source /usr/eelocal/synopsys/vcs_mx-vi2014.03-2/.cshrc  # Synopsys VCS
source /usr/eelocal/synopsys/syn-vi2013.12-sp5-5/.cshrc # Synopsys Design Compiler
source /usr/eelocal/cadence/edi142/.cshrc               # Cadence  EDI
```

Currently (May 2018) all these tools are up-to-date. Update the tools if newer versions are
available.

### Digital standard cell library
The digital standard cell library should be prepared in prior. A Cadence library containing all
the standard digital cells (like AND, XOR, DFF, etc.) is a must, in which abstract view, layout
view, symbol view and schematic view are ready for later usage (some special cells may have some
views missing). Necessary resources are provided by the foundry to be imported into Cadence to
make such a library. For umc065 process, the deliverable content would be

| Directory name/path | Description                                                                  |
| ------------------- | ---------------------------------------------------------------------------- |
| doc                 | A directory containing the files of databook.pdf, cell list etc              |
| cir                 | A directory containing the netlist file after RC extraction                  |
| lvs_netlist         | A directory containing the netlist file for LVS                              |
| gds                 | A directory containing the GDSII file                                        |
| synopsys            | A directory containing the files of Synopsys NLDM liberty models             |
| synopsys/ccs        | A directory containing the files of Synopsys CCS Timing/Noise liberty models |
| symbol              | A directory containing the Cadence composer symbol and EDIF symbol           |
| verilog             | A directory containing verilog model                                         |
| fastscan            | A directory containing ATPG model                                            |
| vital               | A directory containing vital model                                           |
| lef                 | A directory containing lef macro files and technology files                  |
| milkyway            | A directory containing ICC technology files and database                     |

## Step 1: RTL HDL design
The very first step of the digital design flow is to prepare your verilog HDL design based on
the desired functional specification. A skeleton verilog file `SKELETON.v` is already provided
under `SKELETON/verilog` along with 3 testbench files, one for behavior simulation, one for
post-synthesis simulation and one for post-layout simulation. The testbench files are exactly
the same except for the file name and the inclusion of the design module to be tested.

By default there is only one design file under `SKELETON/verilog`. If your design is gonna have
multiple modules, create new files under `SKELETON/verilog` and remember to include them while
compiling (modify `SKELETON/Makefile`). Another recommended solution would be placing all your
modules inside one design file so that you do not need to modify `SKELETON/Makefile`.

Unfortunately not every verilog design is synthesizable. A poorly written verilog module may
violate certain synthesis rules so that you cannot proceed. Here are a few suggestions that
could possibly help you avoid this.
- Avoid combinational feedback
- Avoid hidden latches (always have `default` for `case` statement and `else` for `if` statement)
- Always include a complete sensitivity list in each `always` block
- Do not assign to `reg` type signal in multiple `always` blocks

## Step 2: Behavior simulation
### Prerequisite
- Tool: Synopsys&reg; VCS
- Input: Verilog HDL design and corresponding testbench

The working directory is the same directory as `Makefile`.

### Execution
When you have prepared your verilog HDL design and corresponding testbench files (for behavior
simulation it is `SKELETON/verilog/tb_SKELETON.v`), behavior simulation can be carried out to
verify the functionality of your design. But remember that if you have multiple design files it is
necessary to **either** include them all by modifying the `pre_sim` section in `SKELETON/Makefile`,
**or** put all the modules inside one design file (recommended).

The simulation can be run by typing `make pre_sim` in terminal.
```console
[SKELETON]$ make pre_sim
```

Compilation and everything else will be run automatically (you can check the `pre_sim` section in
`SKELETON/Makefile` for details), and the intermediate files and produced executive are stored in
`SKELETON/pre_sim`. If everything is completed without any error, DVE GUI will be launched for
you to run the simulation and check the output waveform. If there is any syntax error, fix it
according to the error message.

Desired functionality and synthesizable verilog HDL design are the requirements for you to proceed
to the next step.

## Step 3: Logic synthesis
Synthesis is the all encompassing, generic term for the process of achieving an optimal gate-level
netlist from HDL code. Logic synthesis transforms your idea to physically implementable design.
Genrally logic synthesis consists of 3 steps.
- Translation
- Logic optimization
- Mapping

All processes are included when you run Synopsys&reg; Design Compiler, but you won't be aware of
the different stages when it is running. Translation step would translate your RTL HDL to GTECH
HDL, where GTECH is a general, virtual and technology-independent digital cell library. After that
GTECH HDL is further optimized and mapped to the target technology by replacing the generic
GTECH gates with technology-specific gates from your standard digital cell library. Finally the
technology-specific gate-level netlist is derived.

### Prerequisite
- Tool: Synopsys&reg; Design Compiler
- Input: standard digital cell library, `.synopsys_dc.setup`, `run_dc.tcl` and `SKELETON.v`
  - Standard digital cell library, called synthesis library later on in this section, is the
  technology-specific synthesis library provided by the foundry which contains all the standard
  digital cells that will be used by the synthesis tool to map your design to physically
  implementable gate-level netlist and also calculate the corresponding parameters.
  - `.synopsys_dc.setup` is the default environment configuration for Synopsys&reg; Design
  Compiler. For example, it sets up the path to the synthesis library. It needs to be put at the
  directory where you start Design Compiler to take effect.
  - `run_dc.tcl` contains the design constraints applied to the current design and the commands to
  run synthesis. It needs to be modified regarding different designs.
  - `SKELETON.v` is just a symbolic link to `../verilog/SKELETON.v`. This is the RTL HDL design
  to be synthesized.

The working directory is the same directory as `Makefile`.

### Design constraints
During synthesis, design constraints must be applied to constrain the Design Compiler. There are
infinite numbers of designs to realize the desired function, but with design constraints there are
only limited solutions, and Design Compiler will try to find you one that meets the constraints
if possible. It is possible that the resultant design cannot satisfy all the constraints. In that
case you should change your constraints accordingly.

Some typical constraints that are commonly applied would be
- create\_clk
- create\_generated\_clock
- set\_clock\_uncertainty
- set\_input\_delay
- set\_driving\_cell
- set\_output\_delay
- set\_load
- set\_max\_capacitance
- set\_max\_area

Details about design constraints could be found on the Internet or in the books about logic
synthesis. Be careful about assigning design constraints and adding or removing certain constraint
types, because the design constraints play a critical role in the synthesis process for finding a
reasonable compromise between timing and area/power for the output result. Proper design
constraints lead to satisfying performance, while improper design constraints lead to poor
circuit.

### Execution
After your design has passed the behavior simulation, you could proceed to synthesize the design.
Synthesis is run under `SKELETON/syn` directory, where the products are also placed. Before you
run synthesis, make sure the 3 files named `.synopsys_dc.setup`, `run_dc.tcl` and `SKELETON.v`
respectively are all set properly. Type `make synthesis` in terminal to run synthesis.
```console
[SKELETON]$ make synthesis
```

By default (as specified in the current `run_dc.tcl` file), a directory named `reports` and a
log file named `dc.log` will be created under `SKELETON/syn` for you to check the results. It is
highly recommended that you closely check the reports and log file to verify if synthesis is
successfully completed and the constraints are met or certain violations can be ignored.

### Output

3 important logic synthesis products named `SKELETON.sdc`, `SKELETON.sdf` and `SKELETON_syn.v`
are generated under `SKELETON/syn` to proceed.
- `SKELETON.sdc` is a **s**ynopsys **d**esign **c**onstraint file used later in layout generation.
It is derived from your input design constraints.
- `SKELETON.sdf` is a **s**tandard **d**elay **f**ormat file used later for post-synthesis
simulation. It contains the delay information for all standard digital cells used in the design
and also estimated delay for interconnections.
- `SKELETON_syn.v` is the technology-specific gate-level **v**erilog netlist file derived from
the original verilog HDL design. All the digital gates are from your specified synthesis library,
meaning that it is indeed physically implementable.

## Step 4: Post-synthesis simulation

### Prerequisite
- Tool: Synopsys&reg; VCS
- Input: behavior model of the standard digital cell library, gate-level netlist from last step,
corresponding testbench and sdf file
  - Behavior model of the standard digital cell library is needed, since after synthesis the
  gate-level netlist utilizes the digital cells from the standard digital cell library. Compilation
  needs the path to the behavior model.
  - `SKELETON/syn_sim/SKELETON_syn.v` is a symbolic link to the synthesized gate-level netlist
  under `SKELETON/syn/SKELETON_syn.v`.
  - `SKELETON/syn_sim/tb_SKELETON_syn.v` is a symbolic link to the testbench for post-synthesis
  simulation under `SKELETON/verilog/tb_SKELETON_syn.v`.
  - `SKELETON/syn_sim/SKELETON.sdf` is a symbolic link to the sdf file `SKELETON/syn/SKELETON.sdf`.

The working directory is the same directory as `Makefile`.

### Execution
When you have your 3 synthesized products ready under `SKELETON/syn`, the previously red, invalid
symbolic link `SKELETON/syn_sim/SKELETON_syn.v` and `SKELETON/syn_sim/SKELETON.sdf` are now
**valid**. The `SKELETON.sdf` file will be back-annotated during simulation to include all the
delays to verify the function of the design implemented with physical standard digital cells.

The compilation command is a little bit different from behavior simulation (You can check
`Makefile` if interested). It will include the behavior model of the standard digital cell library
through `-v` option and back-annotate the delay information through `-sdf` option. Run
post-synthesis simulation by typing `make syn_sim` in terminal.
```console
[SKELETON]$ make syn_sim
```

Check if there is any syntax error and also **sdf annotation error**. Again, the intermediate
files and produced executive are stored in `SKELETON/syn_sim`. The waveform after simulation
would present you signal latency as well as possible glitches. Make sure that **functionality**
is still achieved, otherwise you may need to go back and find the reason.

## Reference
1. Kurup, Pran, and Taher Abbasi. Logic synthesis using Synopsys&reg;. Springer Science & Business Media, 2012.
2. Bhatnagar, Himanshu. Advanced ASIC Chip Synthesis: Using Synopsys&reg; Design CompilerTM Physical CompilerTM and PrimeTime&reg;. Springer Science & Business Media, 2007.
3. 虞希清. 专用集成电路设计实用教程. 浙江大学出版社, 2007.
