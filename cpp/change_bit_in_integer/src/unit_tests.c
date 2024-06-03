// Author: Tancredi-Paul Grozav <paul@grozav.info>
// Exit codes:
//   - 0 = All tests passed.
//   - 1 = At least one test failed
/**
 * @file src/unit_tests.c contains the application that runs a series of
 * automated tests on the bit processing functions.
 */
#include <stdio.h> // for printf()
#include "bit_processor.h" // subject of test

// Macros for setting test expectations
#define EXPECT_TRUE(expr) if(!(expr)) return 1;
#define EXPECT_FALSE(expr) if(expr) return 1;

//----------------------------------------------------------------------------//
/**
 * Runs a series of automated tests on bit_processor
 * @return 0 if and only if all tests passed. It returns 1 if at least one test
 * failed.
 */
int run_tests()
{
  int value = 1;

  // ----- Test function bp_is_bit_true ----- //
  // ...0001
  EXPECT_TRUE(bp_is_bit_true(value, 0));
  EXPECT_FALSE(bp_is_bit_true(value, 1));

  // ...0010
  value = 1<<1;
  EXPECT_FALSE(bp_is_bit_true(value, 0));
  EXPECT_TRUE(bp_is_bit_true(value, 1));
  EXPECT_FALSE(bp_is_bit_true(value, 2));

  // ...0011
  value = (1<<1) | 1;
  EXPECT_TRUE(bp_is_bit_true(value, 0));
  EXPECT_TRUE(bp_is_bit_true(value, 1));
  EXPECT_FALSE(bp_is_bit_true(value, 2));

  // ...0100
  value = 4;
  EXPECT_FALSE(bp_is_bit_true(value, 0));
  EXPECT_FALSE(bp_is_bit_true(value, 1));
  EXPECT_TRUE(bp_is_bit_true(value, 2));
  EXPECT_FALSE(bp_is_bit_true(value, 3));
  // --- End test function bp_is_bit_true --- //

  // ----- Test function bp_set_bit_true ----- //
  // ...0000 -> ...0001
  value = 0;
  EXPECT_FALSE(bp_is_bit_true(value, 0));
  bp_set_bit_true(&value, 0);
  EXPECT_TRUE(bp_is_bit_true(value, 0));
  EXPECT_TRUE(value == 1);

  // ...0000 -> ...0100
  value = 0;
  EXPECT_FALSE(bp_is_bit_true(value, 2));
  bp_set_bit_true(&value, 2);
  EXPECT_TRUE(bp_is_bit_true(value, 2));
  EXPECT_TRUE(value == 4);

  // ...1000 -> ...1000
  value = 8;
  EXPECT_TRUE(bp_is_bit_true(value, 3));
  bp_set_bit_true(&value, 3);
  EXPECT_TRUE(bp_is_bit_true(value, 3));
  EXPECT_TRUE(value == 8);
  // --- End test function bp_set_bit_true --- //

  // ----- Test function bp_set_bit_false ----- //
  // ...0001 -> ...0000
  value = 1;
  EXPECT_TRUE(bp_is_bit_true(value, 0));
  bp_set_bit_false(&value, 0);
  EXPECT_FALSE(bp_is_bit_true(value, 0));
  EXPECT_TRUE(value == 0);

  // ...0100 -> ...0000
  value = 4;
  EXPECT_TRUE(bp_is_bit_true(value, 2));
  bp_set_bit_false(&value, 2);
  EXPECT_FALSE(bp_is_bit_true(value, 2));
  EXPECT_TRUE(value == 0);

  // ...1000 -> ...1000
  value = 8;
  EXPECT_FALSE(bp_is_bit_true(value, 2));
  bp_set_bit_false(&value, 2);
  EXPECT_FALSE(bp_is_bit_true(value, 2));
  EXPECT_TRUE(value == 8);
  // --- End test function bp_set_bit_false --- //

  return 0;// success
}
//----------------------------------------------------------------------------//
/**
 * Runs the tests and prints a message on stdout
 * @return 0 if and only if all tests passed. It returns 1 if at least one test
 * failed.
 */
int main()
{
  if(run_tests())
  {
    printf("At least one test failed.\n");
    return 1;
  }
  else
  {
    printf("All tests passed.\n");
    return 0;
  }
}
//----------------------------------------------------------------------------//
