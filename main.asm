;-------------------------------------------------------------------------------
;
;
;	Lab 2 - Subroutines - "Cryptography"
;	Gytenis Borusas, USAFA, 17 September 2014/ 18 September 2014
;	Ece 382
;	Instructor - Dr. George W. P. York
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"
;-------------------------------------------------------------------------------
            .text
            .retain

            .retainrefs


encrypted_message:		.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
key_address:			.byte	0xac, 0xdf, 0x23			;our key
key_length:				.equ	0x0003						;length of key (same works if with required funcionallity if we adjust length properly)
store_address:		.equ	0x0200						;Adress where we start storing our values
message_length:			.equ	0x0075
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			mov.w   #encrypted_message, R5
			mov.w	#key_address,        R6
			mov.w	#store_address,  R7
			mov.w	#message_length,	 R8

			call    #decryptMessage

forever:    jmp     forever   ;traps the cpu

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: Gytenis Borusas
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: cipherText_address, key_address, plainText_address, message_length
;Outputs: plainText
;Registers destroyed: R8
;-------------------------------------------------------------------------------

decryptMessage:
			tst.w	R8			; checks if decription is done
			jz		return
			dec.b 	R8			; decrement

			mov.w	#key_address, R11
			mov.w	R6, R12
			sub.w	R11, R12
			cmp.b	#key_length, R12
			jeq		resetKeyPointer

			mov.b	@R5+,R9
			mov.b	@R6+, R10
			call	#decryptCharacter
			mov.b	R10, 0(R7)
			inc.w	R7
			jmp		decryptMessage
resetKeyPointer:
			mov.w	#key_address, R6
			jmp		decryptMessage
return:
            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: Gytenis Borusas
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs: R9, R10
;Outputs: R10
;Registers destroyed: R10
;-------------------------------------------------------------------------------

decryptCharacter:
			xor.b	R9, R10
            ret


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

