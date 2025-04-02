/*
#!/bin/bash
# Run with: cat main.cpp | grep -B 9999 "^Author" | sed '1,1d' | sed '$ d' |bash
g++ *.cpp -o main && ./main ; rm -Rf main
# ============================================================================ #
Author: Tancredi-Paul Grozav <paul@grozav.info>
*/
#include <iostream> // std::cout, std::endl
#include <string> // std::string
#include "Timer.h" // measure time with gtp::Timer
using namespace std;

bool is_digit(char c)
{
    return c >= '0' && c <='9';
}

char char_to_digit(char c)
{
    return c - 48;
}

long int remove_non_digit_chars_v1(const string& input)
{
    if (input.size() == 0)
        return 0;

    long int number = 0;
    unsigned long int pow_of_ten = 1;

    for (short int pos = input.length() - 1; pos >= 0; pos--)
    {
        char ch = input[pos];

        if (is_digit(ch))
        {
            number += char_to_digit(ch) * pow_of_ten;
            pow_of_ten *= 10;
        }
        else if (pos == 0 && ch == '-')
        {
            number = -number;
        }
    }

    return number;
}

long int remove_non_digit_chars_v2(const string& input)
{
    if (input.size() == 0)
        return 0;

    long int number = 0;
    short int pos = 0;
    char ch;
    signed char number_sign = 1; // positive sign
    if(input[pos] == '-')
    {
        number_sign = -1; // negative sign
        pos++;
    }

    for (; pos < input.length(); pos++)
    {
        ch = input[pos];
        if (is_digit(ch))
        {
            number = number * 10 + char_to_digit(ch); // append digit to end
        }
    }

    return number_sign * number;
}
long int remove_non_digit_chars_v3(const string& input)
{
    const char *data = input.data();
    size_t size = input.size();
    if (size == 0)
    {
        return 0;
    }

    long int number = 0;
    size_t pos = 0;
    char const *ch = &(data[pos]);
    signed char number_sign = 1; // positive sign
    if(*ch == '-')
    {
        number_sign = -1; // negative sign
        pos++;
    }

    for (; pos < size; pos++)
    {
        ch = &(data[pos]);
        if (is_digit(*ch))
        {
            number = number * 10 + char_to_digit(*ch); // append digit to end
        }
    }

    return number_sign * number;
}

bool test_remove_non_digit_chars_function(
    long int (*function_ptr)(const string& input))
{
    bool test_status = true;
    test_status &= (*function_ptr)("") == 0;
    test_status &= (*function_ptr)("--abd%€--") == 0;
    test_status &= (*function_ptr)("abd%€--") == 0;
    test_status &= (*function_ptr)("4") == 4;
    test_status &= (*function_ptr)("-4") == -4;
    test_status &= (*function_ptr)("-0") == 0;
    test_status &= (*function_ptr)("-0") == -0;
    test_status &= (*function_ptr)("-10") == -10;
    test_status &=
        (*function_ptr)("999999999999999999") == 999999999999999999;
    test_status &=
        (*function_ptr)("-99999999999999999") == -99999999999999999;
    test_status &= (*function_ptr)("g1992ha0d9s0r18") == 199209018;
    test_status &= (*function_ptr)("130.76562500") == 13076562500;
    test_status &= (*function_ptr)("-130.76562500") == -13076562500;
    return test_status;
}

bool unit_tests()
{
    bool test_status = true;
    gtp::Timer t;

    t.start();
    test_status &= test_remove_non_digit_chars_function(
        &remove_non_digit_chars_v1
    );
    t.stop();
    cout << "Duration v1: " << t.get_interval() << " seconds " << endl;

    t.start();
    test_status &= test_remove_non_digit_chars_function(
        &remove_non_digit_chars_v2
    );
    t.stop();
    cout << "Duration v2: " << t.get_interval() << " seconds " << endl;

    t.start();
    test_status &= test_remove_non_digit_chars_function(
        &remove_non_digit_chars_v3
    );
    t.stop();
    cout << "Duration v3: " << t.get_interval() << " seconds " << endl;

    return test_status;
}

int main()
{
    if( unit_tests() )
    {
        return 0;
    }else{
        cout << "Unit tests failed." << endl;
        return 1;
    }
}
