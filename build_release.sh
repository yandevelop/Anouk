rm -rf ./packages

make clean
make clean package FINALPACKAGE=1

make clean
make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless