library(plyr)
library(reshape2)

# create activity vector
vActivity <- read.table("./activity_labels.txt", sep=" ", stringsAsFactors=F)
vActivity <- vActivity[,2]

# read features
vFeatures <- read.table("./features.txt", sep=" ", stringsAsFactors=F)
vFeatures <- vFeatures[,2]
vFeatures <- gsub("-mean","-Mean",vFeatures)
vFeatures <- gsub("-std","-Std",vFeatures)
vFeatures <- gsub("[[:punct:]]", "", vFeatures)

# inspect number of training subjects
dfTrainSub.tmp <- read.table("./train/subject_train.txt")
# inspect number of observations in training set
dfTrainSet.tmp <- cbind(read.table("./train/y_train.txt"), 
                        read.table("./train/x_train.txt"))
# same number of rows, therefore columns could be combined
dfTrainSet.tmp <- cbind(dfTrainSub.tmp, dfTrainSet.tmp)

# inspect number of test subjects
dfTestSub.tmp <- read.table("./test/subject_test.txt")
# inspect number of observations in test set
dfTestSet.tmp <- cbind(read.table("./test/y_test.txt"), 
                       read.table("./test/x_test.txt"))
# same number of rows, therefore columns could be combined
dfTestSet.tmp <- cbind(dfTestSub.tmp, dfTestSet.tmp)

# dfTrainSet and dfTestSet have same number of columns
# hence the observations in rows could be combined
dfDataSet.full <- rbind(dfTrainSet.tmp, dfTestSet.tmp)

# delete temporary variables
rm(list=ls(pattern="*.tmp"))

# dfDataSet.full has columns in the order: SubjectID, Activity, Features...(561)
# assign column names accordingly
colnames(dfDataSet.full) <- c("SubjectID","Activity",vFeaturesTidy)
# transform SubjectID and Activity as factors
dfDataSet.full <- transform(dfDataSet.full, 
                            SubjectID=as.factor(SubjectID), Activity=as.factor(Activity))
# map factor levels to those from activity_labels.txt
dfDataSet.full$Activity <- with(dfDataSet.full, 
                               {mapvalues(Activity, from=levels(Activity), to=vActivity)})

# regex filter for mean and std types in tBodyAcc, tBodyGyro & tGravityAcc data columns
# i.e. choose only those features that are measured, not derived
regexPattern <- "^(t(body|gravity)(acc|gyro)(mean|std))"
vFeatures.indices <- grep(regexPattern, vFeatures, ignore.case=T, value=F)
vFeatures.sub <- vFeatures[vFeatures.indices]
vFeatures.tidy <- c("SIGNAL_FROM_ACCL_BODY_MEAN_IN_X_AXIS", 
                    "SIGNAL_FROM_ACCL_BODY_MEAN_IN_Y_AXIS", 
                    "SIGNAL_FROM_ACCL_BODY_MEAN_IN_Z_AXIS",
                    "SIGNAL_FROM_ACCL_BODY_STDEV_IN_X_AXIS", 
                    "SIGNAL_FROM_ACCL_BODY_STDEV_IN_Y_AXIS", 
                    "SIGNAL_FROM_ACCL_BODY_STDEV_IN_Z_AXIS",
                    "SIGNAL_FROM_ACCL_GRAVITY_MEAN_IN_X_AXIS", 
                    "SIGNAL_FROM_ACCL_GRAVITY_MEAN_IN_Y_AXIS", 
                    "SIGNAL_FROM_ACCL_GRAVITY_MEAN_IN_Z_AXIS",
                    "SIGNAL_FROM_ACCL_GRAVITY_STDEV_IN_X_AXIS", 
                    "SIGNAL_FROM_ACCL_GRAVITY_STDEV_IN_Y_AXIS", 
                    "SIGNAL_FROM_ACCL_GRAVITY_STDEV_IN_Z_AXIS",
                    "SIGNAL_FROM_GYRO_BODY_MEAN_IN_X_AXIS", 
                    "SIGNAL_FROM_GYRO_BODY_MEAN_IN_Y_AXIS", 
                    "SIGNAL_FROM_GYRO_BODY_MEAN_IN_Z_AXIS",
                    "SIGNAL_FROM_GYRO_BODY_STDEV_IN_X_AXIS", 
                    "SIGNAL_FROM_GYRO_BODY_STDEV_IN_Y_AXIS", 
                    "SIGNAL_FROM_GYRO_BODY_STDEV_IN_Z_AXIS")

# extract from dfDataSet.full, columns numbers that match vFeatureIndices
# feature columns are offsetted by 2 because of SubjectID and Activity columns
# in the beginning of dfDataSet.full data frame
dfDataSet.sub <- dfDataSet.full[,c(1,2,2+vFeatures.indices)]
# all features could be thought of as some form of signal measures that have a numeric value
# other than SubjectID and Activity, all features could be melted
# to form a single column for sensor measures and a corresponding column for their values
dfDataSet.molten <- melt(dfDataSet.sub, 
                         id.vars=c("SubjectID", "Activity"), 
                         variable.name="SignalMeasure", value.name="SignalValue")
# map SignalMeasure factor levels to satisfy tidy data principles
dfDataSet.molten$SignalMeasure <- with(dfDataSet.molten, 
                                       {mapvalues(SignalMeasure, 
                                                  from=levels(SignalMeasure), 
                                                  to=vFeatures.tidy)})

dfDataSet.summary <- ddply(dfDataSet.molten, c("SubjectID","Activity","SignalMeasure"),
                           summarise, SignalValue.average=mean(SignalValue))

# output this tidy data set summary to file
write.table(dfDataSet.summary, file="signal_measure_summary.txt", 
            sep="\t", quote=F, row.names=F)
