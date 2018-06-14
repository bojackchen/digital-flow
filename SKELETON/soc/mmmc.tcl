###############################################################
# MMMC TCL
# Environment: Cadence Encounter 10.1x
# ------------------------------------------------(HKUST IPEL)
# Update: Fan Yang, 28/03/2014
# Update: Feng Chen, 10/04/2018
###############################################################

# Version: 1.0 MMMC View Definition File
source vars.globals
# Create library set
create_library_set -name lib_tt -timing "$MyTimeLibTyp"
create_library_set -name lib_ff -timing "$MyTimeLibMin"
create_library_set -name lib_ss -timing "$MyTimeLibMax"
# Create RC corner
create_rc_corner -name rc_typ   -T "$MyTempTT" -qx_tech_file "$MyqrcTechFileTyp"
create_rc_corner -name rc_cmin  -T "$MyTempFF" -qx_tech_file "$MyqrcTechFileCmin"
create_rc_corner -name rc_cmax  -T "$MyTempSS" -qx_tech_file "$MyqrcTechFileCmax"
create_rc_corner -name rc_rcmin -T "$MyTempFF" -qx_tech_file "$MyqrcTechFileRCmin"
create_rc_corner -name rc_rcmax -T "$MyTempSS" -qx_tech_file "$MyqrcTechFileRCmax"
# Create delay corner
create_delay_corner -name delay_typ   -library_set {lib_tt} -rc_corner {rc_typ}
create_delay_corner -name delay_cmin  -library_set {lib_ff} -rc_corner {rc_cmin}
create_delay_corner -name delay_cmax  -library_set {lib_ss} -rc_corner {rc_cmax}
create_delay_corner -name delay_rcmin -library_set {lib_ff} -rc_corner {rc_rcmin}
create_delay_corner -name delay_rcmax -library_set {lib_ss} -rc_corner {rc_rcmax}
# Create constraint mode
create_constraint_mode -name cons_tt -sdc_files "$MySDCfile"
# Create analysis view
create_analysis_view -name func_typ   -constraint_mode {cons_tt} -delay_corner {delay_typ}
create_analysis_view -name func_cmin  -constraint_mode {cons_tt} -delay_corner {delay_cmin}
create_analysis_view -name func_cmax  -constraint_mode {cons_tt} -delay_corner {delay_cmax}
create_analysis_view -name func_rcmin -constraint_mode {cons_tt} -delay_corner {delay_rcmin}
create_analysis_view -name func_rcmax -constraint_mode {cons_tt} -delay_corner {delay_rcmax}
# Set analysis view
set_analysis_view -setup {func_cmax func_typ func_rcmax} -hold {func_cmin func_typ func_rcmin}
