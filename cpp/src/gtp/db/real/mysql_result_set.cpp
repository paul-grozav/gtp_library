/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include "gtp/db/real/mysql_result_set.hpp"
namespace gtp
{
namespace db
{
namespace real
{
//----------------------------------------------------------------------------//
mysql_result_set::mysql_result_set() :
  result_set(NULL)
{
}
//----------------------------------------------------------------------------//
mysql_result_set::~mysql_result_set()
{
  // No problem if result_set is NULL, the implementation will only do something
  // if not NULL.
  mysql_free_result (result_set);
}
//----------------------------------------------------------------------------//
void mysql_result_set::init(void *result)
{
  if (result_set == NULL)
  {
    result_set = static_cast< MYSQL_RES* >(result);
  }
  else
  {
    /* do not overwrite result_set, because we would get a memory leak, losing
     * the address of the allocated memory to hold the result. This memory space
     * could be very large.
     */
  }
}
//----------------------------------------------------------------------------//
unsigned long long mysql_result_set::num_rows()
{
  return mysql_num_rows(result_set);
}
//----------------------------------------------------------------------------//
char **mysql_result_set::fetch_row()
{
  return mysql_fetch_row(result_set);
}
//----------------------------------------------------------------------------//
unsigned long *mysql_result_set::fetch_lengths()
{
  return mysql_fetch_lengths(result_set);
}
//----------------------------------------------------------------------------//
}// namespace real
}  // namespace db
}  // namespace gtp
