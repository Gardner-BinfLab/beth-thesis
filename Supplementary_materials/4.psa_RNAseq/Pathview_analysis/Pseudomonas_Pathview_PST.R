library(pathview)

#Download kegg pathways for pseudomonas syringae pv tomato (pst)
#PNG and XML files deposited into working directroy 

### pathways with >9 significant DEGs across in vitro samples (P<0.0001)
myMapList <- c(
  "02010",
  "02020",
  "01230",
  "01200",
  "02024",
  "02030",
"00230",
"02025",
"00270",
"00620",
"00630",
"00190",
"00280",
"03070",
"00260",
"00650",
"00860",
"02040",
"00790",
"00920",
"00400",
"00310",
"01212",
"00250",
"00362",
"01210",
"03440",
"00010",
"00071",
"00220",
"00240",
"00330",
"00640",
"00970"
)

#comment out this for first run
#for(i in 1:length(myMapList)){
#  download.kegg(pathway.id = paste(myMapList[i]), species = "pst")
#}  


data <- read.csv("pathview_summary_PST.csv",header=TRUE)

dataNames <- data[,1]
myKeggID <- data[,2]


#Set gene names as rownames, subset L2FC expression data
mydataVal <- data[,3:5]
rownames(mydataVal) <- dataNames

#Attach KEGG ID to data
mydataVal <- cbind(myKeggID,mydataVal)
plotData <- mydataVal

#Remove KEGG ID duplicates
myPlotData <- subset(plotData, !duplicated(plotData[,1], select= plotData[,2:4]))

#Set KEGG IDs as rownames .
rownames(myPlotData) <- myPlotData[,1]
myPlotData <- myPlotData[,-1]

dataMatrix <- as.matrix(myPlotData)
head(dataMatrix)

# Logic switch to Write Expression table for each pathway. 1 = ON, Zero = OFF
myLogicSwitch = 1



for(i in 1:length(myMapList)){
  pv.OUT <- NULL
  pv.OUT  <- pathview(gene.data=dataMatrix,
                      pathway.id=paste(myMapList[i]), 
                      species ="pst", 
                      gene.idtype ="KEGG",
                      out.suffix = paste("pathview"), 
                      kegg.native = TRUE,
                      same.layer=F,
                      multi.state = TRUE,
                      node.sum = "max.abs",
                      high="red",
                      low="blue",
                      mid="lightgray",
                      bins=c(20,8),
                      limit=c(-8,8))
  
  if(myLogicSwitch == 1){
    
    myExpresTable <- NULL
    myExpresTable <- pv.OUT$plot.data.gene
    write.csv(myExpresTable, file=paste0("Expression_table_for_",myMapList[i],"_max_Operator.csv")) # Writes the input values that are subset into pathway tables
    
  }
  
}



