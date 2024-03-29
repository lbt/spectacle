#!/bin/sh

if [ $# -lt 1 ]; then
  echo 'Usage gencase.sh <case-name>'
  exit 1
fi

CaseName=$1

mkdir test-${CaseName}
cd test-${CaseName}

cp ../base/testpkg.yaml .
specify -N -n -o output.spec testpkg.yaml 1>output.1.o 2>output.2.o
vi testpkg.yaml
diff -upN ../base/testpkg.yaml testpkg.yaml > input.p
mv output.spec output.orig.spec
specify -N -n -o output.spec testpkg.yaml 1>output.1 2>output.2
echo 'Input diff:'
cat input.p

if [ -f output.spec ]; then
  diff -upN output.orig.spec output.spec > output.p
  if [ $? != 0 ]; then
    echo 'Output diff:'
    cat output.p
  else
    rm -f output.p
  fi
else
  rm -f output.p
  touch output.no
fi

diff -upN output.1.o output.1 > output.1p
if [ $? != 0 ]; then
  echo 'Stdout diff:'
  cat output.1p
else
  rm -f output.1p
fi

diff -upN output.2.o output.2 > output.2p
if [ $? != 0 ]; then
  echo 'Stderr diff:'
  cat output.2p
else
  rm -f output.2p
fi

mkdir tmp-files
mv -f *.yaml *.spec *.[12o] tmp-files
