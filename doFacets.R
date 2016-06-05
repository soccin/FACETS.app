#!/opt/common/CentOS_6-dev/R/R-3.2.2/bin/Rscript --vanilla

getSDIR <- function(){
    args=commandArgs(trailing=F)
    TAG="--file="
    path_idx=grep(TAG,args)
    SDIR=dirname(substr(args[path_idx],nchar(TAG)+1,nchar(args[path_idx])))
    if(length(SDIR)==0) {
        return(getwd())
    } else {
        return(SDIR)
    }
}

#DEBUG: getSDIR<-function(){return("/home/socci/Code/Pipelines/FACETS/FACETSv2dev")}

#########################################################################
formatSegmentOutput=function(out,sampID) {
    seg=list()
    seg$ID=rep(sampID,nrow(out$out))
    seg$chrom=out$out$chr
    seg$loc.start=rep(NA,length(seg$ID))
    seg$loc.end=seg$loc.start
    seg$num.mark=out$out$num.mark
    seg$seg.mean=out$out$cnlr.median
    for(i in 1:nrow(out$out)) {
        lims=range(out$jointseg$maploc[(out$jointseg$chrom==out$out$chrom[i] & out$jointseg$seg==out$out$seg[i])],na.rm=T)
        seg$loc.start[i]=lims[1]
        seg$loc.end[i]=lims[2]
    }
    as.data.frame(seg)
}

outputPath<-function(dir,...) {
    if(dir==""){
        return(paste0(...))
    } else {
        return(paste0(dir,"/",...))
    }
}

#########################################################################

.libPaths(file.path(getSDIR(),"./Rlib"))
library(facets)
library(Cairo)
source(system.file("extRfns", "readSnpMatrixMSK.R", package="facets"))
library(argparse)
parser=ArgumentParser()
parser$add_argument("-f", "--counts_file", type="character", required=T, help="paired Counts File")
# can not use -g R uses that to specify gui
parser$add_argument("-b", "--genome",type="character",default="hg19",help="Genome of counts file")
parser$add_argument("-t", "--TAG", type="character",default="", help="output prefix")
parser$add_argument("-D", "--directory", type="character", default="", help="output prefix")


args=parser$parse_args()

countsFile=args$counts_file
genome=args$genome
outDir=args$directory

if(args$TAG==""){
    TAG=gsub("counts___","",gsub("\\..*","",basename(countsFile)))
} else {
    TAG=args$TAG
}

rcmat <- readSnpMatrixMSK(countsFile,skip=1)
xx <- preProcSample(rcmat,gbuild=genome)
oo <- procSample(xx)
ff <- emcncf2(oo)

if(!interactive())
    CairoPNG(file=outputPath(outDir,TAG,".png"),width=1000,height=800)

plotSample(oo,ff,chromlevels=c(1:19))

if(!interactive())
    dev.off()

seg=formatSegmentOutput(oo,TAG)
write.table(seg,file=outputPath(outDir,TAG,".seg"),sep="\t",quote=F,row.names=F)

outFile=outputPath(outDir,TAG,".out")
cat("program:","doFacets.R","\n",file=outFile)
catA<-function(...){
    cat(...,"\n",append=T,file=outFile)
}
catA("Rversion:",R.version$version.string)
catA("facetsVersion:",as.character(packageVersion("facets")))
catA("countsFile:",countsFile)
catA("TAG:",TAG)
catA("outDir:",outDir)
catA("genome:",genome)

#> names(oo)
#[1] "jointseg"    "out"         "dipLogR"     "alBalLogR"   "mafR.thresh" "flags"

catA("#[oo]")
catA("oo.dipLogR:",oo$dipLogR)
catA("alBalLogR:",paste(round(as.numeric(oo$alBalLogR),6),sep=":",collapse=":"))
catA("mafR.thres:",oo$mafR.thresh)
for(fi in oo$flags){
    catA("flags:",fi)
}

#> names(ff)
#[1] "purity"  "ploidy"  "dipLogR" "cncf"    "emflags"

catA("#[ff]")
catA("purity:",ff$purity)
catA("polidy:",ff$ploidy)
catA("ff.dipLogR",ff$dipLogR)
for(fi in ff$emflags){
    catA("emflags:", fi)
}

