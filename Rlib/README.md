# Local Rlib for facets R-packages
## 2016_06_05 version 

### Installation

```bash
R=/opt/common/CentOS_6-dev/bin/current/R
$R CMD INSTALL -l . /home/seshanv/Rpackages/gcdata_0.1.0.tar.gz
$R CMD INSTALL -l . /home/seshanv/Rpackages/facets_0.5.1.tar.gz
```

__N.B.__ The file Rlib/gcdata/data/Rdata.rdb is too large to store on GitHub. If you are cloning from GitHub you need to get this file either by doing an install as described above or copying it after the clone. 1

### Usage notes (from Venkat)

Both need to be installed for facets to work. There is a readSnpMatrix function in facets that uses scan to read in a matrix with minimal number of columns (Chrom, Pos, NOR.DP, NOR.RD, TUM.DP, TUM.RD). The usual workflow is
 
```R
rcmat <- readSnpMatrix(filename)
xx <- preProcSample(rcmat)
oo <- procSample(xx)
ff <- emcncf2(oo)
plotSample(oo, ff)
``` 

(`emcncf2` is the improved version of the EM algorithm. The original `emcncf` is still around.)
 
When you install facets it will install a directory `extRfns` with the file `readSnpMatrixMSK.R` which can be sourced using `source(system.file("extRfns", "readSnpMatrixMSK.R", package="facets"))`. This function determines the counter type by reading in the variable name line. You can use `readSnpMatrixMSK(filename)` instead and specify `skip=1` to skip the first comment line.

