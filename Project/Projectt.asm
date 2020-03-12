//--------------------------------------------Application---------------------------------------//
 
 //////// ///////// //   // ///////        *****      ***    ** *******
 //    // ///   /// //   // //   //       *** ***     ***   **  **    *
 //    // ///   /// //   // //   //      ***   ***    ***  **   **    *
 //    // ///   /// //   // //////      ***********   ******    *******
 //    // ///   /// //   // //   //    ***      ***   ***  **   **    *
 //////// ///   /// /////// //   //   ***        ***  ***   **  *******

//--------------------------------Stack and Stack Pointer Addresses

.equ     SPH    =$3E              ;High Byte Stack Pointer Address 
.equ     SPL    =$3D              ;Low Byte Stack Pointer Address 
.equ     RAMEND =$25F             ;Stack Address

//--------------------------------Port Addresses

//output
.equ     PORTC  =$15              ;Port C Output Address 
.equ     PINC   =$14              ;Port C Data Direction Register Address
.equ     DDRC   =$14

.equ     PORTB  =$18              ;Port B output Address
.equ     PINB   =$16              ;Port B Data Direction Register Address
.equ     DDRB   =$17

.equ     PORTD  =$12~+
.equ     PIND   =$10
.equ     DDRD   =$11


//input
.equ     DDRA   =$1A              ;Port A Data direction Register
.equ     PINA   =$19              ;Port A Data Direction Register Address


//--------------------------------Register Definitions

.def     leds    =r19              ;Register to store data for LEDs 
.def     temp    =r20              ;Temporary storage register 
.def     btn     =r22              ;Register definition for buttons
.def     segment =r18
.def     speed   =r24
.def     display =r23

//--------------------------------Program Initialisation

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
		 ldi    r31, $ff           ;load $ff on register 31 immediately
		 out    DDRB,r31          ;Set Port B for output by sending $FF to direction register
		 ldi    temp,$ff          ;load $ff on register 31 immediately
         out    DDRD,temp         ;Set Port D for output by sending $FF to direction register

;=======INPUT
		 ldi    temp,$00          .
		 out    DDRA,temp         ;Set port A for input by sending $00 to direction register
;Initialise Main Program 
         sec                      ;Set carry flag to 1 
sover:   clr    leds              ;Clear LEDs 


//--------------------------------Initialise output ports
ldi    temp,$00           ; set temp 00
out    DDRA,temp          ;Set Port A for input

ldi    temp,$ff 
out    PINC,temp          ;Set Port C for output by sending $FF to direction register

ldi    temp,$ff 
out    PORTB,temp          ;Set Port B for output by sending $FF to direction register

ldi    r31,$ff           ;load $ff on register 31 immediately
out    DDRB,r31          ;Set Port B for output by sending $FF to direction register

 
//-----------------------------Initialise Main Program


reset:   ldi    temp,high(RAMEND) ; reset the code to start over.
         out    SPH,temp   
ldi   segment,$3F
out   PORTD,segment

//---------------------***** Main Program ***** ------------------

main:  rcall holdloop  //call holdloop to start number generator which holds the 66
        
main2: rcall rloop  // will generate the first number XX and will go through the databaes lowest to highest 

   cpi r17,$33
   brlo TLeft  // titanic left  if x is less than 33 then jump to TLeft
   cpi r17,$88
   brlo SLeft  // ship left if x is less than 88 then jump to SLeft
   cpi r17,$AA
   brlo BLeft  // boat left if x is less than AA then jump to BLeft
   cpi r17,$CC
   brlo TRight // titanic right if x is less than CC then jump to TRight
   cpi r17,$EE
   brlo SRight // ship right if x is less than EE then jump to SRight
   cpi r17,$FF
   brlo BRight // boat right if x is less than FF then jump to BLeft
 
//--------------------------------------***** Danger LEDS Below *****-----------------


TLeft: ldi leds,$07  //Titanic Left (3 led)

Tl: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsl leds // Leds going left
    cpi leds,$00 //  if Leds = 00
    brne Tl // go back to T1 to make loop if reach 00 then skip this line
    rjmp main2 // back to main

TRight : ldi leds,0b11100000  //Titanic Right (3 led)

T2: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsr leds    // Leds going left
    cpi leds,$00  //  if Leds = 00
    brne T2 // go back to T2 to make loop if reach 00 then skip this line
    rjmp main2 // back to main

SLeft: ldi leds,$03 //Ship Left (2 LED)

Sl: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsl leds     // Leds going left
    cpi leds,$00 //  if Leds = 00
    brne Sl  // go back to s1 to make loop if reach 00 then skip this line
    rjmp main2 // back to main


SRight: ldi leds,0b11000000 //Ship Right (2 LED)

S2: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsr leds   // Leds going right
    cpi leds,$00 //  if Leds = 00
    brne S2  // go back to S2 to make loop if reach 00 then skip this line
    rjmp main2 // back to main


BLeft: ldi leds,$01 //Boat Left (1 Led)

Bl: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsr leds   // Leds going right
    cpi leds,$00 //  if Leds = 00
    brne Bl  // go back to B1 to make loop if reach 00 then skip this line
    rjmp main2 // back to main

BRight: ldi leds,0b10000000 //Boat Right (1 Led)

B2: out PORTC, leds  // Output on PORTC using Definition Leds
    rcall delay  // call delay to slow down the LEDS
    rcall fire // call Fire just incase user has clicked on a button (Action Listner)
    lsr leds     // Leds going right
    cpi leds,$00 //  if Leds = 00
    brne B2  // go back to B2 to make loop if reach 00 then skip this line
    rjmp main2 // back to main

//------------------Extra Features

           
fire:   in     btn, PINA  //put the pin A value in r17
        com    btn   //basic state of switches is 1111 1111 so invert to get 0000 0000
	    and    btn, leds ;Logical AND
        cpi    btn, 0b00000000  ;compare immediately
		brne   hit        ;branch if not equal to r17
	 	ret ;return

 hit:  clr leds
	   ldi temp, 0b01111111
	   rcall delay
	   out PORTC, leds

buzzloop: inc r21
	   rcall buzzer
	   cpi r21, $ff
	   brne buzzloop


buzzer: rcall smallDelay 
        ldi temp, $FF
		out PORTB, temp

        rcall smallDelay
		ldi temp, $00
		out PORTB, temp
		rcall smallDelay
		ret

//----------------------------------------***** Number Generator *****---------------------------

holdloop:    
  ldi r31, $08 // load R31 apply 08
  ldi r16,$66  // load r16 apply 66
  mov r17, r16 //move r17 to r16

rloop:  // number generator after 66 is set (66 = default)
andi r17,$02 // andi 0 - 1 = 1
lsr r17 // logical shift right
eor r17, r16 // xor 
lsr r16 // logical shift right
andi r16, $7F // andi 0 = 1 = 1
lsl r17 // logical shift left
lsl r17 // logical shift left
lsl r17 // logical shift left
lsl r17 // logical shift left
lsl r17 // logical shift left
lsl r17 // logical shift left
lsl r17 // logical shift left
or r17, r16 // or gate
mov r16, r17 // move r16 to r17
ret  // return

//-------------------------------------------------delay section of code (25.348 ms @ 1MHz) - utilises r25,r24

delay:   ldi    r24,$CC        ;Initialise 2nd loop counter
loop2:   ldi    r25,$Cc         ;Initialise 1st loop counter 
loop1:   dec    r25             ;Decrement the 1st loop counter 
         brne   loop1           ;and continue to decrement until 1st loop counter = 0 
         dec    r24             ;Decrement the 2nd loop counter 
         brne   loop2           ;If the 2nd loop counter is not equal to zero repeat the 1st loop, else continue 
         ret                    ;Return


;Small delay (773 us @ 1MHz) - utilises r24 
smallDelay:   ldi    r29,$FF    ;Initialise decrement counter 
delayBuzz:    dec    r29        ;Decrement counter 
              brne   delayBuzz     ;and continue to decrement until counter = 0 
              ret              ;Return




