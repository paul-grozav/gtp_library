/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef APP_SUB_PROGRAM_HPP
#define APP_SUB_PROGRAM_HPP
#include <string>
#include <vector>
namespace app
{
/**
 * @brief The sub_program class describes a sub program.
 */
class sub_program
{
public:
  /**
   * Sub program name, a string describing it.
   */
  ::std::string name;

  /**
   * Pointer to the main function of that subprogram.
   */
  int (*ptr)(::std::vector< ::std::string > arguments);

  /**
   * Arguments to be passed when calling main function.
   */
  ::std::vector< ::std::string > args;

  /**
   * Constructor used to initialize the structure with values.
   */
  sub_program(::std::string name,
    int (*ptr)(::std::vector< ::std::string > arguments),
    ::std::vector< ::std::string > args);
};

// So that it's accessible for any sub_program
extern ::std::vector< sub_program > sub_programs;

/*
 * Macro for registering sub programs. Addin them to the vector, so that they
 * are ran when the executable starts.
 */
#define REGISTER_SUB_PROGRAM(NAME, POINTER, ...)\
  bool add_main_##NAME() {\
    sub_programs.push_back(sub_program(#NAME, POINTER, {__VA_ARGS__}));\
    return true;\
  }\
  static bool bool_add_main_##NAME = add_main_##NAME();
} // namespace app
#endif // APP_SUB_PROGRAM_HPP
