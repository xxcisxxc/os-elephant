#include "init.h"
#include "memory.h"
#include "print.h"
#include <stdint.h>

int main(void) {
  put_str("I am Kernel\n");
  init_all();
  // asm volatile("sti");

  void *addr = get_kernel_pages(3);
  put_str("\nget_kernel_page start vaddr is ");
  put_int((uint32_t)addr);
  put_str("\n");

  while (1)
    ;
  return 0;
}
