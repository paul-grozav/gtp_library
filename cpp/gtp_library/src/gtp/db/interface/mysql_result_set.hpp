/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#ifndef GTP_DB_INTERFACE_MYSQL_RESULT_SET_HPP
#define GTP_DB_INTERFACE_MYSQL_RESULT_SET_HPP

namespace gtp
{
namespace db
{
namespace interface
{
/**
 * @brief This interface describes a result set received from the database
 * server. This can be seen as a two-dimensional array of C-strings (char***),
 * or as a 3D matrix of characters :-).
 */
class mysql_result_set
{
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
   * @param result - A mysql result structure initialized by store_result()
   * @note A false return value means that there was not enough memory to
   * initialize the object.
   */
  void init(void *result);

public:
  /**
   * @brief ~mysql_result_set destructor.
   */
  virtual ~mysql_result_set() = 0;

  /**
   * @brief Returns the number of rows in the result set.
   * @return The number of rows in the result set.
   */
  virtual unsigned long long num_rows() = 0;

  /**
   * @brief Retrieves the next row of a result set.
   *
   * When used after store_result(), fetch_row() returns NULL when there are no
   * more rows to retrieve.
   *
   * The number of values in the row is given by num_fields(). If row holds the
   * return value from a call to fetch_row(), pointers to the values are
   * accessed as row[0] to row[mysql_num_fields(result)-1]. NULL values in the
   * row are indicated by NULL pointers.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-fetch-row.html
   *
   * @return A char** structure for the next row. NULL if there are no more rows
   * to retrieve or if an error occurred.
   */
  virtual char **fetch_row() = 0;

  /**
   * @brief Returns the lengths of the columns of the current row within a
   * result set.
   *
   * @note fetch_lengths() is valid only for the current row of the result set.
   * It returns NULL if you call it before calling fetch_row() or after
   * retrieving all rows in the result.
   *
   * @note For more info see:
   * https://dev.mysql.com/doc/refman/5.7/en/mysql-fetch-lengths.html
   *
   * @return An array of unsigned long integers representing the size of each
   * column (not including any terminating null bytes). NULL if an error
   * occurred.
   */
  virtual unsigned long *fetch_lengths() = 0;
};
} // namespace interface
} // namespace db
} // namespace gtp
#endif // GTP_DB_INTERFACE_MYSQL_RESULT_SET_HPP
