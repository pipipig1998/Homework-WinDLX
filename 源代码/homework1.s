.data
Prompt:         .asciiz         "please input p:\n\n"
Prompt1:	       .asciiz 	     "p:  "
Prompt2:        .asciiz         "please input h:  "
Prompt3:	       .asciiz 	     "g=:  "
Prompt4:        .asciiz         "\n\nresult: "

;*** Data for printf-Trap
PrintfFormat:  	.asciiz 	     "%lf\n\n"
		        .align		  4
PrintfPar:	        .word   	     PrintfFormat
PrintfValue:	    .space		  8
PrintfPar2:       .space          4

.text
.global main

main:
;
addi            r1,r0,Prompt         
sw              PrintfPar2,r1       
addi            r14,r0,PrintfPar2    
trap            5                     

           
addi            r1,r0,Prompt1         
jal             InputDouble        
movd           f8,f2               

addi           r1,r0,Prompt2       
 jal            InputDouble           
movd           f4,f2              



multd           f4,f4,f8            

addi            r1,r0,Prompt3      
jal             InputDouble         
movd           f8,f2  

multd		 f4,f4,f8
           
 addi            r1,r0,Prompt4         ;
 sw             PrintfPar2,r1          ;
 addi            r14,r0,PrintfPar2     ;
 trap            5                     ;
 sd	            PrintfValue,f4     ;
addi	        r14,r0,PrintfPar       ;
 trap	        5                      ;


