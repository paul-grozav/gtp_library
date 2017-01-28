/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include <mysql.h>

#include "gtp/db/real/mysql_driver.hpp"
namespace gtp
{
namespace db
{
namespace real
{
//----------------------------------------------------------------------------//
bool mysql_driver_is_initialized = mysql_driver::initialize();
//----------------------------------------------------------------------------//
mysql_driver::mysql_driver()
{
  mysql_library_init(0, NULL, NULL);
}
//----------------------------------------------------------------------------//
mysql_driver::~mysql_driver()
{
  mysql_library_end();
}
//----------------------------------------------------------------------------//
mysql_driver& mysql_driver::get()
{
  static mysql_driver driver;
  return driver;
}
//----------------------------------------------------------------------------//
bool mysql_driver::initialize()
{
  mysql_driver::get();
  return true;
}
//----------------------------------------------------------------------------//
}// namespace real
} // namespace db
} // namespace gtp
