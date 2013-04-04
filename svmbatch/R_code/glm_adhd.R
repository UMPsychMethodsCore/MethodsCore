############################################
## GLM for ADHD ReHo dataset              ##
############################################

#Include libraries
library('AnalyzeFMRI')
library('R.matlab') #Make sure you are able to load matlab files
library('Matrix')
library('nlme')
library('multicore')

#Location of master data file
masterpath = '/net/data4/ADHD/Phenotypics/MasterData_ADHD_rePreprocess_Cleansed_NYU_ReHo.csv'

#Define path templates
template.prefix='/net/data4/ADHD/FirstLevel/ReHo_results/Trial1/'
template.site='SITE_ID'
template.sub='SUB_ID'
template.suffix='/session_1/kcc_map_0001.nii'

#Location of output path
outputPath = '/net/data4/ADHD/UnivariateConnectomics/Results/'

includefactor = 'Include.Overall'
mcPath = '~/users/krishan/repos/MethodsCore'
rpath = file.path(mcPath,'svmbatch','R_code')
setwd(rpath)

# Formula for model
model.formula = ~ TYPE + meanFD + meanFD2 + F4IQ + AGE + GENDER + SITE_ID

# Load master data file
colclass = 'character'
names(colclass) = 'SUB_ID'

masterdata = read.csv(masterpath,colClasses=colclass)
master=masterdata[masterdata$Include.Overall,]
master$Include.Overall = ifelse(is.na(master$Include.Overall),FALSE,TRUE)
master=master[master$Include.Overall,]

# Tweak MasterDatafile
master$meanFD2 = master$meanFD^2



#Load ReHo analysis data
for (iSub in 1:dim(master)[1]){

  subj.path = master[iSub,template.sub]

 site.path=master[iSub,template.site]
 #exist[iSub] = file.exists()

 firstlevel.path=paste(template.prefix,site.path,'/',subj.path,template.suffix,sep='')
 reho.firstlevel=f.read.volume(firstlevel.path)
 reho.dim=dim(reho.firstlevel)
 if(iSub==1){
   flatmat=c(reho.firstlevel)
   header.list=f.read.nifti.header(firstlevel.path)
    row.names(flatmat)[iSub]=subj.path
  }
  else{
 temp=c(reho.firstlevel)
 flatmat = rbind(flatmat,temp)
 row.names(flatmat)[iSub]=subj.path
}
}

save(flatmat,file='temp.RData')


# Fit a model

library(corpcor)

design = model.matrix(model.formula,master) # create a design matrix
results = massuni(flatmat, design) # do the mass univariate modeling
t.array = results$tvals[2,] # grab the t values
p.array = results$pvals[2,] # grab the p values

t.out=array(t.array,dim=reho.dim)
p.out=array(p.array,dim=reho.dim)

save(t.out, file='.RData')
save(p.out, file='.RData')

f.write.nifti(t.out,paste(outputPath,'tval',sep=''),header.list, nii=TRUE)
f.write.nifti(p.out,paste(outputPath,'p_val',sep=''),size="float",header.list, nii=TRUE)

## Save what you've loaded so far
#save(superflatmat,superflatmat,file=file.path(outputPath,'superflat.RData'))

# Build a simple lm model, and save the results for later inspection
# mini = data.frame(R = superflatmat[,1],master)
#  model.fit = lm(model.formula,master)
#  save(model.fit,file=file.path(outputPath,'FirstModel.RData'))

# f.write.nifti(t.test.vol,paste(outputPath,'tval2',sep=''),size="float",t.test.header,nii=TRUE)
#t.test.header=f.read.nifti.header('/net/data4/ADHD/FirstLevel/ReHo_results/Trial1/Brown/0026001/session_1/kcc_map_0001.nii')
#t.test.vol[is.na(t.test.vol)]=0
#t.test.vol=f.read.nifti.volume('/net/data4/ADHD/UnivariateConnectomics/Results/tval.nii')
#t.test.header$descrip="SPM{T_[625.0]} - test"
