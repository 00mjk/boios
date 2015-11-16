typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long int uint64_t;

struct regs
{
    uint32_t gs, fs, es, ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t eip, cs, eflags, esp2, ss;
}; //sz=(4+8+5)*4=(17)*4

#define THREAD_STACK_SZ 4096

typedef uint8_t tid_t;
typedef struct thread thread_t;
typedef struct regs regs_t;
extern thread_t *threads;
extern regs_t *regs;
struct thread
{
    tid_t next;
    uint8_t state;
};
void thread_dump(tid_t x);

#define sti() asm __volatile__("sti")
#define cli() asm __volatile__("cli")
#define hlt() asm __volatile__("hlt")
#define die(x)                         \
    {                                  \
        printf("\n\ndie(%s);\n\n", x); \
        for (;;)                       \
            hlt();                     \
    }

typedef __builtin_va_list va_list;
#define va_start(ap, last) __builtin_va_start(ap, last)
#define va_end(ap) __builtin_va_end(ap)
#define va_arg(ap, type) __builtin_va_arg(ap, type)
#define va_copy(dest, src) __builtin_va_copy(dest, src)

#define MEMORY_BARRIER asm volatile("" \
                                    :  \
                                    :  \
                                    : "memory")

extern volatile uint8_t stdout_x;
extern volatile uint8_t stdout_y;

extern void set_irq_handler(uint8_t x, void *handler);

void timer_handler();
void stdin_handler();

uint8_t *kmalloc(uint32_t sz);
