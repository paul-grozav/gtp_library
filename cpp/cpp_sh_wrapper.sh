#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Useful when you want to just paste a snipet and run it "as a script", but of
# course it handles the compile run, clean-up behind the scenes.
# ============================================================================ #
(
tmp_bin=$(mktemp) &&
mv ${tmp_bin} ${tmp_bin}.bin &&
tmp_bin="${tmp_bin}.bin" &&

tmp_src=$(mktemp) &&
mv ${tmp_src} ${tmp_src}.cpp &&
tmp_src="${tmp_src}.cpp" &&

(cat - <<'EOF'
// --------------------------- CPP source code begin ------------------------ //
#include <iostream>

using namespace ::std;

int main()
{
  cout << "Hello from compiled C++ program !" << endl;
  return 0;
}
// --------------------------- CPP source code end -------------------------- //
EOF
) > ${tmp_src} &&

g++ ${tmp_src} -std=c++20 -o ${tmp_bin} &&
rm -f ${tmp_src} &&
${tmp_bin};
rm -f ${tmp_bin}
) # Take the following empty line when you copy-paste

# ============================================================================ #
