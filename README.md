# FACETS.app

## Version 0.9.3 (2015.08.11)

Wrapper script which takes a tumor/normal BAM pair then

* counts the base coverage over SNPs

* creates a join tumor/normal counts file

* runs facets

usage::
```bash

usage:: FACETS/App.sh NORMALBAM TUMORBAM
   or:: FACETS/App.sh NORMALBAM TUMORBAM TAG -c 50

Arguments after TAG are passed to doFacets.R
```

## Updates

* run.sh no longer recounts if counts files already present; can call it to re-run facets instead of calling doFacets.R directly. 

* ```--ndepth``` (```-n```) option added to ```doFacets.R``` added: reduction to 25 recommended by Venkat for high sensitivity

* Waterfall supression from A. Penson

The tumor depth and allele counts are normalized to remove the dependence of the log-ratio on normal depth, using a lowess fit. This is designed to remove the "waterfall" effect produced when degraded tumor DNA with small fragment size means that SNPs adjacent to target exons are consistently covered less well in the tumor than in the normal.

