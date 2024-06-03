// Author: Tancredi-Paul Grozav <paul@grozav.info>
// Function for finding index of element that has the property that the sum
// of elements before it is equal with the sum of elements after it.
/**
 * @file inc/find_index.h contains the function that implements the requirement
 * for this project.
 */
//----------------------------------------------------------------------------//
/**
 * @brief Returns the index of element that has the property that the sum of
 * elements before it is equal with the sum of elements after it.
 * You can see more details about the implementation in the implementation.
 * @param[in] elements - Array of integer elements that we search through.
 * @param[in] number_of_elements - integer number of elements
 * @param[in] sum - A copy of the sum. This variable is modified through the
 *   algorithm.
 * @note Warning! : The elements pointer must be not null
 * @note Warning! : The number_of_elements should be > 0. We don't check this
 * in the implementation to avoid CPU usage. I'm relying on the developer, that
 * he knows what he's doing.
 * @note Warning! : The given sum is taken for granted, we don't verify it.
 * if you pass an invalid value, use at your own risk.
 * @return -1 if such an element is not found and an integer between 0 and
 * 2^31 -1 (representing the index we're looking for) if such an element was
 * found. Also return -1 if number_of_elements <= 0
 */
int find_index(const int *elements, const int number_of_elements,
  long long int sum);
//----------------------------------------------------------------------------//
