# Firmware
Before installing the board into your Amiga, you will need to program the CPLD chip.

The firmware is the same as the original project by lvd. It has been copied here for convenience, but it is unmodified.

The firmware was originally developed for Altera `EPM7032SLC44` CPLDs.

Atmel/Microchip makes compatible devices under the `ATF1502` series, so the `ATF1502AS-10JC44` can be used as an alternative, which is easier to find nowadays (-10J*U*44 is fine as well).

## Flashing the firmware

### Altera EPM7032SLC44
You will need to load the `.POF` file in `quartus_pgm` and flash it using one of the cheap USB Blaster programmer clones you can find everywhere.

*NOTE: One user recommends NOT to use the auto-detect button as it will add two ICs to the window. Just select the USB Blaster hardware and load the .POF file (make sure to check only Program/Configure + Verify!). Then hit the Start button to flash.*

### Atmel/Microchip ATF1502AS-10JC44 (Official way)
You can program the .JED file using the [ATDH1150USB](https://www.microchip.com/DevelopmentTools/ProductDetails/ATDH1150USB) programmer.

### Atmel/Microchip ATF1502AS-10JC44 (Cheaper and hackish way)
These days you will only find the ATF1502AS-10JC44 (or -10JU44) on the market, but, if you read the above, you will know that you will need to buy a >50€ programmer to program it, which doesn't sound reasonable, as this will most likely only need to be done once. Besides, all the tools mentioned above are Windows-only so if you are a Linux user like me, you're pretty screwed. Luckily, there is a solution that allows flashing the Atmel chip with the cheap USB Blaster clones. I have developed and tested it under Linux, but it should also work on Windows and OS X.

First of all you need to power the board. JTAG programmers are not supposed to provide power, hence you need to do so separately. The board does not have a dedicated power connector, but you can use the pads of C1 (which I don't recommend installing, unless you have stability issues) or pins 2 (GND) and 4 (VCC) of the IDC connector. The board needs 5V, I usually take those from an Arduino board but feel free to use whatever suits you.

On the software side, you will need [UrJTAG](http://urjtag.sourceforge.net). I have only tested version 2018.09, others might work or not. I am not sure this version is readily available in binary format, so you might have to compile it from sources.

You will also need to get the [BSDL (Boundary Scan Description Language) files for the 1502 CPLDs](http://ww1.microchip.com/downloads/en/DeviceDoc/1502bsdl.zip). Download the zip file, uncompress it anywhere you like and take note of the path, you will need it later.

Finally, you will need the firmware in SVF format, available in this folder. Use either `4mb.svf` or `8mb.svf` according to how you assembled your board.

Now you are ready for the actual flashing, so connect your USB Blaster to the IDC connector on the board and plug it into an USB port on your PC. Then run urjtag as follows:

```
sukko@shockwave firmware $ sudo jtag

UrJTAG 2018.09 #
Copyright (C) 2002, 2003 ETC s.r.o.
Copyright (C) 2007, 2008, 2009 Kolja Waschk and the respective authors

UrJTAG is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
There is absolutely no warranty for UrJTAG.

warning: UrJTAG may damage your hardware!
Type "quit" to exit, "help" for help.

jtag> cable UsbBlaster
Connected to libftdi driver.
```

This means that your USB Blaster was detected correctly. Let's load the BSDL files, this is where you will need to use the path you took note of at the beginning:
```
jtag> bsdl path <path>
jtag>
```

Now we can scan the JTAG chain:
```
jtag> detect
IR length: 10
Chain length: 1
Device Id: 00000001010100000010000000111111 (0x0150203F)
  Filename:     bsdl/1502AS_A44.bsd
```

This means that the CPLD was found and it is ready to be programmed. If you get no output at this step, try disconnecting and reconnecting the USB Blaster or power to the board. If the chip gets detected but it is reported as unsupported, check that you downloaded the correct BSDL files. Then start the flashing:
```
jtag> svf 8mb.svf progress stop
warning: unimplemented mode 'ABSENT' for TRST
detail: Parsing   3660/3668 ( 99%)detail:
detail: Scanned device output matched expected TDO values.
```

If you get the above output, the flashing was successful and you can start using your board. If instead you get something like:
```
jtag> svf 8mb.svf
warning: unimplemented mode 'ABSENT' for TRST
Error svf: mismatch at position 64 for TDO
 in input file between line 2196 col 1 and line 2198 col 32
```

Then there was an error during the flashing, check your wiring, power and try again.

#### USB Blaster Clones
You are recommended to get **a full-size Altera USB Blaster clone**, i.e. one of these:

![Full-Size](img/good_usbblaster.jpg)

Note the *Rev.C*: I'm not sure if it is crucial, but the one I have says so and is working very well.

Do **NOT** buy this:

![Smaller](img/crappy_usbblaster.jpg)

It does not work correctly, as it always hangs between 47% and 49% of the flashing process.

## Windows considerations
I have managed to build a Windows binary of UrJTAG with only the minimum options needed to program these CPLDs through a USB Blaster. It was tested by a couple of users and seemed to be working fine. A user even automated the procedure, so now you can just download [the UrJTAG.zip file from the windows folder](windows/UrJTAG.zip), unzip it and double click on the `runme.bat` script (with the programmer and board already connected to your PC): this should guide you through the whole flashing process.

I hope this works for you, but please note that **it is unsupported**, as I have no computers running Windows.

## Tinkering with the firmware
The firmware was developed with Quartus 7.2, somewhat totally old and outdated, but I never got any problems with it. I DO NOT recommend using Quartus 6.x as I caught it generating wrong designs (in a way, nothing is working and when you swap to Quartus 7.2 not touching you project, everything is working back).

If you want to move to something newer, it seems that Quartus 10.x and 11.x are still supporting EPM7000S chips. Starting from Quartus 12.x there's no more support for that devices.

### POF => JED
Quartus will produce a .POF file. This can be converted to a .JED file for Atmel devices through [Microchip's POF2JED utility](https://www.microchip.com/design-centers/programmable-logic/spld-cpld/tools/software/pof2jed), which is Windows-only unfortunately.

### JED => SVF
An SVF file can be produced using [Microchip's ATMISP tool](https://www.microchip.com/design-centers/programmable-logic/spld-cpld/tools/software/atmisp), which is also Windows-only.

### Used chips from China
The chips can be pre-used if you bought your ATF1502AS from China. Sometimes JTAG interface is disabled on them, preventing normal JTAG operations.

To enable JTAG, connect +12V power through a 2.2kOhm resistor to pin 7 on the 68000 CPU connector. Afterwards flash the `atf1502as_erase.svf` file to the CLPD. Then you can follow the normal programming procedures.

## Thanks
- *lvd* for providing most of the above information and helping me come up with the Linux flashing procedure.
- *majinga* and *go0se* for testing and helping improve this procedure.
- EAB forum user *katarakt* for the note on Quartus.
- Szymon Roslowski and Graham P. for testing and improving the Windows package.

