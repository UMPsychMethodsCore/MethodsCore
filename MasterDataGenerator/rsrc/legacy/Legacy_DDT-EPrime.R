##Overall process
#1 Read in data
#2 Merge, reorder, and build stuff up in data
#3 copy over the fields you care about to mast

frameinfodefault=c(240,240,240) #values for block 1, 2, and 3 respectively to use for frameinfo when not otherwise specified

data=read.delim('DDT-Merged.txt',skip=2, fileEncoding = 'UCS-2LE',as.is=TRUE)


data=data[,!grepl('Clock',names(data))] #Drop the clock information cuz those strings are huge

delaymap=matrix(data=c(
  'now',0,
  'in 2 weeks',2,
  'in 1 month',4,
  'in 1 month and 2 weeks',6,
  'in 2 months',8,
  'in 3 months',12,
  'in 4 months',16,  
  'in 5 months',20
                       
  ),ncol=2,byrow=TRUE)


delaymap=data.frame(delaymap)
names(delaymap)=c('String','Number')
delaymap$Number=as.numeric(as.character(delaymap$Number))

delaymapleft=delaymap
delaymapright=delaymap

names(delaymapleft)[2]='del_left'
names(delaymapright)[2]='del_right'
data=merge(data,delaymapleft,by.x='Left_Delay',by.y='String',all.x=TRUE,sort=FALSE)
data=merge(data,delaymapright,by.x='Right_Delay',by.y='String',all.x=TRUE,sort=FALSE)

#Start calculating new stuff

moneytrim=function(stringer){
  val=as.character(stringer)
  return(as.numeric(substr(val,2,nchar(val))))
}


data$am_left=moneytrim(data$Left_Amount)
data$am_right=moneytrim(data$Right_Amount)


data$choice_leftward=data$Choice.RESP-1

data$LeftLater=data$del_left>data$del_right

data$am_earler[data$LeftLater]=data$am_right[data$LeftLater]
data$del_earler[data$LeftLater]=data$del_right[data$LeftLater]
data$am_later[data$LeftLater]=data$am_left[data$LeftLater]
data$del_later[data$LeftLater]=data$del_left[data$LeftLater]

data$am_earler[!data$LeftLater]=data$am_left[!data$LeftLater]
data$del_earler[!data$LeftLater]=data$del_left[!data$LeftLater]
data$am_later[!data$LeftLater]=data$am_right[!data$LeftLater]
data$del_later[!data$LeftLater]=data$del_right[!data$LeftLater]

data$AugFactor=round(data$am_later/data$am_earler,1)

data$choice[!data$LeftLater]=data$choice[!data$LeftLater]
data$choice[data$LeftLater]=5-data$choice[data$LeftLater]

data$TrialType_13[data$del_left==0 & data$del_right==0]=1
data$TrialType_13[data$del_left>0 & data$del_right==0]=2
data$TrialType_13[data$del_left==0 & data$del_right>0]=2
data$TrialType_13[data$del_left>0 & data$del_right>0]=3


estim=read.table('Estimates.txt',header=TRUE,stringsAsFactors=FALSE)
TxInfo=read.csv('MAS_TxInfo.csv',stringsAsFactors=FALSE)

data=merge(data,TxInfo)

#Combine files

data=merge(data,estim,all.x=TRUE)

data$sv_earler=(1/(data$h+1))^data$del_earler*data$am_earler
data$sv_later=(1/(data$h+1))^data$del_later*data$am_later
data$DiffSV=data$sv_later-data$sv_earler
data$AbsDiffSV=abs(data$DiffSV)
data$MaxSV=mapply(max,data$sv_earler,data$sv_later)

data$Run=0
data$Run[data$Block %in% 1:56]=1
data$Run[data$Block %in% 57:112]=2
data$Run[data$Block %in% 113:168]=3

sublist=unique(data[,c('Subject','Run','Treatment')])
sublist$TrialMin=NA

for(i in 1:nrow(sublist)){
  miniframe=data[data$Subject==sublist$Subject[i] & data$Run==sublist$Run[i] & data$Treatment==sublist$Treatment[i],]
  sublist$TrialMin[i]=min(miniframe$Choice.OnsetTime)
}

data=merge(data,sublist)

data$OnsetAdjusted=(data$Choice.OnsetTime-data$TrialMin)/1000
data$Duration=data$Choice.RT/1000

frameinfo=read.csv('FrameInfo_DDT.csv',stringsAsFactors=FALSE)

data=merge(frameinfo,data,all.y=TRUE)

for (i in 1:length(frameinfodefault)){  #Set missing framecounts to defaults
data$FrameCount[is.na(data$FrameCount) & data$Session==i]=frameinfodefault[i]  
}

data$MaxTime=data$FrameCount*2

data$OnsetAdjusted[(data$OnsetAdjusted+data$Duration)>data$MaxTime]='NaN'

data=data[order(data$Subject,data$Treatment,data$Run,data$Block),]




data$SubjectTx=paste(data$Subject,data$Treatment,sep='')
data$Run.dup=data$Run  #Just to make the file easier to work with, put your useful stuff out at the end, so append .dup to give it unique name
data$TrialType_Trinary=data$TrialType_13
data$TrialType_AllTrials=1
data$TrialType_ImmediacyPresent=2;data$TrialType_ImmediacyPresent[data$TrialType_13 %in% c(1,2)]=1
data$TrialType_DelayPresent=2;data$TrialType_DelayPresent[data$TrialType_13 %in% c(2,3)]=1
data$OnsetAdjusted.dup=data$OnsetAdjusted
data$OnsetAdjustedFIR=as.numeric(data$OnsetAdjusted)-4
data$OnsetAdjustedFIR[data$OnsetAdjustedFIR<0]='NaN'
data$Duration.dup=data$Duration
data$EarlierSV=data$sv_earler
data$LaterSV=data$sv_later
data$DiffSV.dup=data$DiffSV
data$AbsDiffSV=data$AbsDiffSV
data$BothImmMaxSV=ifelse(data$TrialType_13==1,data$MaxSV,NaN)
data$BothImmDiffSV=ifelse(data$TrialType_13==1,data$DiffSV,NaN)


data$Choice.dup=data$choice
data$ChoiceBin=0
data$ChoiceBin[data$choice %in% c(1,2)]=1
data$ChoiceBin[data$choice %in% c(3,4)]=2


data$amount.delta=data$am_later-data$am_earler
data$amount.delta.quadratic=(data$amount.delta)^2

data$delay.delta=data$del_later-data$del_earler
data$delay.delta.quadratic=data$delay.delta^2

###################################################################
#Clear out all the trials where delay is not present and regressor makes no sense
###################################################################

data$amount.delta[data$TrialType_DelayPresent==2]='NaN'
data$amount.delta.quadratic[data$TrialType_DelayPresent==2]='NaN'
data$delay.delta[data$TrialType_DelayPresent==2]='NaN'
data$delay.delta.quadratic[data$TrialType_DelayPresent==2]='NaN'

###################################################################
#Let us do some psychometric fitting
###################################################################

fits=data[data$TrialType_13!=1,]

#Rescale choice
fits$choicerescale=(fits$choice-1)/3

uh <- function(x,t,b,d,a) {
    #uh=returns subjective value
    #x=monetary reward
    #t=time
    #b=probably a scaling factor, but it's cool since it's always set to 1
    #d=k (parameter that governs discounting
    #a=optional power of x, but no worries since it's always set to 1'
  
  ifelse(t==0,x^a, b/(1+d*t) * x^a)}

cprob.h <- function(x2,t2,x1,t1,b,d,a,sen) 1/(1+exp(sen*(uh(x1,t1,b,d,a)-uh(x2,t2,b,d,a))))
#cprob.h is a logistic function that should predict probability of strong preference for the later

#load nlme
library(nlme)

fits.nlme=groupedData(choicerescale~am_earler + del_earler + am_later + del_later | Subject,data=fits)

kh.nlme = nlme(model=choicerescale~cprob.h(am_earler,del_earler,am_later, del_later,b=1,d,a=1,sen=-1) ,
 start=c(d=.96),fixed=d~1,random=d~1, data=fits.nlme[fits.nlme$Treatment==1,])

fits2.nlme=groupedData(choicerescale~am_earler + del_earler + am_later + del_later | Subject/Treatment ,data=fits)

kh2.nlme = nlme(model=choicerescale~cprob.h(am_earler,del_earler,am_later, del_later,b=1,d,a=1,sen=-1) ,
 start=c(d=.96),fixed=d~1,random=d~1, data=fits2.nlme)

###################################################################
#My lame attempt at modeling it in one step
###################################################################

kh3.nlme=nlme(model=choicerescale~cprob.h(am_earler,del_earler,am_later, del_later,b=1,d,a=1,sen=-1),
  data=fits,
              fixed=d+Treatment ~1+1,random=d~1,groups=~Subject,start=c(d=.96,Treatment=1))


###################################################################
#CLean up and write out
###################################################################

data=rbind(1:ncol(data),data)

data=apply(data,c(1,2),function(x) as.numeric(x))  #Get rid of all the strings

write.csv(data,'DDT_MasterDataFile.csv',na='NaN',row.names=FALSE,quote=FALSE)

#Might consider stripping it down to only include subjects who have ALL trials
#or only include trials that have ALL subjects


###################################################################
#Exploratory analysis
###################################################################

#HI MOM

# fit=aov(choice~Treatment+Error(Subject),data=data[data$Session==1,])
# fit2=aov(choice~Treatment+Error(Subject/(Treatment)),data=data)
# 
# fit3=aov(choice~Session+Error(Subject),data)
# 
# data2=data[data$Session==1,]
# data3=data[data$Session==2,]
# 
# 
# par(mfrow=c(3,1))
# 
# interaction.plot(data$Block,data$Treatment,data$choice,xlab='Trial',ylab='Mean of Choice (1-4)',main='Both Sessions',trace.label='Treatment')
# interaction.plot(data2$Block,data2$Treatment,data2$choice,xlab='Trial',ylab='Mean of Choice (1-4)',main='Session 1',trace.label='Treatment')
# interaction.plot(data3$Block,data3$Treatment,data3$choice,xlab='Trial',ylab='Mean of Choice (1-4)',main='Session 2',trace.label='Treatment')
# 
# fit=aov(choice~factor(Treatment)+Error(factor(Subject)),data=data)
# fit2=aov(choice~factor(Treatment)+Error(factor(Subject)),data=data2)
# 
# summary(fit)
# summary(fit2)
# 
# 
# interaction.plot(data$Block,data$Treatment,data$Choice.RT,xlab='Trial',ylab='Mean of Choice (1-4)',main='Both Sessions',trace.label='Treatment')
# interaction.plot(data2$Block,data2$Treatment,data2$Choice.RT,xlab='Trial',ylab='Mean of Choice (1-4)',main='Session 1',trace.label='Treatment')
# interaction.plot(data3$Block,data3$Treatment,data3$Choice.RT,xlab='Trial',ylab='Mean of Choice (1-4)',main='Session 2',trace.label='Treatment')
# 
# 
# fits.delaychoice=aov(choice~Treatment+delay.delta,data)
