#include <iostream>
#include "SampleClass.h"

int main(int argc, char *argv[])
{
  std::cout << "Hello World" << std::endl;

  SampleClass sample;
  sample.setValue(100);
  std::cout << "value = " << sample.getValue() << std::endl;

  return 0;
}
