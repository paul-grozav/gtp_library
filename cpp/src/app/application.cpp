/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include <iostream>
#include "app/application.hpp"
using namespace ::std;
using namespace ::app;

namespace app
{
//----------------------------------------------------------------------------//
::std::vector< ::app::sub_program > sub_programs;
//----------------------------------------------------------------------------//
int application::run(int argc, char *argv[])
{
  cout << "GTP_CPP_Library example applications." << endl;
  cout << sub_programs.size() << " applications registered." << endl;

  for (sub_program & program : sub_programs)
  {
    cout << "=== Running application: " << program.name << " ===" << endl;
    program.ptr(program.args);
  }
  return EXIT_SUCCESS;
}
//----------------------------------------------------------------------------//
}// namespace app
