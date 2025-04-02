// Author: Tancredi-Paul Grozav <paul@grozav.info>
// License: LGPL - http://www.gnu.org/licenses/lgpl-3.0.en.html
#include "Timer.h"
//#include <iostream>
#include <iomanip> // setfill() and setw()
#include <sstream> // std::stringstream
#include <string> // std::string

namespace gtp {

Timer::Timer(clockid_t type)
{
    timer_type = type;
}

void Timer::start()
{
    clock_gettime(timer_type, &start_time);
}

void Timer::stop()
{
    clock_gettime(timer_type, &stop_time);

//  std::cout << stop_time.tv_sec << " - " << start_time.tv_sec << " = " << (stop_time.tv_sec - start_time.tv_sec) << std::endl;
//  std::cout << stop_time.tv_nsec << " - " << start_time.tv_nsec << " = " << (stop_time.tv_nsec - start_time.tv_nsec) << std::endl;

    interval.seconds = stop_time.tv_sec - start_time.tv_sec;
    long int tmp = stop_time.tv_nsec - start_time.tv_nsec;//compute in signed int variable
    if (tmp < 0)
    {
        tmp += 1000000000;
        interval.seconds -= 1;
    }
    interval.nano_seconds = tmp;//save positive value in unsigned variable
}

std::string Timer::get_interval()
{
    std::stringstream ss;
    ss << interval.seconds << ".";
    ss << std::setfill('0') << std::setw(9) << interval.nano_seconds; // Add leading '0's to nanoseconds in order to be displayed on 9 digits
    return ss.str();
}

}

