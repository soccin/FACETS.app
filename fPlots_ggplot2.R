require(ggplot2)

############################################################################################################################################
############################################################################################################################################
# Multiple plot function from http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    #grid.text("MAIN TITLE", vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

############################################################################################################################################
############################################################################################################################################

copy.number.log.ratio = function(mat, cncf, mid, dipLogR, main='', col.1="#0080FF", col.2="#4CC4FF"){
    
    col.rep = 1 + rep(cncf$chr - 2 * floor(cncf$chr/2), cncf$num.mark)
    cnlr.median = rep(cncf$cnlr.median, cncf$num.mark)
    
    cnlr = ggplot(mat, aes(y=cnlr,x=chr.maploc), environment = environment()) + 
    geom_point(colour=c(col.1, col.2)[col.rep], size=.8) + 
    scale_x_continuous(breaks=mid, labels=names(mid)) + 
    xlab('') +
    ylim(-3,3) +
    ylab('Log-Ratio') +
    geom_hline(yintercept = dipLogR, color = 'white', size = 1) + 
      geom_point(aes(x=chr.maploc,y=cnlr.median),size=.8,colour='red3') +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8),
          axis.text.y = element_text(angle=90, vjust=0.5, size=8)) +
    ggtitle(main)
  cnlr
}

var.allele.log.odds.ratio = function(mat, cncf, mid, col.1="#0080FF", col.2="#4CC4FF", main=''){
  
  col.rep = 1 + rep(cncf$chr - 2 * floor(cncf$chr/2), cncf$num.mark)
  mafR = rep(sqrt(abs(cncf$mafR)), cncf$num.mark)
  
  valor = ggplot(mat,aes(y=valor,x=chr.maploc), environment = environment()) +
    geom_point(colour=c(col.1,col.2)[col.rep], size=.8) +
    scale_x_continuous(breaks=mid, labels=names(mid)) +  
    xlab('') +
    ylim(-4,4) +
    ylab('Log-Odds-Ratio') +
    geom_point(aes(x=chr.maploc,y=mafR), size=.8,colour='red3') +
    geom_point(aes(x=chr.maploc,y=-mafR), size=.8,colour='red3') +
    theme(axis.text.x = element_text(angle=90, vjust=0.5, size=8),
          axis.text.y = element_text(angle=90, vjust=0.5, size=8))
  valor
}

cellular.fraction = function(mat, cncf, mid, method=c("cncf","em"),main=''){
  
  if(method == "em"){cncf$cf.em[is.na(cncf$cf.em)] = -1; test = rep(cncf$cf.em, cncf$num.mark); my.ylab='Cellular fraction (EM)'}

  if(method == "cncf"){cncf$cf[is.na(cncf$cf)] = -1; test = rep(cncf$cf, cncf$num.mark); my.ylab='Cellular fraction (CNCF)'}
  
  cf = qplot(y=test,x=mat$chr.maploc, ylim=c(0,1), ylab=my.ylab, size=I(0.8),environment = environment()) + 
    scale_x_continuous(breaks=mid, labels=names(mid)) + 
    xlab('') +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8),
          axis.text.y = element_text(angle=90, vjust=0.5, size=8))
  cf
}


integer.copy.number = function(mat, cncf, mid, method=c("cncf","em"), main=''){
  
  if(method == 'em'){tcnscaled = cncf$tcn.em; tcnscaled[cncf$tcn.em > 5 & !is.na(cncf$tcn.em)] = (5 + (tcnscaled[cncf$tcn.em > 5 & !is.na(cncf$tcn.em)] - 5)/3)}
  if(method == 'cncf'){tcnscaled = cncf$tcn; tcnscaled[cncf$tcn > 5 & !is.na(cncf$tcn)] = (5 + (tcnscaled[cncf$tcn > 5 & !is.na(cncf$tcn)] - 5)/3)}
  tcn_ = rep(tcnscaled, cncf$num.mark)
  
  if(method == 'em'){lcn_ = rep(cncf$lcn.em, cncf$num.mark); my.ylab='Integer copy number (EM)'}
  if(method == 'cncf'){lcn_ = rep(cncf$lcn, cncf$num.mark); my.ylab='Integer copy number (CNCF)'}
  
  icn = ggplot(as.data.frame(cbind(tcn_,mat$chr.maploc)),aes(y=tcn_, x=mat$chr.maploc), environment = environment()) + 
    geom_point(size=.9) +
    scale_y_continuous(breaks=c(0:5, 5 + (1:35)/3), labels=0:40,limits = c(0, NA)) + 
    scale_x_continuous(breaks=mid, labels=names(mid)) + 
    ylab(my.ylab) +
    xlab('') +
    geom_point(y=lcn_,x=mat$chr.maploc,color='red',size=.8) +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8),
          axis.text.y = element_text(angle=90, vjust=0.5, size=8)) 
  icn
}


get.cumlative.chr.maploc = function(mat, load.genome=FALSE){

  if(load.genome){
    require(BSgenome.Hsapiens.UCSC.hg19)
    genome = BSgenome.Hsapiens.UCSC.hg19
    chrom.lengths = seqlengths(genome)[1:22]
  }
  else{
    chrom.lengths = c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067, 159138663, 146364022, 141213431, 135534747,135006516, 
                      133851895, 115169878, 107349540, 102531392, 90354753,  81195210,  78077248,  59128983,  63025520, 48129895,  51304566) #hg19
  }
  
  cum.chrom.lengths = cumsum(as.numeric(chrom.lengths))
  mid = cum.chrom.lengths - (chrom.lengths/2)
  names(mid) = 1:22
  
  chr.maploc.to.gen.maploc = function(x){mat[mat$chrom==x,]$maploc + cum.chrom.lengths[x-1]}
  chr.maploc = sapply(2:22,chr.maploc.to.gen.maploc)
  chr.maploc = unlist(chr.maploc)
  chr.maploc = c(mat[mat$chrom==1,]$maploc,chr.maploc)
  mat = cbind(mat,chr.maploc)
  
  list(mat=mat, mid=mid)
}

get.gene.pos = function(hugo.symbol,my.path='/ifs/work/taylorb/donoghum/reference_sequences/Homo_sapiens.GRCh37.75.canonical_exons.bed',load.genome=FALSE){
  
  if(load.genome){
    require(BSgenome.Hsapiens.UCSC.hg19)
    genome = BSgenome.Hsapiens.UCSC.hg19
    chrom.lengths = seqlengths(genome)[1:22]
  }
  else{
    chrom.lengths = c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067, 159138663, 146364022, 141213431, 135534747,135006516, 
                      133851895, 115169878, 107349540, 102531392, 90354753,  81195210,  78077248,  59128983,  63025520, 48129895,  51304566) #hg19
  }
  
  cum.chrom.lengths = cumsum(as.numeric(chrom.lengths))
  
  require(rtracklayer)
  genes = import.bed(my.path)
  mcols(genes)$name = matrix(unlist(strsplit(mcols(genes)$name,':')),nc=3,byrow=T)[,1]
  gene.start = min(start(genes[which(mcols(genes)$name == hugo.symbol)]))
  gene.end = max(end(genes[which(mcols(genes)$name == hugo.symbol)]))
  mid.point = gene.start + ((gene.end - gene.start)/2) 
  chrom = seqnames(genes[which(mcols(genes)$name == 'AKT1')])[1]  
  mid.point = cum.chrom.lengths[as.integer(chrom)-1] + mid.point
  
  mid.point
}

#Standard facets output plot
plot.facets.all.output = function(out, fit, w=850, h=1100, type='png', load.genome=FALSE, main='', plotname='test.png'){
    
  mat = out$jointseg
  mat = subset(mat, chrom < 23)
  mat = get.cumlative.chr.maploc(mat, load.genome)
  mid = mat$mid
  mat = mat$mat

  cncf = fit$cncf
  cncf = subset(cncf, chrom < 23)
  dipLogR = out$dipLogR
  sample = out$IGV$ID[1]
  
  cnlr = copy.number.log.ratio(mat, cncf, mid, dipLogR, main=main) #; cnlr
  valor = var.allele.log.odds.ratio(mat, cncf, mid) #; valor
  cfem = cellular.fraction(mat, cncf, mid, 'em') #; cfem
  cfcncf = cellular.fraction(mat, cncf, mid, 'cncf') #; cfcncf
  icnem = integer.copy.number(mat, cncf, mid, 'em') #; icnem
  icncncf = integer.copy.number(mat, cncf, mid, 'cncf') #; icncncf
    
  layout = matrix(c(1,2,3,4,5,6), nrow = 6, byrow = TRUE)
  if(type == 'pdf'){pdf(width = w, height=h, file=plotname, units='px')}
  if(type == 'png'){png(width = w, height=h, file=plotname, units='px')}
  multiplot(plotlist = list(cnlr, valor, cfem, icnem, cfcncf, icncncf), layout = layout)
  dev.off()
}


close.up = function(out, fit, chrom.range, method=NULL, gene.pos=NULL, main=''){
  
  mat = out$jointseg
  mat = subset(mat, chrom < 23)
  mat = get.cumlative.chr.maploc(mat, FALSE)
  mid = mat$mid
  mat = mat$mat
  
  cncf = fit$cncf
  cncf = subset(cncf, chrom < 23)
  dipLogR = out$dipLogR
  sample = out$IGV$ID[1]
  
  mat = mat[mat$chrom %in% chrom.range,]
  cncf = cncf[cncf$chrom %in% chrom.range,]
  mid = mid[chrom.range]
  
  cnlr = copy.number.log.ratio(mat, cncf, mid, dipLogR, main=main)
  valor = var.allele.log.odds.ratio(mat, cncf, mid)
  cfem = cellular.fraction(mat, cncf, mid, 'em')
  cfcncf = cellular.fraction(mat, cncf, mid, 'cncf')
  icnem = integer.copy.number(mat, cncf, mid, 'em')
  icncncf = integer.copy.number(mat, cncf, mid, 'cncf')
  
  if(!is.null(gene.pos)){
    cnlr = cnlr + geom_vline(xintercept=gene.pos, color='palevioletred1')
    valor = valor + geom_vline(xintercept=gene.pos, color='palevioletred1')
    cfem = cfem + geom_vline(xintercept=gene.pos, color='palevioletred1')
    cfcncf = cfcncf + geom_vline(xintercept=gene.pos, color='palevioletred1')
    icnem = icnem + geom_vline(xintercept=gene.pos, color='palevioletred1')
    icncncf = icncncf + geom_vline(xintercept=gene.pos, color='palevioletred1')
  }
  list(cnlr=cnlr,valor=valor,cfem=cfem,cfcncf=cfcncf,icnem=icnem,icncncf=icncncf)
}

