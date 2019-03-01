# OpenAmiga500FastRamExpansion
OpenAmiga500FastRamExpansion is an Open Hardware 4/8 MB Fast RAM Expansion for the Commodore Amiga 500 Computer.

![Board](https://raw.githubusercontent.com/SukkoPera/OpenAmiga500FastRamExpansion/master/doc/render-top.png)

### Summary
Most low-end Amiga models only came with *Chip RAM*. "Big Box" models allowed for a different type of memory to be installed, known as *Fast RAM*, where *fast* means that it's dedicated to the main processor, so that it doesn't have to compete with the other chips in order to gain access to it (as is the case with Chip RAM). While both Chip and Fast RAM are limited in size, you can have at least a few MB of the latter on all Amigas (usually up to 8), while the former can never exceed 2 MB.

OpenAmiga500FastRamExpansion will allow you to add 4 or 8 MB of Fast RAM to your Amiga 600. This way you will be able to run more applications at once and more quickly. If you combine it with [a chip RAM expansion](https://github.com/SukkoPera/OpenAmiga600RamExpansion), you will also be able to run almost all games supported by WHDLoad, pushing your Amiga to its limits. The Fast RAM will be mapped to `$200000-$7fffff`.

OpenAmiga500FastRamExpansion is basically a clone of [a RAM expansion produced by Kipper2K a few years ago](http://eab.abime.net/showthread.php?t=64218), based on [an earlier design by lvd/NedoPC](http://lvd.nedopc.com/Projects/a600_8mb/index.html). He has since stopped producing and selling these cards and I thought it was a pity that he didn't open his designs and actually took all of them down, as this card is quite cheap to build and really useful. So I set about recreating it from scratch. Kipper2K has also made other expansions, including an 8 MB version of this card, but I chose to work on this one as it was simpler and probably enough for most uses. Other cards might come in the future.

### Memory Compatibility
The required RAM Type is 16 Mbit (1M×16) DRAM in the SOJ-42 package with up to 70-80 ns access time. It is 5v-only DRAM (not SD(!)RAM) often found in old 72-pin SIMMs, EDO chips might work or not. All chips having *8160* in their part number should be OK.

|Model         |Maker            |Tested             |Working            |Data Sheet                                                                                                                                                                 |Notes                                                                                |
|--------------|-----------------|:-----------------:|:-----------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|-------------------------------------------------------------------------------------|
|AS4C1M116E5   |Alliance         |![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|GM71C18160    |Hynix/LGS        |![Yes](doc/yes.png)|![Yes](doc/yes.png)|[![PDF](doc/doc.png)](https://github.com/lvd2/A600_8mb_2008/blob/master/DRAM_datasheets/GM71C18160.pdf)                                                                    |                                                                                     |
|HY5118164B    |Hynix            |![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|KM416C1200AJ  |SEC              |![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|KM416C1204AJ  |SEC              |![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|MSM5118160    |OKI              |![Yes](doc/yes.png)|![Yes](doc/yes.png)|[![PDF](doc/doc.png)](https://github.com/lvd2/A600_8mb_2008/blob/master/DRAM_datasheets/msm5118160.pdf)                                                                    |                                                                                     |
|TMS41860DZ    |Texas Instruments|![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|TMS41869DZ    |Texas Instruments|![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |
|4218160       |NEC              |![No](doc/no.png)  |                   |                                                                                                                                                                           |                                                                                     |

RAM chips can either be soldered directly to the board or installed in sockets. While soldering the chips might not be trivial for the unexperienced, sockets for the SOJ-42 package are hard to find and not really easier to solder either, so the choice is up to you.

### Assembly and Installation
Open your A600, doing your best not to crack any of the small tabs that hold the case together. If your A600 has the top part of the shielding, remove it and store it somewhere, as you will not be able to put it back in place when the expansion is installed. The same goes for the HD cradle, sorry.

Lots of A600s (and of A1200s, for the record) have issues with leaking electrolytic capacitors, therefore I really recommend to inspect them first, while you have your Amiga open. They might be leaking even if your Amiga shows no problems and when it finally will, it might be too late (= expensive) to salvage it. So, if you notice any brownish or black marks around those shiny metal cylinders, get them replaced. It is NOT an easy thing to do, and you need some decent tools anyway, so I really recommend to contact a professional, there are many people on Amiga forums offering this kind of service.

Before soldering the CPU socket you will need to rework it a bit: you should sand down one of its edges, or it will hit resistor R102 that is present in REV 1.5 boards (at least). Thus try to fit it on the CPU (the large square chip with *MC68000* written on it) and see which corner it is. Make sure to match the correct orientation: one of the corners of the chip is cut and, if you look at the socket, one of its corners will match that.

Besides that, most PLCC sockets have some sort of "stand-offs" on the bottom (which is going to be our top), which you are recommended to sand down, too. I also suggest to clean the CPU pins if possible, using contact cleaner or isopropyl alcool, as all sorts of gunk have probably gathered on them over the years. Let them dry well then. All of this should hopefully make the socket fit better on the chip.

After you solder the socket, you can cut the bottom of it so that the window in the PCB continues through the socket. Most sockets will already have holes on the bottom that will make this operation easier. This will allow you to install a 14x14mm heatsink on the CPU, which might be a good idea since installing the board will somewhat reduce the heat dissipation capabilities of the chip. Make sure to use good thermal adhesive/glue, otherwise you risk to make the dissipation even worse.

Normally it is not necessary to mount all the decoupling capacitors. I usually skip C4 and C7. Maybe capacitor C13 can be left out as well, your choice. R4 should be chosen according to the particular led you will be using for LD1. Actually you are free to skip LD1 and R4 altogether, if you hate power LEDs.

After everything has been soldered, you will need to program the CPLD. Whenever you do so, **make sure to carefully remove the board from your Amiga, or you might risk damaging it**. Use the typical cheap *USB Blaster* clone you can find on eBay for the task.

Finally, install the expansion in your A600: place it over the CPU with the correct orientation and push it down firmly until it feels solidly in place but don't force it.

Before reassembling your case, I recommend to run [SysTest](https://github.com/keirf/Amiga-Stuff). Use the Memory option (<kbd>F1</kbd>), it must show 4 MB of Fast RAM. Then start the Memory Test (<kbd>F1</kbd> again) and let it run for 50-100 rounds: if it doesn't find any errors, you are probably good to go. If you get any errors, power off your computer and try to give the expansion a better fit, by pushing it further down or twisting it slightly back and forth.

It might happen that the board slowly works its way out of the socket over time. To avoid this you can anchor it to the mainboard using the hole to the left of the CPU, which should align with one of the holes for the HD cradle legs.

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
- lvd for the initial design
- Kipper2K for making his boards
- majinga for helping with the testing
