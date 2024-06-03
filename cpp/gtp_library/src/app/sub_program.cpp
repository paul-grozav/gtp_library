/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include "sub_program.hpp"
namespace app
{
sub_program::sub_program(::std::string n,
  int (*p)(::std::vector< ::std::string > arguments),
  ::std::vector< ::std::string > a)
{
  name = n;
  ptr = p;
  args = a;
}
} // namespace ap
