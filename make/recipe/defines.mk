################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSoC 6 build recipe.
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################
#
# Compactibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION=1

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS:=GCC_ARM IAR ARM

_MTB_RECIPE__START_FLASH:=0x10000000

# Cores configuration check
ifeq (1,$(words $(filter CORE_NAME_CM7%,$(DEVICE_$(DEVICE)_CORES))))
_MTB_RECIPE__HAS_SINGLE_CM7:=true
endif

ifeq ($(MTB_RECIPE__CORE),CM0P)
ifneq ($(MTB_RECIPE__CORE_NAME),CM0P_0)
$(call mtb__error,Incorrect combination of CORE=$(MTB_RECIPE__CORE) and CORE_NAME=$(MTB_RECIPE__CORE_NAME).\
	Supported value is CORE_NAME=CM0P_0. Check the CORE_NAME variable.)
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM7)
ifeq (,$(findstring $(MTB_RECIPE__CORE_NAME),CM7_0 CM7_1))
$(call mtb__error,Incorrect combination of CORE=$(MTB_RECIPE__CORE) and CORE_NAME=$(MTB_RECIPE__CORE_NAME).\
	Supported values are CORE_NAME=CM7_0 and CORE_NAME=CM7_1. Check the CORE_NAME variable.)
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM7)
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_1)
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
$(call mtb__error,The selected part number $(DEVICE) has single CM7 core.\
	Supported value is CORE_NAME=CM7_0. Check the CORE_NAME variable.)
endif
endif
endif

#
# Core specifics
#
ifeq ($(MTB_RECIPE__CORE),CM0P)
_MTB_RECIPE__OPENOCD_CORE:=cm0
_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE:=init
_MTB_RECIPE__GDBINIT_FILE:=gdbinit_cm0
_MTB_RECIPE__OPENOCD_CORE_PORT:=3333
_MTB_RECIPE__JLINK_GDB_PORT:=2334
_MTB_RECIPE__JLINK_SWO_PORT:=2335
_MTB_RECIPE__JLINK_TELNET_PORT:=2336
_MTB_RECIPE__JLINK_CORE:=CM0p
_MTB_RECIPE__JLINK_CORE_TVII:=M0
else ifeq ($(MTB_RECIPE__CORE),CM7)
_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE=run
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
_MTB_RECIPE__OPENOCD_CORE:=cm70
_MTB_RECIPE__OPENOCD_CORE_PORT:=3334
_MTB_RECIPE__JLINK_GDB_PORT:=2337
_MTB_RECIPE__JLINK_SWO_PORT:=2338
_MTB_RECIPE__JLINK_TELNET_PORT:=2339
_MTB_RECIPE__JLINK_CORE:=CM7_0
_MTB_RECIPE__JLINK_CORE_TVII:=M7_0
_MTB_RECIPE__GDBINIT_FILE=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)
else
_MTB_RECIPE__OPENOCD_CORE:=cm71
_MTB_RECIPE__OPENOCD_CORE_PORT:=3335
_MTB_RECIPE__JLINK_GDB_PORT:=2340
_MTB_RECIPE__JLINK_SWO_PORT:=2341
_MTB_RECIPE__JLINK_TELNET_PORT:=2342
_MTB_RECIPE__JLINK_CORE:=CM7_1
_MTB_RECIPE__JLINK_CORE_TVII:=M7_1
_MTB_RECIPE__GDBINIT_FILE=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)
endif
else
$(call mtb__error,Incorrect core $(MTB_RECIPE__CORE). Supported cores are CM0P and CM7. Check the CORE variable.)
endif

_MTB_RECIPE__OPENOCD_EXTRA_PORT_FLAG:=gdb_port 3333
_MTB_RECIPE__OPENOCD_EXTRA_PORT_ECLIPSE:=-c &quot;$(_MTB_RECIPE__OPENOCD_EXTRA_PORT_FLAG)&quot;&\#13;&\#10;
_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_DEBUG_ECLIPSE:=mon reset $(_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE)&\#13;&\#10;mon cat1c reset_halt sysresetreq&\#13;&\#10;flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi
_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_ATTACH_ECLIPSE:=flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi

#
# Architecure specifics
#
_MTB_RECIPE__OPENOCD_CHIP_NAME:=cat1c
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=cat1c.cfg
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
_MTB_RECIPE__OPENOCD_CM71_DISABLE_FLAG:=set ENABLE_CM71 0
_MTB_RECIPE__OPENOCD_CM71_DISABLE_ECLIPSE:=-c &quot;$(_MTB_RECIPE__OPENOCD_CM71_DISABLE_FLAG)&quot;&\#13;&\#10;
else
_MTB_RECIPE__OPENOCD_CM71_DISABLE_FLAG:=
_MTB_RECIPE__OPENOCD_CM71_DISABLE_ECLIPSE:=
endif

ifneq (,$(findstring CYT,$(DEVICE)))
_MTB_RECIPE__TVII_DEVICE=true
endif
ifeq (TVIIBH4M,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__SERIES:=XMC7100
else ifeq (TVIIBH8M,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__SERIES:=XMC7200
else
$(call mtb__error,Incorrect device die $(_MTB_RECIPE__DEVICE_DIE). Supported dies are TVIIBH4M TVIIBH8M. Check the DEVICE_$(DEVICE)_DIE variable.)
endif

ifeq ($(_MTB_RECIPE__TVII_DEVICE),true)
_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM:=$(DEVICE)_M0
_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG:=$(DEVICE)_$(_MTB_RECIPE__JLINK_CORE_TVII)
else
_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM:=$(_MTB_RECIPE__SERIES)-$(_MTB_RECIPE__DEVICE_FLASH_KB)_CM7_0_tm
_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG:=$(_MTB_RECIPE__SERIES)-$(_MTB_RECIPE__DEVICE_FLASH_KB)_$(_MTB_RECIPE__JLINK_CORE)_tm
endif

################################################################################
# Paths
################################################################################

################################################################################
# IDE specifics
################################################################################

MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8

CY_QSPI_FLM_DIR_OUTPUT?=$(CY_QSPI_FLM_DIR)
ifeq ($(CY_QSPI_FLM_DIR_OUTPUT),)
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER=
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG=
else
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER=set QSPI_FLASHLOADER $(patsubst %/,%,$(CY_QSPI_FLM_DIR_OUTPUT))/CAT1C_SMIF.FLM
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_APPLICATION=set QSPI_FLASHLOADER $(patsubst ../%/,%,$(CY_QSPI_FLM_DIR_OUTPUT))/CAT1C_SMIF.FLM
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG=-c &quot;$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER)&quot;&\#13;&\#10;
endif

_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR=$(MTB_RECIPE__CORE)
MTB_RECIPE_VSCODE_TEMPLATE_SUBDIR=CMx/
ifeq ($(MTB_TYPE),PROJECT)
IS_MULTI_CORE=true
endif
ifeq ($(MTB_TYPE),APPLICATION)
IS_MULTI_CORE=true
_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR=Application
endif

ifneq (,$(findstring CM7,$(MTB_RECIPE__CORE_NAME)))
ifeq ($(IS_MULTI_CORE),true)
CY_VSCODE_CORE_NAME=$(MTB_RECIPE__CORE_NAME)
else
CY_VSCODE_CORE_NAME=CM7
endif
endif

ifeq ($(IS_MULTI_CORE),true)
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
CY_VSCODE_WORKSPACE_TEMPLATE_NAME=wks_dual.code-workspace
else
CY_VSCODE_WORKSPACE_TEMPLATE_NAME=wks_triple.code-workspace
endif
endif

ifneq ($(OTA_SUPPORT),)
# OTA post-build script needs python.
CY_PYTHON_REQUIREMENT=true
endif

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)

CY_VSCODE_JSON_PROCESSING=\
	if [[ $$jsonFile == "launch.json" ]]; then\
		cp -f $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile;\
		if [[ $(MTB_RECIPE__CORE) == CM0P ]]; then\
			grep -v "//CM7 Only//" $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile >\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
		else\
			sed -e 's/\/\/CM7 Only\/\///g' $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile >\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
		fi;\
		if [[ "$(IS_MULTI_CORE)" == "true" ]]; then\
			sed -e '/\/\/Except multi-core start\/\//,/\/\/Except multi-core end\/\//d'\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile >\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile;\
			if [[ "$(_MTB_RECIPE__HAS_SINGLE_CM7)" == "true" ]]; then\
				grep -v "//triple-core only//" $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile >\
					$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
			else\
				sed -e 's/\/\/triple-core only\/\///g' $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile >\
					$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
			fi;\
			if [[ "$(_MTB_RECIPE__TVII_DEVICE)" == "true" ]]; then\
				sed -e 's/\/\/traveo only\/\///g' $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile >\
					$(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile;\
			else\
				grep -v "//traveo only//" $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile >\
					$(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile;\
			fi;\
		else\
			sed -e 's/\/\/Except multi-core start\/\///g' -e 's/\/\/Except multi-core end\/\///g'\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile >\
				$(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile;\
		fi;\
		mv -f $(CY_VSCODE_OUT_TEMPLATE_PATH)/__$$jsonFile $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
	fi;

CY_VSCODE_OPENOCD_PROCESSING=\
	if [[ $(MTB_RECIPE__CORE) == CM0P ]]; then\
		grep -v "$${TARGET}.cm7[0|1]" $(CY_VSCODE_OUT_PATH)/openocd.tcl > $(CY_VSCODE_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_OUT_PATH)/_openocd.tcl $(CY_VSCODE_OUT_PATH)/openocd.tcl;\
	fi;\
	if [ $(MTB_RECIPE__CORE) == CM7 ] && [ $(MTB_RECIPE__CORE_NAME) == CM7_0 ]; then\
		grep -v "$${TARGET}.cm71" $(CY_VSCODE_OUT_PATH)/openocd.tcl > $(CY_VSCODE_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_OUT_PATH)/_openocd.tcl $(CY_VSCODE_OUT_PATH)/openocd.tcl;\
	fi;\
	if [ $(MTB_RECIPE__CORE) == CM7 ] && [ $(MTB_RECIPE__CORE_NAME) == CM7_1 ]; then\
		grep -v "$${TARGET}.cm70" $(CY_VSCODE_OUT_PATH)/openocd.tcl > $(CY_VSCODE_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_OUT_PATH)/_openocd.tcl $(CY_VSCODE_OUT_PATH)/openocd.tcl;\
	fi;\
	if [[ "$(_MTB_RECIPE__HAS_SINGLE_CM7)" != "true" ]]; then\
		grep -v "set ENABLE_CM71 0" $(CY_VSCODE_OUT_PATH)/openocd.tcl > $(CY_VSCODE_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_OUT_PATH)/_openocd.tcl $(CY_VSCODE_OUT_PATH)/openocd.tcl;\
	fi;\

CY_VSCODE_OPENOCD_PROCESSING_APPLICATION=\
	if [[ "$(_MTB_RECIPE__HAS_SINGLE_CM7)" == "true" ]]; then\
		grep -v "$${TARGET}.cm71" $(CY_VSCODE_APPLICATION_OUT_PATH)/openocd.tcl > $(CY_VSCODE_APPLICATION_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_APPLICATION_OUT_PATH)/_openocd.tcl $(CY_VSCODE_APPLICATION_OUT_PATH)/openocd.tcl;\
	else\
		grep -v "set ENABLE_CM71 0" $(CY_VSCODE_APPLICATION_OUT_PATH)/openocd.tcl > $(CY_VSCODE_APPLICATION_OUT_PATH)/_openocd.tcl;\
		mv -f $(CY_VSCODE_APPLICATION_OUT_PATH)/_openocd.tcl $(CY_VSCODE_APPLICATION_OUT_PATH)/openocd.tcl;\
	fi;\

$(MTB_RECIPE__IDE_RECIPE_DATA_FILE)_vscode:
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__DEVICE_PROGRAM&&|$(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM)|g;" > $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__DEVICE_DEBUG&&|$(_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__OPENOCD_CHIP&&|$(_MTB_RECIPE__OPENOCD_CHIP_NAME)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__QSPI_CFG_PATH&&|$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__QSPI_CFG_PATH_APPLICATION&&|$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__QSPI_FLASHLOADER&&|$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__QSPI_FLASHLOADER_APPLICATION&&|$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_APPLICATION)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__FIRST_APP_NAME&&|$(word 1,$(MTB_APPLICATION_SUBPROJECTS))|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__SECOND_APP_NAME&&|$(word 2,$(MTB_APPLICATION_SUBPROJECTS))|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__THIRD_APP_NAME&&|$(word 3,$(MTB_APPLICATION_SUBPROJECTS))|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
ifeq ($(MTB_RECIPE__CORE),CM0P)
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&|CM0+|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&|0|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&|init|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
else
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&|$(CY_VSCODE_CORE_NAME)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&|1|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&|run|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
else
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_1)
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&|$(CY_VSCODE_CORE_NAME)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&|2|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&|run|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
endif
endif
endif
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__PROCESSOR_COUNT&&|2|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
else
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__PROCESSOR_COUNT&&|3|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM7)
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
_MTB_RECIPE__IAR_CORE_SUFFIX=M7
else
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
_MTB_RECIPE__IAR_CORE_SUFFIX=M7_0
else
_MTB_RECIPE__IAR_CORE_SUFFIX=M7_1
endif
endif
else ifeq ($(MTB_RECIPE__CORE),CM0P)
_MTB_RECIPE__IAR_CORE_SUFFIX=M0+
endif

ifeq ($(filter ewarm8,$(MAKECMDGOALS)),ewarm8)

# The device name format needs to match the name of the device in the IAR database.
# Expected format for Cypress single core devices is {MPN-name}.
# Expected format for Cypress multi core device is {MPN-name}{Core}.
ewarm8_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(DEVICE)$(_MTB_RECIPE__IAR_CORE_SUFFIX))

ewarm8: ewarm8_recipe_data_file

endif #($(filter ewarm8,$(MAKECMDGOALS)),ewarm8)

ifeq ($(filter uvision5,$(MAKECMDGOALS)),uvision5)

_MTB_RECIPE__CMSIS_ARCH_NAME:=CAT1C_DFP
_MTB_RECIPE__CMSIS_VENDOR_NAME:=Infineon
_MTB_RECIPE__CMSIS_VENDOR_ID:=7

# Define _MTB_RECIPE__CMSIS_PNAME for export into uVision
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M7-0
else ifeq ($(MTB_RECIPE__CORE_NAME),CM7_1)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M7-1
else ifeq ($(MTB_RECIPE__CORE_NAME),CM0P_0)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M0p
else
_MTB_RECIPE__CMSIS_PNAME:=
endif

_MTB_RECIPE__CMSIS_LDFLAGS:=--predefine="-D_CORE_$(MTB_RECIPE__CORE_NAME)_=1"

uvision5_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_PNAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_LDFLAGS))

uvision5: uvision5_recipe_data_file

endif #($(filter uvision5,$(MAKECMDGOALS)),uvision5)

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)

# For multi-core application a set of launch configurations is a bit different.
# To handle this, copy templates into a separate folder and remove extra configurations
_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/template_dir
_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR:=$(MTB_RECIPE__CORE_NAME)

eclipse_recipe_template_dir: 
	$(CY_NOISE)if [ -d "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)" ]; then\
		rm -f -r "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)";\
	fi;\
	mkdir $(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR);\
	cp -r "$(MTB_TOOLS__RECIPE_DIR)/make/scripts/eclipse/$(_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR)" "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)";\
	if [[ "$(IS_MULTI_CORE)" != "true" ]]; then\
		if [[ $(MTB_RECIPE__CORE) == "CM7" ]]; then\
			rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/$(_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR)/Add CM7"* || true;\
		fi;\
	else\
		rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/$(_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR)/Program"*;\
		rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/$(_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR)/Erase"*;\
		cp -r "$(MTB_TOOLS__RECIPE_DIR)/make/scripts/eclipse/Application" "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)";\
		if [[ "$(_MTB_RECIPE__HAS_SINGLE_CM7)" == "true" ]]; then\
			for f in "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Debug MultiCore dualcore"*; do mv "$$f" "$${f//dualcore /}"; done;\
			for f in "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Program Application dualcore"*; do mv "$$f" "$${f//dualcore /}"; done;\
			rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Debug MultiCore triplecore"*;\
			rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Program Application triplecore"*;\
		else\
			for f in "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Debug MultiCore triplecore"*; do mv "$$f" "$${f//triplecore /}"; done;\
			for f in "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Program Application triplecore"*; do mv "$$f" "$${f//triplecore /}"; done;\
			rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Debug MultiCore dualcore"*;\
			rm "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application/Program Application dualcore"*;\
		fi;\
	fi;

eclipse_recipe_template_dir_clean: | eclipse_generate
	$(CY_NOISE)if [ -d "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)" ]; then\
		rm -f -r "$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)";\
	fi;
eclipse_generate: eclipse_recipe_template_dir
eclipse: eclipse_recipe_template_dir_clean

eclipse_textdata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_SECOND_RESET&&=$(_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_RUN_RESTART_DEBUG_CMD&&=$(_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_DEBUG_ECLIPSE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_RUN_RESTART_ATTACH_CMD&&=$(_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_ATTACH_ECLIPSE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_PORT_SELECT&&=$(_MTB_RECIPE__OPENOCD_EXTRA_PORT_ECLIPSE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__CORE&&=$(_MTB_RECIPE__OPENOCD_CORE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CORE_PORT_SELECT&&=$(_MTB_RECIPE__OPENOCD_CORE_PORT))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CM71_FLAG&&=$(_MTB_RECIPE__OPENOCD_CM71_DISABLE_ECLIPSE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__QSPI_CFG_PATH&&=$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__QSPI_FLASHLOADER&&=$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_GDB_PORT&&=$(_MTB_RECIPE__JLINK_GDB_PORT))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_SWO_PORT&&=$(_MTB_RECIPE__JLINK_SWO_PORT))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_TELNET_PORT&&=$(_MTB_RECIPE__JLINK_TELNET_PORT))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__FIRST_APP_NAME&&=$(word 1,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__SECOND_APP_NAME&&=$(word 2,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__THIRD_APP_NAME&&=$(word 3,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__APPNAME&&=$(_MTB_ECLIPSE_PROJECT_NAME))

_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH:=$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/$(_MTB_RECIPE__ECLIPSE_TEMPLATE_SUBDIR)
_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH:=$(_MTB_RECIPE__ECLIPSE_TEMPLATE_DIR)/Application

eclipse_recipe_metadata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_APP_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),PROJECT_UUID=&&PROJECT_UUID_$(MTB_RECIPE__CORE_NAME)&&)
endif

