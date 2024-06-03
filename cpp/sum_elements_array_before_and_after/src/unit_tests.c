// Author: Tancredi-Paul Grozav <paul@grozav.info>
// Exit codes:
//   - 0 = All tests passed.
//   - 1 = At least one test failed
/**
 * @file src/unit_tests.c contains the application that runs a series of
 * automated tests on the find_index function.
 */
#include <stdio.h> // for printf()
#include "find_index.h" // subject of test

// Macros for setting test expectations
#define EXPECT_TRUE(expr) if(!(expr)) return 1;
#define TEST(count, sum, expected_index, ...){\
  int e[count] = {__VA_ARGS__};\
  if(find_index(e, count, sum) != expected_index) return 1;\
}

//----------------------------------------------------------------------------//
/**
 * Runs a series of automated tests on find_index
 * @return 0 if and only if all tests passed. It returns 1 if at least one test
 * failed.
 */
int run_tests()
{
  // using stack is easier in this case
  int elements[3] = {1,58,1};
  // 3 elements, with sum 60, expected returned index is 1
  EXPECT_TRUE(find_index(elements, 3, 60) == 1);

  //   count  sum           expected_index   elements
  TEST(5,     6,            2,               1,-2,8,-2,1);
  TEST(3,     3,            1,               1,1,1);
  TEST(1,     1,            0,               1);
  TEST(5,     -9,           2,               -1,-3,-1,-2,-2);
  TEST(5,     9,            2,               1,2,3,2,1);
  TEST(3,     2000000000,   1,               1000000000,0,1000000000);
  TEST(2,     7,            -1,              3,4);
  TEST(3,     0,            -1,              -1,0,1);

  // This proves that the function find_index does not verify the sum
  // This is OK, because this was not a requirement. The requirement
  // was to have the main application do things a certain way. And
  // things were done as required in main, because the sum is calculated
  // correctly.
  TEST(3,     2,            1,               1,0,2);

  // The method does not verify the count either, we expect it to be >0
  // else, we return -1
//  TEST(0,     0,            -1,              );
  EXPECT_TRUE(find_index(0, 0, 0) == -1);
//  TEST(-1,    99,           -1,              );
  EXPECT_TRUE(find_index(0, -1, 99) == -1);

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
