org 300h

str: DB "Temp is: ", 0
str2: DB "Temp want: ", 0
	
	
TABLE:   DB "00.0","00.5", "01.0", "01.5", "02.0", "02.5", "03.0", "03.5", "04.0", "04.5", "05.0", "05.5", "06.0", "06.5", "07.0", "07.5", "08.0", "08.5", "09.0", "09.5" 
		 DB	"10.0","10.5", "11.0", "11.5", "12.0", "12.5", "13.0", "13.5", "14.0", "14.5", "15.0", "15.5", "16.0", "16.5", "17.0", "17.5", "18.0", "18.5", "19.0", "19.5"
		 DB	"20.0","20.5", "21.0", "21.5", "22.0", "22.5", "23.0", "23.5", "24.0", "24.5", "25.0", "25.5", "26.0", "26.5", "27.0", "27.5", "28.0", "28.5", "29.0", "29.5"
		 DB	"30.0","30.5", "31.0", "31.5", "32.0", "32.5", "33.0", "33.5", "34.0", "34.5", "35.0", "35.5", "36.0", "36.5", "37.0", "37.5", "38.0", "38.5", "39.0", "39.5"
		 DB	"40.0","40.5", "41.0", "41.5", "42.0", "42.5", "43.0", "43.5", "44.0", "44.5", "45.0", "45.5", "46.0", "46.5", "47.0", "47.5", "48.0", "48.5", "49.0", "49.5"	 
			 
ORG 0000H
LJMP main	

org 0003h
	LJMP buton1
	
org 0013h
	LJMP buton2
	
ORG 001BH
	cpl P3.0
	reti

org 0030h
	main:
MOV A, #38H     // use 2 lines and 5*7 
ACALL COMMAND    
MOV A, #0EH   //cursor blinking off 
ACALL COMMAND     
MOV A, #01H     //clr screen
ACALL COMMAND   

MOV IE,#10001101B
setb TCON.0
setb TCON.2
MOV r0, #44

; 5KHZ => 200us Period => 100us delay : 1.08507 = 92
MOV TMOD,#20H;Timer1,mod2
MOV TL1, -92
MOV TH1, #TL1
SETB TR1

mov A, #0C0h
ACALL COMMAND
MOV DPTR ,#str2

l3 : MOV A,#00H   
MOVC A,@A+DPTR    
JZ done3      
ACALL DISPLAY    
INC DPTR    
SJMP l3  
done3:

MOV A, #80H   // force cursor to first line 
ACALL COMMAND  
;display on LCD the string
MOV DPTR ,#str
l1 : MOV A,#00H   
MOVC A,@A+DPTR    
JZ done      
ACALL DISPLAY    
INC DPTR    
SJMP l1  
done:


;read and display the temperature on the LCD
temp: 
ACALL LOAD
mov a, #10h
ACALL COMMAND
mov a, #10h
ACALL COMMAND
mov a, #10h
ACALL COMMAND
mov a, #10h
ACALL COMMAND
SJMP temp


;convert the output from the ADC to ASCII for display
LOAD:
ACALL READY_CONVERSION
;tens
MOV A, P0
MOV B, #33h
DIV AB
add A, #30h
mov r3, A; pt comparare temperaturi
acall display
;units
mov A, B
mov B, #5
div AB
add A, #30h
mov r4, A; pt comparare temperaturi
acall display
;first decimal
mov A,#"."
acall display
mov A, B
mov B, #3
div AB
cjne A, #0, mare
mov A, #"0"
mov r5, A; pt comparare temperaturi
acall display
sjmp gata
mare:
mov A, #"5"
mov r5, A ; pt comparare temperaturi
acall display
gata:

acall compare

RET

;execute commands for LCD configuration
COMMAND:
ACALL READY_LCD
MOV P1, A   
CLR P2.1
CLR P2.0
SETB P2.2
NOP
NOP
CLR P2.2
RET    

;display character on LCD
DISPLAY:
ACALL READY_LCD
MOV P1, A      
SETB P2.1
CLR P2.0
SETB P2.2 
NOP
NOP
CLR P2.2     
RET       

;verify if the LCD displayed the character in order to display the next one
READY_LCD: 
CLR P2.2
SETB P1.7
CLR P2.1 ;RS=0
SETB P2.0 ; R/W = 1 => READ COMMAND REG
BACK:   CLR P2.2
		nop
		nop
		SETB P2.2
		JB P1.7, BACK
CLR P2.2
	RET

;verify if the conversion of the ADC is done
READY_CONVERSION: 
SETB P2.4  ;eoc
NOP
SETB P2.3 ; start
NOP
NOP
CLR P2.3
BACK2: JNB P2.4, BACK2
	RET
	

	buton1:
	

MOV A, #0C0h   
ACALL COMMAND
mov a, #11
cursor:
push acc
mov a, #14h
ACALL COMMAND
pop acc
dec a
jz out
sjmp cursor
out:

   MOV DPTR, #TABLE    ; DPTR points to the start of the lookup table
   MOV A, r0         ; A is the offset from the start of the lookup 
   mov b, #4
   mul AB
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   mov b, #4
   div AB
   mov r0, a


MOV A, #80H   // force cursor to first line 
ACALL COMMAND
mov a, #9
cursor1:
push acc
mov a, #14h
ACALL COMMAND
pop acc
dec a
jz init
sjmp cursor1
init:

reti

	
	buton2:
	
MOV A, #0C0h   
ACALL COMMAND
mov a, #11
cursor2:
push acc
mov a, #14h
ACALL COMMAND
pop acc
dec a
jz out2
sjmp cursor2
out2:

   MOV DPTR, #TABLE    ; DPTR points to the start of the lookup table
   MOV A, r0         ; A is the offset from the start of the lookup 
   dec a
   dec a
   mov B, #4
   mul AB
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   push acc
   MOVC A, @A + DPTR
   acall display
   pop acc
   inc a
   mov b, #4
   div AB
   mov r0, a


MOV A, #80H   // force cursor to first line 
ACALL COMMAND
mov a, #9
cursor3:
push acc
mov a, #14h
ACALL COMMAND
pop acc
dec a
jz init2
sjmp cursor3
init2:
reti

compare:

mov DPTR, #table
mov a, r0
mov b, #4
mul ab
movc a, @a+DPTR
subb a, #30h
push acc
mov a, r3
subb a, #30h

jnz merge 
mov a, #1
merge:

mov b, a ; current temperature
pop acc ; wanted temperature
div ab
	jz oprim
		cjne a, #1, pornim
		mov a, b
		cjne a, #0, pornim2
			;continuam cu urmatoarea cifra
			mov a, r0
			mov b, #4
			mul ab
			inc a
			movc a, @a+DPTR
			subb a, #30h
			push acc
			mov a, r4
			subb a, #30h
			
			jnz merge2 
			mov a, #1
			merge2:
			
			mov b, a
			pop acc
			div ab
				jz oprim2
					cjne a, #1, pornim3
					mov a, b
					cjne a, #0, pornim4
						mov a, r0
						mov b, #4
						mul ab
						inc a
						inc a
						inc a
						movc a, @a+DPTR
						subb a, #30h
						push acc
						mov a, r5
						subb a, #30h
						
						jnz merge3 
						mov a, #1
						merge3:
						
						mov b, a
						pop acc
						div ab
							jz oprim3
								cjne a, #1, pornim5
								mov a, b
								cjne a, #0, pornim6
									sjmp oprim4
pornim:
pornim2:
pornim3:
pornim4:
pornim5:
pornim6:
SETB P3.1

sjmp sarim

oprim:
oprim2:
oprim3:
oprim4:
CLR P3.1

sarim:
ret


END






