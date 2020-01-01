TITLE Program #6    (Project06OptionB.asm)

; Author: Chris Nat
; Last Modified: 11/24/2019
; OSU email address: natc@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 06     Option B           Due Date: 12/08/2019
; Description: This program demonstrates string input conversion to integer, system stack, and recursion concepts

INCLUDE Irvine32.inc

RMIN = 1
RMAX = 10		;not used
NMIN = 3
NMAX = 12		
MAXSIZE = 10

myWriteString MACRO buffer
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx
ENDM

.data

intro_1		BYTE		"Welcome to the Combinations Calculator", 0
intro_2		BYTE		"Implemented by Chris Nat", 0
intro_EC	BYTE		"Extra Credit: Program keeps track of the problem number.", 0
intro_3		BYTE		"I'll give you a combinations problem.", 0
intro_4		BYTE		"You enter your answer and I'll let you know if you're right.", 0

prompt_1	BYTE		"Problem: ", 0
prompt_2	BYTE		"Number of elements in the set: ", 0
prompt_3	BYTE		"Number of elements to choose from the set: ", 0
prompt_4	BYTE		"How many ways can you choose? ", 0
prompt_5	BYTE		"Invalid Response! ", 0
prompt_6	BYTE		"Another problem? (y/n): ", 0

error_1		BYTE		"Invalid response. Please enter a numerical value!", 0


results_1	BYTE		"There are ", 0
results_2	BYTE		" combinations of ", 0
results_3	BYTE		" items from a set of ", 0
results_4	BYTE		".", 0
results_5	BYTE		"You need more practice.", 0
results_6	BYTE		"You are correct!", 0

outro_1		BYTE		"OK ... goodbye.", 0 ;sassy farewell

n			DWORD		?
r			DWORD		?
pNumber		DWORD		1
result		DWORD		?
userInput	BYTE		MAXSIZE DUP(?)
userInput2	BYTE		MAXSIZE DUP(?)
answer		DWORD		0

.code


main PROC
	;Randomize called to be used showProblem to generate values for n and r
	call RANDOMIZE

	;Introduction section to explain program function
	call	introduction

next:	
;section will be called multiple times if the user wants to perform multiple problems

	;Section will generate a random problem statement for the user to solve
	push	OFFSET pNumber
	push	OFFSET n
	push	OFFSET r
	call	showProblem

	;Section calculates the correct answer based on the values generated for n and r in the current problem statement
	push	OFFSET result
	push	n
	push	r
	call	combinations

	;user will enter their answer and the procedure will convert user input from a string to a number
	push	OFFSET answer
	push	OFFSET userInput
	call	getData

	;Section will show the correct answer and let the user know if they got the problem right or wrong
	push	answer
	push	result
	push	n
	push	r
	call	showResults

nextProblem:
;ask the user if they wish to perform another statistics problem

	myWriteString prompt_6
	mov		ecx, sizeof userInput2
	mov		edx, OFFSET userInput2
	call	ReadString
	cmp		eax, 1					;check to see if user entered a single character for Y/N/y/n
	jg		incorrect
	mov		ecx, eax
	mov		esi, OFFSET userInput2
	cld
	call	Crlf

	;load byte and compare with characters for Y/N/y/n to jump to the appropriate section of the main program
	lodsb
	cmp		al, 121
	je		next
	cmp		al, 89
	je		next
	cmp		al, 110
	je		quit
	cmp		al, 78
	je		quit
incorrect:
	myWriteString prompt_5
	jmp		nextProblem				;repeat request for user to enter Y/N/y/n 
quit:
	myWriteString outro_1			;N/n will exit program with outro statement


	exit							
	
main ENDP

introduction PROC
;call macro to write string instructions for the program
;pre-condition: NA
;post-condition: NA
;registers changed: none, but utilize EDX from macro



	myWriteString	intro_1
	call	Crlf
	myWriteString	intro_2
	call	Crlf
	myWriteString	intro_EC
	call	Crlf
	myWriteString	intro_3
	call	Crlf
	myWriteString	intro_4
	call	Crlf
	call	Crlf
	ret

introduction ENDP

showProblem PROC
;assign random values for R and N in the problem statement
;pre-condition: global limits RMIN, NMIN, NMAX
;post-condition: random values set for r and n
;registers changed: eax, ebx, ecx, edx, esi, 

	push	ebp
	mov		ebp, esp

problemStatement:
	myWriteString	prompt_1
	mov		ebx, [ebp+16]	;list current problem number
	mov		eax, [ebx]
	call	WriteDec
	inc		eax				;increase pNumber by one for next problem
	mov		[ebx], eax
	call	Crlf

nGeneration:
	myWriteString	prompt_2
	mov		eax, NMAX		;random number max value of 12
	sub 	eax, NMIN		;subtract the min value of 3 to create a range
	inc 	eax				;add one for inclusion
	call 	RandomRange		;RandomRange will pick a value between 3 and 12
	add 	eax, NMIN		;add NMIN to create lower limit
	mov		ebx, [ebp+12]	;save random value into n
	mov		[ebx], eax		;save random value into n
	call	WriteDec
	call	Crlf

rGeneration:
	myWriteString	prompt_3
	mov		ebx, [ebp+12]	;move generated value for n into register
	mov		eax, [ebx]		;move generated value for n into register
	sub		eax, RMIN		;subtract RMIN
	inc		eax				;add one for inclusion
	call	RandomRange		;random range will pick a value between 
	add		eax, RMIN
	mov		ebx, [ebp+8]	;save random value into r
	mov		[ebx], eax
	call	WriteDec
	call	Crlf

	pop		ebp
	ret		12
showProblem ENDP

combinations PROC
;this section performs the factorial math to calculate the correct answer from the n and r values generated in showProblem
;pre-condition: showProblem must store values for n and r
;post-condition: correct answer stored in address of result
;registers changed: eax, ebx, ecx, edx, esi, 

	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp+8]	;r
	push	ebx
	call	factorial		;r!
	mov		ecx, eax		;r! moved to ecx
	mov		eax, [ebp+12]	;n
	sub		eax, [ebp+8]	;n-r
	push	eax			
	call	factorial		; (n-r)!
	mul		ecx				; r! * (n-r)!
	mov		ecx, eax		; r! * (n-r)!
	mov		eax, [ebp+12]	;n
	push	eax
	call	factorial		;n!
	mov		ebx, ecx
	div		ebx				;n! / (r! * (n-r)!)
	mov		ebx, [ebp+16]
	mov		[ebx], eax
	pop		ebp
	ret		12
combinations ENDP

factorial PROC
;From Chapter 8 Section 8.3.2 Calculating a Factorial

	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+8]	;move value pushed from combinations: (n-r), r, n
	cmp		eax, 0			;greater than 0?
	ja		L1				;yes, continue
	mov		eax, 1			;nopoe, return 1 as the value of 0!
	jmp		L2				;jump to return
L1:	
	dec		eax				;value - 1 for recursion call
	push	eax				;factorial (n-1)
	call	Factorial
ReturnFact:
	mov		ebx, [ebp+8]	; get value address to return
	mul		ebx				;edx:eax = EAX * EBX
L2:
	pop		ebp				;return EAX
	ret		4				;clean up stack
factorial ENDP

getData PROC
;user will enter their answer to the problem statement where n and r values were set
;pre-condition: none
;post-condition: user input is validated and stored in address of answer
;registers changed: eax, ebx, ecx, edx, esi, 

	push	ebp
	mov		ebp, esp
	jmp		response		;skip the error section below for the first pass through procedure
notNumber:
;macro to call error and then request user to enter value

	myWriteString error_1	
	call	Crlf
	jmp		response
response:
;converting string character to integer from demo6 and lecture 23 pseudocode

	myWriteString prompt_4
	mov		edx, [ebp+8]

	mov		ecx, MAXSIZE		;global
	call	ReadString			;ReadString will stop processing at end where '0' is found
	mov		ecx, eax
	mov		esi, [ebp+8]
	cld
	mov		edx, 0

counter:
;check each byte to make sure character value is between 48 and 57 which is 0 - 9
;code manipulates the character values stored in a string so that conversion to integer is possible and able to filter out letters/symbols
	lodsb						;load byte and increment esi
	cmp		al, 57				;compare to 9
	ja		notNumber
	cmp		al, 48				;compare to 0
	jb		notNumber

	movzx	eax, al
	push	ecx				;save current ecx count
	mov		ecx, eax		;current string character moved to ecx
	mov		ebx, 10			
	mov		eax, edx		;initialization of 0
	mul		ebx				;multiply character code by 10 to increase X to X0 before adding chracter - 48 into the 0
	mov		edx, eax		;move product of register * 10 to edx
	sub		ecx, 48			;the character value stored in ecx will have 48 subtracted from it (48 represents character 0)
	add		edx, ecx		;add difference to X0
	pop		ecx				;restore ecx register to loop count
	loop	counter			;call loop to step through remaining array of characters

	mov		ebx, [ebp+12]
	mov		[ebx], edx
	
	pop		ebp
	ret		8
getData ENDP

showResults PROC
;procedure compares user input with the correct answer and states whether their answer is right or wrong
;pre-condition: set values stored in the address for n, r, 
;post-condition: random values set for r, n, result, and answer
;registers changed: eax, ebx, edx

	push	ebp
	mov		ebp, esp
	myWriteString results_1
	mov		eax, [ebp+16]
	call	WriteDec
	myWriteString results_2
	mov		eax, [ebp+8]
	call	WriteDec
	myWriteString results_3
	mov		eax, [ebp+12]
	call	WriteDec
	myWriteString results_4
	call	Crlf
	mov		eax, [ebp+20]		;answer
	mov		ebx, [ebp+16]		;result
	cmp		eax, ebx			;if equal, jump to correct
	je		correct
	myWriteString results_5		;response if user is incorrect
	call	Crlf
	jmp		finish				
correct:
	myWriteString results_6		;response if user is correct
	call	Crlf
finish:
	pop		ebp					
	ret		16					;clean up stack
showResults ENDP

END main
