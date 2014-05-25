*Raw data set for this project was downloaded from:
http://archive.ics.uci.edu/ml/machine-learning-databases/00240/

*For more info, please visit:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

### DataSet Analysis:

Broadly the analysis was done to combine data from training and test sets, 
then extract features of interest and finally produce a summary of average values
of the selected features.

The analysis was done using a script "runAnalysis.R" in the following steps:

* Create a character vector vActivity for 6 activity types from "activity_labels.txt"

* Create a character vector vFeatures for 561 features from "features.txt"
    Apply tidy data principles to remove punctuation marks from feature names
    and appropriately capitalize names.

* Inspect the number of training subjects by reading "subject_train.txt"
    Inspect the number of training set observations by reading "y_train.txt", "x_train.txt"
    Combine the data columns as both data frames have the same number of observations.
    
* Inspect the number of test subjects by reading "subject_test.txt"
    Inspect the number of test set observations by reading "y_test.txt", "x_test.txt"
    Combine the data columns as both data frames have the same number of observations.

* Merge the data rows from the data sets created in 3. and 4. above, into a single data
    frame dfDataSet.full
    
* Delete temporary data frames created in 3. and 4.

* Columns names of dfDataSet.full are derived from SubjectID, Activity and 561 features.

* Transform SubjectID and Activity columns to be factors instead of character vectors.

* Map Activity level values using descriptive names from vActivity.

* 561 features could be broadly classified into 2 parts,
    1. Features that are 'measured'
        These have a prefix t followed by Body/Gravity, then Acc/Gyro
    2. Features that are 'derived'. These are all of the rest. 
    
    Create a regular expression pattern regexPattern to select mean and std features
    from the features that are 'measured'. These are time domain signal features of 
    interest for this analysis. 18 such features are selected.
    Each feature could be thought of as a combination of 4 separate characteritics namely:
    SignalSource, SensorType, SignalAxis, SignalStatistic. Example: tBodyAccMeanX
    
    A descriptive name is chosen for each feature to be used for separating these
    characteristics. Example: ACCELEROMETER_BODY_MEAN_X

*Reference:
==================================================================
Human Activity Recognition Using Smartphones Dataset
Version 1.0
==================================================================
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Universit‡ degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
==================================================================
