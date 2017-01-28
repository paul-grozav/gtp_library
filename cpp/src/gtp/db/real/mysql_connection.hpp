/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_REAL_MYSQL_CONNECTION_HPP
#define GTP_DB_REAL_MYSQL_CONNECTION_HPP

#include <mysql.h>

#include "gtp/db/interface/mysql_connection.hpp"

namespace gtp
{
namespace db
{
namespace real
{

/**
 * @brief This implementation uses MYSQL struct to handle the connection.
 */
class mysql_connection: public interface::mysql_connection
{
  /**
   * @brief MySQL Structure used to hold information about connection.
   */
  MYSQL conn;

  /**
   * @brief True if conn was initialized successfully. This happens during
   * constructor. If this is true, at destruction time, close will be called and
   * memory will be freed.
   */
  bool is_initialized;

  /**
   * @note Private because it will be called automatically by constructor. We
   * do not want the user to call it, because a memory leak will occur.
   */
  bool init();

public:
  /**
   * @brief Calls init and sets is_initialized.
   */
  mysql_connection();

  /**
   * If is_initialized is true, calls close.
   */
  ~mysql_connection();

  bool connect(const char *host, const char *user, const char *passwd,
    const char *db = NULL, unsigned int port = 0,
    const char *unix_socket = NULL, unsigned long client_flag = 0);

  int ping();

  int query(const char *stmt_str);

  unsigned int field_count();

  unsigned long long affected_rows();

  void close();

  const char *error();

  unsigned int error_number();

  /**
   * @note Reads the entire result of a query to the client, allocates a
   * MYSQL_RES structure, and places the result into this structure.
   */
  bool store_result(interface::mysql_result_set &result_set);
};
} // namespace real
} // namespace db
} // namespace gtp
#endif // GTP_DB_REAL_MYSQL_CONNECTION_HPP
