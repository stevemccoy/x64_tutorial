_DATA SEGMENT
	hello_msg	db "Hello world", 0
	info_msg	db "Info", 0
	four		REAL8	4.0		; stores a real number in 8 bytes
	two			REAL8	2.0		; stores a real number in 8 bytes
_DATA ENDS


_TEXT SEGMENT

EXTERN MessageBoxA: PROC
EXTERN GetForegroundWindow: PROC

PUBLIC hello_world_asm
hello_world_asm PROC

	push	rbp			; save frame pointer
	mov		rbp, rsp	; fix stack pointer
	sub		rsp, 8 * (4 + 2)	; allocate shadow register area + 2 QWORDs for stack alignment

	; Get a window handle
	call	GetForegroundWindow
	mov		rcx, rax

	; WINUSERAPI int WINAPI MessageBoxA(
	;	RCX	=> _In_opt_ HWND hWnd,
	;	RDX	=> _In_opt_ LPCSTR lpText,
	;	R8	=> _In_opt_ LPCSTR lpCaption,
	;	R9	=> _In_ UINT uType);

	mov		rdx, offset hello_msg
	mov		r8, offset info_msg
	mov		r9, 0					; MB_OK

	and		rsp, not 8				; align stack to 16 bytes prior to API call
	call	MessageBoxA

	; epilog, restore stack pointer
	mov		rsp, rbp
	pop		rbp

	ret

hello_world_asm ENDP


PUBLIC mandel_count
mandel_count PROC

	; xmm0 => real (64 bit fp)
	; xmm1 => imaginary (64 bit fp)
	; eax => max count (32 bit int)
	; eax <= returned count (32 bit int)

	push	rbp			; save frame pointer
	mov		rbp, rsp	; fix stack pointer
	sub		rsp, 8 * (4 + 2)	; allocate shadow register area + 2 QWORDs for stack alignment

	; Copy c_real and c_imag to xmm2 and xmm3, max count to ebx.
	movsd	xmm2, xmm0
	movsd	xmm3, xmm1
	mov		ebx, eax

	; Zero count.
	mov		eax, 0

loop_start:

	; temp_real is in xmm5, temp_imag in xmm6.
	movsd	xmm5, xmm0
	mulsd	xmm5, xmm5		; z_real * z_real
	movsd	xmm6, xmm1
	mulsd	xmm6, xmm6		; z_imag * z_imag
	subsd	xmm5, xmm6
	addsd	xmm5, xmm2		; (z_real * z_real - z_imag * z_imag + c_real)
	mulsd	xmm1, xmm0
	mulsd	xmm1, two
	addsd	xmm1, xmm3		; (2 * z_real * z_imag + c_imag)
	
	movsd	xmm0, xmm5		; set new z_real

	call	divergent		; Sets flags?
	jge		loop_exit		; Quit if |z| >= 2.0 (indicates divergent)
	
	inc		eax				; increment count
	cmp		eax, ebx		; and loop unless max count is reached
	jl		loop_start

loop_exit:

	; epilog, restore stack pointer
	mov		rsp, rbp
	pop		rbp

	ret

mandel_count ENDP


divergent PROC
	; xmm0 => real
	; xmm1 => imaginary
	; Sets flags according to comparison of square magnitude to 4.0

	push	rbp			; save frame pointer
	mov		rbp, rsp	; fix stack pointer
	sub		rsp, 8 * (4 + 2)	; allocate shadow register area + 2 QWORDs for stack alignment

	mulsd	xmm0, xmm0
	mulsd	xmm1, xmm1
	addsd	xmm0, xmm1
;	movsd	xmm4, four
	comisd	xmm0, four

	; epilog, restore stack pointer
	mov		rsp, rbp
	pop		rbp

	ret
divergent ENDP

_TEXT ENDS

END
