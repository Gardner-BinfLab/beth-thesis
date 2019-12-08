library(ggplot2)
library(ggthemes)
rm(list=ls())
my <-read.table(file = "dates_agg.txt")
mydf <- data.frame(date=c(as.Date(my$V2)), total=c(my$V1))
p <- ggplot(mydf,aes(x=date, y=cumsum(mydf$total))) + geom_area(fill="gray") + geom_rangeframe() + theme_tufte(base_family = "Helvetica") + scale_x_date(name = "Year", date_breaks="1 year", date_labels="%y") + scale_y_continuous(name="Prokaryotic genomes") + theme(text=element_text(size=15))
p <- p + geom_line(colour="gray",size=0.1)
genus <-c("date",
          "total",
          "Streptococcus",
          "Escherichia",
          "Staphylococcus",
          "Mycobacterium",
          "Klebsiella",
          "Pseudomonas",
          "Acinetobacter",
          "Listeria",
          "Campylobacter",
          "Neisseria",
          "Vibrio",
          "Enterococcus",
          "Bacillus",
          "Shigella",
          "Salmonella",
          "Helicobacter",
          "Burkholderia",
          "Enterobacter",
          "Bordetella",
          "Yersinia",
          "Legionella",
          "Haemophilus",
          "Serratia",
          "Stenotrophomonas",
          "Clostridium",
          "Leptospira",
          "Aeromonas",
          "Chlamydia",
          "Corynebacterium",
          "Francisella",
          "Brucella",
          "Pasteurella",
          "Xanthomonas",
          "Bacteroides",
          "Citrobacter",
          "Mycoplasma",
          "Ralstonia",
          "Proteus",
          "Bartonella",
          "Moraxella",
          "Treponema",
          "Xylella",
          "Agrobacterium",
          "Morganella",
          "Rickettsia",
          "Fusobacterium",
          "Anaplasma",
          "Clavibacter",
          "Actinomyces",
          "Streptobacillus",
          "Ehrlichia",
          "Orientia",
          "Edwardsiella",
          "Candidatus",
          "Providencia",
          "Eikenella",
          "Nocardia",
          "Rothia",
          "Borrelia",
          "Peptostreptococcus",
          "Tatlockia",
          "Erysipelothrix",
          "Parachlamydia",
          "Veillonella",
          "Anaerococcus",
          "Neorickettsia",
          "Peptococcus",
          "Rhodococcus"
          )



tmp2 <- matrix(0, nrow = (nrow(mydf)), ncol = 1)
for(x in genus[-c(1,2)]){
  myfile<-paste0("path2/dates/",x,".csv")
  tmp <-read.csv2(file=myfile, sep=",",header = FALSE)
  tmp2 <- tmp2 + tmp$V2
  mydf <-cbind.data.frame(mydf,tmp2)
}
colnames(mydf) <- genus
genus <- genus[-c(1,2)]
a=0
library(RColorBrewer)
#n <- 74
#qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
#col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

for(i in genus){
  mydf[,i] <- cumsum(as.numeric(mydf[,i]))
}

p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Rhodococcus), colour="white",fill="plum1", show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Pseudomonas),colour="white", fill="chocolate1", show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Klebsiella),colour="white", fill="brown1",show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Mycobacterium),colour="white", fill="chartreuse1",show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Staphylococcus),colour="white", fill="cyan1",show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Escherichia), colour="white",fill="gold1", show.legend = TRUE)
p<-p+geom_area(data=mydf,aes(x=mydf$date,y=mydf$Streptococcus), colour="white", fill="mediumpurple1",show.legend = TRUE)
p <- p + scale_fill_identity(name="Species",guide="none",aesthetics="fill",labels=c("Streptococcus",
                                                    "Escherichia",
                                                    "Staphylococcus",
                                                    "Mycobacterium",
                                                    "Klebsiella",
                                                    "Pseudomonas",
                                                    "Other"))
p

