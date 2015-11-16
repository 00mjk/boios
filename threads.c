#include "includes.h"

volatile tid_t current;
void regs_init(tid_t x, void *main)
{
    regs_t *r = &regs[x];
    r->gs = 0x08;
    r->fs = 0x08;
    r->es = 0x08;
    r->ds = 0x08;
    r->edi = 0;
    r->esi = 0;
    r->ebp = 0;
    uint32_t *stack = (uint32_t *)kmalloc(THREAD_STACK_SZ);
    //stack[sizeof(thread_t)] = (uint32_t)args;
    r->esp = (uint32_t)(stack + THREAD_STACK_SZ);
    r->ebx = 0;
    r->edx = 0;
    r->ecx = 0;
    r->eax = 0;
    r->eip = (uint32_t)main;
    r->cs = 0x08;
    r->eflags = 0x0202;
    r->esp2 = 0;
    r->ss = 0x08;
    thread_dump(x);
}
tid_t thread_create(void *main)
{
    cli();
    uint32_t x = 0;
    thread_t *t, *cur;
    while (x <= 255)
    {
        t = &threads[x];
        if (t->state == 0)
        {
            t->state = 1;
            regs_init(x, main);
            cur = &threads[current];
            t->next = cur->next;
            cur->next = x;
            //die("aa");
            sti();
            return x;
        }
        x++;
    }
    die("max threads reached.");
}
extern void save_stack(uint8_t *x);
extern void load_stack(uint8_t *x);
void threads_do()
{
    //save_stack(&thread_main);
    //thread_dump(current);
    //thread_dump(current->next);
    //die();
    //current = current->next;
    //load_stack(&(current->r));
}
void threads_init()
{
    thread_t *t = &threads[0];
    t->next = 0;
    t->state = 1;
    current = 0;
    thread_dump(0);
    die("a");
}
void thread_dump(tid_t x)
{
    thread_t *t = &threads[x];
    printf("thread_dump id=%d next.id=%d\n", x, t->next);
    regs_t *r = &regs[x];
    printf("cs=%x ds=%x ss=%x es=%x fs=%x gs=%x\n"
           "eip=%x eflags=%x esp=%x ebp=%x esp2=%x\n"
           "eax=%x ebx=%x ecx=%x edx=%x esi=%x edi=%x\n",
           r->cs, r->ds, r->ss, r->es, r->fs, r->gs,
           r->eip, r->eflags, r->esp, r->ebp, r->esp2,
           r->eax, r->ebx, r->ecx, r->edx, r->esi, r->edi);
}
