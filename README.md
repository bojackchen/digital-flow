^-^
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
| lvs\_netlist        | A directory containing the netlist file for LVS                              |
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
could possibly help you avoid this [1], [2].
- Avoid combinational feedback
- Avoid hidden inferred latches (always have `default` for `case` statement and `else` for
`if` statement)
- Always include a complete sensitivity list in each `always` block
- Do not assign to `reg` type signal in multiple `always` blocks

In addition to the above, the following are general guidelines that every designer shoud be aware
of. There is no fixed rule adhere to these guidelines, however, following them vastly improves
the performance of the synthesized logic, and may produce a cleaner design that is well suited
for automating the synthesis process [1].
- Clock logic including clock gating logic and reset generation should be kept in one block, to
be synthesized once and not touched again
- Avoid multiple clocks per block
- No glue logic at top level
- Do not create unnecessary hierarchy
- Register all outputs whenever practical

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
netlist from HDL code [3]. Logic synthesis transforms your idea to physically implementable design.
Genrally logic synthesis consists of 3 steps [4].
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

Some typical constraints that are commonly applied would be [1], [4]
- create\_clk
- create\_generated\_clock
- set\_dont\_touch
- set\_clock\_latency
- set\_clock\_uncertainty
- set\_propagated\_clock
- set\_input\_delay
- set\_driving\_cell
- set\_output\_delay
- set\_load
- set\_max\_capacitance
- set\_max\_area
- set\_max\_fanout

Details about design constraints could be found on the Internet or in the books about logic
synthesis [1], [3], [4]. Be careful about assigning design constraints and adding or removing
certain constraint types, because the design constraints play a critical role in the synthesis
process for finding a reasonable compromise between timing and area/power for the output result.
Proper design constraints lead to satisfying performance, while improper design constraints lead
to poor circuit.

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

## Step 5: Place & route
With a clean and optimized netlist, it is ready to transfer the design to its physical form,
using the layout tool. The place & route process is complicated and can be condensed to several
steps as listed below [1], [3].
- Data Preparation & Validation
- Flow Preparation
- Pre-Placement
- Floorplanning
- Powerplanning
- Placement
- Pre-CTS
- Clock Tree Synthesis (CTS)
- Post-CTS
- Detail Routing
- Post-Route
- Physical Verification
- Timing Signoff

While **static timing analysis (STA)** is executed across the whole flow to ensure timing
closure at the end of the flow or mark the necessity of iteration between synthesis and P&R.

A more complete implementation flow is shown below [5]. It is not necessary to include all.

![Complete EDI timing closure flow](encounter_flow.jpg "Complete EDI timing closure flow")

### Data preparation & validation
#### Preparation
- Tool: Cadence&reg; EDI
- Input
  - Timing libraries, containing the timing of all standard digital cells for each corner
  - Physical libraries, containing the abstract defined for every standard digital cell,
  and the technology LEF file from process foundry
  - CapTable or QRC tech file for RC extraction
  - Output from synthesis (netlist and sdc)
  - Multi-Mode Multi-Corner (MMMC) setup for analyzing and optimizing the design over multiple
  operating conditions and process corners

#### Validation
After the preparation of all the necessary data, start encounter by typing `encounter` in terminal.
The encounter console would occupy the original terminal for you to run commands. To import the
design, type
```console
encounter 1> source vars.globals
encounter 1> init_design
```

Encounter will load the design and check the run environment for any missing setup or the design
for any problems and highlight them.

#### Optional check
You could proceed to the next step now, but alternatively there are several things you can check.
Run `checkDesign -all` command to check for missing or inconsistent library and design data, and
run `check_timing -verbose` to report timing problems that the Common Timing Engine (CTE) sees.
Run the command below to check the zero wire-load model timing to get an idea of how much effort
will be required to close timing [5].
```console
encounter 1> check_timing -verbose
encounter 1> checkDesign -all
encounter 1> timeDesign -prePlace
```

### Flow preparation
#### Design mode
Setting the design mode and understanding how extraction and timing analysis are used during the
flow are important for achieving timing closure [5]. This setting affects globally throughout
the whole flow.
```console
encounter 1> setDesignMode -process 65 -flowEffort high
```

As indicated above, `-process` option sets the process technology you are using so that it changes
the process technology dependent default settings globally. The `-flowEffort` options specifies
the effort level for every super command such as `placeDesign`, `optDesign` and `routeDesign`.

#### Extraction
Resistance and Capacitance (RC) extraction using the `extractRC` command is run frequently in the
flow. Set the extraction engine and effort level similarly. The first command is used before detail
routing while the second command should be run when detail routing is finished.
```console
encounter 1> setExtractRCMode -engine preRoute
encounter 1> setExtractRCMode -engine postRoute -effortLevel medium
```

The `-effortLevel` option controls which extractor is used when postRoute engine is used.
- `low` invokes the native detailed extraction engine. This is the default setting.
- `medium` invokes the Turbo QRC (TQRC) extraction engine. TQRC is the default engine for process
nodes of 65 nm and below whenever Quantus techfiles are available.
- `high` invokes the Integrated QRC (IQRC) extraction engine, which requires a Quantus QRC license.
- `signoff` invokes the Standalone Quantus QRC extraction engine. It provided the highest accuracy,
and obviously requires a Quantus QRC license.

#### Timing analysis
Timing analysis is typically run after each step in the timing closure flow using the `timeDesign`
command. If timing violation occurs, Global Timing Debug (GTD) GUI is recommended to analyze and
debug the results. The initial timing analysis should be performed after pre-CTS optimization.

### Pre-Placement
The goals of pre-placement Optimization are to optimize the netlist to
1. Improve the logic structure
2. Reduce congestion
3. Reduce area
4. Improve timing

In some situations, the input netlist from synthesis is not a good candidate for placement because
it might contain buffer trees or logic that is poorly structured for timing closure. It can be
accomplished by running `deleteBufferTree` and `deleteClockTree` commands to claim some area by
deleting buffer and double-inverter (by default, `deleteBufferTree` is run by `placeDesign`).

For designs where the logical structure or high congestion are the problems, restructuring or
remapping the cells can provide better results. Use the `runN2NOpt` to perform netlist-to-netlist
optimization.

### Floorplanning
Floorplanning targets at producing a floor plan with reasonable area, timing enclosure and no
routing congestion. It is recommended that an initial, prototyping mode floorplan can be run
for faster turnaround to get a baseline placement. This is optional, but if your design is apt
to having placement or routability problems, it is recommended that a prototyping floorplan and
placement be run in prior.
```console
encounter 1> setPlaceMode -fp true
```

When you are certain that your design can be properly placed and routed, run the command to
specify floorplan, where "1" is the aspect ratio, "0.6" is the core utilization and "8 8 8 8"
is the space reserved for power rings at the top, bottom, left and right. Apply proper values
for your own design.
```console
encounter 1> floorPlan -site CORE -r 1 0.6 8 8 8 8
```

### Powerplanning
#### Global net connection
After the floorplan, the spaces for power rings as well as the power and ground rails of the
standard digital cells are in place. It is possible now to complete the power plan. Global net
connections should be properly defined using the `globalNetConnect` command, or using the GUI
through `Power -> Connect Global Nets`. Totally there are 4 sets of entries required.

| Entry             | Set 1    | Set 2    | Set 3    | Set 4    |
| ----------------- |:--------:|:--------:|:--------:|:--------:|
| Pin Name(s)       | VDD      | VSS      |          |          |
| Instance Basename | *        | *        | *        | *        |
| Tie High          |          |          | selected |          |
| Tie Low           |          |          |          | selected |
| Apply All         | selected | selected | selected | selected |
| To Global Net     | VDD      | VSS      | VDD      | VSS      |

```console
encounter 1> globalNetConnect VDD -type pgpin -pin VDD -inst *
encounter 1> globalNetConnect VSS -type pgpin -pin VSS -inst *
encounter 1> globalNetConnect VDD -type tiehi -inst *
encounter 1> globalNetConnect VSS -type tielo -inst *
```

#### Power ring
The reserved power ring width is specified in floor plan and now it is time to add the power ring
surrounding the core area. Access through `Power -> Power Planning -> Add Ring` and specify the
parameters needed to finish the power ring setup. By default a VDD ring and a VSS ring are created
around the core area with VDD ring inside.

Another optional power plan is the power stripe running vertically. If you need it, access through
`Power -> Power Planning -> Add Stripe`.

#### Power routing
The `sroute` command is utilized to route the power/ground structures. Access through
`Route -> Special Route` to route the block pins, pad pins, pad rings, floating stripes, etc.
After that you would at lease have horizontal ME1 to connect all the VDD pins and VSS pins for
the standard digital cells.

### Placement
As the routability of the floorplan and powerplan stabilizes, you could place the standard digital
cells now. The command `placeDesign` by default is timing-driven (`setPlaceMode -timingDriven true`)
and pre-placement optimization is also enabled (`deleteBufferTree`, `deleteClockTree`).
```console
encounter 1> placeDesign
```

By default, placement will identify clock gates and place them in a good position for the rest of
the flow (`setPlaceMode -clkGateAware true`). The congestion repairing effort is auto-adaptive based
on the routing congestion (`setPlaceMode -congEffort auto`). And if the `flowEffort` is set to high,
then depending on the design, `placeDesign` may enable adaptive placement for better congestion
and timing closure.

The placement will finish along with a trial routing to indicate routability. It is important to
review the congestions and the trial route overflow issues in the log file. If congestion happens,
run `setPlaceMode -congEffort high` to enable the `congRepair` command, increase the numerical
iterations and make the instance bloating more aggressive. Standalone command `congRepair` can be
called in any part of the Pre-Route flow to relieve congestion.

### Pre-CTS
Pre-CTS optimization is run after placement to fix timing based on ideal clocks including
- Setup slack (WNS - worst negative slack)
- Design rule violation (DRV)
- Setup times (TNS - total negative slack)

The `optDesign` command will control timing convergence by updating the design state, placement
and routing, incrementally.

There are several optional guidelines before starting optimization
- Review `checkDesign -all` results
- Check that timing is met in zero wireload using `timeDesign -prePlace`
- Check the don't use report `reportDontUseCells`

Run pre-CTS optimization through
```console
encounter 1> optDesign -preCTS
```

When `optDesign` completes, you will see a summary of the timing results. Additionally, you can
also use the command `timeDesign -preCTS` to check the current timing.
```console
timeDesign -preCTS
```

Again, if timing violations exist, use Global Timing Debug (GTD) to analyze the problem. You can
also focus timing optimization on specific paths using path groups. By default `optDesign` will
temporarily generate 2 high effort `path_groups` (reg2reg and reg2clkgate). The flow to create
and optimize path groups is as follows:
```console
encounter 1> group_path -name path_group_name -from from_list -to to_list
encounter 1> setPathGroupOptions ...
encounter 1> optDesign -preCTS -incr
```

### CTS
The traditional goal of CTS is to buffer clock nets and balance clock path delays. From EDI 14.2
onwards, the default engine for performing this is CCOpt-CTS. The key steps and commands for a
typical setup are as follows.
1. Load post-CTS timing constraints
2. Configure non-default routing rules (NDRs) and route types using `create_route_type` and
`set_ccopt_property route_type` commands
3. Set a target maximum transition time and a target skew using
`set_ccopt_property target_max_trans` and `set_ccopt_property target_skew` commands
4. Configure which library cells CTS should use, using
`set_ccopt_property buffer_cells, inverter_cells, clock_gating_cells` and
`use_inverters` properties
5. Create a clock tree

To run CCOpt-CTS with the following command. CCOpt-CTS will automatically route clock nets using
NanoRoute, switch timing clocks to propagated mode and update source latencies to maintain
correct I/O and inter-clock timing.
```console
encounter 1> ccopt_design -cts
```

To report results after CTS, use the `timeDesign -postCTS` command. Reports on clock trees and
skew groups can be obtained using the following commands. Besides, the CCOpt Clock Tree Debugger
(CTD) permit interactive visualization of debugging of clock trees.
```console
report_ccopt_clock_trees -filename clock_trees.rpt
report_ccopt_skew_groups -filename skew_groups.rpt
```

### Post-CTS

### Detail Routing

### Post-Route

### Physical verification

### Timing Signoff

### Output

## Reference
[1] Bhatnagar, Himanshu. Advanced ASIC Chip Synthesis: Using Synopsys&reg; Design Compiler&trade;
Physical Compiler&trade; and PrimeTime&reg;. Springer Science & Business Media, 2007.

[2] Lee, Weng Fook. Verilog coding for logic synthesis. Wiley-interscience, 2003.

[3] Kurup, Pran, and Taher Abbasi. Logic synthesis using Synopsys&reg;. Springer Science & Business
Media, 2012.

[4] 虞希清. 专用集成电路设计实用教程. 浙江大学出版社, 2007.

[5] Cadence Design Systems Inc. EDI System User Guide. Cadence Design Systems Inc., 2015.
