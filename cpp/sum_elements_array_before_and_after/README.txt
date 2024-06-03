# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# License: GNU GPLv3
#
# Read this file in order to understand what the project does and how to use it.
# ============================================================================ #


Table of contents
=================
  1. Requirements
  2. Requirements to compile the project
  3. Steps to compile and run the project
  4. Steps to compile and run unit tests
  5. Documentation


# ============================================================================ #
1. Requirements
===============
  - Sa scrii o aplicatie consola care la pornire cere o serie de integeri
    introdusi de la tastatura (cere numarul de elemente si apoi cere valoarea
    fiecarui element in parte)
  - Elementere respective se stocheaza intr-un array.
  - Programul sa calculeze indexul elementului care are proprietatea ca suma
    elementelor de dinaintea lui este egala cu suma elementelor de dupa el.
  - Daca nu gaseste un astfel de element programul sa afiseze ca nu a gasit
    elementul.

  Cerinte suplimentare:
  - Aplicatia sa fie scrisa in C sau C++,
  - Compilatorul il alegi tu care doresti Visual C++, gcc, etc
  - Softul sa fie compilabil pe Windows sau Linux, e la alegerea ta.
  - Cand sunt gata proiectele ma astept la cate un fisier zip pentru fiecare
    proiect care sa contina:
    - Un folder inc cu fisierele (*.h)
    - Un folder src cu sursele (*.cpp)
    - Un folder bin cu executabilele
    - Un folder doc in care sa fie explicat in ce mediu de dezvoltare a fost
      creat proiectul, cum sa il compilez si cum sa il rulez. Descrierea sa fie
      facuta in asa maniera incat eu cand vad pentru prima data proiectul sa
      pot sa il compilez si sa il rulez fara probleme.
    - Un fisier de test specification care va contine informatii despre cum ai
      testat proiectele(ce valori de input ai dat) si ce rezultate ai primit
      (ce valori de output)
# ============================================================================ #


2. Requirements to compile the project
======================================
  The program was created on Linux(Debian), using nano as a text editor. It was
compiled using GCC (plus CMake & make).
  - Compiler: gcc version 6.3.0 20170516 (Debian 6.3.0-18+deb9u1)
  - OS: Debian GNU/Linux 9.3 (stretch)
  - CMake version 3.7.2
  - GNU Make version 4.1
  The project should compile just fine on other distributions of linux.
# ============================================================================ #


3. Steps to compile and run the project
=======================================
  To compile the project, simply create a new folder (for example bin), go
inside it and run the following commands (in linux shell):

cmake ..
make

  This should create the makefiles used to compile the project, and then
actually compile it.
  To run the project simply execute the generated binary file:

./main
# ============================================================================ #


4. Steps to compile and run unit tests
======================================
  You can compile the unit tests just like compiling the project, except when
calling cmake, you have to pass -Dbuild_unit_tests=ON as a parameter to activate
and compile that binary as well. So the commands would be (inside bin folder):

cmake .. -Dbuild_unit_tests=ON
make

  And then to run the unit tests:

./unit_tests
# ============================================================================ #


5. Documentation
================
  To read the project documentation (beyond what's in this README file), you can
open doc/html/index.html in any decent browser. That documentation is generated
by doxygen based on the comments that are present in the source code (inc and
src folders).
# ============================================================================ #
