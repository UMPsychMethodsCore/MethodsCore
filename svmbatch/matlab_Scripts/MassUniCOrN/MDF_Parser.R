## Arg Standards

# First arg - path to csv
# Second arg - include column
# Third arg - formula for design matrix

args <-  commandArgs(trailingOnly=TRUE)

csvpath = args[1]
IncludeCol = args[2]
model = as.formula(args[3])

## Load the CSV
colclass = 'character'
names(colclass) = 'Subject'

master = read.csv(csvpath,colclass)

## Subset the MDF

### Clean up the include logic in case of NA
master[IncludeCol] = ifelse(!is.na(master[IncludeCol]),master[IncludeCol],FALSE)

### Do the actual subset
mini = master [ master[,IncludeCol],]

## Build the design matrix and list of subjects
design = model.matrix(model,mini)

subs = mini$Subject

## Save the results

library(R.matlab)
writeMat('FixedFX.mat',subs=subs,design=design)
