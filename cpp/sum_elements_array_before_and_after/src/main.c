// Author: Tancredi-Paul Grozav <paul@grozav.info>
/**
 * @file src/main.c contains the application that was requested. This file
 * handles the interface(stdin,stdout) with the user and calls bit processing
 * functions.
 *
 * @mainpage Array Numbers
 * The purpose of this project is to read an integer of elements, then read the
 * integer elements into an array, and at the end print the index of the element
 * that has the property that the sum of elements before it is equal with the
 * sum of elements after it.
 *
 * To implement this I will calculate the sum of elements, while reading them
 * and putting them in the array. Then, I will pass the array and the sum to
 * a method that will determine and return the required index. If such an index
 * is not found, the method should return -1.
 *
 * I'm creating this method to be able to test the algorithm that finds the
 * index, using different values in the array.
 *
 * If the method will return -1 if the index was not found, it means that it
 * will return an integer, therefore using only half of the range for actual
 * index values. Therefore the maximum value that I could return in an integer
 * is 2147483647(2^31 -1). I have to set this limit so that I can return -1.
 *
 * There would be another alternative. I could have the function return an
 * unsigned integer (the actual index) and then have an extra output parameter
 * to the function saying if such an index was found or not. I will not go with
 * this approach because it uses more memory for that extra variable and I think
 * 2^31 -1 elements are ehough for this example.
 *
 *   - @ref find_index
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
number of elements (1 to 2^31 -1) = 3
Please make sure that the sum of integers does not overflow a long long int.
integers[0]=1
integers[1]=2
integers[2]=1
Found index at position 1.
pgrozav:bin>./main
number of elements (1 to 2^31 -1) = 2
Please make sure that the sum of integers does not overflow a long long int.
integers[0]=1
integers[1]=-1
Could not find such an index.
 * @endcode
 *
 * @author Tancredi-Paul Grozav &lt;paul@grozav.info&gt;
 */
#include <stdio.h> // for printf() and scanf()
#include <stdlib.h> // for malloc()
#include "find_index.h"

//----------------------------------------------------------------------------//
/**
 * Will ask for an integer from stdin and then read the integer numbers.
 * Then print the index if found.
 * @return Exit code possible values:
 *   - 0 if the program terminated successfully
 *   - 1 if an invalid number of elements was read from stdin.
 *   - 2 if we can not allocate enough memory for integers.
 */
int main()
{
  // Read user given integer value
  printf("number of elements (1 to 2^31 -1) = ");
  int value = 0; // holds user given integer value
  scanf("%d", &value);
  if(value < 1)
  {
    printf("Really?! Next time, give me a valid value!\n");
    return 1;
  }

  // Alocate memory for integers or exit 2
  int *integers = (int*)malloc(value * sizeof(int));//returns void*
  if(integers == 0)
  {
    printf("ERROR: Can not allocate memory for %d integers.\n", value);
    // nothing to free, because nothing was allocated(on heap).
    return 2;
  }

  // Read integers
  long long int sum = 0;
  printf("Please make sure that the sum of integers does not overflow "
    "a long long int.\n");
  for(int i=0; i<value; i++)
  {
    printf("integers[%d]=", i);
    scanf("%d", &integers[i]);
    // THIS COULD BE A PROBLEM!
    // we can't really protect agains sum overflow because integers can be
    // negative
//    if(sum > (sum + integers[i])
//    {
//      free(integers);
//      printf("ERROR: Sum of integers is too big. Overflow.");
//      return 3;
//    }
    sum += integers[i]; // calculate sum now, while reading integers
    // this helps by only having to go through the elements once to search the
    // index
  }

  int index = find_index(integers, value, sum);
  if(index == -1)
  {
    printf("Could not find such an index.\n");
  }
  else
  {
    printf("Found index at position %d.\n", index);
  }
  free(integers);
  return 0;
}
//----------------------------------------------------------------------------//
