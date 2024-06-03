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

void main_detailed_query_no_result()
{
  mysql_connection conn;
  bool connected = conn.connect("127.0.0.1", "root", "cvscvs",
    "translator_test", 0, NULL, 0);
  if (!connected)
  {
    cout << "Could not connect" << endl;
  }
  else
  {
    cout << "Connected" << endl;
    // no ; or \g at the end of query, unless you run multiple queries
    int ret_code = conn.query("create database pgrozav_mysql_test1");
    if (ret_code == 0)
    {
      cout << "query ran fine" << endl;
      unsigned int field_count = conn.field_count();
      cout << "Query returned " << field_count << " rows." << endl;
      if (field_count == 0)
      {
        cout << "No results to be read" << endl;
      }
      else
      {
        cout << "Reading results" << endl;
      }
    }
    else
    {
      cout << "query return error code: " << ret_code << endl;
    }
  }
  // affected rows:
  my_ulonglong num_rows_affected = conn.affected_rows();
  cout << "Affected " << num_rows_affected << " rows" << endl;
}

void main_detailed_query_with_result()
{
  mysql_connection conn;
  bool connected = conn.connect("127.0.0.1", "root", "cvscvs",
    "translator_test", 0, NULL, 0);
  if (!connected)
  {
    cout << "Could not connect" << endl;
  }
  else
  {
    cout << "Connected" << endl;
    // no ; or \g at the end of query, unless you run multiple queries
    int ret_code = conn.query("show databases;"); //select NOW() as t");
    if (ret_code == 0)
    {
      cout << "query ran fine" << endl;
      unsigned int field_count = conn.field_count();
      cout << "Query returned " << field_count << " rows." << endl;
      if (field_count == 0)
      {
        cout << "No results to be read" << endl;
      }
      else
      {
        cout << "Reading results (please wait) ..." << endl;
        mysql_result_set result;
        bool is_result_ok = conn.store_result(result);
        cout << "Result reading ended." << endl;
        if (!is_result_ok)
        {
          cout << "No results could be read. Maybe the statement does not "
            << "return a result set, or there was an error while reading the "
            << "result from the server." << endl;
          // Checking mysql_error
          const char * err_str = conn.error();
          if (*err_str == 0)
          {
            cout << "mysql_error said that there is no error" << endl;
          }
          else
          {
            cout << "mysql_error said: " << err_str << endl;
          }
          // Checking mysql_errno
          // Client error message numbers are listed in the MySQL errmsg.h
          // header file. Server error message numbers are listed in
          // mysqld_error.h.
          unsigned int err_no = conn.error_number();
          if (err_no == 0)
          {
            cout << "mysql_errno said that there is no error" << endl;
          }
          else
          {
            cout << "mysql_errno returned error code: " << err_no << endl;
          }
          // Checking mysql_field_count
          unsigned int field_cnt = conn.field_count();
          if (field_cnt == 0)
          {
            cout << "mysql_field_count said: No results to be read" << endl;
          }
          else
          {
            cout << "mysql_field_count said that there should be a result set"
              << " to be read" << endl;
          }
        }
        else
        {
          cout << "Result set read successfully" << endl;
          unsigned long long num_rows = result.num_rows();
          cout << "Result set contains " << num_rows << " rows" << endl;
          // or mysql_row_seek() and mysql_row_tell() to obtain or set the
          // current row position within the result set.
          char **row; // array of char*
          unsigned long *lengths;
          for (;;)
          {
            row = result.fetch_row();
            if (row == NULL)
            {
              cout << "No more rows. Or an error occured while fetching the "
                << "next row" << endl;
              // use error calls above to see if there is an error, and if you
              // should break or not
              break;
            }
            else
            {
              // Get length of cells(useful when reading BLOBs)
              lengths = result.fetch_lengths();
              cout << "Printing row:" << endl;
              // using field_count the variable above that tells us how many
              // columns there are in each row.
              for (unsigned int i = 0; i < field_count; i++)
              {
                cout << "string(" << lengths[i] << ")\"" << row[i] << "\""
                  << endl;
              }
            }
          }
        }
      }
    }
    else
    {
      cout << "query return error code: " << ret_code << endl;
    }
  }
}

int main_detailed_query(::std::vector< ::std::string > arguments)
{
  // Written using this documentation:
  // https://dev.mysql.com/doc/refman/5.7/en/mysql-store-result.html

  main_detailed_query_no_result();

  cout << "-----------------------------------------------------------" << endl;

  main_detailed_query_with_result();

  return EXIT_SUCCESS;
}
//REGISTER_SUB_PROGRAM(example_detailed_query, &main_detailed_query)
}
  // namespace applications
} // namespace app
