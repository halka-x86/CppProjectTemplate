#include "SampleClass.h"
#include "gtest/gtest.h"

TEST(testCaseName, testName)
{
  SampleClass s;
  s.setValue(1);
  EXPECT_EQ(1, s.getValue());
  ASSERT_EQ(1, s.getValue()) << "error message";
}

