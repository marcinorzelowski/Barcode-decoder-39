; MARCIN ORZEŁOWSKI - BITMAP DECODING CODE 39
; VERSION: 32 BIT




section .data


array: 	dd 111221211,  211211112, 112211112,  212211111, 111221112, 211221111, 112221111, 111211212, 211211211, 112211211, 211112112, 112112112, 212112111, 111122112,
		dd 211122111,  112122111, 112122111,  211112211, 112112211, 111122211, 211111122, 112111122, 212111121, 111121122, 211121121, 112121121,
		dd 111111222,  211111221, 112111221,  111121221, 221111112, 122111112, 222111111, 121121112, 221121111, 122121111, 121111212, 221111211,
		dd 122111211,  121212111, 121211121,  121112121, 111212121, 121121211

array2:
db	 '0','1','2', '3', '4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','-','.', ' ','$','/','+','%','*'











	%define image 	 [ebp+8]
	%define output	 [ebp+16]
	%define line	 [ebp+12]	
	%define width	 1800 ;pixels * 3bytes
	%define bar_width [ebp-4]
	
section .text
	global decode
	extern printf
decode:
;prologue:
	
	  push    ebp
    mov     ebp, esp
    sub     esp, 52

    push    ecx
    push    ebx
    ;push    edx
    push    esi
    push    edi
	mov eax, image
	mov ecx, width
	imul ecx, line
	add eax, ecx 
;After above operations:
; EAX  -> image ( first pixel in scanned line)
;Cleaning registers:
	xor ecx, ecx	 
	xor edi, edi
	xor ebx, ebx
	xor bh, bh
	mov esi, output
skip:	; program skipping white space before pattern
	mov ecx, eax
	cmp	BYTE[ecx], 0
	je	black_found
	inc edi
	cmp edi,	600 ;Checking if edi > 600 (width)
	je 	exit;	if edi == 600, exit;
	add eax, 	3
	jmp skip
black_found: ;checking the wdith of the bar
	xor ecx, ecx ;cleaning ecx
	
	mov ecx, eax
	cmp BYTE[ecx], 0 	;checking if pixel is black
	jne back_position	; if its is not, break
	add eax, 3		 	; go to next pixel
	inc ebx			 	; increment length of stipe
	inc edi			 	; increment x position
	cmp edi, 600	 	; check if we are "in line"
	je exit
	jmp black_found
	
back_position: ;getting back to the first bar
	sub	edi,	ebx
	;Tracking back to the first black pixel :
	sub eax, 	ebx
	sub eax, 	ebx
	sub eax, 	ebx
	xor ecx, 	ecx
	
	mov bar_width, ebx
	;Now we are at starting position, we can decode ;)
	;After this operation:
	;EAX -> image
	;EDI -> position (x)
	;Width of the bar is moved to bar_width variable on frame;
	
preparation:
;EBX holds number of read bars/stripes
;ECX hold length of stripe
;EDX hold the control number
	xor edx,	edx
	xor ebx, 	ebx
decoding:
	xor ecx, ecx		;clearing the ECX 
	cmp BYTE[eax], 0	;Check if we have black or white color, than jump to proper label
	je	black
	jne white
	
black:
;incrementing ecx. eax, edi.
;Stay as long in label as color change

	inc ecx	
	add eax, 3
	inc edi
	cmp edi,	600
	je 	exit
	cmp BYTE[eax], 0
	je 	black
	jmp after_change

	
white:
;incrementing ecx. eax, edi.
;Stay as long in label as color change

	inc ecx
	add eax, 3
	inc edi
	cmp edi,	600
	je 	exit
	cmp BYTE[eax], 0
	jne white
	jmp after_change
	
after_change:
;after changing from bar to strip (color change from black to white or from black to white:
	
	cmp ebx, 9
	je find_position_prep
	inc ebx
	cmp ecx, bar_width ;jump if greater stripe/bar width is greater than slim bar/width
	jg	long_mult
;Multiplication give a form such a 1211....


short_mult:
;short multiplication (adding 1)
	imul edx, 10
	inc 	edx
	cmp ebx, 9
	je find_position_prep
	jmp decoding
	
long_mult:
;long multiplication (adding 2 )
	imul edx, 10
	add edx, 2
	cmp ebx, 9
	je find_position_prep
	jmp decoding

find_position_prep:
;EBX -> ARRAY  (with patterns)
;ECX -> POSITION IN ARRAY
	xor ebx, ebx
	xor ecx, ecx

find_position: 
;Iteration through array to check if encoded symbol equal one of the array.
	mov ebx, [array+4*ecx]
	cmp edx, ebx
	je 	encode ;found symbol
	inc ecx
	cmp ecx, 44; checking if we do not cross the array border
	je	exit
	jmp find_position ;else back to iteration
encode:
	xor edx, edx
	mov	bl, [array2+ecx]
	mov BYTE[esi],bl
	inc esi
next_bar:
;looking for the next bar.
;Color black announce about next bar.
	add eax, 3
	inc edi
	cmp edi,	600
	je 	exit
	cmp BYTE[eax], 0
	je preparation
	jmp next_bar
	
	
	
exit:
;returning 1 to int 
	mov 	eax, 1

	pop    edi
    pop    esi
 
    pop    ebx
    pop    ecx

    mov    esp, ebp
    pop    ebp
    ret
   	
  
