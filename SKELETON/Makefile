###############################################
###############################################
# File: Makefile
# Author: Feng Chen @ IPEL
# Date: 15/04/2018
# Makefile for umc065 digital synthesis and P&R
###############################################
###############################################

#---- global variables ----#
WORK_PATH    := $(shell pwd)
TOP_MODULE   := $(shell basename `pwd`)
LIB_PATH      = /home/ipel1/fchenaf/VerilogDesign/umc065_digital
VLG_PATH      = $(WORK_PATH)/verilog
PRE_SIM_PATH  = $(WORK_PATH)/pre_sim
SYN_SIM_PATH  = $(WORK_PATH)/syn_sim
POST_SIM_PATH = $(WORK_PATH)/post_sim
SYN_PATH      = $(WORK_PATH)/syn
SOC_PATH      = $(WORK_PATH)/soc
VCS           = vcs +v2k -full64 -Mupdate -debug_all

#---- initialization ----#
init:
	@echo "----------------------------------------------"
	@echo SERVER        - $(HOST)
	@echo USER          - $(USER)
	@echo WORK PATH     - $(WORK_PATH)
	@echo TOP MODULE    - $(TOP_MODULE)
	@echo LIB PATH      - $(LIB_PATH)
	@echo VLG PATH      - $(VLG_PATH)
	@echo PRE SIM PATH  - $(PRE_SIM_PATH)
	@echo SYN SIM PATH  - $(SYN_SIM_PATH)
	@echo POST SIM PATH - $(POST_SIM_PATH)
	@echo SYN PATH      - $(SYN_PATH)
	@echo SOC PATH      - $(SOC_PATH)
	@echo VCS           - $(VCS)
	@echo "----------------------------------------------"

#---- clean up junk files ----#
clean_syn:
	@rm -v $(SYN_PATH)/*.log && rm -v $(SYN_PATH)/*.svf && rm -rv $(SYN_PATH)/reports

clean_soc:
	@rm -v $(SOC_PATH)/encounter.* && rm -rv $(SOC_PATH)/*[rR]eport? && rm -rv $(SOC_PATH)/qrc*.log && rm -rv $(SOC_PATH)/extLog* && rm -v $(SOC_PATH)/.holdtw* && rm -v $(SOC_PATH)/*.old

clean:
	@make --silent clean_syn ; make --silent clean_soc

#---- behavioral verilog simulation ----#
pre_sim: init
	@cd $(PRE_SIM_PATH) &&\
	$(VCS) tb_$(TOP_MODULE).v &&\
	./simv -gui &

#---- behavioral simulation after synthesis ----#
syn_sim: init
	@cd $(SYN_SIM_PATH) &&\
	$(VCS) +neg_tchk tb_$(TOP_MODULE)_syn.v -v $(LIB_PATH)/verilog/uk65lscllmvbbl_sdf21.v -sdf typ:$(TOP_MODULE):$(TOP_MODULE).sdf &&\
	./simv -gui &

#---- synopsys logic synthesis ----#
synthesis: init
	@cd $(SYN_PATH) &&\
	dc_shell-xg-t -f run_dc.tcl | tee -i dc.log

#---- post simulation after encounter process ----#
post_sim: init
	@cd $(POST_SIM_PATH) &&\
	$(VCS) +neg_tchk tb_$(TOP_MODULE)_encounter.v -v $(LIB_PATH)/verilog/uk65lscllmvbbl_sdf21.v -sdf max:$(TOP_MODULE):$(TOP_MODULE).sdf &&\
	./simv -gui &

#---- generate sp netlist ----#
sp:
	@cd $(SOC_PATH) &&\
	./v2lvs

#---- End of Makefile ----#
