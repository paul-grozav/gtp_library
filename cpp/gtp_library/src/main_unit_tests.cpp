/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include <gtest/gtest.h>

/**
 * @brief main Entry point for the program.
 * This method is automatically called by the operating system when the binary
 * starts running.
 * @param argc - Number of arguments given to the executable.
 * @param argv - Array of c-string values, representing the values given as a
 * parameter.
 * @return an integer number describing the output status. 0 is used for success
 * and non-zero for describing problems.
 */
int main(int argc, char *argv[])
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
