#!/bin/sh

# Launch all tests in bin/ directory. This script must be run from the top
# level of the HElib repository.

# TODO: This file is only necessary because tests are implemented in such an
# ad-hoc way. Moving to a unit testing framework like gtest would eliminate the
# need for this launch script altogether.

function die() {
  echo "Test failed."
  exit 1
}

./bin/Test_General_x R=1 k=10 p=2 r=2 || die

./bin/Test_General_x R=1 k=10 p=2 d=2 || die

./bin/Test_General_x R=2 k=10 p=7 r=2 || die

./bin/Test_LinPoly_x || die

./bin/Test_Permutations_x || die

./bin/Test_PolyEval_x p=7 r=2 d=34 || die

./bin/Test_Replicate_x m=1247 || die

./bin/Test_EvalMap_x mvec="[7 3 221]" gens="[3979 3095 3760]" ords="[6 2 -8]" \
  || die

./bin/Test_extractDigits_x m=2047 p=5 || die

./bin/Test_bootstrapping_x || die

./bin/Test_bootstrapping_x p=7 || die

echo "All tests passed."
