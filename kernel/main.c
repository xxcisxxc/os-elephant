#include "print.h"
#include "init.h"

void main(void) {
  put_str("I am Kernel\n");
  init_all();
  asm volatile("sti");
  put_str("Hello\n");
  while(1);
}
