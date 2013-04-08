## Arg Standards

# First arg - path to csv
# Second arg - include column
# Third arg - formula for design matrix
args <-  commandArgs(trailingOnly=TRUE)
csvpath = args[2]
IncludeCol = args[3]
model = as.formula(args[4])
writepath = args[5]
FoldCol = args[6]


options(stringsAsFactors=FALSE) # don't deal with factors til the last second

## Load the CSV
colclass = 'character'
names(colclass) = 'Subject'

master = read.csv(csvpath,colClasses = colclass)
## Subset the MDF

### Clean up the include logic in case of NA
master[,IncludeCol] = ifelse(!is.na(master[,IncludeCol]),master[,IncludeCol],FALSE)

master[,IncludeCol] = as.logical(master[,IncludeCol])

### Do the actual subset
mini = master [ master[,IncludeCol],]

## Build the design matrix and list of subjects
design = model.matrix(model,mini)

subs = mini$Subject

## Build the logical matrix of Cross Fold Validation
library(R.matlab)

FoldIDS = sort(unique(mini$Fold))
CrossValidFold = matrix(rep(FALSE,length(FoldIDS)*nrow(mini)),nrow=nrow(mini),ncol=length(FoldIDS))
for (iFold in 1:length(FoldIDS)){
  CrossValidFold[,iFold] <- mini$Fold==FoldIDS[iFold]
}

CrossValidFold = apply(CrossValidFold,c(1,2),as.numeric)

SiteIDS = mini$SITE_ID

DesignColNames = colnames(design)

## Save the results

library(R.matlab)
writeMat(writepath,subs=subs,design=design,CrossValidFold=CrossValidFold,SiteIDS=SiteIDS,DesignColNames = DesignColNames)
