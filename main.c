#include <stdio.h>
#include <stdint.h>

extern void mutate_region(void*, size_t);
extern void engine_init(int);

#define ENGINE_LIGHT   1
#define ENGINE_HEAVY   2
#define ENGINE_CHAOTIC 3

__attribute__((section(".payload")))
uint8_t payload[] = {
    0x48,0x65,0x6c,0x6c,0x6f
};

int main() {

    engine_init(ENGINE_CHAOTIC);

    printf("Before: ");
    for (int i = 0; i < sizeof(payload); i++)
        printf("%02x ", payload[i]);
    printf("\n");

    mutate_region(payload, sizeof(payload));

    printf("After:  ");
    for (int i = 0; i < sizeof(payload); i++)
        printf("%02x ", payload[i]);
    printf("\n");

    return 0;
}
