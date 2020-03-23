// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
// these are meant for debugging. Not optimized for speed.
// -------------------------------------------------------------------------- //
#include <string>
#include <sstream>
// -------------------------------------------------------------------------- //
using namespace ::std;
// -------------------------------------------------------------------------- //
namespace gtp
{
  void debugging_utils__wrapper()
  {
// -------------------------------------------------------------------------- //
    // convert string to list of ascii codes
    auto str_to_u8_list = [&](const string &s) -> string
    {
      const size_t s_size = s.size();
      stringstream ss;
      ss << "[";
      for(size_t i=0; i<s_size; i++)
      {
        ss << static_cast<unsigned int>(static_cast<unsigned char>(s.at(i)));
        if(i+1 < s_size)
        {
          ss << ", ";
        }
      }
      ss << "]";
      return ss.str();
    };
    str_to_u8_list = str_to_u8_list; // avoid warning "set but not used"
// -------------------------------------------------------------------------- //
  }
} // namespace gtp
// -------------------------------------------------------------------------- //
