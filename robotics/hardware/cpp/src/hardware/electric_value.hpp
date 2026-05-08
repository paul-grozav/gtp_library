//----------------------------------------------------------------------------//
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//----------------------------------------------------------------------------//
#ifndef HARDWARE_ELECTRIC_VALUE_HPP
#define HARDWARE_ELECTRIC_VALUE_HPP
//----------------------------------------------------------------------------//
namespace hardware
{
/**
 * The electric_value is a boolean indicating if there is a current flow on
 * the wire or not.
 * We might change this later to something like a char, indicating the magnitude
 * of the electic tension.
 */
typedef bool electric_value;
}
//----------------------------------------------------------------------------//
#endif // HARDWARE_ELECTRIC_VALUE_HPP
