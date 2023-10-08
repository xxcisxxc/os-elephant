#include "init.h"
#include "memory.h"
#include "print.h"
#include "stdint.h"
#include "thread.h"

void k_thread_a(void *);

int main(void) {
  put_str("I am Kernel\n");
  init_all();
  // asm volatile("sti");

  void *addr = get_kernel_pages(3);
  put_str("\nget_kernel_page start vaddr is ");
  put_int((uint32_t)addr);
  put_str("\n");

  thread_start("k_thread_a", 31, k_thread_a, "argA ");

  while (1)
    ;
  return 0;
}

void k_thread_a(void *arg) {
  char *para = arg;
  put_str(para);
}
