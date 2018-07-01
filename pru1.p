.origin 0
.entrypoint TOP

#define CLOCKPIN 8
#define LATCHPIN 9


; Interrupt
#define PRU_INT_VALID         32
#define PRU0_PRU1_INTERRUPT   1       ; PRU_EVTOUT_
#define PRU1_PRU0_INTERRUPT   2       ; PRU_EVTOUT_
#define PRU0_ARM_INTERRUPT    3       ; PRU_EVTOUT_0
#define PRU1_ARM_INTERRUPT    4       ; PRU_EVTOUT_1
#define ARM_PRU0_INTERRUPT    5       ; PRU_EVTOUT_
#define ARM_PRU1_INTERRUPT    6       ; PRU_EVTOUT_


#define CTPPR_0  0x22028

#define NOP ADD R0.b0, R0.b0, R0.b0

TOP:
  ;LDI    R0.w2, 0x02               ; CTPPR_0 MSB
  ;LDI    R0.w0, 0x2028 + 0x2000    ; Add 0x2000
	;LDI    R1, 0x00000240                   ; C28 = 00_0240_00h = PRU1 CFG Registers
	;SBBO   &R1, R0, 0, 4

  ; HALT ; // wait for PRU0 to get ready

SHIFT:
  XIN 10, &r21, 32 ; r21-r28
  LDI r31.b0, PRU_INT_VALID + PRU1_PRU0_INTERRUPT ; Signal PRU0

  MOV r30, r21.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r21.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r21.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r21.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r22.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r22.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r22.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r22.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r23.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r23.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r23.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r23.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r24.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r24.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r24.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r24.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r25.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r25.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r25.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r25.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r26.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r26.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r26.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r26.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r27.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r27.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r27.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r27.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP


  MOV r30, r28.b0 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r28.b1 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r28.b2 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  MOV r30, r28.b3 ;
  SET r30, r30, CLOCKPIN ;
  NOP
  CLR r30, r30, CLOCKPIN ;
  NOP

  SET r30, r30, LATCHPIN ;
  NOP
  CLR r30, r30, LATCHPIN ;
  ; NOP

  JMP SHIFT ;

  ; MOV r31.b0, 32 + 3 ;
  ; HALT
