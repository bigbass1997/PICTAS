[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
### Description
The PICTAS is a device used to replay Tool-Assisted-Speedruns on real hardware. While currently being developed for the N64, it may be capable of use on other retro consoles too.

A PIC18LF47K42 microcontroller is used as the brain of this device. While an ARM-based MCU could have been used instead, I already had prior experience with the PIC architecture and instruction set.

This project is still a work-in-progress. Support for the N64 (highest priority), NES, and SNES are planned, though other consoles may be possible in the distant future.

### Usage
Once a working prototype is developed, you will connect the PICTAS device over USB to a computer. Running on that computer will be a program (either graphical or CLI-based) that communicates with the replay device. Before starting a replay, you will need to provide the program with a compatible TAS movie file (more details to be provided later). The program will parse out the input data and upload it to the replay device, which then saves it to FLASH memory.

Because the input data is saved onto the device, you will _not_ need to reprogram it again unless you wish to change the TAS inputs. Finally, once the program signals READY, turn on the console and the replay should begin.

### Discord/Support
If you have questions or suggestions, you can find me on the N64 homebrew Discord server https://discord.gg/KERXwaT or the TASBot server https://discord.gg/4XrrJm8Jyq