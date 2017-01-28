/*******************************************************************************
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 ******************************************************************************/
#include <iostream>
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "gtp/db/mock/mysql_connection.hpp"
#include "gtp/db/mock/mysql_result_set.hpp"

using namespace ::std;
using namespace ::testing;
using namespace ::gtp::db;

namespace app
{
namespace tests
{
/**
 * An example unit test
 */
namespace example
{
/**
 * @brief Example of a database user.
 */
class mysql_user
{
  interface::mysql_connection &c;
  interface::mysql_result_set &rs;
public:
  mysql_user(interface::mysql_connection &c, interface::mysql_result_set &rs) :
    c(c), rs(rs)
  {
  }
  void do_something()
  {
    cout << "c.connect="
      << (
        c.connect("127.0.0.1", "root", "cvscvs", NULL, 0, NULL, 0) ?
          "true" : "false") << endl;
    cout << "c.query=" << c.query("show databases") << endl;
    cout << "c.connect=" << (c.store_result(rs) ? "true" : "false") << endl;
    char **row;
    for (;;)
    {
      row = rs.fetch_row();
      if (row == NULL)
        break;
      cout << row[0] << "," << row[1] << endl;
    }
  }
};

ACTION_P3(InvokeUnrelatedFunction, classPointer, pointerToMemberFunc, first)
{
  (classPointer->*pointerToMemberFunc)(first);
  return 0; //something
}

TEST(Example, A)
{
  mock::mysql_connection c;
  mock::mysql_result_set rs;
  example::mysql_user usr(c, rs);

  EXPECT_CALL(c, connect(_, _, _, NULL, 0, NULL, 0)).Times(1)
  .WillOnce(Return(true));
  EXPECT_CALL(c, query(_)).Times(1).WillOnce(Return(0));
  mock::mysql_result_set t_rs;
  string as("asas");
  void *vp = NULL; vp = &as;
  cout << "vp=" << vp << endl;
  EXPECT_CALL(c, store_result(_)).Times(1)
//    .WillOnce(DoAll(
//      SaveArg<0>(static_cast<::app::db::interface::mysql_result_set*>(&t_rs)),
//      InvokeUnrelatedFunction(&t_rs,&::app::db::mock::mysql_result_set::init
//      ,vp)
//    ));
  .WillOnce(InvokeUnrelatedFunction(&rs,&mock::mysql_result_set::init,vp));
  EXPECT_CALL(rs, init(_)).Times(1);
  char const *rrr[3][2] =
  {
    { "r1c1", "r1c2"},
    { "r2c1", "r2c2"},
    { "r3c1", "r3c2"},
  };
  size_t rows = sizeof(rrr) / sizeof(rrr[0]);
  size_t columns = sizeof(rrr[0])/sizeof(rrr[0][0]);
  cout << "rows=" << rows << endl;
  cout << "columns=" << columns << endl;
  Sequence s1;
  for(size_t i = 0; i < rows; i++)
  {
    EXPECT_CALL(rs, fetch_row()).InSequence(s1)
    .WillOnce(Return(const_cast<char**>(rrr[i])));
  }
  EXPECT_CALL(rs, fetch_row()).InSequence(s1).WillRepeatedly(Return(
      static_cast<char**>(NULL)));

  usr.do_something();
  EXPECT_TRUE(true);
}

}
 // namespace example
}// namespace tests
} // namespace app
