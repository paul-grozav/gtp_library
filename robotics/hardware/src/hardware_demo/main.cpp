//----------------------------------------------------------------------------//
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//----------------------------------------------------------------------------//
#include <cstdlib> // EXIT_SUCCESS
#include <iostream>

#include "hardware/pin.hpp"

using namespace ::std;
using namespace ::hardware;

namespace hardware_demo
{
//----------------------------------------------------------------------------//
void handler(const electric_value value)
{
  cout << "got electric_value=" << (value ? "true" : "false") << endl;
}
//----------------------------------------------------------------------------//
int run(int argc, char** argv)
{
  pin in_pin;
  in_pin.set_handler(&handler);
//  in_pin.handle_value(v);

  pin out_pin;
  out_pin.set_destination(in_pin);
  out_pin.set_value(false); // calls handle_value on in_pin

  return EXIT_SUCCESS;
}
//----------------------------------------------------------------------------//
} // hardware_demo
//----------------------------------------------------------------------------//
int main(int argc, char** argv)
{
  return hardware_demo::run(argc, argv);
}
//----------------------------------------------------------------------------//
