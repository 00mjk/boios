#include "includes.h"

const char *stdin_map = "\0\27"
                        "1234567890-="
                        "\0\0"
                        "qwertyuiop[]"
                        "\0\0"
                        "asdfghjkl;'`"
                        "\0"
                        "\\zxcvbnm,./"
                        "\0";

void stdin_handler()
{
    uint8_t x = in_byte(0x60);
    if (!(x & 0x80))
        putchar(stdin_map[x & 0x7f]);
}
