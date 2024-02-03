#!/bin/bash

function ShowUsage()
{
    cat <<EOT
$(basename "$0") options
    [--archlist=<archlist>]  - architectures to build for (x86_64|aarch64)
    [--toolchain=<toolchainfile>] - toolchain file for aarch64 builds
    [--cxx=<path/to/cxx>]    - path for CXX environment variable for native builds
    [--cc=<path/to/cc>]      - path for CC env variable for native builds
    [--cmake=<options>]      - option string to pass to CMake
    [--concourse]            - building in Concourse
EOT
    return 0    
}

PARAM_ARCHLIST="x86_64 aarch64"
PARAM_TOOLCHAIN=
PARAM_CC=
PARAM_CXX=
PARAM_CMAKE=
PARAM_CONCOURSE=

while test $# -gt 0; do
    param="$1"
    if test "${1::1}" = "-"; then
        if test ${#1} -gt 2 -a "${1::2}" = "--" ; then
            param="${1:2}"
        else
            param="${1:1}"
        fi
    else
        break
    fi

    shift

    case $param in
    archlist=*)
        PARAM_ARCHLIST=$(echo "$param"|cut -f2 -d'=')
        PARAM_ARCHLIST=${PARAM_ARCHLIST/,/ }
        ;;
    toolchain=*)
        PARAM_TOOLCHAIN=$(echo "$param"|cut -f2 -d'=')
        ;;
    cc=*)
        PARAM_CC=$(echo "$param"|cut -f2 -d'=')
        ;;
    cxx=*)
        PARAM_CXX=$(echo "$param"|cut -f2 -d'=')
        ;;
    cmake=*)
        PARAM_CMAKE=$(echo "$param"|cut -f2- -d'=')
        ;;
    concourse*)
        PARAM_CONCOURSE=1
        ;;
    help|h|?|-?)
        ShowUsage
        exit 0
        ;;
    *)
        echo "Error: Unknown parameter: $param"
        ShowUsage
        exit 2
        ;;    
    esac
done

echo "PARAM_ARCHLIST=$PARAM_ARCHLIST"
echo "PARAM_TOOLCHAIN=$PARAM_TOOLCHAIN"
echo "PARAM_CC=$PARAM_CC"
echo "PARAM_CXX=$PARAM_CXX"
echo "PARAM_CMAKE=$PARAM_CMAKE"

# If running in a Concourse pipeline then validate the repo was cloned
if [ -n "$PARAM_CONCOURSE" ]; then
    [ ! -d ./cpp-multiarch-git ] && { echo "ERROR: repo not cloned!"; exit 1; }

    # Change to the base directory of the repo
    cd cpp-multiarch-git || exit 1
fi

BASEDIR=$PWD

for ARCH in $PARAM_ARCHLIST
do
    echo "Building for Architecture $ARCH"

    mkdir -p "build_$ARCH"
    cd "build_$ARCH" || exit

    # Run CMake for the specified architecture
    case $ARCH in
    aarch64)
        cmake -DCMAKE_TOOLCHAIN_FILE="$PARAM_TOOLCHAIN" "$PARAM_CMAKE" -DCMAKE_INSTALL_PREFIX="$PWD"/.. ..
        ;;
    *)
        # Handle possible override for native compiler
        if [ -n "$PARAM_CC" ] || [ -n "$PARAM_CXX" ];
        then
            CC=$PARAM_CC CXX=$PARAM_CXX cmake "$PARAM_CMAKE" -DCMAKE_INSTALL_PREFIX="$PWD"/.. ..
        else
            cmake "$PARAM_CMAKE" -DCMAKE_INSTALL_PREFIX="$PWD"/.. ..
        fi
        ;;
    esac
    ret=$?
    [ $ret -ne 0 ] && exit $ret

    # Build and install for the specified architecture
    make install
    ret=$?
    [ $ret -ne 0 ] && exit $ret

    # Back to base 
    cd "$BASEDIR" || exit 1

done

# Return result
exit 0
