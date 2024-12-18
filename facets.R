png_cairo<-function(filename,res=300,units="in",pointsize=12,...) {
    png(filename=filename,res=res,units=units,pointsize=pointsize,...)
}

process_sample<-function(rcmat,cval) {

    ii=1
    repeat({

        rr=try({

            xx=preProcSample(rcmat)
            oo=procSample(xx,cval=cval)

        })

        if(class(rr)!="try-error") {
            break
        }

        cat("\nretry ",ii,"\n")
        ii=ii+1

    })

    rr

}

suppressPackageStartupMessages({
    require(facets)
    require(argparser)
    require(tidyverse)
})

p <- arg_parser("Round a floating point number") %>%
    add_argument("pileup", help="pileup file from snp-pileup", type="character") %>%
    add_argument("--sample_id", help="sample id", default="") %>%
    add_argument("--output_dir", help="output folder", default="") %>%
    add_argument("--cval",help="cval for facets::procSample",default=100) %>%
    add_argument("--seed", help="random seed", default=42)

argv=parse_args(p)
if(argv$sample_id=="") {
    argv$sample_id=basename(argv$pileup) %>% gsub(".gz$","",.) %>% gsub(".txt","",.)
}

set.seed(argv$seed)

if(argv$output_dir=="") {
    argv$output_dir=file.path("out","facets",argv$sample_id)
}

fs::dir_create(argv$output_dir)
cat("output_dir =",argv$output_dir,"\n")

rcmat=readSnpMatrix(argv$pileup)

# xx=preProcSample(rcmat)
# oo=procSample(xx,cval=argv$cval)

oo=process_sample(rcmat,argv$cval)

fit=emcncf(oo)

png_cairo(file.path(argv$output_dir,cc(argv$sample_id,"profile.png")),height=11,width=8.5)
plotSample(oo,emfit=fit,sname=argv$sample_id)
dev.off()

png_cairo(file.path(argv$output_dir,cc(argv$sample_id,"spider.png")),height=6,width=6)
logRlogORspider(oo$out,oo$dipLogR)
dev.off()

