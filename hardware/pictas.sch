EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L pictas:PIC18LF47K42 U?
U 1 1 5FCC6CF9
P 8875 3600
F 0 "U?" H 8875 4965 50  0000 C CNN
F 1 "PIC18LF47K42" H 8875 4874 50  0000 C CNN
F 2 "" H 8925 3500 50  0001 C CNN
F 3 "" H 8925 3500 50  0001 C CNN
	1    8875 3600
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x05 J?
U 1 1 5FCC9332
P 10475 2600
F 0 "J?" H 10555 2642 50  0000 L CNN
F 1 "ICSProgrammer" H 10555 2551 50  0000 L CNN
F 2 "" H 10475 2600 50  0001 C CNN
F 3 "~" H 10475 2600 50  0001 C CNN
	1    10475 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	8075 2500 7975 2500
Wire Wire Line
	7975 2500 7975 2100
Wire Wire Line
	7975 2100 10175 2100
Wire Wire Line
	10175 2100 10175 2400
Wire Wire Line
	10075 2700 10075 3400
Wire Wire Line
	10075 3400 9675 3400
Wire Wire Line
	9675 3500 10175 3500
Wire Wire Line
	10175 3500 10175 2800
NoConn ~ 9675 3250
NoConn ~ 9675 3150
NoConn ~ 9675 3050
NoConn ~ 9675 2950
NoConn ~ 9675 2850
NoConn ~ 9675 2750
NoConn ~ 9675 3700
NoConn ~ 9675 3800
NoConn ~ 9675 3900
NoConn ~ 9675 4000
NoConn ~ 9675 4600
NoConn ~ 9675 4700
NoConn ~ 8075 4250
NoConn ~ 8075 4150
NoConn ~ 8075 4000
NoConn ~ 8075 3900
NoConn ~ 8075 3500
NoConn ~ 8075 3400
NoConn ~ 8075 3300
NoConn ~ 8075 3150
NoConn ~ 8075 3050
NoConn ~ 8075 2950
NoConn ~ 8075 2850
NoConn ~ 8075 2750
NoConn ~ 8075 2650
$Comp
L Device:R R?
U 1 1 5FCCCDA2
P 7725 2500
F 0 "R?" V 7518 2500 50  0000 C CNN
F 1 "10k" V 7609 2500 50  0000 C CNN
F 2 "" V 7655 2500 50  0001 C CNN
F 3 "~" H 7725 2500 50  0001 C CNN
	1    7725 2500
	0    1    1    0   
$EndComp
Wire Wire Line
	7875 2500 7975 2500
Connection ~ 7975 2500
Wire Wire Line
	7475 2500 7575 2500
$Comp
L Connector_Generic:Conn_01x03 J?
U 1 1 5FCCDEB1
P 5475 2300
F 0 "J?" V 5439 2112 50  0000 R CNN
F 1 "N64 Controller" V 5348 2112 50  0000 R CNN
F 2 "" H 5475 2300 50  0001 C CNN
F 3 "~" H 5475 2300 50  0001 C CNN
	1    5475 2300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5575 3750 5575 2500
Wire Wire Line
	5475 2500 5475 4700
$Comp
L Device:R R?
U 1 1 5FCD18E4
P 7475 4000
F 0 "R?" H 7405 3954 50  0000 R CNN
F 1 "10k" H 7405 4045 50  0000 R CNN
F 2 "" V 7405 4000 50  0001 C CNN
F 3 "~" H 7475 4000 50  0001 C CNN
	1    7475 4000
	1    0    0    1   
$EndComp
Wire Wire Line
	5475 4700 7475 4700
Wire Wire Line
	7475 4150 7475 4700
Connection ~ 7475 4700
Wire Wire Line
	7475 4700 8075 4700
Wire Wire Line
	7475 3850 7475 3650
Wire Wire Line
	7475 3650 8075 3650
$Comp
L Connector_Generic:Conn_01x06 J?
U 1 1 5FCD6411
P 4325 2300
F 0 "J?" V 4300 1900 50  0000 R CNN
F 1 "TTL to USB" V 4225 1900 50  0000 R CNN
F 2 "" H 4325 2300 50  0001 C CNN
F 3 "~" H 4325 2300 50  0001 C CNN
	1    4325 2300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4525 2500 4525 3750
Wire Wire Line
	4525 3750 5575 3750
Wire Wire Line
	4425 2500 4425 4350
Wire Wire Line
	4425 4350 8075 4350
Wire Wire Line
	8075 4450 4325 4450
Wire Wire Line
	4325 4450 4325 2500
NoConn ~ 4225 2500
NoConn ~ 4125 2500
Text Label 5475 2500 3    50   ~ 0
DATA
Text Label 5575 2500 3    50   ~ 0
GND
Text Label 4625 2500 3    50   ~ 0
3.3V
Text Label 4525 2500 3    50   ~ 0
GND
Text Label 4325 2500 3    50   ~ 0
-->USB_RX
Text Label 8075 4350 2    50   ~ 0
-->U1RX
Text Label 8075 4450 2    50   ~ 0
<--U1TX
Text Label 4425 2500 3    50   ~ 0
<--USB_TX
Wire Wire Line
	9675 2600 10275 2600
Wire Wire Line
	9675 2500 10275 2500
Wire Wire Line
	10175 2400 10275 2400
Wire Wire Line
	10175 2800 10275 2800
Wire Wire Line
	10275 2700 10075 2700
$Comp
L Connector_Generic:Conn_01x04 J?
U 1 1 5FCF0B13
P 4425 2100
F 0 "J?" V 4350 2400 50  0000 L CNN
F 1 "USB Port" V 4425 2400 50  0000 L CNN
F 2 "" H 4425 2100 50  0001 C CNN
F 3 "~" H 4425 2100 50  0001 C CNN
	1    4425 2100
	0    1    1    0   
$EndComp
Wire Wire Line
	4525 1900 4525 1525
Wire Wire Line
	4425 1900 4425 1525
Wire Wire Line
	4325 1900 4325 1525
Wire Wire Line
	4225 1900 4225 1525
Text Label 4225 1900 1    50   ~ 0
5V_HOST
Text Label 4325 1900 1    50   ~ 0
D-
Text Label 4425 1900 1    50   ~ 0
D+
Text Label 4525 1900 1    50   ~ 0
GND_HOST
Wire Notes Line
	4025 1450 4025 3000
Wire Notes Line
	4025 3000 4700 3000
Wire Notes Line
	4700 3000 4700 1450
Wire Notes Line
	4700 1450 4025 1450
Text Notes 4000 1425 0    50   ~ 0
TTL to USB Adapter
$Comp
L Connector_Generic:Conn_01x03 J?
U 1 1 5FD04561
P 5475 2100
F 0 "J?" V 5347 1912 50  0000 R CNN
F 1 "N64 Controller" V 5438 1912 50  0000 R CNN
F 2 "" H 5475 2100 50  0001 C CNN
F 3 "~" H 5475 2100 50  0001 C CNN
	1    5475 2100
	0    -1   1    0   
$EndComp
Wire Wire Line
	5475 1900 5475 1525
Text Label 5475 1900 1    50   ~ 0
DATA
Text Label 5575 1900 1    50   ~ 0
GND
Wire Wire Line
	5575 1525 5575 1900
Wire Notes Line
	5275 2725 5650 2725
Wire Notes Line
	5650 2725 5650 1450
Wire Notes Line
	5275 2725 5275 1450
Connection ~ 7475 3650
Wire Wire Line
	7475 2500 7475 3650
Wire Wire Line
	4625 2500 4625 3650
Wire Wire Line
	4625 3650 6550 3650
Wire Notes Line
	5275 1450 5650 1450
Text Notes 5250 1425 0    50   ~ 0
N64 Port 1
Connection ~ 5575 3750
Wire Wire Line
	5575 3750 6650 3750
$Comp
L Memory_Flash:W25Q128JVS_PinAligned U?
U 1 1 5FD3A853
P 8875 5400
F 0 "U?" H 8875 5817 50  0000 C CNN
F 1 "W25Q128JVS_PinAligned" H 8875 5726 50  0000 C CNN
F 2 "Package_SO:SOIC-8_5.23x5.23mm_P1.27mm" H 8875 5400 50  0001 C CNN
F 3 "http://www.winbond.com/resource-files/w25q32jv%20revg%2003272018%20plus.pdf" H 8875 5400 50  0001 C CNN
	1    8875 5400
	1    0    0    -1  
$EndComp
NoConn ~ 9375 5350
NoConn ~ 8375 5450
Wire Wire Line
	8075 4600 7975 4600
Wire Wire Line
	7975 4600 7975 5250
Wire Wire Line
	7975 5250 8375 5250
NoConn ~ 9675 4150
Wire Wire Line
	9375 5250 9475 5250
Wire Wire Line
	9475 5250 9475 5750
Wire Wire Line
	9475 5750 6550 5750
Wire Wire Line
	6550 5750 6550 3650
Connection ~ 6550 3650
Wire Wire Line
	6550 3650 7475 3650
Wire Wire Line
	8375 5550 6650 5550
Wire Wire Line
	6650 5550 6650 3750
Connection ~ 6650 3750
Wire Wire Line
	6650 3750 8075 3750
Wire Wire Line
	9375 5450 10075 5450
Wire Wire Line
	10075 5450 10075 4450
Wire Wire Line
	10075 4450 9675 4450
Wire Wire Line
	9375 5550 10175 5550
Wire Wire Line
	10175 5550 10175 4350
Wire Wire Line
	10175 4350 9675 4350
Wire Wire Line
	8375 5350 8250 5350
Wire Wire Line
	8250 5350 8250 4875
Wire Wire Line
	8250 4875 10275 4875
Wire Wire Line
	10275 4875 10275 4250
Wire Wire Line
	10275 4250 9675 4250
NoConn ~ 5375 2500
NoConn ~ 5375 1900
$Comp
L MCU_Microchip_PIC18:PIC18LF4550-IP-PinAligned U?
U 1 1 5FD5A9AA
P 2575 3850
F 0 "U?" H 2575 5367 50  0000 C CNN
F 1 "PIC18LF4550-IP-PinAligned" H 2575 5276 50  0000 C CNN
F 2 "Package_DIP:DIP-40_W15.24mm" H 2575 4050 50  0001 C CIN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/39760d.pdf" H 2575 3600 50  0001 C CNN
	1    2575 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3875 4600 4075 4600
Wire Wire Line
	4075 4600 4075 4350
Wire Wire Line
	4075 4350 4225 4350
Wire Wire Line
	3875 4500 3975 4500
Wire Wire Line
	3975 4500 3975 4450
Wire Wire Line
	3975 4450 4225 4450
Wire Wire Line
	3875 3650 4225 3650
Wire Wire Line
	3875 3750 4225 3750
$Comp
L Device:Crystal Y?
U 1 1 5FD67447
P 1000 4450
F 0 "Y?" V 950 4325 50  0000 R CNN
F 1 "Crystal" V 1050 4325 50  0000 R CNN
F 2 "" H 1000 4450 50  0001 C CNN
F 3 "~" H 1000 4450 50  0001 C CNN
	1    1000 4450
	0    1    1    0   
$EndComp
$Comp
L Device:C C?
U 1 1 5FD67CE8
P 750 4200
F 0 "C?" V 500 4200 50  0000 C CNN
F 1 "C" V 600 4200 50  0000 C CNN
F 2 "" H 788 4050 50  0001 C CNN
F 3 "~" H 750 4200 50  0001 C CNN
	1    750  4200
	0    1    1    0   
$EndComp
$Comp
L Device:C C?
U 1 1 5FD6875F
P 750 4700
F 0 "C?" V 900 4700 50  0000 C CNN
F 1 "C" V 1000 4700 50  0000 C CNN
F 2 "" H 788 4550 50  0001 C CNN
F 3 "~" H 750 4700 50  0001 C CNN
	1    750  4700
	0    1    1    0   
$EndComp
Wire Wire Line
	600  4200 500  4200
Wire Wire Line
	500  4200 500  4700
Wire Wire Line
	500  4700 600  4700
Wire Wire Line
	900  4200 1000 4200
Wire Wire Line
	1000 4200 1000 4300
Wire Wire Line
	1000 4600 1000 4700
Wire Wire Line
	1000 4700 900  4700
Connection ~ 1000 4200
Wire Wire Line
	1000 4700 1175 4700
Wire Wire Line
	1175 4700 1175 4300
Wire Wire Line
	1175 4300 1275 4300
Connection ~ 1000 4700
Wire Wire Line
	1000 4200 1275 4200
Wire Wire Line
	500  4200 500  4000
Wire Wire Line
	500  4000 1275 4000
Connection ~ 500  4200
$EndSCHEMATC
