/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include <iostream>
#include "gtp/db/real/mysql_connection.hpp"
#include "gtp/db/real/mysql_result_set.hpp"
#include "app/sub_program.hpp"

using namespace ::std;
using namespace ::gtp::db::real;

namespace app
{
namespace applications
{
int main_fast_query(::std::vector< ::std::string > arguments)
{
  mysql_connection c;
  mysql_result_set rs1, rs2;
  char **row;
  c.connect("127.0.0.1", "root", "cvscvs");

  cout << "List of databases:" << endl;
  c.query("show databases");
  c.store_result(rs1);
  while ((row = rs1.fetch_row()))
    cout << row[0] << endl;

  c.query("select NOW()");
  c.store_result(rs2);
  cout << endl << "NOW is = " << rs2.fetch_row()[0] << endl;
  return EXIT_SUCCESS;
}
REGISTER_SUB_PROGRAM(example_fast_query, &main_fast_query)
}
 // namespace applications
}// namespace app
