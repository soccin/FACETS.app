#!/bin/bash

# Rerun just the facets parts over all count
# files under CWD

SDIR="$( cd "$( dirname "$0" )" && pwd )"

for file in $(find . -name "countsMerged____*"); do
    bsub -We 59 -o LSF.FACETS_$$/ -J f_FACETS_$$ \
        $SDIR/doFacets.R $* $file
done


