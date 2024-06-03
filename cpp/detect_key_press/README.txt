I’m not sure if you’ve ever wondered how C++ games can “feel” when you press a
key. I was curious about this, especially because (by default) when you read
some value from stdin you don’t get it character by character, as the user types
it, but you get the entire string, the moment the user hits Enter.

Tested on Linux only with g++

# Compile:
g++ main.cpp -o bin

# Run:
./bin