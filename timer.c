#include "includes.h"

volatile uint32_t time_ms = 0;
void sleep_ms(uint32_t ms)
{
    ms += time_ms;
    while (time_ms < ms)
        asm("hlt");
}
void timer_handler()
{
    time_ms++;
    threads_do();
}
