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
colnames(dfDataSet.full) <- c("SubjectID","Activity",vFeatures)
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
vFeatures.names <- c("ACCELEROMETER_BODY_X_MEAN", 
                    "ACCELEROMETER_BODY_Y_MEAN", 
                    "ACCELEROMETER_BODY_Z_MEAN",
                    "ACCELEROMETER_BODY_X_STDEV", 
                    "ACCELEROMETER_BODY_Y_STDEV", 
                    "ACCELEROMETER_BODY_Z_STDEV",
                    "ACCELEROMETER_GRAVITY_X_MEAN", 
                    "ACCELEROMETER_GRAVITY_Y_MEAN", 
                    "ACCELEROMETER_GRAVITY_Z_MEAN",
                    "ACCELEROMETER_GRAVITY_X_STDEV", 
                    "ACCELEROMETER_GRAVITY_Y_STDEV", 
                    "ACCELEROMETER_GRAVITY_Z_STDEV",
                    "GYROSCOPE_BODY_X_MEAN", 
                    "GYROSCOPE_BODY_Y_MEAN", 
                    "GYROSCOPE_BODY_Z_MEAN",
                    "GYROSCOPE_BODY_X_STDEV", 
                    "GYROSCOPE_BODY_Y_STDEV", 
                    "GYROSCOPE_BODY_Z_STDEV")

# extract from dfDataSet.full, columns numbers that match vFeatureIndices
# feature columns are offsetted by 2 because of SubjectID and Activity columns
# in the beginning of dfDataSet.full data frame
dfDataSet.sub <- dfDataSet.full[,c(1,2,2+vFeatures.indices)]
# all features could be thought of as some form of signal measures that have a numeric value
# other than SubjectID and Activity, all features could be melted
# to form a single column for sensor measures and a corresponding column for their values
dfDataSet.molten <- melt(dfDataSet.sub, 
                         id.vars=c("SubjectID", "Activity"), 
                         variable.name="SignalMeasure", value.name="SignalStatisticValue")

# map SignalMeasure factor levels to descriptive names
dfDataSet.molten$SignalMeasure <- with(dfDataSet.molten, 
                                       {mapvalues(SignalMeasure, 
                                                  from=levels(SignalMeasure), 
                                                  to=vFeatures.names)})
# separate SignalMeasure into separate variables
dfDataSet.molten <- transform(dfDataSet.molten, SignalMeasure=as.character(SignalMeasure))

lSignalMeasure <- strsplit(dfDataSet.molten$SignalMeasure,"_")
dfSignalMeasure <- ldply(lSignalMeasure)
colnames(dfSignalMeasure) <- c("SensorType","SignalSource","SignalAxis","SignalStatistic")
dfDataSet.molten <- cbind(dfDataSet.molten, dfSignalMeasure)

dfDataSet.molten <- transform(dfDataSet.molten, 
                              SensorType=as.factor(SensorType),
                              SignalSource=as.factor(SignalSource),
                              SignalAxis=as.factor(SignalAxis),
                              SignalStatistic=as.factor(SignalStatistic))

dfDataSet.molten <- dfDataSet.molten[c("SubjectID","Activity","SensorType","SignalSource","SignalStatistic","SignalAxis","SignalStatisticValue")]
dfDataSet.summary <- ddply(dfDataSet.molten, 
                           c("SubjectID","Activity","SensorType","SignalSource","SignalStatistic","SignalAxis"),
                           summarise, SignalStatisticAverage=mean(SignalStatisticValue))

# output this tidy data set summary to file
write.table(dfDataSet.summary, file="signal_measure_summary.txt", 
            sep="\t", quote=F, row.names=F)
