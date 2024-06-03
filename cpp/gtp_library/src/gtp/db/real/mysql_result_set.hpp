/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_REAL_MYSQL_RESULT_SET_HPP
#define GTP_DB_REAL_MYSQL_RESULT_SET_HPP

#include <mysql.h>

#include "gtp/db/interface/mysql_result_set.hpp"

namespace gtp
{
namespace db
{
namespace real
{

class mysql_connection;

/**
 * @brief This implementation uses MYSQL struct to handle the connection.
 */
class mysql_result_set: public interface::mysql_result_set
{
  /**
   * This class has to be a friend, in order to call the private member init().
   * The init() member has to be private to prevent users from calling it.
   */
  friend class mysql_connection;

  /**
   * @brief MySQL Structure used to hold data received from the database server.
   */
  MYSQL_RES *result_set;

  /**
   * @brief Initializes result object, using the given pointer.
   *
   * @note This method is called by mysql_connection class, when calling
   * store_result(), to set the result into this instance.
   *
   * @note Do not call this method, manually, because once it was called, a
   * second call is ignored. To prevent users from calling this method manually,
   * the method was made private, and this class was made a friend of
   * mysql_connection.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-store-result.html
   *
   * @param result - A mysql result structure ini
   * @note A false return value means that there was not enough memory to
   * initialize the object.
   */
  void init(void *result);

public:
  /**
   * Sets result set pointer to NULL
   */
  mysql_result_set();

  /**
   * Frees result set.
   */
  ~mysql_result_set();

  unsigned long long num_rows();

  char **fetch_row();

  unsigned long *fetch_lengths();

};
} // namespace real
} // namespace db
} // namespace gtp
#endif // GTP_DB_REAL_MYSQL_RESULT_SET_HPP
