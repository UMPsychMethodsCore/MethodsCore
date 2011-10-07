#This file will build a masterdatafile for both HRD and FIR analysis for the MSIT task.
#It requires
# 1) A merged edat file converted to CSV
# 2) A TxInfo file that maps Subject Ids + Session to Treatments
# 3) A frameinfo file that maps 



TxInfo=read.csv('MSIT_TxInfo.csv',stringsAsFactors=FALSE)  #This file has info that keys Subject & Session to Tx
data2=read.csv('MSIT-MainRun-MergedFixed.csv',stringsAsFactors=FALSE) #This is the raw, merged file

frameinfo=read.csv('FrameInfo_MSIT.csv',stringsAsFactors=FALSE)
frameinfodefault=c(220,235) #values for block 1 and 2 respectively to use for frameinfo when not otherwise specified


names(frameinfo)[5]='RunDir'
names(frameinfo)[1]='Subject'



mast=data2[,0] #Create dataframe with same number of rows as data2


RespCalc=function(stimRESP,jitRESP,srcind){
  resp=NA
  src=''
  stimRESP=as.numeric(stimRESP)
  jitRESP=as.numeric(jitRESP)
  if (!is.na(stimRESP)){resp=stimRESP;src='stim'}
  if(is.na(stimRESP)){resp=jitRESP;if(!is.na(jitRESP)){src='jit'}}
  if(srcind=='resp'){return(resp)}
  if(srcind=='src'){return(src)}
}

mast$Subject=data2$Subject
mast$Session=data2$Session



mast$Trial=data2$Block  #Just use the prespecified trial sequence, encoded as "block" in the original file
mast$Block[mast$Trial %in% 1:100]=1  #This will get renamed to "run" later
mast$Block[mast$Trial %in% 101:200]=2


##CALCULATE A SIMULATED RESPONSE

mast$StimResp=data2$MSITStim.RESP
mast$JitterResp=data2$JitterFix.RESP
mast$StimRT=data2$MSITStim.RT
mast$StimDur=data2$MSITStim.Duration
mast$JitterRT=data2$JitterFix.RT

mast$Resp=mapply(RespCalc,mast$StimResp,mast$JitterResp,'resp')  #Why is there an X in the MSIT Stim Resp?
mast$RespSrc=mapply(RespCalc,mast$StimResp,mast$JitterResp,'src')
mast$RespRecode=mast$Resp-1
mast$CResp=data2$MSITStim.CRESP  #For some reason, some of the Jitter CRESPs are null, so use MSIT
mast$Acc=0
mast$Acc[mast$Resp==mast$CResp]=1


mast$TrialType=data2$TrialType
mast$TrialOnset=data2$MSITStim.OnsetTime
mast$TrialDur=NA
mast$TrialDur[mast$RespSrc=='stim']=mast$StimRT[mast$RespSrc=='stim']
mast$TrialDur[mast$RespSrc=='jit']=mast$JitterRT[mast$RespSrc=='jit']+mast$StimDur[mast$RespSrc=='jit']

mast=merge(mast,TxInfo) ##Add treatment info
mast=merge(mast,frameinfo,all.x=TRUE) #Merge in frame info for later cleaning


for (i in 1:length(frameinfodefault)){  #Set missing framecounts to defaults
mast$FrameCount[is.na(mast$FrameCount) & mast$Session==i]=frameinfodefault[i]  
}



# Zero everything by recentering on onset for trial 1 of a given run


names(mast)[3]='Run'

sublist=unique(mast[,c('Subject','Run','Treatment')])
sublist$TrialMin=NA

for(i in 1:nrow(sublist)){
  miniframe=mast[mast$Subject==sublist$Subject[i] & mast$Run==sublist$Run[i] & mast$Treatment==sublist$Treatment[i],]
  sublist$TrialMin[i]=min(miniframe$TrialOnset)
}

mast=merge(mast,sublist)

mast$ScanTime=mast$FrameCount*2
mast$TrialDur=mast$TrialDur/1000
mast$TrialOnsetAligned=mast$TrialOnset-mast$TrialMin
mast$TrialOnsetAligned=mast$TrialOnsetAligned/1000
mast$TrialOnset=mast$TrialOnset/1000
mast$TrialOnsetAligned[mast$TrialOnsetAligned>mast$ScanTime]='NaN'

mast$TrialOnsetFIR = as.numeric(mast$TrialOnsetAligned)-10
mast$TrialOnsetFIR[mast$TrialOnsetFIR<0]='NaN'



mast=mast[order(mast$Subject,mast$Treatment,mast$Trial),]
mast$Subject=as.numeric(paste(mast$Subject,mast$Treatment,sep=''))

mast=apply(mast,c(1,2),as.numeric)

mast=rbind(1:ncol(mast),mast)  #Add the column indices to the top
write.csv(mast,'MSIT_MasterDataFile.csv',row.names=FALSE,na='NaN')




####DOWN HERE IS SOME DEMO CODE FROM TEACHING CHANDRA R

# aggr=ddply(mast[,c('Subject','Treatment','TrialDur')],c('Subject','Treatment'),mean,na.rm=TRUE)
# 
# wide=reshape(aggr,v.names='TrialDur',idvar='Subject',timevar='Treatment',direction='wide')
# 
# aggr2=ddply(mast[,c('Subject','Treatment', 'TrialType','TrialDur')],c('Subject','Treatment','TrialType'),mean,na.rm=TRUE)
# 
# wide2=reshape(aggr2,v.names='TrialDur',idvar=c('Subject','TrialType'),timevar='Treatment',direction='wide')
# 
# wide3=reshape(aggr2,v.names=('TrialDur.1','TrialDur.2'),idvar=c('Subject'),timevar='TrialType',direction='wide')

##Examples for subscripting
# TxInfo[TxInfo$Treatment==2,]
# 
# 
# test$field2[2]=c(1,2,3,4)
# 
# test[3,2]=c(1,2,3,4)