/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_MOCK_MYSQL_RESULT_SET_HPP
#define GTP_DB_MOCK_MYSQL_RESULT_SET_HPP

#include <gmock/gmock.h>

#include "gtp/db/interface/mysql_result_set.hpp"

namespace gtp
{
namespace db
{
namespace mock
{

/**
 * Implements a mock mysql result set.
 */
class mysql_result_set: public interface::mysql_result_set
{
public:
  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD1(init, void(void *result));

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(num_rows, unsigned long long());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(fetch_row, char **());

  /**
   * @brief Auto generated mock implementation.
   */
  MOCK_METHOD0(fetch_lengths, unsigned long *());

};
} // namespace mock
} // namespace db
} // namespace gtp
#endif // GTP_DB_MOCK_MYSQL_RESULT_SET_HPP
