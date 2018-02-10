
extern "C" void hello_world_asm();
extern "C" int mandel_count(double real, double imag, int max_count);

int main(int argc, char *argv[])
{
	hello_world_asm();

	int c = mandel_count(2.0, -1.0, 10000);

	return 0;
}


/*


_DATA SEGMENT
hello_msg	db "Hello world", 0
info_msg	db "Info", 0
_DATA ENDS

_TEXT SEGMENT
hello_msg	db "Hello world", 0
info_msg	db "Info", 0
_TEXT ENDS


extern "C"
{
char c_ext_byte = 1;
unsigned short c_ext_word = 2;
long c_ext_dword = 3;
__int64 c_ext_qword = 4;
void *c_ext_ptr = (void*)(5);
void c_ext_my_function();
}

EXTERN c_ext_byte: byte
EXTERN c_ext_word: word
EXTERN c_ext_dword: dword
EXTERN c_ext_qword: qword
EXTERN c_ext_ptr: qword
EXTERN c_ext_my_function: PROC

PUBLIC access_extern_data

access_extern_data PROC
; Dereference all the data according to each data's size
mov	al, byte ptr [c_ext_byte]
mov	ax, word ptr [c_ext_word]
mov	eax, dword ptr [c_ext_dword]
mov	rax, qword ptr [c_ext_qword]

; Remember a pointer is just a QWORD
mov	rax, qword ptr [c_ext_ptr]

; Similarly a function pointer is also a QWORD
mov	rax, offset c_ext_function
sub	rsp, 4 * 8	; Register shadow stack
call rax		; Call the C function
add	rsp, 4 * 8	; Restore the stack

ret
access_extern_data ENDP







*/