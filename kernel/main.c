#include "print.h"

void main(void) {
  put_str("I am Kernel\n");
  init_all();
  asm volatile("sti");
  while(1);
}
