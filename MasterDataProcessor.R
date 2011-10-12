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

runmap=newrunmap;rm(newrunmap);rm(runseq)
names(runmap)=c('Run',opts$Master$TrialField)

#Label trials by run by merging runmapping file
data=merge(data,runmap)
rm(runmap)


#Create concatenated Subject Fields
if(!is.null(opts$Master$SubjectCatFields)){
vec=unlist(strsplit(x=opts$Master$SubjectCatFields,split=';'))
for (i in 1:(length(vec))) data$Subject=paste(data$Subject,data[,vec[i]],sep='')
}
rm(vec)

#Calculate Onsets
data$Onsets=data[,opts$Master$TimeField]/1000 #Divide to get it into seconds

#Zero out the onsets
##This for loop contains a really absurd subtraction that could probably be done much better using R functions I don't know. 
##It essentially subsets data for a given subject/run and returns just the onsets, then sets them equal to
##itself minus the min of that subset, in effect zeroing it out.
subruns=unique(data[,c(opts$Master$SubjectField,'Run')])
for (i in 1:nrow(subruns)){  
#   eval(parse(text=paste('min=min(data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\'])',sep='')))
  eval(parse(text=paste('data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\']=data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\']-min(data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\'])',sep='')))
  }
if(!is.null(opts$Master$TimeOffset)) data$Onsets=data$Onsets+as.numeric(opts$Master$TimeOffset)  #add the offset time is defined
rm(subruns)
  
  
#Perform task specific processing steps
flag=0  #This will check whether task type has been properly specified
if(opts$Master$TaskType=='DDT') source(DDT.R); flag=1
if(opts$Master$TaskType=='MSIT') source(MSIT.R); flag=1

if(flag==0){print('No Task Specified')} #Print an error message if you've defined a task that doesn't have a corresponding source pointer


#Prune trials outside of scan time
if(!is.null(opts$Master$RunMax)){
  runmax=data.frame()
  for (i in 1:length(opts$Master$RunMax)){
    thing=unlist(strsplit(opts$Master$RunMax[[i]],'_'))
    run=thing[1]
    max=thing[2]
    runmax[i,1]=run
    runmax[i,2]=max
    rm(thing,run,max)
  }
  names(runmax)=c('Run','RunMaxTime')
  data=merge(data,runmax)
  rm(runmax)
}

data$Onsets=ifelse(data$Onsets+data$TrialDur<=data$RunMaxTime,data$Onsets,NA)


#Calculate FIR onsets

data$FIROnsets=data$Onsets-as.numeric(opts$Master$TR)*as.numeric(opts$Master$FIRpretrial)
data$FIROnsets=ifelse(data$FIROnsets>=0,data$FIROnsets,NA) #Trim off the trials with FIR's extending before the trial
data$FIROnsets=ifelse(data$FIROnsets+as.numeric(opts$Master$TR)*as.numeric(opts$Master$FIRposttrial)<=data$RunMaxTime,data$FIROnsets,NA) #Trim off trials with FIRs extending beyond the scan


#Resort the file
data=with(data,data[order(Subject,Run,get(opts$Master$TrialField)),])

#Write the human readable version
write.csv(data,paste('FULL_',opts$Master$Masterdatafilename,sep=''),quote=FALSE,row.names=FALSE,na='NaN')


#Add the column indices to the top
data=rbind(1:ncol(data),data)  

#Coerce everything to numeric so that MATLAB will be happy
data=apply(data,c(1,2),as.numeric)
data=data.frame(data)
#Write out the master datafile
write.csv(data,opts$Master$Masterdatafilename,quote=FALSE,row.names=FALSE,na='NaN')