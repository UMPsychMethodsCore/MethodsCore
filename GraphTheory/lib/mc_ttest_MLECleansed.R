colclass = 'character'
names(colclass) = 'Subject'

global = read.csv('/net/data4/Autism/GraphTheory/0426/MotionScrubbed/Measure_global.csv',colClasses = colclass)

# number of sparsities

s = 6

# number of networks
w = 7

# number of metrics
m = 6

avelength <-length(global$Subject)/s

aveSubs<- global$Subject[seq(1,length(global$Subject),s)]

aveType <- global$Type[seq(1,length(global$Subject),s)]

aveNets <- global$Network[seq(1,length(global$Network),s)]

aveglobal <- data.frame(Subject = aveSubs,TYPE = aveType,Network = aveNets,Clustering = c(rep(0,avelength)),CharacteristicPathLength = c(rep(0,avelength)),Transitivity = c(rep(0,avelength)),GlobalEfficiency = c(rep(0,avelength)),Modularity = c(rep(0,avelength)),Assortativity = c(rep(0,avelength)))

n = 0;

for (aveSub in  global$Subject[seq(1,length(global$Subject),w*s)]) {
  
  for (aveNet in c(1:w)){
    n = n+1;
    
    subtable = global[which(global$Subject == aveSub & global$Network == aveNet),]
    
    aveglobal$Clustering[n]               = mean(subtable$Clustering)
    aveglobal$CharacteristicPathLength[n] = mean(subtable$CharateristicPathLength)
    aveglobal$Transitivity[n]             = mean(subtable$Transitivity)
    aveglobal$GlobalEfficiency[n]         = mean(subtable$GlobalEfficiency)
    aveglobal$Modularity[n]               = mean(subtable$Modularity)
    aveglobal$Assortativity[n]            = mean(subtable$Assortativity)
  }
}



write.csv(aveglobal,'/net/data4/Autism/GraphTheory/0426/MotionScrubbed/Measure_global_aveSpars.csv',row.names=FALSE)
data = aveglobal

metrics = c(rep(c('Clustering','CharacteristicPathLength','Transitivity','GlobalEfficiency','Modularity','Assortativity'),w))

nets = c(rep(1,m),rep(2,m),rep(3,m),rep(4,m),rep(5,m),rep(6,m),rep(7,m))

output = data.frame(Metric = metrics,Network = nets, HCmean = c(rep(0,m*w)),DSmean = c(rep(0,m*w)),pValue = c(rep(0,m*w)))

n = 0

for (net in c(1:w)) {

  for (metric in c('Clustering','CharacteristicPathLength','Transitivity','GlobalEfficiency','Modularity','Assortativity')) {
  
       n = n+1   

       myform = reformulate('TYPE',metric)

       result = t.test(myform,data[data$Network == net,],var.equal = TRUE)

       output$HCmean[n]= result$estimate[1]

       output$DSmean[n] = result$estimate[2]

       output$pValue[n] = result$p.value
     

   }


 }

write.csv(output,'/net/data4/Autism/GraphTheory/0426/MotionScrubbed/test_results_aveSpars.csv',row.names=FALSE)


output[which(output$pValue<0.05),]

