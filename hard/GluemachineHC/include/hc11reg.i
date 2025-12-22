
*********************************************************************
*                              \|/                                  *
*                              @ @                                  *
*--------------------------ooO-(_)-Ooo------------------------------*
*                                                                   *
*                     Includes for 68HC811E2.                       *
*               Customized by (and for) Gluemaster                  *
*                             950503                                *
*-------------------------------------------------------------------*
*                                                                   *
*                                                                   *
*********************************************************************

*********************************************************************
*        Address   Name      Function
*        -------   ----      ----------------------------------------
*        $x000     PORTA     I/O Port A (3 In only, 5 Out only)
*        $x001               Reserved
*        $x002     PIOC      Parallel I/O Control Register
*        $x003     PORTC     I/O Port C
*        $x004     PORTB     I/O Port B (Output only)
*        $x005     PORTCL    Alternate Latched Port C
*        $x007     DDRC      Data Direction for Port C
*        $x008     PORTD     I/O Port D
*        $x009     DDRD      Data Direction for Port D
*        $x00A     PORTE     I/O Port E (Input only)
*        $x00B     CFORC     Compare Force Register
*        $x00C     OC1M      OC1 Action Mask Register
*        $x00D     OC1D      OC1 Action Data Register
*        $x00E,0F  TCNT      Timer Counter Register
*        $x010,11  TIC1      Input Capture 1 Register
*        $x012,13  TIC2      Input Capture 2 Register
*        $x014,15  TIC3      Input Capture 3 Register
*        $x016,17  TOC1      Output Compare 1 Register
*        $x018,19  TOC2      Output Compare 2 Register
*        $x01A,1B  TOC3      Output Compare 3 Register
*        $x01C,1D  TOC4      Output Compare 4 Register
*        $x01E,1F  TOC5      Output Compare 5 Register
*        $x020     TCTL1     Timer Control Register 1
*        $x021     TCTL2     Timer Control Register 2
*        $x022     TMSK1     Main Timer Interrupt Mask Register 1
*        $x023     TFLG1     Main Timer Interrupt Flag Register 1
*        $x024     TMSK2     Main Timer Interrupt Mask Register 2
*        $x025     TFLG2     Main Timer Interrupt Flag Register 2
*        $x026     PACTL     Pulse Accumulator Control Register
*        $x027     PACNT     Pulse Accumulator Count Register
*********************************************************************

*********************************************************************
*        Address   Name      Function
*        -------   ----      ----------------------------------------
*        $x028     SPCR      SPI Control Register
*        $x029     SPSR      SPI Status Register
*        $x02A     SPDAT     SPI Date In/Out
*        $x02B     BAUD      SPI Baud Rate Control
*        $x02C     SCCR1     SCI Control Register 1
*        $x02D     SCCR2     SCI Control Register 2
*        $x02E     SCSR      SCI Status Register
*        $x02F     SCDAT     SCI Data (Read RDR, Write TDR)
*        $x030     ADCTL     A to D Control Register
*        $x031     ADR1      A to D Result Register 1
*        $x032     ADR2      A to D Result Register 2
*        $x033     ADR3      A to D Result Register 3
*        $x034     ADR4      A to D Result Register 4
*        $x035     BPROT     EEPROM Block Protect Register
*        $x036               Reserved
*        $x037               Reserved
*        $x038               Reserved
*        $x039     OPTION    System Configuration Options
*        $x03A     COPRST    Arm/Reset COP Timer Circuitry
*        $x03B     PROG      EEPROM Programming Control Register
*        $x03C     HPRIO     Highest Priority I-bit Interrupt and Misc
*        $x03D     INIT      RAM - I/O Mapping Register
*        $x03E     TEST1     Factory TEST Control Register
*        $x03F     CONFIG    COP, ROM & EEPROM enables (EEPROM cells)
*********************************************************************

REGBASE EQU	$1000
RAM     EQU	$0000
EEPROM  EQU	$F800

*********************************************************************
PORTA	EQU	$000	Port A Data Register
PA7	EQU	$80	Port A Data bit 7
PA6	EQU	$40	Port A Data bit 6
PA5	EQU	$20	Port A Data bit 5
PA4	EQU	$10	Port A Data bit 4
PA3	EQU	$08	Port A Data bit 3
PA2	EQU	$04	Port A Data bit 2
PA1	EQU	$02	Port A Data bit 1
PA0	EQU	$01	Port A Data bit 0
*-------------------------------------------------------------------*
PIOC	EQU	$002	Parallel I/O Control Register
STAF	EQU	$80	Strobe A Input Status Flag
STAI	EQU	$40	Strobe A Interrupt Enable Mask
CWOM	EQU	$20	Port C Wire-Or Mode
HNDS	EQU	$10	Handshake Modes
OIN	EQU	$08	Output or Input Handshaking
PLS	EQU	$04	Pulse/Interlocked Handshake Operation
EGA	EQU	$02	Active Edge for STRA
INVB	EQU	$01	Invert Strobe B
*-------------------------------------------------------------------*
PORTC	EQU	$003	Port C Data Register
PC7	EQU	$80	Port C Data bit 7
PC6	EQU	$40	Port C Data bit 6
PC5	EQU	$20	Port C Data bit 5
PC4	EQU	$10	Port C Data bit 4
PC3	EQU	$08	Port C Data bit 3
PC2	EQU	$04	Port C Data bit 2
PC1	EQU	$02	Port C Data bit 1
PC0	EQU	$01	Port C Data bit 0
*-------------------------------------------------------------------*
PORTB	EQU	$004	Port B Data Register (Output only)
PB7	EQU	$80	Port B Data bit 7
PB6	EQU	$40	Port B Data bit 6
PB5	EQU	$20	Port B Data bit 5
PB4	EQU	$10	Port B Data bit 4
PB3	EQU	$08	Port B Data bit 3
PB2	EQU	$04	Port B Data bit 2
PB1	EQU	$02	Port B Data bit 1
PB0	EQU	$01	Port B Data bit 0
*-------------------------------------------------------------------*
PORTCL	EQU	$005	Alternate Latched Port C
PCL7	EQU	$80	Port C Latched Data bit 7
PCL6	EQU	$40	Port C Latched Data bit 6
PCL5	EQU	$20	Port C Latched Data bit 5
PCL4	EQU	$10	Port C Latched Data bit 4
PCL3	EQU	$08	Port C Latched Data bit 3
PCL2	EQU	$04	Port C Latched Data bit 2
PCL1	EQU	$02	Port C Latched Data bit 1
PCL0	EQU	$01	Port C Latched Data bit 0
*-------------------------------------------------------------------*
DDRC	EQU	$07	Data Direction for Port C
DDC7	EQU	$80	Data Direction for Port C bit 7
DDC6	EQU	$40	Data Direction for Port C bit 6
DDC5	EQU	$20	Data Direction for Port C bit 5
DDC4	EQU	$10	Data Direction for Port C bit 4
DDC3	EQU	$08	Data Direction for Port C bit 3
DDC2	EQU	$04	Data Direction for Port C bit 2
DDC1	EQU	$02	Data Direction for Port C bit 1
DDC0	EQU	$01	Data Direction for Port C bit 0
*-------------------------------------------------------------------*
PORTD	EQU	$008	Port D Data Register
PD5	EQU	$20	Port D Data bit 5
PD4	EQU	$10	Port D Data bit 4
PD3	EQU	$08	Port D Data bit 3
PD2	EQU	$04	Port D Data bit 2
PD1	EQU	$02	Port D Data bit 1
PD0	EQU	$01	Port D Data bit 0
*-------------------------------------------------------------------*
DDRD	EQU	$009	Data Direction for Port D
DDD5	EQU	$20	Data Direction for Port D bit 5
DDD4	EQU	$10	Data Direction for Port D bit 4
DDD3	EQU	$08	Data Direction for Port D bit 3
DDD2	EQU	$04	Data Direction for Port D bit 2
DDD1	EQU	$02	Data Direction for Port D bit 1
DDD0	EQU	$01	Data Direction for Port D bit 0
*-------------------------------------------------------------------*
PORTE	EQU	$00A	Port E Data Register (Input only)
PE7	EQU	$80	Port E Data bit 7
PE6	EQU	$40	Port E Data bit 6
PE5	EQU	$20	Port E Data bit 5
PE4	EQU	$10	Port E Data bit 4
PE3	EQU	$08	Port E Data bit 3
PE2	EQU	$04	Port E Data bit 2
PE1	EQU	$02	Port E Data bit 1
PE0	EQU	$01	Port E Data bit 0
*-------------------------------------------------------------------*
CFORC	EQU	$00B	Compare Force Register
FOC1	EQU	$80	Force Output Compare 1 Action
FOC2	EQU	$40	Force Output Compare 2 Action
FOC3	EQU	$20	Force Output Compare 3 Action
FOC4	EQU	$10	Force Output Compare 4 Action
FOC5	EQU	$08	Force Output Compare 5 Action
*-------------------------------------------------------------------*
OC1M	EQU	$00C	OC1 Action Mask Register
OC1M7	EQU	$80	Output Compare 1 Mask bit 7
OC1M6	EQU	$40	Output Compare 2 Mask bit 6
OC1M5	EQU	$20	Output Compare 3 Mask bit 5
OC1M4	EQU	$10	Output Compare 4 Mask bit 4
OC1M3	EQU	$08	Output Compare 5 Mask bit 3
*-------------------------------------------------------------------*
OC1D	EQU	$00D	OC1 Action Data Register
OC1D7	EQU	$80	Output Compare 1 Data bit 7
OC1D6	EQU	$40	Output Compare 2 Data bit 6
OC1D5	EQU	$20	Output Compare 3 Data bit 5
OC1D4	EQU	$10	Output Compare 4 Data bit 4
OC1D3	EQU	$08	Output Compare 5 Data bit 3
*-------------------------------------------------------------------*
TCNT	EQU	$00E	Timer Counter Register
*-------------------------------------------------------------------*
TIC1	EQU	$010	Input Capture 1 Register
TIC2	EQU	$012	Input Capture 2 Register
TIC3	EQU	$014	Input Capture 3 Register
*-------------------------------------------------------------------*
TOC1	EQU	$016	Output Compare 1 Register
TOC2	EQU	$018	Output Compare 2 Register
TOC3	EQU	$01A	Output Compare 3 Register
TOC4	EQU	$01C	Output Compare 4 Register
TOC5	EQU	$01E	Output Compare 5 Register
TIC4	EQU	TOC5	Input Capture 4 Register
*-------------------------------------------------------------------*
TCTL1	EQU	$020	Timer Control Register 1
OM2	EQU	$80	Output Mode
OL2	EQU	$40	Output Level
OM3	EQU	$20	Output Mode
OL3	EQU	$10	Output Level
OM4	EQU	$08	Output Mode
OL4	EQU	$04	Output Level
OM5	EQU	$02	Output Mode
OL5	EQU	$01	Output Level
*-------------------------------------------------------------------*
TCTL2	EQU	$021	Timer Control Register 2
EDG4B	EQU	$80	Input Capture edge control 4B
EDG4A	EQU	$40	Input Capture edge control 4A
EDG1B	EQU	$20	Input Capture edge control 1B
EDG1A	EQU	$10	Input Capture edge control 1A
EDG2B	EQU	$08	Input Capture edge control 2B
EDG2A	EQU	$04	Input Capture edge control 2A
EDG3B	EQU	$02	Input Capture edge control 3B
EDG3A	EQU	$01	Input Capture edge control 3A
*-------------------------------------------------------------------*
TMSK1	EQU	$022	Main Timer Interrupt Mask Register 1
OC1I	EQU	$80	Output Compare 1 Interrupt Enable
OC2I	EQU	$40	Output Compare 2 Interrupt Enable
OC3I	EQU	$20	Output Compare 3 Interrupt Enable
OC4I	EQU	$10	Output Compare 4 Interrupt Enable
OC5I	EQU	$08	Output Compare 5 Interrupt Enable
IC1I	EQU	$04	Input Compare 1 Interrupt Enable
IC2I	EQU	$02	Input Compare 2 Interrupt Enable
IC3I	EQU	$01	Input Compare 3 Interrupt Enable
IC4I	EQU	OC5I	Input Compare 4 Interrupt Enable
*-------------------------------------------------------------------*
TFLG1	EQU	$023	Main Timer Interrupt Flag Register 1
OC1F	EQU	$80	Output Compare 1 Flag
OC2F	EQU	$40	Output Compare 2 Flag
OC3F	EQU	$20	Output Compare 3 Flag
OC4F	EQU	$10	Output Compare 4 Flag
OC5F	EQU	$08	Output Compare 5 Flag
IC1F	EQU	$04	Input Compare 1 Flag
IC2F	EQU	$02	Input Compare 2 Flag
IC3F	EQU	$01	Input Compare 3 Flag
IC4F	EQU	OC5F	Input Compare 4 Flag
*-------------------------------------------------------------------*
TMSK2	EQU	$024	Misc Timer Interrupt Mask Register 2
TOI	EQU	$80	Timer Overflow Interrupt enable
RTII	EQU	$40	RTI Interrupt enable
PAOVI	EQU	$20	Pulse Accumulator Overflow Interrupt
PAII	EQU	$10	Pulse Accumulator Input Interrupt enable
PR1	EQU	$02	Timer Prescaller select 1
PR2	EQU	$01	Timer Prescaller select 2
*-------------------------------------------------------------------*
TFLG2	EQU	$025	Misc Timer Interrupt Flag Register 2
TOF	EQU	$80	Timer Overflow Flag
RTIF	EQU	$40	Real Time (periodic) Interrupt Flag
PAOVF	EQU	$20	Pulse Accumulator Overflow Flag
PAIF	EQU	$10	Pulse Accumulator Input edge Flag
*-------------------------------------------------------------------*
PACTL	EQU	$026	Pulse Accumulator Control Register
DDRA7	EQU	$80	Data Direction for Port A bit 7
PAEN	EQU	$40	Pulse Accumulator system ENable
PAMOD	EQU	$20	Pulse Accumulator MODe
PEDGE	EQU	$10	Pulse Accumulator Edge Control
DDRA3	EQU	$08	Data Direction for Port A bit 3
I4_O5	EQU	$04	Input Capture 4 (=1)/Output Compare 5 (=0)
RTR1	EQU	$02	RTI Interrupt Rate 1
RTR0	EQU	$01	RTI Interrupt Rate 0
*-------------------------------------------------------------------*
PACNT	EQU	$027	Pulse Accumulator Count Register
*-------------------------------------------------------------------*
SPCR	EQU	$028	SPI Control Register
SPIE	EQU	$80	SPI Control Register
SPE	EQU	$40	SPI Interrupt Enable
DWOM	EQU	$20	Port D Wire-Or Mode
MSTR	EQU	$10	Master Mode Select
CPOL	EQU	$08	Clock Polarity
CPHA	EQU	$04	Clock Phase
SPR1	EQU	$02	SPI Rate Select bit 1
SPR0	EQU	$01	SPI Rate Select bit 0
*-------------------------------------------------------------------*
SPSR	EQU	$029	SPI Status Register
SPIF	EQU	$80	SPI Interrupt Status Flag
WCOL	EQU	$40	SPI Write Collision Status Falg
MODF	EQU	$10	SPI Mode Fault Interrupt Status Flag
*-------------------------------------------------------------------*
SPDAT	EQU	$02A	SPI Date In/Out
*-------------------------------------------------------------------*
BAUD	EQU	$02B	SPI Baud Rate Control
TCLR	EQU	$80	Test/Clear Baud Rate Counters
SCP1	EQU	$20	Serial Prescaler Selects 1
SCP0	EQU	$10	Serial Prescaler Selects 0
RCKB	EQU	$08	SCI Receiver Test Bit
SCR2	EQU	$04	SCI Rate Select bit 2
SCR1	EQU	$02	SCI Rate Select bit 1
SCR0	EQU	$01	SCI Rate Select bit 0
*-------------------------------------------------------------------*
SCCR1	EQU	$02C	SCI Control Register 1
R8	EQU	$80	Receive bit 8
T8	EQU	$40	Transmit bit 8
M	EQU	$10	SCI Mode Select
WAKE	EQU	$08	Wake Up by Address Mark / Idle
*-------------------------------------------------------------------*
SCCR2	EQU	$02D	SCI Control Register 2
TIE	EQU	$80	Transmit Interrupt Enable
TCIE	EQU	$40	Transmit Complete Interrupt Enable
RIE	EQU	$20	Receiver Interrupt Enable
ILIE	EQU	$10	Idle Line Interrupt Enable
TE	EQU	$08	Transmitter Enable
RE	EQU	$04	Receiver Enable
RWU	EQU	$02	Receiver Wake-up Control
SBK	EQU	$01	Send Break
*-------------------------------------------------------------------*
SCSR	EQU	$02E	SCI Status Register
TDRE	EQU	$80	Transmit Data Register Empty Flag
TC	EQU	$40	Transmit Complete Flag
RDRF	EQU	$20	Receive Data Register Full Flag
IDLE	EQU	$10	Idle Line Detected Flag
OR	EQU	$08	Over-run flag
NF	EQU	$04	Noise Error Flag
FE	EQU	$02	Framing Error Flag
*-------------------------------------------------------------------*
SCDAT	EQU	$02F	SCI Data (Read RDR, Write TDR)
*-------------------------------------------------------------------*
ADCTL	EQU	$030	A to D Control Register
CCF	EQU	$80	Conversion Complete Flag
SCAN	EQU	$20	Continuous Scan Control
MULT	EQU	$10	Multiple Channel / Single Channel control
CD	EQU	$08	Channel Select D
CC	EQU	$04	Channel Select C
CB	EQU	$02	Channel Select B
CA	EQU	$01	Channel Select A
*-------------------------------------------------------------------*
ADR1	EQU	$031	A to D Result Register 1
ADR2	EQU	$032	A to D Result Register 2
ADR3	EQU	$033	A to D Result Register 3
ADR4	EQU	$034	A to D Result Register 4
*-------------------------------------------------------------------*
BPROT	EQU	$035	EEPROM Block Protect Register
PTCON	EQU	$10	Protect CONFIG Register
*                       . =1 disables programming/erasure, =0 enables
BPRT3	EQU	$08	Block Protect $B600-B61F ( 32 bytes)
BPRT2	EQU	$04	Block Protect $B620-B65F ( 64 bytes)
BPRT1	EQU	$02	Block Protect $B660-B6DF (128 bytes)
BPRT0	EQU	$01	Block Protect $B6E0-B7FF (288 bytes)
*-------------------------------------------------------------------*
OPTION	EQU	$039	System Configuration Options
ADPU	EQU	$80	A to D Power Up
CSEL	EQU	$40	A to D Clock Select
IRQE	EQU	$20	IRQ Select Edge Sensitive Only
DLY	EQU	$10	Enable Oscillator Start-up delay
CME	EQU	$08	Clock Monitor Enable
CR1	EQU	$02	COP Timer Rate Select bit 1
CR0	EQU	$01	COP Timer Rate Select bit 0
*-------------------------------------------------------------------*
COPRST	EQU	$03A	Arm/Reset COP Timer Circuitry
*-------------------------------------------------------------------*
PPROG	EQU	$03B	EEPROM Programming Control Register
ODD	EQU	$80	Program Odd Rows in Test
EVEN	EQU	$40	Program Even Rows in Test
ASEL	EQU	$20	Array Select
BYTE	EQU	$10	Select Byte Erase Mode for the EEPROM
ROW	EQU	$08	Row/All EEPROM Erase Mode
ERASE	EQU	$04	Erase/Normal Control for EEPROM
EELAT	EQU	$02	EEPROM Latch Control
EEPGM	EQU	$01	EEPROM Program Command
*-------------------------------------------------------------------*
HPRIO	EQU	$03C	Highest Priority I-bit Interrupt and Misc
RBOOT	EQU	$80	Read Bootstrap ROM
SMOD	EQU	$40	Special Mode
MDA	EQU	$20	Mode Select A
IRV	EQU	$10	Internal Read Visibility
PSEL3	EQU	$08	Priority Select bit 3
PSEL2	EQU	$04	Priority Select bit 2
PSEL1	EQU	$02	Priority Select bit 1
PSEL0	EQU	$01	Priority Select bit 0
*-------------------------------------------------------------------*
INIT	EQU	$03D	RAM - I/O Mapping Register
RAM3	EQU	$80	RAM Map Position bit 3
RAM2	EQU	$40	RAM Map Position bit 2
RAM1	EQU	$20	RAM Map Position bit 1
RAM0	EQU	$10	RAM Map Position bit 0
REG3	EQU	$08	64-byte Register block Map Position bit 3
REG2	EQU	$04	64-byte Register block Map Position bit 2
REG1	EQU	$02	64-byte Register block Map Position bit 1
REG0	EQU	$01	64-byte Register block Map Position bit 0
*-------------------------------------------------------------------*
TEST1	EQU	$03E	Factory TEST Control Register
TILOP	EQU	$80	Test Illegal Opcode
OCCR	EQU	$20	Output Condition Code Register to Timer
CBYP	EQU	$10	Timer Divider Chain Bypass
DISR	EQU	$08	Disable Resets from COP and Clock Monitor
FCM	EQU	$04	Force Clock Monitor Failure
FCOP	EQU	$02	Force COP Watchdog Failure
TCON	EQU	$01	Test Configuration
*-------------------------------------------------------------------*
CONFIG	EQU	$03F	COP, ROM & EEPROM enables (EEPROM cells)
NOSEC	EQU	$08	Security Mode (=0 enable, 1= disable)
NOCOP	EQU	$04	COP System ON (=0 enable, 1= disable)
ROMON	EQU	$02	No-ROM Mode Select bit
*                       .  0= disable ROM & use external memory
*                       .  1= enable ROM
EEON	EQU	$01	No-EEPROM Mode Select bit
*                       .  0= disable 512 byte EEPROM & use external memory
*                       .  1= enable EEPROM
*********************************************************************
	END
