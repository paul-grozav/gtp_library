/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_MOCK_MYSQL_CONNECTION_HPP
#define GTP_DB_MOCK_MYSQL_CONNECTION_HPP

#include <gmock/gmock.h>

#include "gtp/db/interface/mysql_connection.hpp"

namespace gtp
{
namespace db
{
namespace mock
{

/**
 * Implements a mock mysql_connection.
 */
class mysql_connection: public interface::mysql_connection
{
public:
  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(init, bool());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD7(connect, bool(const char *host, const char *user,
      const char *passwd, const char *db, unsigned int port,
      const char *unix_socket, unsigned long client_flag));

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(ping, int());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD1(query, int(const char *stmt_str));

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(field_count, unsigned int());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(affected_rows, unsigned long long());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(close, void());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(error, const char*());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(error_number, unsigned int());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD1(store_result, bool(interface::mysql_result_set &result_set));

};
} // namespace mock
} // namespace db
} // namespace gtp
#endif // GTP_DB_MOCK_MYSQL_CONNECTION_HPP
