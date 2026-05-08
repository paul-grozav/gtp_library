//----------------------------------------------------------------------------//
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//----------------------------------------------------------------------------//
#include "hardware/pin.hpp"

namespace hardware
{
//----------------------------------------------------------------------------//
pin::pin()
{
}
//----------------------------------------------------------------------------//
pin::pin(const electric_handler handler):
  handler(handler)
{
}
//----------------------------------------------------------------------------//
//pin::~pin()
//{
//}
//----------------------------------------------------------------------------//
void pin::handle_value(const electric_value value) const
{
  handler(value);
}
//----------------------------------------------------------------------------//
void pin::set_handler(const electric_handler handler)
{
  this->handler = handler;
}
//----------------------------------------------------------------------------//
void pin::set_destination(const pin& destination)
{
  this->destination = &destination;
}
//----------------------------------------------------------------------------//
void pin::set_value(const electric_value value) const
{
  if(destination == nullptr)
  {
    return;
  }
  destination->handle_value(value);
}
//----------------------------------------------------------------------------//
} // namespace hardware
