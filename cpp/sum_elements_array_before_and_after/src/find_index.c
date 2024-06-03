// Author: Tancredi-Paul Grozav <paul@grozav.info>
/**
 * @file src/find_index.c contains the implementation of the function that
 * was required. This has to do with bit manipulation and interogation.
 */
#include "find_index.h"

//----------------------------------------------------------------------------//
int find_index(const int *elements, const int number_of_elements,
  long long int sum)
{
  // I'm  not checking if elements == 0 to avoid CPU usage

  // I'm relying on the developer that he knows what he is doing, and will
  // not pass a number_of_elements < 1. I'm avoiding this check to save CPU.

  // I'm also not checking if the sum of elements is well calculated, also to
  // avoid CPU usage.

  // sum holds the sum of elements after the current one(starting at 0)
  // sum_before holds the sum of elements before the current one(starting at 0)
  unsigned long long int sum_before = 0;

  // Go through the elements and search for the one.
  for(int i=0; i<number_of_elements; i++)
  {
    // take the current element out of the sum_after
    sum -= elements[i];
    // check if sum_before = sum_after
    if(sum_before == sum)
    {
      // if so, then we found the element
      return i;
    }
    else
    {
      // if not, then add the element to the sum_before and go to the next elem.
      sum_before += elements[i];
    }
  }
  // if not returned from for, it means we did not find such an element so ...
  return -1;
}
//----------------------------------------------------------------------------//
