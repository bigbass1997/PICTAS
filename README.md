[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
### Description
The PICTAS is a device used to replay Tool-Assisted-Speedruns (aka Tool-Assisted-Superruns) on physical hardware. It currently has single controller support for the N64 and NES consoles, with plans to support more.

A PIC18LF47K42 microcontroller is used as the brain of this device. While an ARM-based MCU could have been used instead, I already had prior experience with the PIC architecture and instruction set. Unlike other TAS replay devices, this one stores the entire movie's inputs on-board, using a serial flash memory IC (W25Q128JV), capable of storing 16 MB of input data. While this does have some minor drawbacks, it is far less susceptible to desyncs during playback. 

While programming the inputs, the device will respond with each byte it recieved, so that the interface can detect any corrupted data. If programming is successful, you can re-run that TAS as many times as you want, without reprogramming, even if the device loses power; similar to how Flash Carts store save data.

I also have plans to implement an on-board button that will initiate the movie playback. This will be useful, both for ease of use vs running a command, and more importantly, to allow playback without being connected to a host computer at all.

This project is still just a prototype under heavy development. While I will offer help and support as best I can, please understand that significant code and design changes can occur at any time.

### Usage
The general process looks like this: Load movie into a [host interface](https://github.com/bigbass1997/PICTAS-Interface). Program the movie's inputs onto the PICTAS device. Turn on and while holding the console's reset button, run the the start command from the host interface.

Refer to the [PICTAS-Interface project](https://github.com/bigbass1997/PICTAS-Interface) for details on how to use that software. If you would like to make your own interface, you may do so. There will be docs provided here once the communication protocol is better organized and stable. The PICTAS communicates over USB at a 500,000 baud rate. Commands are initiated from the interface software, by sending a single byte value. The PICTAS will respond with one or more bytes depending on the command used.

Because the input data is saved onto the device, you will _not_ need to reprogram it again unless you wish to change the TAS inputs. Finally, once the program signals READY, turn on the console and the replay should begin.

### Discord/Support
If you have questions or suggestions, you can find me on the [N64brew Discord server](https://discord.gg/WqFgNWf) or the [TASBot server](https://discord.tas.bot/).
