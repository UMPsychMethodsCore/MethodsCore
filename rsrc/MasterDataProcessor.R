#See README file included with this distribrution for help and authorship information

#Setup some directories
pkgdir=getwd() #The directory where the package resides.
srcdir=file.path(pkgdir,'rsrc') #The directory that holds all the src code (and thus directory from which this central script is being run)
inputdir=file.path(pkgdir,'input') #Directory where input files are expected
configdir=file.path(pkgdir,'config') #Directory where config files are expected
outdir=file.path(pkgdir,'output') #Directory where output will be sent

#Read in Options file
optscsv=read.csv(file.path(configdir,'Options.csv'),as.is=TRUE)
optscsv=optscsv[optscsv$OptionOn==1,-3]

#Convert options file to options list object, ala struct variable in MATLAB
opts=list()

for (i in 1:nrow(optscsv)){eval(parse(text=paste('opts$',optscsv[i,1],'$',optscsv[i,2],'=c(opts$',optscsv[i,1],'$',optscsv[i,2],',','optscsv[',i,',3])',sep='')))}

#If a custom run field name is used, use that, if not, use the default "Run"
if(!is.null(opts$Master$RunField)){runfieldname=opts$Master$RunField} else {runfieldname='Run'}

#Read in EMerge file
setwd(inputdir) #Set your working directory to the input directory. This way, regardless of whether the user specified the full path to the file or a relative path, it will still work
if(opts$Master$Filetype=='csv'){data=read.csv(opts$Master$Filename,as.is=TRUE,skip=opts$Master$SkipRows,fileEncoding = 'UCS-2LE')}
if(opts$Master$Filetype=='tab'){data=read.csv(opts$Master$Filename,as.is=TRUE,skip=opts$Master$SkipRows,sep='\t',fileEncoding = 'UCS-2LE')}
                                
                                
#Drop the clock information cuz those strings are huge
data=data[,!grepl('Clock',names(data))]


#Read in supplemental file. This may contain Tx identifiers, calculated parameters, etc. This needs to contain some sort of meaningful keys
setwd(inputdir) #Make sure you're in the input directory, just in case
if(!is.null(opts$Master$SupplementFile)){ suppl=read.csv(opts$Master$SupplementFile,stringsAsFactors=FALSE)

#Merge EMerge file with supplemental file
data=merge(data,suppl)
}
                                          
if(is.null(opts$Master$RunField)){

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
}

if(!is.null(opts$Master$RunField)){data$Run=with(data,get(opts$Master$RunField))}

#Create concatenated Subject Fields
if (is.null(data$Subject)) data$Subject=NA; data$Subject=with(data,get(opts$Master$SubjectField))  #If there is no field explicitly called subject, initialize it, and copy their subject info into it
if(!is.null(opts$Master$SubjectCatFields)){
  data$SubjectPreCat=with(data,get(opts$Master$SubjectField))  #Protect their preconcatenated subject fields in SubjectPreCat
  vec=unlist(strsplit(x=opts$Master$SubjectCatFields,split=';'))
  for (i in 1:(length(vec))) data$Subject=paste(data$Subject,data[,vec[i]],sep='')
  
  rm(vec)
}
#Calculate Onsets
data$Onsets=data[,opts$Master$TimeField]/1000 #Divide to get it into seconds

#Zero out the onsets
##This for loop contains a really absurd subtraction that could probably be done much better using R functions I don't know. 
##It essentially subsets data for a given subject/run and returns just the onsets, then sets them equal to
##itself minus the min of that subset, in effect zeroing it out.
subruns=unique(data[,c(opts$Master$SubjectField,'Run')])
for (i in 1:nrow(subruns)){  
  eval(parse(text=paste('data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\']=data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\']-min(data[data$',opts$Master$SubjectField,'==subruns[i,1] & data$Run==subruns[i,2],\'Onsets\'])',sep='')))
  }
if(!is.null(opts$Master$TimeOffset)) data$Onsets=data$Onsets+as.numeric(opts$Master$TimeOffset)  #add the offset time is defined

rm(subruns)
  
#Remap trial types
if(!is.null(opts$Master$TrialTypeMap)){
  trialmap=data.frame()
  for (i in 1:length(opts$Master$TrialTypeMap)){
    thing=unlist(strsplit(opts$Master$TrialTypeMap[[i]],'_'))
    trialname=thing[1]
    trialnum=thing[2]
    trialmap[i,1]=trialname
    trialmap[i,2]=trialnum
    rm(thing,trialname,trialnum)
  }
  names(trialmap)=c(opts$Master$TrialTypeField,'TrialTypeNum')
  data=merge(data,trialmap)
  rm(trialmap)
} else {data=within(data,expr={TrialTypeNum=get(opts$Master$TrialTypeField)})}

  
#Perform task specific processing steps
flag=0  #This will check whether task type has been properly specified
if(opts$Master$TaskType=='DDT') source(file.path(srcdir,'DDT.R'),echo=TRUE); flag=1
if(opts$Master$TaskType=='MSIT') source(file.path(srcdir,'MSIT.R'),echo=TRUE); flag=1

if(flag==0){print('No Task Specified')} #Print an error message if you've defined a task that doesn't have a corresponding source pointer



#Prune trials outside of scan time
#if(!is.null(opts$Master$RunMaxDefault)){
#  runmax=data.frame()
#  for (i in 1:length(opts$Master$RunMaxDefault)){
#    thing=unlist(strsplit(opts$Master$RunMaxDefault[[i]],'_'))
#    run=thing[1]
#    max=thing[2]
#    runmax[i,1]=run
#    runmax[i,2]=max
#    rm(thing,run,max)
#  }
#  names(runmax)=c('Run','RunMaxTime')
#  data=merge(data,runmax)
#  rm(runmax)
#}

#if(!is.null(opts$Master$RunMaxFile)){
#  setwd(inputdir) #set to input directory just in case
#  frameinfo=read.csv(opts$Master$RunMaxFile,stringsAsFactors=FALSE)
#  if(!is.null(opts$Master$SubjectCatFields)) names(frameinfo)[grep('Subject',names(frameinfo))]='SubjectPreCat' #change the name of the subject field in the frame info file to match the protected one, if there were subject field concatenations performed
#  names(frameinfo)[ncol(frameinfo)]='RunMaxTime2'
#  data=merge(data,frameinfo,all.x=TRUE) #Merge in your runmax/frameinfo file with your subjects, retaining all edat rows (as these will fall back on the defaults)
#  if(!is.null(opts$Master$RunMaxDefault)) data$RunMaxTime=ifelse(!is.na(data$RunMaxTime2),data$RunMaxTime2,data$RunMaxTime);data$RunMaxTime2=NULL
#}


#data$RunMaxTime=as.numeric(data$RunMaxTime) #Coerce RunMax times to numerics, otherwise comparisons below are really weird
#data$Onsets=ifelse(data$Onsets+data$TrialDur<=data$RunMaxTime,data$Onsets,NA)

#Add your trial by trial regressors, if turned on
if(!is.null(opts$Master$TrialByTrial) & opts$Master$TrialByTrial %in% c(1,2)) {
  subruns=unique(data[,c('Subject','Run')]) #Get list of unique subject-run combinations (postcat if applicable) to iterate over
  data$TrialByTrial=NA
  
  for (i in 1:nrow(subruns)){
    sublogic=with(data,get(opts$Master$SubjectField))==subruns[i,1] #ID only those rows with current subject
    timelogic=!is.na(with(data,get('Onsets')))
    if(opts$Master$TrialByTrial==1) trialtypelogic=!is.na(with(data,get('TrialTypeNum'))) #ID only those rows where trialtype is defined
    if(opts$Master$TrialByTrial==2) trialtypelogic=!is.na(with(data,get('TrialTypeNumAccOnly'))) #ID only those rows where trialtype is defined and accurate (ONLY if you're in trial-by-trial MSIT mode which has a special feature for accurate trials only)
    supalogic=sublogic & timelogic & trialtypelogic #Find the logical intersection of all your above logic
    
    
    templength=length(data[supalogic,][order(with(data[supalogic,],get(opts$Master$TrialField))),]$TrialByTrial)
    data[supalogic,][order(with(data[supalogic,],get(opts$Master$TrialField))),]$TrialByTrial=1:templength
    rm(sublogic,timelogic,trialtypelogic,supalogic,templength)
  }
  rm(subruns)
}
  
    

#Calculate FIR onsets

data$FIROnsets=data$Onsets-as.numeric(opts$Master$TR)*as.numeric(opts$Master$FIRpretrial)
#data$FIROnsets=ifelse(data$FIROnsets>=0,data$FIROnsets,NA) #Trim off the trials with FIR's extending before the trial
#data$FIROnsets=ifelse(data$FIROnsets+as.numeric(opts$Master$TR)*as.numeric(opts$Master$FIRposttrial)<=data$RunMaxTime,data$FIROnsets,NA) #Trim off trials with FIRs extending beyond the scan






#Resort the file
data=with(data,data[order(Subject,get(runfieldname),get(opts$Master$TrialField)),])

#Introduce parametric decay if option enabled, best to do this after sorting so trials are in proper sequence
if(!is.null(opts$Master$ParametricTrialDecaySlope) & opts$Master$ParametricTrialDecaySlope!=0){
  subruns=unique(data[,c('Subject','Run')]) #Get list of unique subject-run combinations (postcat if applicable) to iterate over
  if(as.numeric(opts$Master$ParametricTrialDecaySlope)>0) {startpt=0;stoppt=1;} else {startpt=1;stoppt=0}
  
  attach(data)
  data$DecayParameter=NA
  for (i in 1:nrow(subruns)){  
  data[get(opts$Master$SubjectField)==subruns[i,1] & get(runfieldname)==subruns[i,2],]$DecayParameter=
    seq(from=startpt,to=stoppt,length.out=
    nrow(data[get(opts$Master$SubjectField)==subruns[i,1] & get(runfieldname)==subruns[i,2],]))
  }
  detach(data)
}

#Write the human readable version
setwd(outdir) #change to the output directory
write.csv(data,paste('FULL_',opts$Master$Masterdatafilename,sep=''),quote=FALSE,row.names=FALSE,na='NaN')


#Add the column indices to the top
data=rbind(1:ncol(data),data)  

#Coerce everything to numeric so that MATLAB will be happy
data=apply(data,c(1,2),as.numeric)
data=data.frame(data)
#Write out the master datafile
setwd(outdir) #change to the output directory
write.csv(data,opts$Master$Masterdatafilename,quote=FALSE,row.names=FALSE,na='NaN')
