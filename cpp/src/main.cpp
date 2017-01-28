/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include "app/application.hpp"

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
int main(int argc, char**argv)
{
  ::app::application a;
  return a.run(argc, argv);
}

//----------------------------------------------------------------------------//
// Doxygen first page documentation
//----------------------------------------------------------------------------//
/**
 * @mainpage
 * @author Tancredi-Paul Grozav &lt;paul@grozav.info&gt;
 * @copyright
 * <b>License:</b> M.I.T. License. See the LICENSE file in this project.
 */
//----------------------------------------------------------------------------//
// Namespace documentation
//----------------------------------------------------------------------------//
/**
 * Application definitions and contents.
 */
namespace app
{
//----------------------------------------------------------------------------//
/**
 * Example applications.
 */
namespace applications
{
}
//----------------------------------------------------------------------------//
/**
 * Unit tests.
 */
namespace tests
{
}
//----------------------------------------------------------------------------//
}
//----------------------------------------------------------------------------//
