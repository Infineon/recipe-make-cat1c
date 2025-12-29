################################################################################
# \file recipe_ide.mk
#
# \brief
# This make file defines the IDE export variables and target.
#
################################################################################
# \copyright
# (c) 2022-2025, Cypress Semiconductor Corporation (an Infineon company)
# or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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

MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/interface_version_2/recipe_ide_common.mk

##############################################
# Eclipe VSCode
##############################################
ifeq ($(firstword $(MTB_APPLICATION_SUBPROJECTS)),$(notdir $(realpath $(MTB_TOOLS__PRJ_DIR))))
_MTB_RECIPE__IS_FIRST_PRJ=1
endif

_MTB_RECIPE__IDE_TEXT_DATA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_text_data.txt

CY_QSPI_FLM_DIR_OUTPUT?=$(CY_QSPI_FLM_DIR)
ifeq ($(CY_QSPI_FLM_DIR_OUTPUT),)
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER=
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG=
else
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER=set QSPI_FLASHLOADER $(patsubst %/,%,$(CY_QSPI_FLM_DIR_OUTPUT))/CAT1C_SMIF.FLM
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_APPLICATION=set QSPI_FLASHLOADER $(patsubst ../%/,%,$(CY_QSPI_FLM_DIR_OUTPUT))/CAT1C_SMIF.FLM
_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG=-c &quot;$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER)&quot;&\#13;&\#10;
endif

ifeq ($(MTB_TYPE),PROJECT)
_MTB_RECIPE__IS_MULTI_CORE_APPLICATION:=true
endif

ifneq (,$(findstring CM7,$(MTB_RECIPE__CORE_NAME)))
ifeq ($(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION),true)
_MTB_RECIPE__VSCODE_CORE_NAME=$(MTB_RECIPE__CORE_NAME)
else
_MTB_RECIPE__VSCODE_CORE_NAME=CM7
endif
endif

_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_vscode_template_meta_data.txt
_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_vscode_template_regex_data.txt
vscode_generate: recipe_vscode_text_replacement_data_file recipe_vscode_meta_data_file recipe_vscode_regex_replacement_data_file
vscode_generate: MTB_CORE__EXPORT_CMDLINE += -textdata $(_MTB_RECIPE__IDE_TEXT_DATA_FILE) -metadata $(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE) -textregexdata $(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE)

recipe_vscode_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__DEVICE_PROGRAM&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__DEVICE_DEBUG&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CHIP&&=$(_MTB_RECIPE__OPENOCD_CHIP_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_CFG_PATH&&=$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_CFG_PATH_APPLICATION&&=$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_FLASHLOADER&&=$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_FLASHLOADER_APPLICATION&&=$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_APPLICATION))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__FIRST_APP_NAME&&=$(word 1,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__SECOND_APP_NAME&&=$(word 2,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__THIRD_APP_NAME&&=$(word 3,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__MCU_NAME&&=$(_MTB_RECIPE__MCU_NAME))
ifeq ($(MTB_RECIPE__CORE),CM0P)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&=CM0+)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&=0)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&=init)
endif
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&=$(_MTB_RECIPE__VSCODE_CORE_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&=1)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&=run)
endif
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_1)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NAME&&=$(_MTB_RECIPE__VSCODE_CORE_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__TARGET_PROCESSOR_NUMBER&&=2)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__LAUNCH_RESET_TYPE&&=run)
endif
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__PROCESSOR_COUNT&&=2)
else
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__PROCESSOR_COUNT&&=3)
endif

recipe_vscode_regex_replacement_data_file:
ifeq (CM7,$(MTB_RECIPE__CORE))
	$(call mtb__file_write,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//CM7 Only//(.*)$$=\1\2)
else
	$(call mtb__file_write,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM7 Only//.*$$=)
endif
ifeq (CM7_0,$(MTB_RECIPE__CORE_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//CM7_0 Only//(.*)$$=\1\2)
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM7_0 Only//.*$$=)
endif
ifeq (CM7_1,$(MTB_RECIPE__CORE_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//CM7_1 Only//(.*)$$=\1\2)
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM7_1 Only//.*$$=)
endif
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//triple-core only//.*$$=)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//dual-core only//(.*)$$=\1\2)
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//triple-core only//(.*)$$=\1\2)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//dual-core only//.*$$=)
endif
ifeq (true,$(_MTB_RECIPE__TVII_DEVICE))
ifneq (,$(filter true,$(_MTB_RECIPE__IS_TVIIC2D4M_DEVICE) $(_MTB_RECIPE__IS_TVIIC2D6M_DEVICE)))
ifeq ($(MTB_RECIPE__CORE),CM0P)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//CM0 TVIIC2D only//(.*)$$=\1\2)
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM0 TVIIC2D only//.*$$=)
endif
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//traveo only//.*$$=)
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^(.*)//traveo only//(.*)$$=\1\2)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM0 TVIIC2D only//.*$$=)
endif
else
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//traveo only//.*$$=)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_REGEX_DATA_FILE),^.*//CM0 TVIIC2D only//.*$$=)
endif

recipe_vscode_meta_data_file:
ifneq (,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
	$(call mtb__file_write,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/CMx/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/launch_multicore.json=.vscode/launch.json)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(MTB_TOOLS__CORE_DIR)/make/scripts/interface_version_2/vscode/dependencies_tasks.json=.vscode/tasks.json)
ifneq (,$(_MTB_RECIPE__IS_FIRST_PRJ))
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/Application/openocd.tcl=../openocd.tcl)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/Application/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/launch.json=../.vscode/launch.json)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(MTB_TOOLS__CORE_DIR)/make/scripts/interface_version_2/vscode/tasks.json=../.vscode/tasks.json)
else #(,$(_MTB_RECIPE__IS_FIRST_PRJ))
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=../.vscode=../.vscode)
endif #(,$(_MTB_RECIPE__IS_FIRST_PRJ))
else #(,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
	$(call mtb__file_write,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/CMx/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/launch.json=.vscode/launch.json)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(MTB_TOOLS__CORE_DIR)/make/scripts/interface_version_2/vscode/tasks.json=.vscode/tasks.json)
endif #(,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR),KitProg3)
	$(call mtb__file_append,$(_MTB_RECIPE__VSCODE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/CMx/openocd.tcl=openocd.tcl)
endif

.PHONY: recipe_vscode_text_replacement_data_file recipe_vscode_meta_data_file recipe_vscode_regex_replacement_data_file

##############################################
# Eclipse
##############################################
_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_eclipse_template_meta_data.txt
eclipse_generate: recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_data_file
eclipse_generate: MTB_CORE__EXPORT_CMDLINE += -textdata $(_MTB_RECIPE__IDE_TEXT_DATA_FILE) -metadata $(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE)

recipe_eclipse_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_SECOND_RESET&&=$(_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_RUN_RESTART_DEBUG_CMD&&=$(_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_DEBUG_ECLIPSE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_RUN_RESTART_ATTACH_CMD&&=$(_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_ATTACH_ECLIPSE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_PORT_SELECT&&=$(_MTB_RECIPE__OPENOCD_EXTRA_PORT_ECLIPSE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__CORE&&=$(_MTB_RECIPE__OPENOCD_CORE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CORE_PORT_SELECT&&=$(_MTB_RECIPE__OPENOCD_CORE_PORT))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CM71_FLAG&&=$(_MTB_RECIPE__OPENOCD_CM71_DISABLE_ECLIPSE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CHIP&&=$(_MTB_RECIPE__OPENOCD_CHIP_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_CFG_PATH&&=$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__QSPI_FLASHLOADER&&=$(_MTB_RECIPE__OPENOCD_QSPI_FLASHLOADER_WITH_FLAG))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_GDB_PORT&&=$(_MTB_RECIPE__JLINK_GDB_PORT))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_SWO_PORT&&=$(_MTB_RECIPE__JLINK_SWO_PORT))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_TELNET_PORT&&=$(_MTB_RECIPE__JLINK_TELNET_PORT))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__FIRST_APP_NAME&&=$(word 1,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__SECOND_APP_NAME&&=$(word 2,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__THIRD_APP_NAME&&=$(word 3,$(MTB_APPLICATION_SUBPROJECTS)))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__PRJ_NAME&&=$(_MTB_RECIPE__ECLIPSE_PROJECT_NAME))

recipe_eclipse_meta_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),UUID=&&PROJECT_UUID_$(MTB_RECIPE__CORE_NAME)&&)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),UUID=&&PROJECT_UUID&&)
ifeq (true,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),APPLICATION_UUID=&&APPLICATION_UUID&&)
ifneq (,$(_MTB_RECIPE__IS_FIRST_PRJ))
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),UPDATE_APPLICATION_PREF_FILE=1)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/Application/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)=../.mtbLaunchConfigs)
ifeq (true,$(_MTB_RECIPE__HAS_SINGLE_CM7))
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/Dual/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)=../.mtbLaunchConfigs)
else
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/Triple/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)=../.mtbLaunchConfigs)
endif
else
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=../.mtbLaunchConfigs=../.mtbLaunchConfigs)
endif #(,$(_MTB_RECIPE__IS_FIRST_PRJ))
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_0)
ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), KitProg3)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(MTB_RECIPE__CORE)/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/dual_core=.mtbLaunchConfigs)
endif
endif
ifeq ($(MTB_RECIPE__CORE_NAME),CM7_1)
ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), KitProg3)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(MTB_RECIPE__CORE)/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/triple_core=.mtbLaunchConfigs)
endif
endif
else #(true,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(MTB_RECIPE__CORE)/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/single_core=.mtbLaunchConfigs)
endif #(true,$(_MTB_RECIPE__IS_MULTI_CORE_APPLICATION))
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(MTB_RECIPE__CORE)/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/any_core=.mtbLaunchConfigs)

.PHONY: recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_data_file

##############################################
# EW UV
##############################################
_MTB_RECIPE__IDE_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_build_data.txt

ewarm8 uvision5: recipe_build_data_file
ewarm8 uvision5: MTB_CORE__EXPORT_CMDLINE += -build_data $(_MTB_RECIPE__IDE_BUILD_DATA_FILE)

recipe_build_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_BUILD_DATA_FILE),LINKER_SCRIPT=$(MTB_RECIPE__LINKER_SCRIPT))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_BUILD_DATA_FILE),LDFLAGS=$(_MTB_RECIPE__XMC7__LDFLAGS))

.PHONY:recipe_build_data_file

##############################################
# UV
##############################################
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

_MTB_RECIPE__UV_DFP_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_dfp_data.txt
_MTB_RECIPE__UV_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_uv_build_data.txt

uvision5: recipe_uvision5_dfp_data_file
uvision5: MTB_CORE__EXPORT_CMDLINE += -dfp_data $(_MTB_RECIPE__UV_DFP_DATA_FILE) --build_data  $(_MTB_RECIPE__UV_BUILD_DATA_FILE)

recipe_uvision5_dfp_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__UV_DFP_DATA_FILE),DEVICE=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__UV_DFP_DATA_FILE),DFP_NAME=$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__UV_DFP_DATA_FILE),VENDOR_NAME=$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__UV_DFP_DATA_FILE),VENDOR_ID=$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(_MTB_RECIPE__UV_DFP_DATA_FILE),PNAME=$(_MTB_RECIPE__CMSIS_PNAME))

.PHONY: recipe_uvision5_dfp_data_file
##############################################
# EW
##############################################
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
