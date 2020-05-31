#!/usr/bin/env bash
set -e

JDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$JDIR"/util.sh

set -x

pushd ns-3 >/dev/null

BOOST_VERSION=$(python -c "import sys; sys.path.append('build/c4che'); import _cache; v = _cache.BOOST_VERSION.split('_'); print int(v[0]) * 100000 + int(v[1]) * 100;")

ut_log_args() {
    if (( BOOST_VERSION >= 106200 )); then
        echo --logger=HRF,test_suite,stdout:XML,all,build/xunit-${1:-report}.xml
    else
        if [[ -n $XUNIT ]]; then
            echo --log_level=all $( (( BOOST_VERSION >= 106000 )) && echo -- ) \
                 --log_format2=XML --log_sink2=build/xunit-${1:-report}.xml
        else
            echo --log_level=test_suite
        fi
    fi
}

export BOOST_TEST_BUILD_INFO=1
export BOOST_TEST_COLOR_OUTPUT=1

# Run unit tests
./waf --run "ndnSIM-unit-tests $(ut_log_args)"

popd >/dev/null
