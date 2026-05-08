//----------------------------------------------------------------------------//
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//----------------------------------------------------------------------------//
#ifndef HARDWARE_PIN_HPP
#define HARDWARE_PIN_HPP
#include <functional> // ::std::function
#include "hardware/electric_value.hpp"
//----------------------------------------------------------------------------//
namespace hardware
{
/**
 * A pin is the end of a wire, you send signals through it, to something.
 */
class pin
{
public:
  /**
   * An electric_handler is a pointer to a method that receives a constant
   * electric_value and does something with it, returning nothig.
   */
//  typedef void (*electric_handler)(const electric_value);
  typedef ::std::function<void(const electric_value value)> electric_handler;

  /**
   * Allow creating pins without a handler
   */
  pin();

  /**
   * Create a pin using an electric handler
   * @param[in] handler - The handler of electric charges set to the pin
   */
  pin(const electric_handler handler);

  /* *
   * Virtual destructor
   */
//  virtual ~pin();

  /**
   * Set the electric_value of this pin.
   * @note For now, this is a constant method, indicating that the pin is not
   * changed by the fact that we apply an electric_value to it. But maybe in
   * time we will change this.
   * @param[in] value - Electric value received by the pin
   */
  void set_value(const electric_value value) const;

  /**
   * Set a handler for electric_values.
   * @param[in] handler - The handler of electric charges set to the pin
   */
  void set_handler(const electric_handler handler);

  /**
   * Set the destination pin that will receive the electric_value that is
   * set on this pin.
   * @param[in] destination - Pin that will receive the electic_value that
   * is applied on this pin.
   */
  void set_destination(const pin &destination);

  /**
   * This method simply calls the electric_handler if it is set, giving it
   * the electric_value received.
   * @param[in] value - The electric value received from a remote pin
   */
  void handle_value(const electric_value value) const;

private:
  /**
   * Will handle electric_values.
   */
  electric_handler handler{nullptr};

  /**
   * Destination pin that will receive the electric_values set to this one.
   */
  pin const *destination{nullptr};
};
}
//----------------------------------------------------------------------------//
#endif // HARDWARE_PIN_HPP
