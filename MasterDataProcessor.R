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
names(runmap)=c(opts$Master$TrialField,'range')
  
#Label trials by run
  
names(data)[grep(opts$Master$TrialField,names(data))]='Trial'
  
for (i in 1:nrow(data)) {
#Now loop over
  
  


