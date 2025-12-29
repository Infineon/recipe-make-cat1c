################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the XMC7000 and Traveo II build recipe.
#
################################################################################
# \copyright
# (c) 2018-2025, Cypress Semiconductor Corporation (an Infineon company)
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

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################
_MTB_RECIPE__PROGRAM_INTERFACE_SUPPORTED:=KitProg3 JLink

#
# Compatibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION:=2
MTB_RECIPE__EXPORT_INTERFACES:=1 2 3 4

MTB_RECIPE__NINJA_SUPPORT:=1 2
#
# List the supported toolchains
#
ifdef CY_SUPPORTED_TOOLCHAINS
MTB_SUPPORTED_TOOLCHAINS?=$(CY_SUPPORTED_TOOLCHAINS)
else
MTB_SUPPORTED_TOOLCHAINS?=GCC_ARM IAR ARM LLVM_ARM
endif

# For BWC with Makefiles that do anything with CY_SUPPORTED_TOOLCHAINS
CY_SUPPORTED_TOOLCHAINS:=$(MTB_SUPPORTED_TOOLCHAINS)

_MTB_RECIPE__START_FLASH:=0x10000000

#Exact string: TVIIC2D6M
ifneq (,$(findstring TVIIC2D6M,$(_MTB_RECIPE__DEVICE_DIE)))
_MTB_RECIPE__IS_TVIIC2D6M_DEVICE:=true
endif
ifneq (,$(findstring TVIIC2D4M,$(_MTB_RECIPE__DEVICE_DIE)))
_MTB_RECIPE__IS_TVIIC2D4M_DEVICE:=true
endif
ifneq (,$(filter true,$(_MTB_RECIPE__IS_TVIIC2D4M_DEVICE)))
_MTB_RECIPE__IS_SINGLE_CM7_DEVICE_DIE:=true
endif

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
_MTB_RECIPE__OPENOCD_GDBINIT_FILE:=gdbinit_cm0
_MTB_RECIPE__JLINK_GDBINIT_FILE:=gdbinit_cm0_jlink
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
# For single CM7 only devices JLink aliases do not have core index suffix
_MTB_RECIPE__JLINK_CORE_TVII:=M7_0
ifeq (true,$(_MTB_RECIPE__IS_SINGLE_CM7_DEVICE_DIE))
_MTB_RECIPE__JLINK_CORE_TVII:=M7
endif
_MTB_RECIPE__OPENOCD_GDBINIT_FILE:=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)
_MTB_RECIPE__JLINK_GDBINIT_FILE:=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)_jlink
else
_MTB_RECIPE__OPENOCD_CORE:=cm71
_MTB_RECIPE__OPENOCD_CORE_PORT:=3335
_MTB_RECIPE__JLINK_GDB_PORT:=2340
_MTB_RECIPE__JLINK_SWO_PORT:=2341
_MTB_RECIPE__JLINK_TELNET_PORT:=2342
_MTB_RECIPE__JLINK_CORE:=CM7_1
_MTB_RECIPE__JLINK_CORE_TVII:=M7_1
_MTB_RECIPE__OPENOCD_GDBINIT_FILE:=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)
_MTB_RECIPE__JLINK_GDBINIT_FILE:=gdbinit_$(_MTB_RECIPE__OPENOCD_CORE)_jlink
endif
else
$(call mtb__error,Incorrect core $(MTB_RECIPE__CORE). Supported cores are CM0P and CM7. Check the CORE variable.)
endif

_MTB_RECIPE__OPENOCD_EXTRA_PORT_FLAG:=gdb_port 3333
_MTB_RECIPE__OPENOCD_EXTRA_PORT_ECLIPSE:=-c &quot;$(_MTB_RECIPE__OPENOCD_EXTRA_PORT_FLAG)&quot;&\#13;&\#10;
_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_DEBUG_ECLIPSE=mon reset $(_MTB_RECIPE__OPENOCD_SECOND_RESET_TYPE)&\#13;&\#10;mon $(_MTB_RECIPE__OPENOCD_CHIP_NAME) reset_halt sysresetreq&\#13;&\#10;flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi
_MTB_RECIPE__OPENOCD_RUN_RESTART_CMD_ATTACH_ECLIPSE:=flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi

#
# Architecure specifics
#
_MTB_RECIPE__MCU_NAME:=XMC7000
_MTB_RECIPE__OPENOCD_CHIP_NAME:=cat1c
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=cat1c.cfg
ifneq (,$(_MTB_RECIPE__IS_TVIIC2D6M_DEVICE))
_MTB_RECIPE__MCU_NAME:=CYT4DN
else ifneq (,$(_MTB_RECIPE__IS_TVIIC2D4M_DEVICE))
_MTB_RECIPE__MCU_NAME:=CYT3DL
endif
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
else ifeq (TVIIC2D6M,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__SERIES:=TVIIC2D6M
else ifeq (TVIIC2D4M,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__OPENOCD_CHIP_NAME:=traveo2
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=infineon/cyt3dl.cfg
_MTB_RECIPE__SERIES:=TVIIC2D4M
else
$(call mtb__error,Incorrect device die $(_MTB_RECIPE__DEVICE_DIE). Supported dies are TVIIBH4M TVIIBH8M. Check the DEVICE_$(DEVICE)_DIE variable.)
endif

ifeq ($(_MTB_RECIPE__TVII_DEVICE),true)
ifneq (,$(_MTB_RECIPE__IS_TVIIC2D6M_DEVICE))
_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM:=CYT4DNDBHA_M7_0
_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG:=CYT4DNDBHA_$(_MTB_RECIPE__JLINK_CORE_TVII)
else
_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM:=$(DEVICE)_M0
_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG:=$(DEVICE)_$(_MTB_RECIPE__JLINK_CORE_TVII)
endif
else
_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM:=$(_MTB_RECIPE__SERIES)-$(_MTB_RECIPE__DEVICE_FLASH_KB)_CM7_0_tm
_MTB_RECIPE__JLINK_DEVICE_CFG_DEBUG:=$(_MTB_RECIPE__SERIES)-$(_MTB_RECIPE__DEVICE_FLASH_KB)_$(_MTB_RECIPE__JLINK_CORE)_tm
endif

ifneq ($(OTA_SUPPORT),)
# OTA post-build script needs python.
CY_PYTHON_REQUIREMENT=true
endif


# Linker options definitions for multiple cores support
ifeq ($(TOOLCHAIN),IAR)
_MTB_RECIPE__XMC7__LDFLAGS+=--config_def _CORE_$(MTB_RECIPE__CORE_NAME)_=1
else ifeq ($(TOOLCHAIN),GCC_ARM)
_MTB_RECIPE__XMC7__LDFLAGS+=-Wl,'--defsym=_CORE_$(MTB_RECIPE__CORE_NAME)_=1'
else ifeq ($(TOOLCHAIN),ARM)
_MTB_RECIPE__XMC7__LDFLAGS+=--predefine="-D_CORE_$(MTB_RECIPE__CORE_NAME)_=1"
endif

