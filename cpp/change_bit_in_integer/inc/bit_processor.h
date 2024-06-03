// Author: Tancredi-Paul Grozav <paul@grozav.info>
// Functions for bit-processing integer values.
// Prefixed with "bp_" to avoid name conflict.
/**
 * @file inc/bit_processor.h contains the functions that were required in this
 * project.
 */
//----------------------------------------------------------------------------//
/**
 * @brief Returns the value of bit at bit_position in the given value.
 * You can see more details about the implementation in the implementation.
 * @param[in] value - The integer value from which we will read the bit value
 * @param[in] bit_position - The bit number, from right to left, counting from 0
 * @return 1 if the bit has a value of true, and 0 it the bit is set to false.
 */
char bp_is_bit_true(const int value, const char bit_position);
//----------------------------------------------------------------------------//
/**
 * @brief Inside value, set bit at position bit_position to true(1).
 * @param[in,out] value - Pointer to the integer value that is modified by
 * modifying the bit at position bit_position, by setting it to true(1).
 * @param[in] bit_position - The position of the bit that will be set to true
 * @note Warning! : Pointer value must be not null.
 */
void bp_set_bit_true(int *value, const char bit_position);
//----------------------------------------------------------------------------//
/**
 * @brief Inside value, set bit at position bit_position to false(0).
 * @param[in,out] value - Pointer to the integer value that is modified by
 * modifying the bit at position bit_position, by setting it to false(0).
 * @param[in] bit_position - The position of the bit that will be set to false.
 * @note Warning! : Pointer value must be not null.
 */
void bp_set_bit_false(int *value, const char bit_position);
//----------------------------------------------------------------------------//
