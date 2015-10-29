#!/bin/bash
export PATH=/opt/common/CentOS_6/python/python-2.7.8/bin:$PATH
SDIR="$( cd "$( dirname "$0" )" && pwd )"
$SDIR/doFacets.R $*
