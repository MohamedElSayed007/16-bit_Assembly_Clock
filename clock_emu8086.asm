;Coded by : Mohamed El Sayed
;engmohamedelsayed007@gmail.com

;This source code is compatible and tested with emu8086, the masm compatible code can be founded in the same repository
;with the name of clock_masm.asm

ORG 100H 
.MODEL TINY 
	
.CODE 
MAIN PROC

 
	;Init. Data Segment
	MOV AX, @DATA 
	MOV DS, AX 
	
	;CHECK FOR KEY TO END THE APPLICATION
	KEY_CHECK:
	
	;CHECKS IF THERE IS A KEYPRESS, IF NOT. JUMP TO _LOOP TO PREVENT WAITING FOR A KEYPRESS
	
	MOV AH, 01H
	INT 16H
	JZ _LOOP
	
	
	;XOR AH, OR REMOVE ITS CURRENT VALUE AFTER CHECKING IF ITS NOT ESCAPE(27)
	
	XOR AH, AH		;OR MOV AH, 0
	INT 16H
	
	;CEHCK IF ITS ESCAPE OR NOT
	
	CMP AL	, ESCAPE_ASCII
	JE CONT
_LOOP:
	CALL MAJOR
	JMP KEY_CHECK
	
CONT:
	
	
	;MOVE CURSOR 
	MOV AH, 02H 
	MOV BH, 0		   	 	        ;DISPLAY PAGE 
	MOV DH, 05H 		 		      	;ROW 
	MOV DL, 00H					;COLUMN 
	INT 10H		 


	;RESETTING THE VIDEO MODE TO ITS NORMAL STATE ( 03H IS THE NORMAL VID. MODE)
	MOV AH, 0
	MOV AL, 03H
	INT 10H
	
	
	;EXITING AND RETURN CONTROL TO DOS
	MOV AX, 4C00H 
	INT 21H 
	
MAIN ENDP 
	
MAJOR PROC

	CMP TEMP, 1
	JE BEGIN	
	
	MOV AX, 0     			 ;Instead of setting AH=0 , Formatting or Setting AX=0 Will set AH=0
	MOV AL, 013H   			 ;Setting Video Mode			,Available Modes : 01h , 03h	 
	INT 10H 
	

	;PAINTING THE FIRST FRAME
	 
	MOV AL, GREEN
  MOV BH, 1
	MOV CX, -1
	MOV DX, 0
	MOV ENDLOOP, 4799
	CALL PAINT 	     	;Call Paint Function
	 
	 
	 
	;PAINTING THE SECOND FRAME
	MOV AL, GREEN
	MOV BH, 1
	MOV CX, -1
	MOV DX, 25
	MOV ENDLOOP, 2239
	CALL PAINT


	 
	 
	;SETTING FOR PRINTING MY NAME; 
	MOV AH, 02H 
	MOV BH, 0 
	MOV DH, 00H 
	MOV DL, 06H 
	INT 10H 
	 
	;PRINTING MY NAME
	 
	MOV AH, 09H 
	LEA DX, MNAME 
	INT 21H 
	 
	 
	
	MOV AH, 02H 								
	MOV BH, 0							      	
	MOV DH, 02H					  			
	MOV DL, 00H						  			
	INT 10H		 
			 
	LEA BX, FORMAT                 ; BX=OFFSET ADDRESS OF STRING TIME 
 	
 	MOV TEMP, 1 
 	
BEGIN: 
  
  CALL READ_TIME                ; CALL THE PROCEDURE READ_TIME 
  
  LEA DX, MSG               ; DX=OFFSET ADDRESS OF STRING PROMPT 
  MOV AH, 09H                  ; PRINT THE STRING PROMPT 
  INT 21H                       
 
  LEA DX, FORMAT                 ; DX=OFFSET ADDRESS OF STRING TIME 
  MOV AH, 09H                  ; PRINT THE STRING TIME 
  INT 21H                      	 

	 
	;MOVE CURSOR 
	MOV AH, 02H 
	MOV BH, 0				 ;DISPLAY PAGE 
	MOV DH, 02H				 ;ROW 
	MOV DL, 00H				 ;COLUMN 
	INT 10H		 
	

	RET
MAJOR ENDP
		      
READ_TIME PROC 
    ; THIS PROCEDURE WILL GET THE CURRENT SYSTEM TIME  
    ; INPUT : BX=OFFSET ADDRESS OF THE STRING TIME 
    ; OUTPUT : BX=CURRENT TIME 
 
    PUSH AX                       ; PUSH AX ONTO THE STACK 
    PUSH CX                       ; PUSH CX ONTO THE STACK  
 
    MOV AH, 2CH                   ; GET THE CURRENT SYSTEM TIME 
    INT 21H                        
 
    MOV AL, CH                    ; SET AL=CH , CH=HOURS 
    CALL BIN_TO_ASCII                  ; CALL THE PROCEDURE BIN_TO_ASCII 
    MOV [BX], AX                  ; SET [BX]=HR  , [BX] IS POINTING TO HR 
                                  ; IN THE STRING TIME 
 
    MOV AL, CL                    ; SET AL=CL , CL=MINUTES 
    CALL BIN_TO_ASCII                  ; CALL THE PROCEDURE BIN_TO_ASCII 
    MOV [BX+3], AX                ; SET [BX+3]=MIN  , [BX] IS POINTING TO MIN 
                                  ; IN THE STRING TIME 
                                            
    MOV AL, DH                    ; SET AL=DH , DH=SECONDS 
    CALL BIN_TO_ASCII                  ; CALL THE PROCEDURE BIN_TO_ASCII 
    MOV [BX+6], AX                ; SET [BX+6]=MIN  , [BX] IS POINTING TO SEC 
                                  ; IN THE STRING TIME 
                                                       
    POP CX                        ; POP A VALUE FROM STACK INTO CX 
    POP AX                        ; POP A VALUE FROM STACK INTO AX 
 
    RET                           ; RETURN CONTROL TO THE CALLING PROCEDURE 
READ_TIME ENDP                  ; END OF PROCEDURE READ_TIME 
 


BIN_TO_ASCII PROC  
    ; THIS PROCEDURE WILL BIN_TO_ASCII THE GIVEN BINARY CODE INTO ASCII CODE 
    ; INPUT : AL=BINARY CODE 
    ; OUTPUT : AX=ASCII CODE 
 
    PUSH DX                       ; PUSH DX ONTO THE STACK  
 
    MOV AH, 0                     ; SET AH=0 
    MOV DL, 10                    ; SET DL=10 
    DIV DL                        ; SET AX=AX/DL 
    OR AX, 3030H                  ; BIN_TO_ASCII THE BINARY CODE IN AX INTO ASCII 
 
    POP DX                        ; POP A VALUE FROM STACK INTO DX  
 
    RET                           ; RETURN CONTROL TO THE CALLING PROCEDURE 
BIN_TO_ASCII ENDP                   ; END OF PROCEDURE BIN_TO_ASCII		       
 
 
 
PAINT PROC		 ;Input : Color in AL , BH = Page Number , CX = X Pos , DX = Y Pos , ENDLOOP = When to stop looping
	
	MOV AH, 0CH      			;FUNCTION CODE FOR DRAWING PIXELS 
	MOV CX, -1 
		;SETTING BH TO THE PAGE NUMBER IS NOT NEEDED AS IT ALREADY CONTAINS THE PAGE NUMBER 
	PLOOP: 
			INC CX   			 ;X POINT POS.
			INT 10H 
			CMP CX, ENDLOOP
			JNE PLOOP
	
	RET 
PAINT ENDP 
			 
  MSG   				  DB			"The Current Time Is : $" 
	FORMAT				  DB			"00:00:00$" 
	MNAME	  			  DB			"Coded By : Mohamed El Sayed$" 
	ENDLOOP				  DW			?
	TEMP		  		  DB			?
	ESCAPE_ASCII	  EQU			27
	GREEN				    EQU			0010B
            
			END MAIN

