DATE <- function() {gsub("-","",Sys.Date())}
ddir="."
files=dir(ddir,pattern=".R[Dd]ata")
cbs=NULL
for(file in files) {
  print(file)
  load(file.path(ddir,file))
  #d$output[,1]=gsub("___FIXED.*","",d$output[,1])
  if(is.null(cbs)) {
    cbs=out$IGV
  } else {
    cbs=rbind(cbs,out$IGV)
  }
}
cbs$loc.end=as.integer(cbs$loc.end)
cbs$loc.start=as.integer(cbs$loc.start)
write.table(cbs[,1:6],
            file=paste("IGV_",DATE(),".seg",sep=""),
            sep="\t",eol="\n",quote=F,row.names=F)
