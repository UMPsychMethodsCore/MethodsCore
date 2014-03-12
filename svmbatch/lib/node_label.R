
raw=read.table('nodes.node')
raw$sort=1:nrow(raw)


labels=read.csv('NodesOutput_culled.csv',stringsAsFactors=FALSE,header=FALSE)
labels=labels[,c(1:3,5,9)]
names(labels)[c(4,5)]=c('Region','Network')
head(labels)

data=merge(raw,labels,all.x=TRUE)

data=data[order(data$sort),]


data$V4=as.integer(as.factor(data$Network))
data$V4[is.na(data$V4)]=max(data$V4,na.rm=TRUE)+1

data=data[,1:6]
write.table(data,'LabeledNodes.node',quote=FALSE,row.names=FALSE,col.names=FALSE)
