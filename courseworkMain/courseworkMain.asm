////////////////////////////////////////////
///;*********AVR- Torpedo Game**********;///
///;*********By Sandesh Koirala*********;///
////////////////////////////////////////////
 
;Stack and Stack Pointer Addresses 
.equ     SPH    =$3E              ;High Byte Stack Pointer Address 
.equ     SPL    =$3D              ;Low Byte Stack Pointer Address 
.equ     RAMEND =$25F             ;Stack Address

;Port Addresses 
;=======INPUT
.equ     DDRA   =$1A              ;Port A Data Direction Register Address 
.equ     PINA   =$19              ;Port A Input Address
;=======OUTPUT
.equ     PORTC  =$15              ;Port C Output Address 
.equ     DDRC   =$14              ;Port C Data Direction Register Address 
.equ     PORTB  =$18              ;Port B Output for Buzzer
.equ     DDRB   =$17              ;Port B Data Direction Register Address 
.equ     PORTD  =$12              ;Port D Output for Dual Seven Segment 
.equ     DDRD   =$11              ;Port D Data Direction Register Address

;Register Definitions 
.def     leds   =r30              ;Register to store data for LEDs 
.def     temp   =r16              ;Temporary storage register
.def     YL     =r20              ;Register for Seven Segment
.def     YH     =r21              ;Register for Seven Segment
.def     ZL     =r22              ;Register for Seven Segment
.def     ZH     =r23              ;Register for Seven Segment
.def     count  =r26

;Program Initialisation 
;Set stack pointer to end of memory 
         ldi    temp,high(RAMEND) 
         out    SPH,temp          ;Load high byte of end of memory address 
         ldi    temp,low(RAMEND) 
         out    SPL,temp          ;Load low byte of end of memory address 

;Initialise ports 
;=======OUTPUT
         ldi    temp,$ff	      ;load $ff on temp immediately on temp
         out    DDRC,temp         ;Set Port C for output by sending $FF to direction register 
		 ldi    r31,$ff           ;load $ff on register 31 immediately
		 out    DDRB,r31          ;Set Port B for output by sending $FF to direction register
		 ldi    temp,$ff          ;load $ff on register 31 immediately
         out    DDRD,temp         ;Set Port D for output by sending $FF to direction register

;=======INPUT
		 ldi    temp,$00          .
		 out    DDRA,temp         ;Set port A for input by sending $00 to direction register
;Initialise Main Program 
         sec                      ;Set carry flag to 1 
sover:   clr    leds              ;Clear LEDs 

;Main Program 
ldi r18, $66                   ;load $66 on r18
mov r19,r18                    ;Copy register value from r18 and store on r19
BOSSofLeds: rcall RandomG      ;execute RandomG subroutine

SHIPS: cpi r28,$00             ;Compare Immediately r28 with $00
       breq TurnLeft           ;Branch to TurnLeft if r28, $00 is equal
	   cpi r28,$01             ;Comapre Immediatelty r28 with $01
	   breq TurnRightLED2      ;Branch to TurnLeftLED2 if r28, $01 is equal
	   cpi r28, $02            ;Comparing 2 registers
	   breq TurnLeftLED3       

;=================***LED1***==========================
TurnLeft: ldi leds, 0b00000001    ;Load immediat on leds
ll1:out PORTC, leds               ;output led value
	rcall delay                   ;execute delay subroutine
	rcall checkButtons            ;execute checkbuttons subroutine
	rcall buzzer                  ;execut buzzer subroutine
	lsl leds                      ;logical shift left
	cpi leds,$00                  ;compare leds with $00
	brne ll1                      ;branch to ll1 if not equal 
	rjmp TurnRight                ;go to TurnRight

TurnRight: ldi leds, 0b10000000   
rr1:out  PORTC, leds
    rcall delay
	rcall checkButtons
	lsr leds
	cpi leds,$00
	brne rr1
	rjmp BOSSofLeds
;=================***LED2***==========================
TurnLeftLED2: ldi leds, 0b00000111
ll2:out PORTC, leds
    rcall delay
	rcall checkButtons
	lsl leds
	cpi leds, $00
	brne ll2
	rjmp TurnRightLED2

TurnRightLED2: ldi leds, 0b11100000
rr2:out  PORTC, leds 
    rcall delay
	rcall checkButtons
	lsr leds
	cpi leds,$00
	brne rr2
	rjmp BOSSofLeds
;=================***LED3***==========================
TurnLeftLED3: ldi leds, 0b00000011
ll3:out PORTC, leds
    rcall delay
	rcall checkButtons
	lsl leds
	cpi leds, $00
	brne ll3
	rjmp TurnRightLED3

TurnRightLED3: ldi leds, 0b11000000
rr3:out  PORTC, leds 
    rcall delay
	rcall checkButtons
	lsr leds
	cpi leds,$00
	brne rr3
	rjmp BOSSofLeds
;================***ButtonPress***===================
checkButtons:           in     r17, PINA  //put the pin A value in r17
                        com    r17   //basic state of switches is 1111 1111 so invert to get 0000 0000
						and    r17, leds ;Logical AND
                        cpi    r17, 0b00000000  ;compare immediately
						brne   shootDown        ;branch if not equal to r17
						ret ;return

             shootDown: rcall delay
			            ldi leds, 0b01010101
			            out PORTC, leds
			 
						

				buzzloop: inc r27
				          rcall buzzer
						  cpi r27, $ff
						  brne buzzloop
						  ret
;=================***Random***==========================
RandomG: lsr r19  
         eor r19, r18  ;Logical eor 
		 lsr r18       ;logical shift right 
		 lsl r19       ;logical shift left
		 lsl r19       ;logical shift left
		 lsl r19       ;logical shift left
		 lsl r19       ;logical shift left
		 lsl r19       ;logical shift left
		 lsl r19       ;logical shift left
		 or r19, r18   ;Logical OR
		 mov r18, r19  ;copy register 
		 mov  r28, r18 ; copy register
		 andi r28, $03 ;logical AND between the contents of register Rd and a constant
		 ret
;=================***Buzzer***==========================
buzzer: rcall smallDelay 
        ldi temp, $FF
		out PORTB, temp
	   ;******************;
        rcall smallDelay
		ldi temp, $00
		out PORTB, temp
		rcall smallDelay
		ret

;=================***Delay***===========================
;delay section of code (25.348 ms @ 1MHz) - utilises r25,r24 
delay:   ldi    r24,$FF          ;Initialise 2nd loop counter 
loop2:   ldi    r25,$FF          ;Initialise 1st loop counter 
loop1:   dec         r25              ;Decrement the 1st loop counter 
         brne   loop1            ;and continue to decrement until 1st loop counter = 0 
         dec    r24              ;Decrement the 2nd loop counter 
         brne   loop2            ;If the 2nd loop counter is not equal to zero repeat the 1st loop, else continue 
        ret                   ;Return

;Small delay (773 us @ 1MHz) - utilises r24 
smallDelay:   ldi    r29,$FF    ;Initialise decrement counter 
delayBuzz:    dec    r29        ;Decrement counter 
              brne   delayBuzz     ;and continue to decrement until counter = 0 
              ret              ;Return
























.


