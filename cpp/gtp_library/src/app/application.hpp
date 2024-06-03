/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef APP_APPLICATION_HPP
#define APP_APPLICATION_HPP
#include <vector>
#include "app/sub_program.hpp"
namespace app
{
/**
 * @brief sub_programs Will be populated by each CPP that links into the
 * executable. The main function of the executable will start all these
 * subprograms.
 */
extern ::std::vector< ::app::sub_program > sub_programs;

/**
 * @brief The entry point to the application.
 */
class application
{
public:
  /**
   * @brief Start the application.
   * @param argc - Number of arguments given to the executable.
   * @param argv - Array of c-string values, representing the values given as a
   * parameter.
   * @return an integer number describing the output status. 0 is used for
   * success and non-zero for describing problems.
   */
  int run(int argc, char *argv[]);
};
} // namespace app
#endif // APP_APPLICATION_HPP
