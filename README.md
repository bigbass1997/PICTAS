[![CERN License](https://img.shields.io/badge/license-CERN%20OHL--W--V2-blue)](license/cern_ohl_w_v2.txt)
### Description
The PICTAS is an input device used to replay Tool-Assisted-Speedruns (aka Tool-Assisted-Superruns) on physical hardware.

A PIC18F47K42 microcontroller is used for the replay portion of the device, and the smaller PIC18F27K42 is used for controlling the input displays.

Unlike a typical TAS replay device, this one stores the TAS inputs on-board, using serial flash memory (W25Q128JVSIQ), capable of storing 16 MB of input data. The advantage is that USB communication is not required during replay. It simplifies the replay process, and greatly reduces the chance of corrupted inputs. Additionally, once programmed, the device can be used without a USB host computer (WIP feature).

This project is still a prototype under heavy development. While I will offer help and support as best I can, please understand that significant code and design changes can occur at any time.

### Usage
The general process looks like this: Load movie into a [host interface](https://github.com/bigbass1997/pictas-interface-rs). Program the movie's inputs and config options onto the PICTAS device. Finally, use one of the available start methods to begin the playback.

Refer to the [PICTAS-Interface project](https://github.com/bigbass1997/pictas-interface-rs) for details on how to use that software. Anyone is free to make their own interface software. There will be docs provided here once the communication protocol has stablized. The PICTAS communicates over USB at a 500,000 baud rate. Single byte commands are initiated from the interface. The PICTAS will respond with one or more bytes.

Because the input data is saved onto the device, you will _not_ need to reprogram it again unless you wish to change the TAS inputs or other configuration data.

### Flash Memory Map
```
0x000000 - 0xFFEFFF | Sequential controller inputs
0xFFF000 - 0xFFF0FF | Config options
0xFFF100 - 0xFFFFFF | Frame-numbered commands
```
All except the last sector (4KB) of memory, is dedicated to storing the TAS inputs. Format will depend on the console and how many controllers are used. Within the last sector, the first 256 bytes are for config options, while the rest is for special commands that are performed on specific frame numbers.

Each command is made up of a 3 byte wide number, which specifies the frame number. And then a 1 byte command.
```
0x00 | Console Reset
0x01 | Console Power off and on

0xFF | Null
```

### Input Displays
This replay device also supports input displays (aka viz/visualization boards), providing the viewers a way see which inputs are being pressed in real time.

The displays are designed to be placed on a SPI bus, where each display board shares the same clock and serial signals. Each device uses it's own Chip Select signal as a data latch.

An auxilary power supply must be connected for these displays. The PCB design is rated for a maximum of 2Amps.

### Discord/Support
If you have questions or suggestions, you can find me on the [N64brew Discord server](https://discord.gg/WqFgNWf) or the [TASBot server](https://discord.tas.bot/).
