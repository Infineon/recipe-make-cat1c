&&_MTB_RECIPE__QSPI_FLASHLOADER&&
source [find interface/kitprog3.cfg]
&&_MTB_RECIPE__VSCODE_OPENOCD_PROBE_SERIAL_CMD&&
transport select &&_MTB_RECIPE__PROBE_INTERFACE&&
set ENABLE_CM71 0 //dual-core only//
source [find target/&&_MTB_RECIPE__OPEN_OCD_FILE&&]
${TARGET}.cm70 configure -rtos auto -rtos-wipe-on-reset-halt 1 //CM7_0 Only//
${TARGET}.cm71 configure -rtos auto -rtos-wipe-on-reset-halt 1 //CM7_1 Only//
&&_MTB_RECIPE__OPENOCD_CHIP&& sflash_restrictions 1
