; syscall shit on 32bits:
; args in ebx, ecx, edx, esi, edi, and ebp
; https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-and-user-space-f
;
; jump comparison
; http://unixwiz.net/techtips/x86-jumps.html

; used registers:
; esp: value stack
; ebp: return stack
; esi: continuation ptr
; eax: current block ptr

default rel

global _start

%macro next 0
  lodsd
  jmp [eax]
%endmacro

%macro resetregs 0
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  xor esi, esi
  xor edi, edi
  xor esp, esp
  xor ebp, ebp
%endmacro

section .text

_mem_start:

_start:
  resetregs
  mov esp, _mem_end - 256*4
  mov ebp, _mem_end
  mov esi, main
  next

_syscall_save_ebp:
  dd 0
_syscall_save_esi:
  dd 0

syscall_:
; args in ebx, ecx, edx, esi, edi, and ebp
; return value in eax
; eax < 0: errno
  ; save ebp and esi
  mov [_syscall_save_ebp], ebp
  mov [_syscall_save_esi], esi

  pop ebp
  pop edi
  pop esi
  pop edx
  pop ecx
  pop ebx
  pop eax
  int 0x80
  push eax

  mov ebp, [_syscall_save_ebp]
  mov esi, [_syscall_save_esi]
  
  next

nest_:
  sub ebp, 4
  mov [ebp], esi
  lea esi, [eax+4]
  next

unnest_:
  mov esi, [ebp]
  add ebp, 4
  next

call_:
  pop eax
  jmp [eax]

tail_:
  mov eax, [esi]
  lea esi, [eax+4]
  next
; old tail impl: just pop the ret stack before jumping
; safer but slower since you have to run nest_
; the new version skips nest_, so speed
; unless it didnt point to nest_ in the first place, UB ;)
;  lodsd
;  mov esi, [ebp]
;  add ebp, 4
;  jmp [eax]

read_:
  pop eax
  push dword [eax]
  next

readb_:
  pop eax
  xor ebx, ebx
  mov bl, byte [eax]
  push ebx
  next

write_:
  pop eax
  pop ebx
  mov [eax], ebx
  next

writeb_:
  pop eax
  pop ebx
  mov byte [eax], bl
  next

push_:
  lodsd
  push eax
  next

drop_:
  pop eax
  next

dup_:
  mov eax, [esp]
  push eax
  next

swap_:
  pop eax
  pop ebx
  push eax
  push ebx
  next

over_:
  mov eax, [esp+4]
  push eax
  next

nip_:
  pop eax
  mov [esp], eax
  next

nip2_:
  pop eax
  pop ebx
  mov [esp], ebx
  push eax
  next

add_:
  pop eax
  add [esp], eax
  next
  
sub_:
  pop eax
  sub [esp], eax
  next
  
mul_:
  pop eax
  pop ebx
  imul eax, ebx
  push eax
  next

div_:
  pop ebx
  pop eax
  xor edx, edx
  div ebx
  push eax
  next

mod_:
  pop ebx
  pop eax
  xor edx, edx
  div ebx
  push edx
  next

and_:
  pop eax
  and [esp], eax
  next

or_:
  pop eax
  or [esp], eax
  next

eqz_:
  pop ebx
  xor eax, eax
  test ebx, ebx
  sete al
  push eax
  next

lt_:
  pop ecx
  pop ebx
  xor eax, eax
  cmp ebx, ecx
  setl al
  push eax
  next

gt_:
  pop ecx
  pop ebx
  xor eax, eax
  cmp ebx, ecx
  setg al
  push eax
  next

whenz_:
  lodsd
  pop ebx
  test ebx, ebx
  jz .noop
  lea esi, [esi+eax*4] ; branch jmp distance is in cells
.noop:
  next

memcpy_: ; dst src byte-count
  mov ebx, esi
  cld ; write forward
  pop ecx
  pop esi
  pop edi
  rep movsb
  mov esi, ebx
  next

memset_: ; dst byte byte-count
  pop ecx
  pop eax
  pop edi
  rep stosb
  next

%macro def_over 1
over%1_:
  mov eax, [esp+4*%1]
  push eax
  next
%endmacro

def_over 2
def_over 3
def_over 4
def_over 5
def_over 6

_text_end:
_data_start:

; header format:
; dd next ; pointer to next entry in dict.
; db rep 12 name ; 8 bytes with the name, 0 padded.
; dd flags ; 4 bytes of metadata, like immediate
; dd interpreter ; pointer to native code, usually nest
; dd a, b, c, d, ... ; data

%macro mkwsi 3
%1_entry:
  dd last_in_dict
%1_name:
  db %2
  times %1_name+16-$ db 0
  dd %3 ; flags
%1:
%define last_in_dict %1_entry
%endmacro

%macro mkws 2
  mkwsi %1, %2, 0
%endmacro

%macro mkw 1
  mkws %1,%str(%1)
%endmacro

%macro mknw 1
  mkw %1
  dd %1_
  end
%endmacro

%macro mknws 2
  mkws %1, %2
  dd %1_
  end
%endmacro

%define last_in_dict 0

%macro end 0
  dd unnest, 0xffffffff
%endmacro

mknw syscall
mknw nest
mknw unnest
mknw call
mknw tail
mknws read, '@'
mknws readb, '@b'
mknws write,'!'
mknws writeb,'!b'
mknw push
mknw drop
mknw dup
mknw swap
mknw over
mknw nip
mknw nip2
mknws add, '+'
mknws sub, '-'
mknws mul, '*'
mknws div, '/'
mknws mod, '%'
mknw and
mknw or
mknw eqz
mknws lt, '<'
mknws gt, '>'
mknw whenz
mknw memcpy
mknw memset
mknw over2
mknw over3
mknw over4
mknw over5
mknw over6

mkw syscall_exit
  dd nest_, push, 1, swap, push, 0, dup, dup, dup, dup, syscall
  end

mkw exit
  dd nest_, push, 255, syscall_exit
  end

mkw mem_start
  dd nest_, push, _mem_start
  end

mkw mem_end
  dd nest_, push, _mem_end
  end

mkw here
  dd nest_, push, _here
  end
_here:
  dd _data_end

mkw cells
  dd nest_, push, 4, mul
  end

mkw cell
  dd nest_, push, 4
  end

mkws comma, ','
  dd nest_, here, read, write
  dd here, read, cell, add, here, write
  end

mkw eq
  dd nest_, sub, eqz
  end

mkw namecells
  dd nest_, push, 4
  end

mkw namesize
  dd nest_, namecells, cells
  end

mkw zeroname
  dd nest_, push, 0, namesize, memset
  end

mkw notwhite
  dd nest_, dup, push, ' ', eq, eqz
  dd over, push, `\t`, eq, eqz, and
  dd swap, push, `\n`, eq, eqz, and
  end

mkw syscall_read ; fd buf count
  dd nest_, push, 3, over3, over3, over3, push, 0, dup, dup, syscall
  dd nip, nip, nip
  end

mkw in_buf
  dd nest_, push, _mem_end - 256*4*2 - 1024
  end

mkw in_buf_cap
  dd nest_, push, 1024
  end

mkw in_buf_len
  dd nest_, push, _in_buf_len
  end
_in_buf_len:
  dd 0

mkw in_buf_cursor
  dd nest_, push, _in_buf_cursor
  end
_in_buf_cursor:
  dd 0

mkw in_buf_eof
  dd nest_, push, _in_buf_eof
  end
_in_buf_eof:
  dd 0

mkw in_buf_fill
  dd nest_, in_buf_eof, read, eqz, whenz, 4, push, 254, syscall_exit, unnest
  dd push, 0, in_buf, in_buf_cap, syscall_read
  dd dup, push, 0, lt, eqz, whenz, 2, syscall_exit, unnest
  dd dup, in_buf_len, write
  dd whenz, 4, push, 1, in_buf_eof, write
  dd push, 0, in_buf_cursor, write
  end

mkw getc
  dd nest_, in_buf_cursor, read, in_buf_len, read, lt
  dd whenz, 3, in_buf_fill, tail, getc
  dd in_buf_cursor, read, in_buf, add, readb
  dd in_buf_cursor, read, push, 1, add, in_buf_cursor, write
  end

mkw readword
  dd nest_, push, _buf, zeroname, _skipwhite, push, 0, _readword, push, _buf, unnest
_skipwhite:
  dd nest_, _readc, notwhite, whenz, 2, tail, _skipwhite, unnest
_readword:
  dd nest_, dup, _lastc, _appbuf
  dd push, 1, add, dup, namesize, push, 1, sub, sub
  dd whenz, 2, drop, unnest
  dd _readc, notwhite, whenz, 2, drop, unnest, tail, _readword
_appbuf: ; idx, char
  dd nest_, swap, push, _buf, add, writeb, unnest
_readc:
  dd nest_, getc, dup, push, _lastcbuf, writeb, unnest
_lastc:
  dd nest_, push, _lastcbuf, readb, unnest
_lastcbuf:
  dd 0
_buf:
  dd 0,0,0,0
  end

mkw nameeq
  dd nest_, namecells, _nameeq_loop, nip, nip, nip, unnest
_nameeq_loop:
  dd nest_, dup, whenz, 3, push, 1, unnest
  dd push, 1, sub
  dd over2, over, cells, add, read, over2, over2, cells, add, read, sub
  dd whenz, 2, tail, _nameeq_loop
  dd push, 0
  end

mkws gotoname, '>name'
  dd nest_, cell, add
  end

mkws gotoflags, '>flags'
  dd nest_, gotoname, namesize, add
  end

mkws gotocode, '>code'
  dd nest_, gotoflags, cell, add
  end

mkws lookup_fail_die, 'lookup-fail-die'
  dd nest_, push, 252, syscall_exit
  end

mkws lookup_fail, 'lookup-fail'
  dd nest_, push, _lookup_fail
  end
_lookup_fail: ; called with word prev header on the stack
  dd lookup_fail_die

mkw lookup ; ptr to 16 bytes word -- pointer to start of header
  dd nest_, dicthead, read, dup, _lookup_loop
  ; word prev header
  ; header = *dicthead -> do nothing (otherwise breaks linked list)
  dd dicthead, read, over, sub, whenz, 3, nip, nip, unnest
  ; 1: make *prev point to *header
  ; 2: make *header point to *dicthead
  ; 3: make *dicthead point to header
  dd dup, read, over2, write
  dd dicthead, read, over, write
  dd dup, dicthead, write
  dd nip, nip, unnest
_lookup_loop: ; 16b-word prev header
  dd nest_, dup
  dd whenz, 4, lookup_fail, read, call, lookup_fail_die
  dd over2, over, gotoname, nameeq
  dd whenz, 5, nip, dup, read, tail, _lookup_loop
  end

mkw asnum 
  dd nest_, push, 0, _asnum_loop, unnest
_asnum_loop: ; ptr to next, acc -- num
  dd nest_, over, readb, dup, whenz, 3, drop, nip, unnest
  dd push, '0', sub, swap, push, 10, mul, add
  dd swap, push, 1, add, swap, tail, _asnum_loop
  end

mkw outermode
  dd nest_, push, _outermode, unnest
_outermode:
  dd 0
  end

mkws colon, ":"
  dd nest_
  dd here, read, last_def_word, write
  dd dicthead, dup, read, swap, here, read, swap, write, comma
  dd readword
  dd here, read, dup, namesize, add, here, write
  dd swap, namesize, memcpy
  dd push, 0, comma
  dd push, nest_, comma
  dd push, 1, outermode, write
  end

mkwsi semi, ";", 1
  dd nest_, push, unnest, comma, push, 0xffffffff, comma
  dd push, 0, outermode, write
  end

mkws is_digit, 'is-digit'
  dd nest_, dup
  dd push, '0', lt
  dd swap, push, '9', gt, or, eqz
  end

mkw callword
  dd nest_, readword, dup, readb, is_digit
  dd whenz, 4, lookup, gotocode, call, unnest
  dd asnum
  end

mkw isimm
  dd nest_, gotoflags, read, push, 1, and
  end

mkw compileword
  dd nest_, readword, dup, readb, is_digit, eqz
  dd whenz, 6, push, push, comma, asnum, comma, unnest
  dd lookup, dup, isimm
  dd whenz, 3, gotocode, comma, unnest
  dd gotocode, call
  end

mkw outer
  dd nest_, outermode, read
  dd whenz, 3, callword, tail, outer
  dd compileword, tail, outer
  end

mkw main
  dd push, 0xf0f0f0f0, outer, exit
  end

mkws last_def_word, 'last-def-word'
  dd nest_, push, _last_def_word
  end
_last_def_word:
  dd 0

mkw dicthead
  dd nest_, push, _dicthead
  end
_dicthead:
  dd last_in_dict ; must be here since last_in_dict must be the last!

_data_end:

times _data_end+0x4000-$ db 0
; times _data_end+0x10000-$ db 0

_mem_end:

