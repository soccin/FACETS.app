library(facets)
library(Cairo)
source(system.file("extRfns", "readSnpMatrixMSK.R", package="facets"))
countsFile="~/Work/FACETS/v4/Proj_05873_x/counts/s_11155___s_11155N/counts___s_11155___s_11155N.dat.gz"
base=gsub("\\..*","",basename(countsFile))

rcmat <- readSnpMatrixMSK(countsFile,skip=1)

genome="mm10"
if(genome=="mm10"){
    rcmat[Chrom=="X",Chrom := "20"]
    rcmat[Chrom=="Y",Chrom := "21"]
    rcmat[,Chrom:=as.numeric(Chrom)]
}

xx <- preProcSample(rcmat,gbuild=genome)
oo <- procSample(xx)
ff <- emcncf2(oo)

if(!interactive())
    CairoPNG(file=paste0(base,".png"),width=1000,height=800)

plotSample(oo,ff,chromlevels=c(1:19))

if(!interactive())
    dev.off()
