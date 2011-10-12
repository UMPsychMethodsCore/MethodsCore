#Put some version info or contact info up here


#Read in Options file

optscsv=read.csv('Options.csv',as.is=TRUE)


#Convert options file to options list object, ala struct variable in MATLAB
opts=list()

for (i in 1:nrow(optscsv)){eval(parse(text=paste('opts$',optscsv[i,1],'$',optscsv[i,2],'=c(opts$',optscsv[i,1],'$',optscsv[i,2],',','optscsv[',i,',3])',sep='')))}



#Read in EMerge file
if(opts$Master$Filetype=='csv'){data=read.csv(opts$Master$Filename,as.is=TRUE,skip=opts$Master$SkipRows,fileEncoding = 'UCS-2LE')}
if(opts$Master$Filetype=='tab'){data=read.csv(opts$Master$Filename,as.is=TRUE,skip=opts$Master$SkipRows,sep='\t',fileEncoding = 'UCS-2LE')}
                                
                                
#Drop the clock information cuz those strings are huge
data=data[,!grepl('Clock',names(data))]

#Read in supplemental file. This may contain Tx identifiers, calculated parameters, etc. This needs to contain some sort of meaningful keys
suppl=read.csv(opts$Master$SupplementFile,stringsAsFactors=FALSE)

#Merge EMerge file with supplemental file
data=merge(data,suppl)

#Build up runmapping frame
runmap=data.frame()
for (i in 1:length(opts$Master$RunMap)){
  thing=unlist(strsplit(opts$Master$RunMap[[i]],'_'))
  run=thing[1]
  range=thing[2]
  runmap[i,1]=run
  runmap[i,2]=range
  rm(thing,run,range)
}

newrunmap=data.frame()

for (i in 1:nrow(runmap)){
  runseq=eval(parse(text=runmap[i,2]))
  for (j in 1:length(runseq)){
    newrunmap[nrow(newrunmap)+1,1]=runmap[i,1]
    newrunmap[nrow(newrunmap),2]=runseq[j]
  }
}

runmap=newrunmap;rm(newrunmap)
names(runmap)=c('Run',opts$Master$TrialField)

#Label trials by run by merging runmapping file
data=merge(data,runmap)

#Perform task specific processing steps
flag=0  #This will check whether task type has been properly specified
if(opts$Master$TaskType=='DDT') source(DDT.R); flag=1
if(opts$Master$TaskType=='MSIT') source(MSIT.R); flag=1

if(flag==0){print('No ')} #Print an error message if you've defined a task that doesn't have a corresponding source pointer

