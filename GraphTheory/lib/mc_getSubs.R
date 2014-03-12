colclass = 'character'
names(colclass) = 'Subject'

args <- commandArgs(TRUE)

writepath=args[2]

mdf = read.csv('/net/data4/Autism/Scripts/slab/MasterData_AUTISM_repeat_Cleansed.csv',colClasses=colclass)

mdfScrub = mdf[(mdf$Include.Overall.Scrub=='TRUE' & (mdf$nonzeroFD<(mdf$TOTAL_TP-1))),]

ScrubSubj = mdfScrub$Subject

library(R.matlab)

writeMat(writepath,Subject=ScrubSubj)


