/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_REAL_MYSQL_DRIVER_HPP
#define GTP_DB_REAL_MYSQL_DRIVER_HPP

#include <mysql.h>

namespace gtp
{
namespace db
{
namespace real
{

/**
 * @brief This class automatically initiates and ends the mysql library,
 * allocating and freeing some stuff required by the library.
 * For more info see:
 * https://dev.mysql.com/doc/refman/5.7/en/mysql-library-init.html and
 * https://dev.mysql.com/doc/refman/5.7/en/mysql-library-end.html .
 */
class mysql_driver
{

public:
  /**
   * Constructor calls: mysql_library_init(0, NULL, NULL).
   * If you would like to pass parameters to mysql_library_init, comment the
   * call in the constructor implementation and call it in main().
   */
  mysql_driver();

  /**
   * Destructor calls: mysql_library_end().
   */
  ~mysql_driver();

  /**
   * @brief Deletes copy constructor to make sure a singleton instance can not
   * be copied.
   */
  mysql_driver(mysql_driver const&) = delete;

  /**
   * @brief Deletes assignment operator to make sure a singleton instance can
   * not be copied.
   */
  void operator=(mysql_driver const&) = delete;

  /**
   * Retrives the one and only instance of this driver.
   * @return The one and only instance.
   */
  static mysql_driver& get();

  /**
   * Initialize the mysql driver.
   */
  static bool initialize();

};
/**
 * @brief Used to call initialize(). Set to true after initialization.
 */
extern bool mysql_driver_is_initialized;
} // namespace real
} // namespace db
} // namespace gtp
#endif // GTP_DB_REAL_MYSQL_DRIVER_HPP
