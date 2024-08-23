&&_MTB_RECIPE__QSPI_FLASHLOADER_APPLICATION&&
source [find interface/kitprog3.cfg]
transport select swd
set ENABLE_CM71 0 //dual-core only//
source [find target/&&_MTB_RECIPE__OPEN_OCD_FILE&&]
${TARGET}.cm70 configure -rtos auto -rtos-wipe-on-reset-halt 1
${TARGET}.cm71 configure -rtos auto -rtos-wipe-on-reset-halt 1 //triple-core only//
&&_MTB_RECIPE__OPENOCD_DRIVER_NAME&& sflash_restrictions 1
