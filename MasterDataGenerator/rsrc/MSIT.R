
RespCalc=function(stimRESP,jitRESP,srcind){
  resp=NA
  src=''
  flag=0
  stimRESP=as.numeric(stimRESP)
  jitRESP=as.numeric(jitRESP)
  if (!is.na(stimRESP)){resp=stimRESP;src='stim'} else if(!is.na(jitRESP)) {resp=jitRESP;src='jit'}
  if(srcind=='resp'){return(resp)}
  if(srcind=='src'){return(src)}
}

data=within(data,{   #Calculate accuracy and trial duration within the data environment (makes the code much easier to read)
  Resp=mapply(RespCalc,get(opts$MSIT$StimRespField),get(opts$MSIT$JitterRespField),'resp')
  RespSrc=mapply(RespCalc,get(opts$MSIT$StimRespField),get(opts$MSIT$JitterRespField),'src')
  RespRecode=Resp-1
  CResp=get(opts$MSIT$CorrectResponseField)
  Acc=ifelse(Resp==get(opts$MSIT$CorrectResponseField) & !is.na(Resp),1,0)
  TrialDur=ifelse(RespSrc=='stim',get(opts$MSIT$StimRTfield),NA)
  TrialDur=ifelse(RespSrc=='jit',get(opts$MSIT$JitterRTfield)+get(opts$MSIT$StimDurField),TrialDur)
  TrialDur=TrialDur/1000
  TrialTypeNumAccOnly=ifelse(Acc==1,TrialTypeNum,3) #Change inaccurate trials to be type 3
  TrialTypeNumAccOnly=ifelse(!is.na(TrialDur),TrialTypeNumAccOnly,4) #Change nonresponse trials to type 4
  TrialDur=ifelse(Acc==1,TrialDur,NA) #For innaccurate trials, change duration to NA
})
  

