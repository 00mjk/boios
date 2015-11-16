format coff

extrn _boios_main
extrn _puts

section '.boot' code data
org 0x7c00
use16
main16:
        jmp     0:.z
.z:
        cli
.nmi_disable:
        in      al,0x70
        or      al,0x80
        out     0x70,al
        xor     eax,eax
        mov     ds,ax
        mov     eax,0x08
        mov     ss,ax
        mov     esp,0xF000
        lgdt    [gdtx]
        mov     eax,cr0
        or      eax,1
        mov     cr0,eax
        jmp     0x08:main32
use32

gdt:
gdt_null:
   dq 0
gdt_code:
   dw 0xFFFF
   dw 0
   db 0
   db 10011010b
   db 11001111b
   db 0
gdt_data:
   dw 0xFFFF
   dw 0
   db 0
   db 10010010b
   db 11001111b
   db 0
gdt_end:
gdtx:
   dw gdt_end-gdt-1
   dd gdt
idt:
rept 32 n:0
{
      dw isr#n
      dw 0x0008
      db 0x00
      db 0x8E
      dw 0x0000
}
rept 16 n:0
{
      dw irq#n
      dw 0x0008
      db 0x00
      db 0x8E
      dw 0x0000
}
rb 8*(256-32-16)
idt_end:
idtx:
    dw idt_end-idt-1
    dd idt

isrz:
rept 32 n:0
{
;TODO: handle error codes
isr#n:
        push    word n
        jmp     isr_handler
}
isr_handler:
        push    dword[isr_str_err]
        mov     esi,_puts
        call    esi
        add     esp,4
        xor     eax,eax
        pop     ax
        cmp     eax,32
        jg      .z
        cmp     eax,20
        jl      .zz
        mov     eax,19
.zz:
        push    dword[eax*4+isr_errs]
        mov     esi,_puts
        call    esi
        add     esp,4
        push    dword[isr_str_err]
        mov     esi,_puts
        call    esi
        add     esp,4
.z:
        hlt
        jmp     .z

isr_str_err db 0x0a,0x0d,'ERRORRRRR! WTF???????????',0x0a,0x0d,0

isr_err0  db 'Division By Zero',0
isr_err1  db 'Debug',0
isr_err2  db 'Non Maskable Interrupt',0
isr_err3  db 'Breakpoint',0
isr_err4  db 'Into Detected Overflow',0
isr_err5  db 'Out of Bounds',0
isr_err6  db 'Invalid Opcode',0
isr_err7  db 'No Coprocessor',0
isr_err8  db 'Double Fault',0
isr_err9  db 'Coprocessor Segment Overrun',0
isr_err10 db 'Bad TSS',0
isr_err11 db 'Segment Not Present',0
isr_err12 db 'Stack Fault',0
isr_err13 db 'General Protection Fault',0
isr_err14 db 'Page Fault',0
isr_err15 db 'Unknown Interrupt',0
isr_err16 db 'Coprocessor Fault',0
isr_err17 db 'Alignment Check',0
isr_err18 db 'Machine Check',0
isr_err19 db 'Reserved',0

isr_errs:
rept 20 n:0
{
dd isr_err#n
}
irqz:
rept 16 n:0
{
irq#n:
        cli
        push    word n
        jmp     irq_handler
}
irq_handler:
        pop     word[.n]
        pushad
        push    ds
        push    es
        push    fs
        push    gs
        mov     [irq_stack],esp
        mov     esp,[irq_stack_mem]
        xor     eax,eax
        mov     ax,[.n]
        mov     ebx,[irqhs+eax*4]
        cmp     ebx,0
        je      .zz
        call    ebx
.zz:
        cmp     [.n],8
        jle     .z
        mov     al,0x20
        out     0x0A,al
.z:
        mov     al,0x20
        out     0x20,al
        mov     esp,[irq_stack]
        mov     [irq_stack],0
        pop     gs
        pop     fs
        pop     es
        pop     ds
        popad
        iret
.n dw 0
irq_stack dd 0
rb 1024
irq_stack_mem:
irqhs:
rept 16 n:0
{
irqh#n dd 0
}

main32:
        mov     eax,0x08
        mov     ds,ax
        mov     es,ax
        mov     fs,ax
        mov     gs,ax
.remap_pic:
macro outb p,v
{
        mov     al,v
        out     p,al
}
        outb    0x20,0x11
        outb    0xA0,0x11
        outb    0x21,0x20
        outb    0xA1,40
        outb    0x21,0x04
        outb    0xA1,0x02
        outb    0x21,0x01
        outb    0xA1,0x01
        outb    0x21,0x0
        outb    0xA1,0x0
purge outb
        lidt    [idtx]
.init_timer:
        mov     al,00110100b
        out     0x43,al
        mov     ax,1193;1193180
        out     0x40,al
        mov     al,ah
        out     0x40,al
.nmi_enable:
        in      al,0x70
        and     al,0x7F
        out     0x70,al
        xor     eax,eax
        xor     ebx,ebx
        xor     ecx,ecx
        xor     edx,edx
        xor     ebp,ebp
        xor     esi,esi
        xor     edi,edi
        jmp     0x08:_boios_main

public _set_irq_handler
_set_irq_handler:
        mov     ebx,[esp+8]
        mov     eax,[esp+4]
        mov     dword[irqhs+4*eax],ebx
        ret

public _printf
extrn _puthex32
extrn _putdec32
extrn _putchar
_printf:
        push    ebp
        xor     ebp,ebp
        push    ebx
        mov     ebx,[esp+12]
.n:
        mov     al,[ebx]
        inc     ebx
        cmp     al,0
        je      .r
        cmp     al,'%'
        jne     .nf
        mov     al,[ebx]
        inc     ebx
        cmp     al,0
        je      .r
        cmp     al,'x'
        je      .fx
        cmp     al,'d'
        je      .fd
        cmp     al,'s'
        je      .fs
        cmp     al,'c'
        je      .fc
        cmp     al,'#'
        je      .fh
.nf:
        push    eax
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .n
.fx:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_puthex32
        call    eax
        add     esp,4
        jmp     .n
.fd:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_putdec32
        call    eax
        add     esp,4
        jmp     .n
.fs:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_puts
        call    eax
        add     esp,4
        jmp     .n
.fc:
        mov     eax,[esp+ebp*4+16]
        inc     ebp
        push    eax
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .n
.fh:
        inc     ebx
        push    dword '0'
        mov     eax,_putchar
        call    eax
        add     esp,4
        push    dword 'x'
        mov     eax,_putchar
        call    eax
        add     esp,4
        jmp     .fx
.r:
        pop     ebx
        pop     ebp
        ret

REGS_SZ=(4+8+5)*4

public _threads
_threads rb 2*32
public _regs
_regs rb REGS_SZ*32

public _save_stack
_save_stack:
        mov     eax,[esp+4]
        push    esi
        push    edi
        mov     esi,[irq_stack]
        mov     edi,eax
        mov     ecx,REGS_SZ/4
.copy:
        mov     eax,dword[ss:(esi+ecx*4)]
        mov     dword[ds:(edi+ecx*4)],eax
        dec     ecx
        jnz     .copy
        pop     edi
        pop     esi
        ret

public _load_stack
_load_stack:
        mov     eax,[esp+4]
        push    esi
        push    edi
        mov     esi,eax
        mov     edi,[irq_stack]
        mov     ecx,REGS_SZ/4
.copy:
        mov     eax,dword[ds:(esi+ecx*4)]
        mov     dword[ss:(edi+ecx*4)],eax
        dec     ecx
        jnz     .copy
        pop     edi
        pop     esi
        ret





