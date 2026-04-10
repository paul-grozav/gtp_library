// -------------------------------------------------------------------------- //
// Authors:
// - Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <thread>
#include <atomic>
#include <condition_variable>
#include <mutex>

using namespace ::std;

int c = 0;
condition_variable cv;
mutex cout_mtx;
//! Shared mutex for all threads
mutex shared_mtx;

std::string get_current_timestamp() {
  using namespace ::std::chrono;
  auto now = system_clock::now();
  auto timer = system_clock::to_time_t(now);
  std::tm bt = *std::localtime(&timer);
  auto nanoseconds = duration_cast<chrono::nanoseconds>(
    now.time_since_epoch()) % 1000000000;
  std::ostringstream oss;
  oss << std::put_time(&bt, "%Y-%m-%d %H:%M:%S");
  oss << '.' << std::setfill('0') << std::setw(9) << nanoseconds.count();
  return oss.str();
}

#define LOG(msg) \
{ \
  unique_lock<mutex> l(cout_mtx); \
  cout << "[ " << get_current_timestamp() << " ] - " << msg << endl; \
}


void worker() {
  thread::id id = this_thread::get_id();
  // sleep at least 2 seconds
  int sec = 1 + rand() % 4;

  LOG("Thread " << id << " sleeping for " << sec << "s");
  this_thread::sleep_for(chrono::seconds(sec));

  {
    unique_lock<mutex> l(shared_mtx);
    c++;
    cv.notify_all();
    LOG("Thread " << id << " reached barrier, waiting...");
    cv.wait(l, [] { return c == 2; });
  }

  LOG("Thread " << id << " passed the barrier!");
}

int main()
{
  LOG("App start");
  srand(time(NULL));
  thread t1(worker);
  thread t2(worker);
  t1.join();
  t2.join();
  LOG("App end");
  return 0;
}
// -------------------------------------------------------------------------- //

/*
Runtime output:
  [ 2026-04-10 10:59:02.211515205 ] - App start
  [ 2026-04-10 10:59:02.211904123 ] - Thread 140559168243392 sleeping for 2s
  [ 2026-04-10 10:59:02.212130445 ] - Thread 140559159850688 sleeping for 4s
  [ 2026-04-10 10:59:04.212193358 ] - Thread 140559168243392 reached barrier, waiting...
  [ 2026-04-10 10:59:06.212459648 ] - Thread 140559159850688 reached barrier, waiting...
  [ 2026-04-10 10:59:06.212629030 ] - Thread 140559159850688 passed the barrier!
  [ 2026-04-10 10:59:06.212770897 ] - Thread 140559168243392 passed the barrier!
  [ 2026-04-10 10:59:06.212865259 ] - App end

---

Explanation:
second 4 - T1 wakes from sleep, acquires lock on mtx, increments c from 0 to 1
  then T1 calls notify_all(but there is no one else waiting on the condition
  variable, as T2 is still sleeping - so T1's notify does nothing really), then
  T1 calls wait() which checks the condition (it's false), so T1 releases the
  mtx and goes to sleep
second 6 - T2 wakes from sleep, acquires lock on mtx (because it is now released
  as T1 went to sleep), increments c from 1 to 2, then T2 calls notify_all.
  T2's call of notify_all, wakes up T1 but T1 needs to acquire the mutex before
  calling the lambda/inline function, and checking it's spurious wakeup
  condition. so T1 waits for the mtx as it's locked by T2. T2 finished calling
  notify_all, so it calls wait() which checks the condition(it is true) so
  T2 never sleeps, it just exits wait and releases the mtx lock as the scope
  ends. In the mean time T1 was waiting for the mtx, so T1 acquires the mtx,
  checks the condition, it's true, so it returns from the wait and releases the
  mtx as the scope ends.

So basically the mtx is used as a sync mechanism between threads, but also to
protect the counter c.

So, when you call cv.wait(lock, lambda) it actually calls the lambda condition
and if that is true it just exits. If it's false, it will do 2 things atomically
(that is in an uninterruptible way):
1. release the lock/mutex
2. puts the thread to sleep
*/
