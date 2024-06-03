// Author: Tancredi-Paul Grozav <paul@grozav.info>
/**
 * @file src/bit_processor.c contains the implementation of the functions that
 * were required. This has to do with bit manipulation and interogation.
 */
#include "bit_processor.h"

//----------------------------------------------------------------------------//
/**
 * @brief this was a first implementation but I realized that I could achieve
 * the same thing with fewer operations. I left this implementation with the
 * explanation just to have another approach.
 */
char bp_is_bit_true_bad(const int value, const char bit_position)
{
  // Let's say we have input:
  //   - value = 90 = ...01011010 base 2
  //   - bit_position = 3
  //
  // Algorithm:
  // 1. Create a bit mask with all zeroes and a 1 at bit_position. That's
  //   created by shifting 1 bit_positions to the left.
  //   mask = 00001000
  // 2. Apply operation & between input value and the mask
  //   value  = 01011010
  //   mask   = 00001000
  //   ----------------- &
  //   result = 00001000
  // The resulting value will contain 0 or 1 at bit_position, depending on
  // the value of the bit in the original, given, value
  // 3. Shift that bit back to the first position in order to return a boolean
  //   prev_result  = 00001000
  //   ----------------------- >> 3
  //   final_result = 00000001
  return (
    (
      value // original value that contains various bits
      & ( 1 << bit_position ) //Create mask and copy in it the value of that bit
    )
    >> bit_position // shift the copied bit back to first position
  ); // final value is all 0 except the first bit from right, which tells us
  // if the bit at bit_position in value was true or not.
}
//----------------------------------------------------------------------------//
char bp_is_bit_true(const int value, const char bit_position)
{
  // Let's say we have input:
  //   - value = 90 = ...01011010 base 2
  //   - bit_position = 3
  //
  // Algorithm:
  // 1. Shift value bit_positions to the right
  //   value = 01011010
  //   ----------------- >> 3
  //   result = 00001011
  // 2. Apply operation & between previous result and 1 (...0001) to check if
  //   the first bit from right is set to true or not.
  //   prev_result  = 00001011
  //   mask = 1     = 00000001
  //   ----------------------- &
  //   final_result = 00000001
  return (
      (value >> bit_position) // original value that contains various bits
      & 1 //Create mask and copy in it the value of that bit
  ); // final value is all 0 except the first bit from right, which tells us
  // if the bit at bit_position in value was true or not.
}
//----------------------------------------------------------------------------//
void bp_set_bit_true(int *value, const char bit_position)
{
  // I'm relying on the developer to pass value != 0(NULL)
  // Adding the verification here would only slow down execution (CPU)
  // I think it's better to check this somewhere up the call-stack

  // Let's say the input values are:
  //   - *value = 2 = ...0010 as binary
  //   - bit_position = 2
  // Expected result= ...0110 as binary
  // Algorithm:
  // 1. Create a bit mask with 1 on the bit_position position. We will use this
  //   mask to copy the 1 in the input *value. The mask is created by shifting
  //   1 bit_positions to the left.
  //   mask = 0100
  // 2. Dereference the pointer value, to get the value from memory, at address
  //   value. We'll use this value later to modify it and put it back in place.
  //   Say value is 0x7fff08ab429c , by dereferencing it we get the value 2.
  // 3. Apply the | operator which will copy the bit from the mask into the
  //   value.
  //   *value = 0010
  //   mask   = 0100
  //   ------------- |
  //   result = 0110
  *value = (
    *value // dereference value
    | ( 1 << bit_position ) // create a bitmask with 1 at bit_position
    // then use this mask to copy the 1 into the *value.
  );
}
//----------------------------------------------------------------------------//
void bp_set_bit_false(int *value, const char bit_position)
{
  // I'm relying on the developer to pass value != 0(NULL)
  // Adding the verification here would only slow down execution (CPU)
  // I think it's better to check this somewhere up the call-stack

  // First thing that came to my mind was:
  // Set 1 in the negative value - but that was too expensive. It uses:
  // 2 negation operations, 1 or(|) operation and a shift operation (total of 4)
//  *value = ~(
//    ~(*value) | (1 << bit_position)
//  );
  // This can be solved by applying the ~ inside the parenthesis which converts
  // operation | into & and negates the two operands ... leading to 3 operations
  // -----
  // Let's say the input values are:
  //   - *value = 10 = ...00001010 we'll represent it as 1010
  //   - bit_position = 3
  // Algorithm:
  // 1. Create a mask with 1 on the bit_position by shifting 1 bit_positions
  //   to the left
  //   mask = 1000
  // 2. Negate the mask
  //   mask          = 1000
  //   -------------------- ~ (negation)
  //   negative_mask = 0111
  // 3. Apply operation & between *value and the negated mask
  //   negative_mask = 0111
  //   value         = 1010
  //   -------------------- &
  //   result        = 0010
  *value = (
    *value & ~(1 << bit_position)
  );
}
//----------------------------------------------------------------------------//
