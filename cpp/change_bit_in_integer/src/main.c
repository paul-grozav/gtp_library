// Author: Tancredi-Paul Grozav <paul@grozav.info>
// Exit codes:
//   - 0 = Program terminated successfully
//   - 1 = Invalid bit position

/**
 * @file src/main.c contains the application that was requested. This file
 * handles the interface(stdin,stdout) with the user and calls bit processing
 * functions.
 *
 * @mainpage Bit Processor
 * Methods required and defined in this project:
 *   - @ref bp_is_bit_true
 *   - @ref bp_set_bit_true
 *   - @ref bp_set_bit_false
 *
 * You can also check the @link unit_tests.c unit tests @endlink and @link
 * main.c the main file @endlink.
 *
 * The project was created and compiled on Linux using nano, CMake, Make,
 * doxygen and GCC.
 * The project is written in C (not C++).
 *
 * Example of running the program:
 * @code{.sh}
pgrozav:bin>cmake .. -Dbuild_unit_tests=ON && make # Compile project
pgrozav:bin>./unit_tests
All tests passed.
pgrozav:bin>./main
integer = 4
bit_position(first one from right is number 0) = 1
Inside integer value=4, the bit at position 1 has a value of 0.
Setting bit at position 1 to 1.
Inside integer value=6, the bit at position 1 has a value of 1.
Setting bit at position 1 to 0.
Inside integer value=4, the bit at position 1 has a value of 0.
 * @endcode
 *
 * @author Tancredi-Paul Grozav &lt;paul@grozav.info&gt;
 */
#include <stdio.h> // for printf() and scanf()
#include "bit_processor.h"

// Size of byte in bits (usually 8)
#define BITS_IN_BYTE 8

//----------------------------------------------------------------------------//
/**
 * Will ask for an integer from stdin and the position of the bit that will be
 * verified and then changed.
 * @return 0 if the program terminated successfully and 1 if an invalid bit was
 * read from stdin.
 */
int main()
{
  // Read user given integer value
  printf("integer = ");
  int value = 0; // holds user given integer value
  scanf("%d", &value);

  // Read position of bit in smallest numeric data type
  unsigned char bit_position = 0;
  printf("bit_position(first one from right is number 0) = ");
  scanf("%hhu", &bit_position);
  if(bit_position >= sizeof(int) * BITS_IN_BYTE)
  {
    printf("ERROR: An integer(int) value only has %d bits on this architecture"
      ".\n", sizeof(int) * BITS_IN_BYTE);
    return 1;
  }

  // Print original value
  printf("Inside integer value=%d, the bit at position"
    " %d has a value of %d.\n", value, bit_position,
    bp_is_bit_true(value, bit_position));

  // Set to 1 and print value
  printf("Setting bit at position %d to 1.\n", bit_position);
  bp_set_bit_true(&value, bit_position);
  printf("Inside integer value=%d, the bit at position"
    " %d has a value of %d.\n", value, bit_position,
    bp_is_bit_true(value, bit_position));

  // Set to 0 and print value
  printf("Setting bit at position %d to 0.\n", bit_position);
  bp_set_bit_false(&value, bit_position);
  printf("Inside integer value=%d, the bit at position"
    " %d has a value of %d.\n", value, bit_position,
    bp_is_bit_true(value, bit_position));

  return 0;
}
//----------------------------------------------------------------------------//
