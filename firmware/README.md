# Main PCB

## AVR firmware (for ISP programmer)
### Fuses
- low  - 0x3F
- high - 0x88
- ext  - 0xFF
- lock - 0xEF

### Bootloader
- zxevo_bl.hex - flash
- zxevo_bl.e2p - eeprom

Link: http://nedopc.com/zxevo/zxevo.php


## AVR firmware (for bootloader via USB/SD card)
### Test & Service
- zxevo_fw_tns_vdac2.bin

Link: https://github.com/tslabs/zx-evo/blob/master/pentevo/test_n_service/trunk/zxevo_fw_tns_vdac2.bin

### BaseConf + TSConf
- zxevo_fw_vdac2.bin

Link: https://github.com/tslabs/zx-evo/blob/master/pentevo/avr/current/default/zxevo_fw_vdac2.bin


## ROM
### BaseConf
- zxevo_fe.rom

Link: http://nedopc.com/zxevo/zxevo.php

### TSConf
Install on top of BaseConf
- ts-bios.rom

Link: https://github.com/tslabs/zx-evo/tree/master/pentevo/rom/bin



# Top PCB
## NeoGS ROM
**Flash before soldering!**
- full_ngs.rom

Link: http://nedopc.com/gs/ngs.php

## NeoGS CPLD firmware
- GS_cpld_3064.pof - for EPM3064ATC100
- GS_cpld_3128.pof - for EPM3128ATC100

Link: http://nedopc.com/gs/ngs.php

## PSG CPLD firmware
-
