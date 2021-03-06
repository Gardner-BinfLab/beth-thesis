
######################################################################
#FIGURE 3!!!!!!!!!!!!!!!

rfam<-read.table("~/Dropbox/PhD/sRNA_review/figure_3/rfamExpressionConservation2.dat",header=TRUE)
pfam<-read.table("~/Dropbox/PhD/sRNA_review/figure_3/pfamExpressionConservation2.dat",header=TRUE)

bk<-50
breaks<-seq(min(pfam$maxF84)-0.01,max(pfam$maxF84)+0.01,length.out=bk)
rlisH<-hist(rfam$maxF84[rfam$maxF84>0], breaks=breaks, plot=FALSE)
plisH<-hist(pfam$maxF84[pfam$maxF84>0], breaks=breaks, plot=FALSE)

cumR<-0*seq(bk, 1)
cumP<-0*seq(bk, 1)
cumF<-0*seq(bk, 1)
cumR[bk]<-rlisH$counts[bk-1]
cumP[bk]<-plisH$counts[bk-1]
for (i in seq(bk-1, 2)){    
     cumR[i]<-cumR[i+1]+rlisH$counts[i-1]    
     cumP[i]<-cumP[i+1]+plisH$counts[i-1]    
}
cumR<-cumR/max(cumR)
cumR[1]<-1.0
cumP<-cumP/max(cumP)
cumP[1]<-1.0

brks<-seq(0,0.625,by=0.02)
rfamFracCons<-0*1:(length(brks)-1)
pfamFracCons<-0*1:(length(brks)-1)
colNames<-0*1:(length(brks)-1)
phylodist<-0*1:(length(brks)-1)
for(i in 1:(length(brks)-1)){      
      rfamFracCons[i]<-max(cumR[brks[i]<rlisH$breaks & rlisH$breaks<=brks[i+1]])	 
      pfamFracCons[i]<-max(cumP[brks[i]<rlisH$breaks & rlisH$breaks<=brks[i+1]])	 
      colNames[i]<-paste(sprintf("%0.3f",brks[i]), sep="")
      phylodist[i]  <-brks[i]
}
fracCons <- matrix(100*c(pfamFracCons, rfamFracCons), nrow = 2, ncol=(length(brks)-1), byrow=TRUE,
                    dimnames = list(c("Pfam (N=6671)", "Rfam (N=331)"),
                                    colNames))

superkingdom<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/superkingdom-phyla.phylodOut2.processed"); superkingdomQ<-quantile(superkingdom$V2, probs = c(0,0.25,0.5,0.75,1.0))
phyla<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/phyla-class.phylodOut2.processed"); phylaQ<-quantile(phyla$V2, probs = c(0,0.25,0.5,0.75,1.0))
class<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/class-order.phylodOut2.processed"); classQ<-quantile(class$V2, probs = c(0,0.25,0.5,0.75,1.0))
order<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/order-family.phylodOut2.processed"); orderQ<-quantile(order$V2, probs = c(0,0.25,0.5,0.75,1.0))
family<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/family-genus-small.phylodOut2.processed"); familyQ<-quantile(family$V2, probs = c(0,0.25,0.5,0.75,1.0))
genus<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/genus-species-small.phylodOut2.processed"); genusQ<-quantile(genus$V2, probs = c(0,0.25,0.5,0.75,1.0))

arebaD<-read.table("~/Dropbox/PhD/sRNA_review/figure_2/areba-phylodists.dat")
arebaDH<-hist(arebaD$V3, breaks=500, plot=FALSE)

phyloD<-matrix(c(superkingdomQ,phylaQ, classQ, orderQ, familyQ, genusQ), nrow=5, ncol=6,dimnames = list(c("0.00","0.25","0.50","0.75","1.00"),c("Kingdom","Phylum", "Class", "Order", "Family", "Genus")))

xout<-seq(95,75, by=-0.01)
rGZ<-approx(fracCons[2,], phylodist, xout = xout, ties='mean')
pGZ<-approx(fracCons[1,], phylodist, xout = xout, ties='mean')


pdf(file="~/Dropbox/PhD/sRNA_review/figure_2/fracConsMaxDnadistF84-lineplot2-1.pdf", width=22, height=24)
par(fig = c(0, 1, 0.25, 1))
par(las=2,cex=3.5,mar=c(7, 5, 4, 2) + 0.1, mgp=c(1.8,0.4,0)) #mar: bottom, left, top, right; fig: x1, x2, y1, y2
plot(phylodist, fracCons[2,], type="l", axes=FALSE, bty="n",xlab="Phylogenetic Distance", ylab="Conserved families (%)",col="indianred1", lwd=12,xlim=c(0,0.6),ylim=c(0,100),yaxs="i", xaxs="i")
xlabs<-c("","","0.2","","0.4","","0.6")
axis(side=1, col="grey", col.ticks = "darkgrey", tck=-0.02, at=c(0,0.1,0.2,0.3,0.4,0.5,0.6), labels=xlabs[0:7], las=1)
axis(side=2, col="grey", col.ticks = "darkgrey", tck=-0.02)
for (i in 1:length(xout)){    
    lines(c(pGZ$y[i],pGZ$y[i]),  c(0,xout[i]), col="cornflowerblue", lwd=12)
    lines(c(rGZ$y[i],rGZ$y[i]),  c(0,xout[i]), col="indianred1", lwd=12)
}
lines(phylodist, fracCons[2,],  col="red3", lwd=16)
lines(phylodist, fracCons[1,],  col="blue3", lwd=16)

legend("topright", rownames(fracCons), bty="n",fill= c("blue", "red"))
xgz<-approx(fracCons[2,], phylodist, xout = c(95,75), ties='mean')$y

par(lty=3,lwd=0.5,col="gray")
#abline(h=0:10/10,); abline(v=0:12/20)
par(fig = c(0.00, 1.00, 0.0, 0.5), new = T)
par(las=1,cex=3.5,mar=c(5, 5, 4, 2) + 0.1)


boxplot(phyloD,horizontal = T,ylim=c(0,0.6), xlab="", xaxt="n",range=0,outline=FALSE,axes=FALSE,frame = FALSE,boxlty=0, boxwex=0.5, staplewex=0.8,boxlwd=2, col="lightgray", medlty=2, medlwd=3,whisklty=0) #col=c("seashell","papayawhip","peachpuff","peachpuff1","peachpuff2","peachpuff3"), 
glabs=c("Kingdom","Phylum","Class","Order","Family","Genus")
axis(side=2, col="White", at=c(1,2,3,4,5,6), labels=glabs[0:6])

jitter <- rnorm(length(superkingdom$V2), 0, 0.06)
points(superkingdom$V2, rep(1,length(superkingdom$V2))+jitter, pch=20, cex=0.2, col="black" )
jitter <- rnorm(length(phyla$V2), 0, 0.06)
points(phyla$V2, rep(2,length(phyla$V2))+jitter, pch=20, cex=0.2, col="black")
jitter <- rnorm(length(class$V2), 0, 0.06)
points(class$V2, rep(3,length(class$V2))+jitter, pch=20, cex=0.2, col="black" )
jitter <- rnorm(length(order$V2), 0, 0.06)
points(order$V2, rep(4,length(order$V2))+jitter, pch=20, cex=0.2, col="black" )
jitter <- rnorm(length(family$V2), 0, 0.06)
points(family$V2, rep(5,length(family$V2))+jitter, pch=20, cex=0.2, col="black" )
jitter <- rnorm(length(genus$V2), 0, 0.06)
points(genus$V2, rep(6,length(genus$V2))+jitter,pch=20, cex=0.2, col="black" )
par(new=T)
boxplot(phyloD,horizontal = T,ylim=c(0,0.6), xlab="", xaxt="n",range=0,outline=FALSE,axes=FALSE,frame = FALSE,border="grey22",boxlty=0, boxwex=0.5, staplewex=0.8, staplelty=1, staplelwd=5, boxlwd=2,medlty=1, medlwd=5,whisklty=0) #col=c("seashell","papayawhip","peachpuff","peachpuff1","peachpuff2","peachpuff3"), 


dev.off()


#Pfam GZ:	
approx(fracCons[1,], phylodist, xout = c(95,75), ties='mean')
#0.1332647 0.3391833
#Rfam GZ:	
approx(fracCons[2,], phylodist, xout = c(95,75), ties='mean')
#0.01182143 0.05416667



