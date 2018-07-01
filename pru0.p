.origin 0
.entrypoint TOP

#define SYSEV_PRU1_TO_PRU0	18
#define MEMSIZE			30*32

#define CONST_PRUDRAM   C24
#define CONST_SHAREDRAM C28
#define CONST_L3RAM     C30
#define CONST_DDR C31

/** Register map */
#define data_addr	r0
#define data_len r5

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTPPR_0         0x7028
// Address for the Constant table Programmable Pointer Register 1(CTPPR_1)
#define CTPPR_1         0x702C

.macro ST32
.mparam src,dst
    SBBO    src,dst,#0x00,4
.endm

TOP:
  LDI	  r10, SYSEV_PRU1_TO_PRU0 ;
  LDI   r1, 0; // clear command register
  LDI   r2, 0; // clear response register
  LDI   r3, 0; // clear phase counter
  LDI   r21, 0;
  LDI   r22, 0;
  LDI   r23, 0;
  LDI   r24, 0;
  LDI   r25, 0;
  LDI   r26, 0;
  LDI   r27, 0;
  LDI   r28, 0;

  // Enable OCP master port
	// clear the STANDBY_INIT bit in the SYSCFG register,
	// otherwise the PRU will not be able to write outside the
	// PRU memory space and to the BeagleBon's pins.
	LBCO	r0, C4, 4, 4
	CLR	r0, r0, 4
	SBCO	r0, C4, 4, 4

	// Configure the programmable pointer register for PRU0 by setting
	// c28_pointer[15:0] field to 0x0120.  This will make C28 point to
	// 0x00012000 (PRU shared RAM).
	MOV	r0, 0x00000120
	MOV	r1, CTPPR_0
	ST32	r0, r1

	// Configure the programmable pointer register for PRU0 by setting
	// c31_pointer[15:0] field to 0x0010.  This will make C31 point to
	// 0x80001000 (DDR memory).
	MOV	r0, 0x00100000
	MOV	r1, CTPPR_1
	ST32	r0, r1

	// Write a 0x1 into the response field so that they know we have started
	MOV	r2, #0x01
  SBCO r2, CONST_PRUDRAM, 8, 4

_LOOP:
	// Load the pointer to the buffer from PRU DRAM into r0 and the
	// start command into r1
	LBCO	data_addr, CONST_PRUDRAM, 0, 8

	// Wait for a non-zero command
  QBEQ _LOOP, r1, #0

SETBUF:
  LDI data_len, MEMSIZE
  LBCO data_addr, CONST_PRUDRAM, 0, 8 // poll command byte & address

RELOAD:
  WBS	r31, 30 ; wait for PRU1 Interrupt
  SBCO	&r10, C0, 0x24, 4 ; clear interrupt flag

  LBBO r21, data_addr, 0, 32 ; load data from DDR to r21 - r29

  XOUT 10, &r21, 32 ; send 8 registers to PRU1
  ADD data_addr, data_addr, 32 // move to next memory
  SUB data_len, data_len, 32
  QBNE RELOAD, data_len, #0 ;

  ADD r3, r3, 1 // increment phase counter
  SBCO r3, CONST_PRUDRAM, 12, 4 // store phase counter

  QBNE SETBUF, r1.b0, #0xFF ; // check for exit code

EXIT:
  // Write a 0xFF into the response field so that they know we're done
	MOV r2, #0xFF
  SBCO r2, CONST_PRUDRAM, 8, 4
  MOV r31.b0, 32 + 3 ;
