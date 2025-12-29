# XMC7000 and Traveo II GNU make Build System Release Notes
This repo provides the build recipe make files and scripts for building and programming XMC7000 and Traveo II applications. Builds can be run either through a command-line interface (CLI) or through a supported IDE such as Eclipse or VS Code.

### What's Included?
This release of the XMC7000 and Traveo II GNU make build recipe includes complete support for building, programming, and debugging XMC7000 and Traveo II application projects. It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specific items, like the XMC7000 or Traveo II part, for the target board. Supported functionality includes the following:

* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code, IAR, uVision)
* Supported toolchains:
    * GCC
    * IAR
    * ARM Compiler 6
    * LLVM Embedded Toolchain for Arm (Experimental)

### What Changed?
#### v1.6.1
* Added support for TRAVEO™ T2G CYT3DL device series.

#### v1.6.0
* Moved CFLAGS, CXXFLAGS, ASFLAGS, LDFLAGS variables to be added after default flags. In case of conflict, most toolchains select the last flags as the option. This allows those variables to overwrite the default flags.
* Added support for GNU assembly syntax when using ARM toolchain.

#### v1.5.0
* Added Ninja support. Ninja build will be enabled by default with ModusToolbox 3.4, and latest core-make. To disable Ninja build set NINJA to empty-String. (For example: "make build NINJA=").

#### v1.4.1
* Fixed a postbuild dependency that could cause memcalc to fail.

#### v1.4.0
* Experimental support for LLVM Embedded Toolchain for Arm.
* Optimization for speed changed to optimization for size for the IAR toolchain.
* The feature of setting the default location of the ARM and IAR toolchains has been deprecated.
* Added task in VS Code export's tasks.json in multicore application to only build the current project.
* Added option for Eclipse export to only build the current project in multicore application.
* Added launch configurations for Eclipse and VS Code to only program/debug a single project in multi-core application.
* Added a "last_config" build configuration directory that contains the hex file and elf file from last build.
* VS Code and Eclipse launch configurations now use "last_config" directory. Launch configurations no longer have to be re-generated when switching between "Debug" and "Release".

#### v1.3.0
* Adds support for Traveo II Cluster 2D 6M devices.

#### v1.2.0
* Improved stability and bug fixes.

#### v1.1.1
* Added support for BSP_PROGRAM_INTERFACE to select debug interface. Valid values are "KitProg3" and "JLink". Default value is "KitProg3".
* Eclipse and VS Code export will now only generate the launch configuration for the selected programming interface.

#### v1.0.0
* Initial release

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools\_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY\_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the XMC7000 and Traveo II build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 3.5     |
| GCC Compiler                              | 11.3    |
| IAR Compiler                              | 9.3     |
| ARM Compiler                              | 6.16    |

Minimum required ModusToolbox Software Environment: v3.4

### More information
* [Infineon GitHub](https://github.com/Infineon)
* [ModusToolbox](https://www.infineon.com/cms/en/design-support/tools/sdk/modustoolbox-software)

---
(c) 2022-2025, Cypress Semiconductor Corporation (an Infineon company) or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
