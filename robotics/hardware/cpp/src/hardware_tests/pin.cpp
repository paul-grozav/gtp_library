//----------------------------------------------------------------------------//
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//----------------------------------------------------------------------------//
#include <gtest/gtest.h>
#include <hardware/pin.hpp>

using namespace ::hardware;

namespace hardware_tests
{
void handler(const electric_value value){}
TEST(pin, in_out)
{
  electric_value v = true;

  pin in_pin;
  in_pin.set_handler([&](const electric_value value) {
    v = value;
  });

  pin out_pin;
  out_pin.set_destination(in_pin);
  out_pin.set_value(false); // calls handle_value() on in_pin

  EXPECT_EQ(v, false);
}
} // namespace hardware_tests
