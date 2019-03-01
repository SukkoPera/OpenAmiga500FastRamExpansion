# OpenAmiga500FastRamExpansion
OpenAmiga500FastRamExpansion is an Open Hardware 4/8 MB Fast RAM Expansion for the Commodore Amiga 500 Computer.

![Board](https://raw.githubusercontent.com/SukkoPera/OpenAmiga500FastRamExpansion/master/doc/render-top.png)

### Summary
Most low-end Amiga models only came with *Chip RAM*. "Big Box" models allowed for a different type of memory to be installed, known as *Fast RAM*, where *fast* means that it's dedicated to the main processor, so that it doesn't have to compete with the other chips in order to gain access to it (as is the case with Chip RAM). While both Chip and Fast RAM are limited in size, you can have at least a few MB of the latter on all Amigas (usually up to 8), while the former can never exceed 2 MB.

OpenAmiga500FastRamExpansion will allow you to add 4 or 8 MB of Fast RAM to your Amiga 500. This way you will be able to run more applications at once and more quickly. If you combine it with [a chip RAM expansion](https://github.com/SukkoPera/OpenAmiga600RamExpansion), you will also be able to run almost all games supported by WHDLoad, pushing your Amiga to its limits. The Fast RAM will be mapped to `$200000-$9fffff` (`$200000-$5fffff` for the 4 MB version).

OpenAmiga500FastRamExpansion is basically a clone of [a RAM expansion produced by Kipper2K a few years ago](http://eab.abime.net/showthread.php?t=64218), based on [an earlier design by lvd/NedoPC](http://lvd.nedopc.com/Projects/a600_8mb/index.html). He has since stopped producing and selling these cards and I thought it was a pity that he didn't open his designs and actually took all of them down, as this card is quite cheap to build and really useful. So I set about recreating it from scratch.

### Memory Compatibility
The required RAM Type is 16 Mbit (1M×16) DRAM in the SOJ-42 package with up to 70-80 ns access time. It is 5v-only DRAM (not SD(!)RAM) often found in old 72-pin SIMMs, EDO chips might work or not. All chips having *8160* in their part number should be OK.

See [OpenAmiga600FastRamExpansion](https://github.com/SukkoPera/OpenAmiga600FastRamExpansion#memory-compatibility) for a compatibility list.

RAM chips can either be soldered directly to the board or installed in sockets. While soldering the chips might not be trivial for the unexperienced, sockets for the SOJ-42 package are hard to find and not really easier to solder either, so the choice is up to you.

### Assembly and Installation
Normally it is not necessary to mount all the decoupling capacitors. I usually skip C4 and C7. Maybe capacitor C13 can be left out as well, your choice. R4 should be chosen according to the particular led you will be using for LD1. Actually you are free to skip LD1 and R4 altogether, if you hate power LEDs.

After everything has been soldered, you will need to program the CPLD. Whenever you do so, **make sure to carefully remove the board from your Amiga, or you might risk damaging it**. Use the typical cheap *USB Blaster* clone you can find on eBay for the task.

For the 4 MB version, solder only U7 and U8 and use the dedicated CPLD firmware.

When assembly is complete, open your A500 and remove the top shield. Carefully remove the CPU (leftmost chip), using a chip extractor or a small flat screwdriver, taking care not to break/bend any pins. Plug it on the board, matching the orientation, and plug the whole board in the CPU socket.

Before reassembling your case, I recommend to run [SysTest](https://github.com/keirf/Amiga-Stuff). Use the Memory option (<kbd>F1</kbd>), it must show 4 MB of Fast RAM. Then start the Memory Test (<kbd>F1</kbd> again) and let it run for 50-100 rounds: if it doesn't find any errors, you are probably good to go. If you get any errors, check your solder joints, starting from those for the RAM chips.

### License
The OpenAmiga500FastRamExpansion documentation, including the design itself, is copyright &copy; SukkoPera 2019.

OpenAmiga500FastRamExpansion is Open Hardware licensed under the [CERN OHL v. 1.2](http://ohwr.org/cernohl).

You may redistribute and modify this documentation under the terms of the CERN OHL v.1.2. This documentation is distributed *as is* and WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES whatsoever with respect to its functionality, operability or use, including, without limitation, any implied warranties OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE or infringement. We expressly disclaim any liability whatsoever for any direct, indirect, consequential, incidental or special damages, including, without limitation, lost revenues, lost profits, losses resulting from business interruption or loss of data, regardless of the form of action or legal theory under which the liability may be asserted, even if advised of the possibility or likelihood of such damages.

A copy of the full license is included in file [LICENSE.pdf](LICENSE.pdf), please refer to it for applicable conditions. In order to properly deal with its terms, please see file [LICENSE_HOWTO.pdf](LICENSE_HOWTO.pdf).

The contact points for information about manufactured Products (see section 4.2) are listed in file [PRODUCT.md](PRODUCT.md).

Any modifications made by Licensees (see section 3.4.b) shall be recorded in file [CHANGES.md](CHANGES.md).

The Documentation Location of the original project is https://github.com/SukkoPera/OpenAmiga500FastRamExpansion/.

### Support the Project
Since the project is open you are free to get the PCBs made by your preferred manufacturer, however in case you want to support the development, you can order them from PCBWay through this link:

[![PCB from PCBWay](https://www.pcbway.com/project/img/images/frompcbway.png)](https://www.pcbway.com/project/shareproject/OpenAmiga500FastRamExpansion_V1.html)

You get my gratitude and cheap, professionally-made and good quality PCBs, I get some credit that will help with this and [other projects](https://www.pcbway.com/project/member/shareproject/?bmbid=41100). You won't even have to worry about the various PCB options, it's all pre-configured for you!

Also, if you still have to register to that site, [you can use this link](https://www.pcbway.com/setinvite.aspx?inviteid=41100) to get some bonus initial credit (and yield me some more).

Again, if you want to use another manufacturer, feel free to, don't feel obligated :).

### Get Help
If you need help or have questions, you can join [the official Telegram group](https://t.me/joinchat/HUHdWBC9J9JnYIrvTYfZmg).

### Thanks
- lvd for the initial design and the support he gave me during development
- Kipper2K for making his boards
- majinga for helping with the testing
