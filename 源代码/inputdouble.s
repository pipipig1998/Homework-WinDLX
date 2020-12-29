.data
;***Data for Read-Trap
ReadBuffer:	.space		80
ReadPar:	    .word		0,ReadBuffer,80

;***Data for Printf-Trap
	PrintfPar:  	.space	    4

SaveR2:		.space		4
SaveR3:		.space		4
SaveR4:		.space		4
SaveR5:		.space		4
Savef4:      .space       8
Savef6:      .space       8

        .text

	.global		InputDouble
InputDouble:	
;***save register contents
	sw		SaveR2,r2     ;R2送M(SaveR2)
	sw		SaveR3,r3     ;R3送M(SaveR3)
	sw		SaveR4,r4     ;R4送M(SaveR4)
	sw		SaveR5,r5     ;R5送M(SaveR5)
sd      Savef4,f4      ;f4送M(Savef4)
sd      Savef6,f6      ;f6送M(Savef6)
;***Prompt
	sw		PrintfPar,r1     ;R1送PrintPar
	addi		r14,r0,PrintfPar  ;PrintPar+0送R14
	trap		5              ;自陷调用5

;***call Trap-3 to read line
	addi		r14,r0,ReadPar   ;ReadPar+0送R14
	trap		3              ;自陷调用3

;***determine value
	addi		r2,r0,ReadBuffer  ;ReadBuffer+0送R2
	addi		r1,r0,0          ;0送R1
movf     f3,f0           ;f0送f3
movf     f1,f0           ;f0送f1
	addi		r4,r0,10	        ;10送R4
addi     r6,r0,1          ;1送R6

Loop:		;***reads digits to end of line 标号LOOP
	lbu		r3,0(r2)          ;M(R2)+0送R3（R2内容为ReadBuffer的地址）
	seqi		r5,r3,10	        ;IF(R3=立即数10)1送R5 ELSE 0送R5
	bnez		r5,Finish         ;IF(R5不等于0)转Finish
seqi     r5,r3,46          ;IF(R3=立即数46)1送R5 ELSE 0送R5
bnez    r5,Decim        ;IF(R5不等于0)转Decim
	subi		r3,r3,48        	;R3-48送R3（48为十六进制30，ASCII码变换）
multu	r1,r1,r4	        ;R4*R1送R1
	add		r1,r1,r3          ;R3+R1送R1
	addi		r2,r2,1 	        ;R2+1送R2
	j		Loop            ;转LOOP

Decim:   ;***处理小数部分
addi     r2,r2,1           ;R2+1送R2
lbu      r3,0(r2)          ;M(R2)+0送R3
seqi     r5,r3,10          ;IF(R3=立即数10)1送R5 ELSE 0送R5
bnez     r5,Finish         ;IF(R5不等于0)转Finish
subi     r3,r3,48          ;R3-48送R3（48为十六进制30，ASCII码变换）
multu    r6,r6,r4          ;R4*R6送R6
movi2fp    f6,r6          ;R6送F6
movi2fp    f3,r3          ;R3送F3
divf        f3,f3,f6       ;f3/f6送f3
addf       f1,f1,f3        ;f3+f1送f1
j          Decim        ;转Decim

	Finish:  ;***restore old register contents 标号Finish
movi2fp        f5,r1       ;R1送F5
cvti2f          f3,f5       ;F5变为整数送F3
cvtf2d          f2,f3       ;F3变为双精度浮点数送F2
cvtf2d          f4,f1       ;F1变为双精度浮点数送F4
addd           f2,f2,f4     ;f4+f2送f2
	lw		       r2,SaveR2   ;M(SaveR2)送R2
	lw		       r3,SaveR3   ;M(SaveR3)送R3
	lw		       r4,SaveR4   ;M(SaveR4)送R4
	lw		       r5,SaveR5   ;M(SaveR5)送R5
ld             f4,Savef4    ;M(Savef4)送f4
ld             f6,Savef6    ;M(Savef6)送f6
	jr		       r31	      ;R31送PC 从子程序返回