################################################################################
# \file GCC_ARM.mk
#
# \brief
# GCC ARM toolchain configuration
#
################################################################################
# \copyright
# (c) 2018-2025, Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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

################################################################################
# Macros
################################################################################

# The base path to the GCC cross compilation executables
_MTB_TOOLCHAIN_GCC_ARM__INSTALL_DIR:=$(wildcard $(call mtb_core__escaped_path,$(CY_TOOL_gcc_BASE_ABS)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__INSTALL_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_TOOL_gcc_BASE_ABS))
endif

ifeq ($(TOOLCHAIN),GCC_ARM)
_MTB_TOOLCHAIN_GCC_ARM__USER_1_DIR :=$(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_PATH)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__USER_1_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_COMPILER_PATH))
endif
endif

_MTB_TOOLCHAIN_GCC_ARM__USER_2_DIR :=$(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_GCC_ARM_DIR)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__USER_2_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_COMPILER_GCC_ARM_DIR))
endif

ifeq ($(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR),)
$(info CY_TOOL_gcc_BASE_ABS=$(CY_TOOL_gcc_BASE_ABS) [$(if $(wildcard $(call mtb_core__escaped_path,$(CY_TOOL_gcc_BASE_ABS))),exists,absent)])
$(info CY_COMPILER_PATH=$(CY_COMPILER_PATH) [$(if $(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_PATH))),exists,absent)])
$(info CY_COMPILER_GCC_ARM_DIR=$(CY_COMPILER_GCC_ARM_DIR) [$(if $(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_GCC_ARM_DIR))),exists,absent)])
#$(error Unable to find GCC_ARM base directory.)
endif

# Elf to bin conversion tool
MTB_TOOLCHAIN_GCC_ARM__ELF2BIN=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-objcopy

# Run ELF2BIN conversion
# $(1) : artifact elf
# $(2) : artifact bin
mtb_toolchain_GCC_ARM__elf2bin=$(MTB_TOOLCHAIN_GCC_ARM__ELF2BIN) -O binary $1 $2


################################################################################
# Tools
################################################################################

# The base path to the GCC cross compilation executables
ifeq ($(TOOLCHAIN),GCC_ARM)
CY_CROSSPATH:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)
endif

# Build tools
MTB_TOOLCHAIN_GCC_ARM__CC :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-gcc
MTB_TOOLCHAIN_GCC_ARM__CXX:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-g++
MTB_TOOLCHAIN_GCC_ARM__AS :=$(MTB_TOOLCHAIN_GCC_ARM__CC)
MTB_TOOLCHAIN_GCC_ARM__AR :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-ar
MTB_TOOLCHAIN_GCC_ARM__LD :=$(MTB_TOOLCHAIN_GCC_ARM__CXX)

MTB_TOOLCHAIN_GCC_ARM__READELF:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-readelf
MTB_TOOLCHAIN_GCC_ARM__GDB    :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-gdb
MTB_TOOLCHAIN_GCC_ARM__OBJCOPY:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-objcopy


################################################################################
# Options
################################################################################

# DEBUG/NDEBUG selection
ifeq ($(CONFIG),Debug)
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=-DDEBUG
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=-Og
else ifeq ($(CONFIG),Release)
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=-DNDEBUG
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=-Os
else
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=
endif

#
# Flags common to compile and link
#
_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS:=\
	-mthumb\
	-ffunction-sections\
	-fdata-sections\
	-ffat-lto-objects\
	-g\
	-Wall\
	-pipe

_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO:=--specs=nano.specs

#
# CPU core specifics
#
ifeq ($(MTB_RECIPE__CORE),CM0)
# Arm Cortex-M0 CPU
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m0 $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=
endif

ifeq ($(MTB_RECIPE__CORE),CM0P)
# Arm Cortex-M0+ CPU
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m0plus $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=
endif

ifeq ($(MTB_RECIPE__CORE),CM4)
# Arm Cortex-M4 CPU
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m4 $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
ifeq ($(VFP_SELECT),hardfp)
# FPv4 FPU, hardfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv4-sp-d16
else ifeq ($(VFP_SELECT),softfloat)
# Software FP
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=
else
# FPv4 FPU, softfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv4-sp-d16
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM7)
# Arm Cortex-M7 CPU
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m7 $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
ifeq ($(VFP_SELECT),hardfp)
ifeq ($(VFP_SELECT_PRECISION),singlefp)
# FPv5 FPU, hardfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv5-sp-d16
else
# FPv5 FPU, hardfp, double-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv5-d16
endif
else ifeq ($(VFP_SELECT),softfloat)
# Software FP
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=
else
ifeq ($(VFP_SELECT_PRECISION),singlefp)
# FPv5 FPU, softfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv5-sp-d16
else
# FPv5 FPU, softfp, double-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv5-d16
endif
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM33)
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_DSP_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
_MTB_TOOLCHAIN_GCC_ARM__DSP_FLAG_SUFFIX=+nodsp
else
_MTB_TOOLCHAIN_GCC_ARM__DSP_FLAG_SUFFIX=
endif
# Arm Cortex-M33 CPU
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m33$(_MTB_TOOLCHAIN_GCC_ARM__DSP_FLAG_SUFFIX) $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_FPU_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
# Software FP
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=
else
ifeq ($(VFP_SELECT),hardfp)
# FPv5 FPU, hardfp, single-precision only
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv5-sp-d16
else ifeq ($(VFP_SELECT),softfloat)
# Software FP
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=
else
# FPv5 FPU, softfp, single-precision only
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv5-sp-d16
endif
endif
endif

ifeq ($(MTB_RECIPE__CORE),CM55)
# Check if MVE is supported
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_MVE_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
ifneq ($(MVE_SELECT),NO_MVE)
$(call mtb__error, "MVE_SELECT=$(MVE_SELECT)" but "$(MTB_RECIPE__CORE)" core does not support MVE. Set "MVE_SELECT=NO_MVE" to disable MVE support for "$(MTB_RECIPE__CORE)" core.)
endif
endif
ifeq ($(MVE_SELECT),NO_MVE)
# Disable MVE
_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS=+nomve
else ifeq ($(MVE_SELECT),MVE-I)
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_FPU_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
# Force switch to softfloat mode if FPU is not available
_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS=+nofp
else
ifeq ($(VFP_SELECT),softfloat)
# Enable MVE-I and disable FPU
_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS=+nofp
else
# Integer precision MVE
_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS=+nomve.fp
endif
endif
else 
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_FPU_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
$(info INFO: MVE_SELECT=MVE-F is set but FPU is not available on $(MTB_RECIPE__CORE) core. Valid options for $(MTB_RECIPE__CORE) core are MVE_SELECT=MVE-I or MVE_SELECT=NO_MVE.)
else ifeq ($(VFP_SELECT),softfloat)
$(info INFO: MVE_SELECT=MVE-F is set but VFP_SELECT=softfloat. Set VFP_SELECT=softfp or VFP_SELECT=hardfp to enable MVE-F support.)
endif
# Integer, half-, and single-precision floating-point MVE
_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS=
endif
# Arm Cortex-M55 CPU + extensions
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-m55$(_MTB_TOOLCHAIN_GCC_ARM__MVE_FLAGS) $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
ifeq ($(filter $(MTB_RECIPE__CORE_NAME)_FPU_PRESENT,$(DEVICE_$(DEVICE)_FEATURES)),)
# Software FP
ifeq ($(MVE_SELECT),MVE-I)
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=-mfloat-abi=hard -mfpu=auto
else
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=
endif
else
ifeq ($(VFP_SELECT),softfp)
ifeq ($(VFP_SELECT_PRECISION),singlefp)
# FPv5 FPU, softfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv5-sp-d16
else
# FPv5 FPU, softfp, double-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=softfp -mfpu=fpv5-d16
endif
else ifeq ($(VFP_SELECT),softfloat)
# Software FP
ifeq ($(MVE_SELECT),MVE-I)
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=-mfloat-abi=hard -mfpu=auto
else
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS=
endif
else
ifeq ($(VFP_SELECT_PRECISION),singlefp)
# FPv5 FPU, hardfp, single-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv5-sp-d16
else
# FPv5 FPU, hardfp, double-precision
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=hard -mfpu=fpv5-d16
endif
endif
endif
endif

# Command line flags for c-files
MTB_TOOLCHAIN_GCC_ARM__CFLAGS:=\
	-c\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)

# Command line flags for cpp-files
MTB_TOOLCHAIN_GCC_ARM__CXXFLAGS:=\
	$(MTB_TOOLCHAIN_GCC_ARM__CFLAGS)\
	-fno-rtti\
	-fno-exceptions

# Command line flags for s-files
MTB_TOOLCHAIN_GCC_ARM__ASFLAGS:=\
	-c\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)

# Command line flags for archiving
MTB_TOOLCHAIN_GCC_ARM__ARFLAGS:=rs

# Command line flags for linking
MTB_TOOLCHAIN_GCC_ARM__LDFLAGS:=\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)\
	-Wl,--gc-sections

# Toolchain-specific suffixes
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_S  :=S
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_s  :=s
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_C  :=c
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_H  :=h
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CPP:=cpp
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CXX:=cxx
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CC :=cc
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_HPP:=hpp
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O  :=o
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_A  :=a
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D  :=d
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_LS :=ld
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_MAP:=map
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_TARGET:=elf
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_PROGRAM:=hex

# Toolchain specific flags
MTB_TOOLCHAIN_GCC_ARM__OUTPUT_OPTION:=-o
MTB_TOOLCHAIN_GCC_ARM__ARCHIVE_LIB_OUTPUT_OPTION:=-o
MTB_TOOLCHAIN_GCC_ARM__MAPFILE:=-Wl,-Map,
MTB_TOOLCHAIN_GCC_ARM__STARTGROUP:=-Wl,--start-group
MTB_TOOLCHAIN_GCC_ARM__ENDGROUP:=-Wl,--end-group
MTB_TOOLCHAIN_GCC_ARM__LSFLAGS:=-T
MTB_TOOLCHAIN_GCC_ARM__INCRSPFILE:=@
MTB_TOOLCHAIN_GCC_ARM__INCRSPFILE_ASM:=@
MTB_TOOLCHAIN_GCC_ARM__OBJRSPFILE:=@

# Produce a makefile dependency rule for each input file
MTB_TOOLCHAIN_GCC_ARM__DEPENDENCIES=-MMD -MP -MF "$(@:.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O)=.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D))" -MT "$@"
MTB_TOOLCHAIN_GCC_ARM__EXPLICIT_DEPENDENCIES=-MMD -MP -MF "$$(@:.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O)=.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D))" -MT "$$@"

# Additional includes in the compilation process based on this toolchain
MTB_TOOLCHAIN_GCC_ARM__INCLUDES:=

# TODO: Set MTB_RECIPE__xyzzy, replace MTB_TOOLCHAIN_xyzzy with recipe's var
# Additional libraries in the link process based on this toolchain
MTB_TOOLCHAIN_GCC_ARM__DEFINES:=$(_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG)

MTB_TOOLCHAIN_GCC_ARM__VSCODE_INTELLISENSE_MODE:=gcc-arm
MTB_TOOLCHAIN_GCC_ARM__VSCODE_PROBLEM_MATCHER:=gcc
