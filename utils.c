#include "includes.h"

void memcpy(void *dest, void *src, uint32_t count)
{
    uint8_t *sp = (uint8_t *)src;
    uint8_t *dp = (uint8_t *)dest;
    for (; count != 0; count--)
        *dp++ = *sp++;
}

uint8_t in_byte(uint16_t _port)
{
    uint8_t rv;
    asm __volatile__("inb %1, %0"
                     : "=a"(rv)
                     : "dN"(_port));
    return rv;
}

void out_byte(uint16_t _port, uint8_t _data)
{
    asm __volatile__("outb %1, %0"
                     :
                     : "dN"(_port), "a"(_data));
}
