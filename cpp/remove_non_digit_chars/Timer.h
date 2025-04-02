//
// Timer.h
//
// Created on: 2015-10-01
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// License: LGPL - http://www.gnu.org/licenses/lgpl-3.0.en.html
//

#ifndef TIMER_H_
#define TIMER_H_

#include <time.h> // for clock_gettime()
#include <string> // std::string

namespace gtp {

/**
 * @brief !NOT FAST! Timer class used to measure time.
 * Simply call start(), then stop() and then get_interval().
 *
 * The get_interval() method returns a string with the number of seconds.
 * \code{.cpp}
 * gtp::Timer t; t.start();
 * // your time consuming code
 * t.stop();
 * cout << "Duration 1: " << t.get_interval() << " seconds " << endl;
 * // later you can measure another interval with the same object
 * // this will start counting again from 0 seconds.
 * t.start();
 * // your time consuming code
 * t.stop();
 * cout << "Duration 2: " << t.get_interval() << " seconds " << endl;
 * \endcode
 */
class Timer {
public:

    /// Interval. Time difference from start() to stop().
    struct Interval {
        //! Number of seconds in the interval
        unsigned long long int seconds;
        /**
         * Number of nano_seconds in the inverval
         * (less than 1 second = 1000000000 nanoseconds)
         */
        unsigned long long int nano_seconds;
    };

    /**
     * Constructs the timer object.
     * @param type - Defines Timer type.
     * Possible values:
     * - CLOCK_MONOTONIC for measuring wall-clock time(this is also the default
     * value)
     * - CLOCK_PROCESS_CPUTIME_ID for measuring CPU time.
     */
    Timer(clockid_t type = CLOCK_MONOTONIC);

    /// Starts the timer.
    void start();

    /// Stops the timer.
    void stop();

    /// Returns a string representation of the interval
    std::string get_interval();

    /// The time interval between stop and start ( a.k.a. stop-start )
    Interval interval;

private:
    /// Used to keep the start time
    struct timespec start_time;
    /// Used to keep the stop time
    struct timespec stop_time;
    /// Timer type
    clockid_t timer_type;
};

}
#endif /* TIMER_H_ */

