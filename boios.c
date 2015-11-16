#include "includes.h"

void thread1()
{
    for (;;)
        hlt();
}

void boios_main2()
{
    tid_t t = thread_create(thread1);
    for (;;)
    {
        puts("boios_main2()\n");
        sleep_ms(1000);
    }
}
void boios_main()
{
    cls();
    set_irq_handler(0, timer_handler);
    set_irq_handler(1, stdin_handler);
    threads_init();
    sti();
    boios_main2();
}