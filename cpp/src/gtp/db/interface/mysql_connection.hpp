/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
// See list of complete mysql functions offered by mysql C connector at:
// https://dev.mysql.com/doc/refman/5.7/en/c-api-function-overview.html
// Should still add support for:
// - mysql_select_db()
// - mysql_set_character_set()
#ifndef GTP_DB_INTERFACE_MYSQL_CONNECTION_HPP
#define GTP_DB_INTERFACE_MYSQL_CONNECTION_HPP

#include <stddef.h> // NULL
#include "gtp/db/interface/mysql_result_set.hpp"

namespace gtp
{
namespace db
{
namespace interface
{

/**
 * @brief This interface describes a database connection.
 */
class mysql_connection
{
public:
  /**
   * @brief ~mysql_connection destructor.
   */
  virtual ~mysql_connection() = 0;

  /**
   * @brief Initializes object, prepering it for connection.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-init.html
   *
   * @return True if the object was successfully initialized and false
   * otherwise.
   * @note A false return value means that there was not enough memory to
   * initialize the object.
   */
  virtual bool init() = 0;

  /**
   * @brief Attempts to establish a connection to a MySQL database engine
   * running on given host.
   *
   * @note It seems that multiple calls to connect, without calling close, will
   * not lead to memory leaks.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-connect.html
   *
   * @param host - The value of host may be either a host name or an IP address.
   * @param user - Contains the user's MySQL login ID. If user is the empty
   * string "", the current user is assumed.
   * @param passwd - Contains the password for user.
   * @param db - The database name, the connection sets the default database to
   * this value.
   * @param port - The value is used as the port number for the TCP/IP
   * connection. Note that the host parameter determines the type of the
   * connection.
   * @param unix_socket - The string specifies the socket or named pipe to use.
   * Note that the host parameter determines the type of the connection.
   * @param client_flag - Is usually 0, but can be set to a combination of the
   * following flags to enable certain features. See possible values at:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-real-connect.html
   * @return True if and only if the connection was successful, and false
   * otherwise.
   * @note Call init before calling this method.
   */
  virtual bool connect(const char *host, const char *user, const char *passwd,
    const char *db = NULL, unsigned int port = 0,
    const char *unix_socket = NULL, unsigned long client_flag = 0) = 0;

  /**
   * @brief Checks whether the connection to the server is working.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-ping.html
   *
   * @note A nonzero return does not indicate whether the MySQL server
   * itself is down; the connection might be broken for other reasons such as
   * network problems.

   * @return Zero if the connection to the server is active. Nonzero if an error
   * occurred.
   */
  virtual int ping() = 0;

  /**
   * @brief Executes the given SQL statement pointed to by the null-terminated
   * string stmt_str.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-query.html
   *
   * Normally, the string must consist of a single SQL statement without a
   * terminating semicolon (;) or \\g. If multiple-statement execution has been
   * enabled, the string can contain several statements separated by semicolons.
   *
   * @note This method cannot be used for statements that contain binary data;
   * you must use real_query() instead.
   *
   * @param stmt_str - SQL Statement to be executed.
   * @return Zero for success. Nonzero if an error occurred.
   */
  virtual int query(const char *stmt_str) = 0;

  /**
   * @brief  Returns the number of columns for the most recent query on the
   * connection.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-field-count.html
   *
   * @note The normal use of this function is when store_result() returned NULL
   * (and thus you have no result set pointer). In this case, you can call
   * field_count() to determine whether store_result() should have produced a
   * nonempty result. This enables the client program to take proper action
   * without knowing whether the query was a SELECT (or SELECT-like) statement.
   *
   * @return An unsigned integer representing the number of columns in a result
   * set.
   */
  virtual unsigned int field_count() = 0;

  /**
   * @brief Returns the number of rows changed, deleted, or inserted by the last
   * statement if it was an UPDATE, DELETE, or INSERT.
   *
   * @note For SELECT statements, affected_rows() works like num_rows().
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-affected-rows.html
   *
   * @return An integer greater than zero indicates the number of rows affected
   * or retrieved. Zero indicates that no records were updated for an UPDATE
   * statement, no rows matched the WHERE clause in the query or that no query
   * has yet been executed. -1 indicates that the query returned an error or
   * that, for a SELECT query, affected_rows() was called prior to calling
   * store_result().
   *
   * @note Because affected_rows() returns an unsigned value, you can check for
   * -1 by comparing the return value to (unsigned long long)-1 (or to
   * (unsigned long long)~0, which is equivalent).
   */
  virtual unsigned long long affected_rows() = 0;

  /**
   * @brief Closes a previously opened connection. close() also deallocates the
   * connection handle pointed to by mysql if the handle was allocated
   * automatically by init() or connect().
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-close.html
   */
  virtual void close() = 0;

  /**
   * @brief Returns a null-terminated string containing the error message for
   * the most recently invoked API function that failed. If a function did not
   * fail, the return value of error() may be the previous error or an empty
   * string to indicate no error.
   *
   * @note Either of these two tests can be used to check for an error:
   * @code{.cpp}
   * if(*conn.error(&mysql))
   * {
   *   // an error occurred
   * }
   *
   * if(conn.error(&mysql)[0])
   * {
   *   // an error occurred
   * }
   * @endcode
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-error.html
   *
   * @return A null-terminated character string that describes the error. An
   * empty string if no error occurred.
   */
  virtual const char *error() = 0;

  /**
   * @brief Returns the error code for the most recently invoked API function
   * that can succeed or fail. A return value of zero means that no error
   * occurred.
   *
   * @note Client error message numbers are listed in the MySQL errmsg.h header
   * file.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-errno.html
   *
   * @return An error code value for the last method call, if it failed. Zero
   * means no error occurred.
   */
  virtual unsigned int error_number() = 0;

  /**
   * @brief Reads the entire result from the server, to the client.
   *
   * @note This call is synchronous and might block your application/thread
   * until the entire result is downloaded from the server.
   *
   * @note If you do not want to download the entire result at once, you can
   * call method: use_result() which will download one row at a time.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-store-result.html
   *
   * @param result_set - The result object where the result should be stored.
   * @return True if and only if The result set was downloaded successfully from
   * the server. And false if there was an error getting the result set from the
   * server.
   */
  virtual bool store_result(interface::mysql_result_set &result_set) = 0;
};
} // namespace interface
} // namespace db
} // namespace gtp
#endif // GTP_DB_INTERFACE_MYSQL_CONNECTION_HPP
