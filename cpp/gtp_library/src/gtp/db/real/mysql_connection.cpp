/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include "gtp/db/real/mysql_connection.hpp"
#include "gtp/db/real/mysql_result_set.hpp"
namespace gtp
{
namespace db
{
namespace real
{
//----------------------------------------------------------------------------//
mysql_connection::mysql_connection()
{
  is_initialized = init(); // allocates memory
}
//----------------------------------------------------------------------------//
mysql_connection::~mysql_connection()
{
  if (is_initialized)
  {
    close(); // free memory allocated in constructor
  }
}
//----------------------------------------------------------------------------//
bool mysql_connection::init()
{
  MYSQL *ret = mysql_init(&conn);
  if (ret == NULL)
  {
    // could not initialize. Probably because there was insufficient memory to
    // allocate a new object.
    return false;
  }
  else
  {
    // ret is the same as &conn. A pointer to the same initialized instance.
    return true;
  }
}
//----------------------------------------------------------------------------//
bool mysql_connection::connect(const char *host, const char *user,
  const char *passwd, const char *db, unsigned int port,
  const char *unix_socket, unsigned long client_flag)
{
  MYSQL *connection_attempt = mysql_real_connect(&conn, host, user, passwd, db,
    port, unix_socket, client_flag);
  if (connection_attempt == NULL)
  {
    // Could not connect
    return false;
  }
  else
  {
    // Connection successful.
    return true;
  }
}
//----------------------------------------------------------------------------//
int mysql_connection::ping()
{
  return mysql_ping(&conn);
}
//----------------------------------------------------------------------------//
int mysql_connection::query(const char *stmt_str)
{
  return mysql_query(&conn, stmt_str);
}
//----------------------------------------------------------------------------//
unsigned int mysql_connection::field_count()
{
  return mysql_field_count(&conn);
}
//----------------------------------------------------------------------------//
unsigned long long mysql_connection::affected_rows()
{
  return mysql_affected_rows(&conn);
}
//----------------------------------------------------------------------------//
void mysql_connection::close()
{
  mysql_close (&conn);
}
//----------------------------------------------------------------------------//
const char *mysql_connection::error()
{
  return mysql_error(&conn);
}
//----------------------------------------------------------------------------//
unsigned int mysql_connection::error_number()
{
  return mysql_errno(&conn);
}
//----------------------------------------------------------------------------//
bool mysql_connection::store_result(interface::mysql_result_set &result_set)
{
  // Get result from server
  MYSQL_RES *result = mysql_store_result(&conn);

  // Set it into mysql_result_set
  mysql_result_set& r = dynamic_cast< mysql_result_set& >(result_set);
  r.init(result);

  // Return bool
  if (result == NULL)
  {
    // an error occurred while reading/downloading the result from server.
    return false;
  }
  else
  {
    // Result set read completed. Might have zero or more rows inside.
    return true;
  }
}
//----------------------------------------------------------------------------//
}// namespace real
}    // namespace db
}    // namespace gtp
