===================================================================================
### Raw data set:
* Raw data set for this project was downloaded from:
    http://archive.ics.uci.edu/ml/machine-learning-databases/00240/

* For more info, please visit:
    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

===================================================================================
### Data Set Analysis:
Broadly the analysis was done to combine data from training and test sets, 
then extract features of interest and finally produce a summary of average values
of the selected features.

The analysis was done using a script "runAnalysis.R" in the following steps:

* Create a character vector vActivity for 6 activity types from "activity_labels.txt"

* Create a character vector vFeatures for 561 features from "features.txt"
    Apply tidy data principles to remove punctuation marks from feature names
    and appropriately capitalize names.

* Inspect the number of training subjects by reading "subject_train.txt"
    Inspect the number of training set observations 
    by reading "y_train.txt", "x_train.txt".
    Combine the data columns as both data frames have the same number of observations.
    
* Inspect the number of test subjects by reading "subject_test.txt"
    Inspect the number of test set observations by reading "y_test.txt", "x_test.txt"
    Combine the data columns as both data frames have the same number of observations.

* Merge the data rows from the data sets created in 3. and 4. above, into a single data
    frame dfDataSet.full having 10299 obs. of 563 variables.
    
* Delete temporary data frames created in 3. and 4.

* Columns names of dfDataSet.full are derived from SubjectID, Activity and 561 features.

* Transform SubjectID and Activity columns to be factors instead of character vectors.

* Map Activity level values using descriptive names from vActivity.

* 561 features could be broadly classified into 2 parts,
    1. Features that are 'measured'.
        These have a prefix t followed by Body/Gravity, then Acc/Gyro.
    2. Features that are 'derived'. These are all of the rest. 
    
    Create a regular expression pattern regexPattern to select mean and std features
    from the features that are 'measured'. These are time domain signal features of 
    interest for this analysis. 18 such features are selected.
    Each feature is a combination of 4 separate characteritics namely:
    SignalSource, SensorType, SignalAxis, SignalStatistic.
    Example: Body,Acc,Mean,X in tBodyAccMeanX
    
    A descriptive name is chosen for each feature to be used for separating these
    characteristics. Example: ACCELEROMETER_BODY_MEAN_X
    A vector of such descriptive names vFeatures.names is created.
    
* A subset data set dfDataSet.sub is extracted from dfDataSet.full
    only for the 18 features selected for analysis.
    dfDataSet.sub has 20 columns - SubjectID, Activity and 18 feature columns.
    Other than SubjectID and Activity, all feature columns could be thought of as
    being a kind of signal measure with a corresponding value. Using melt
    function from reshape2 library, all these 18 feature columns could be 'melted'
    into 2 columns, feature names under SignalMeasure, values under SignalStatisticValue.
    
* From dfDataSet.sub, a molten data set dfDataSet.molten is created having
    185382 obs. of 4 variables. SignalMeasure column is transformed into factors instead
    of a vector of characters. Finally vFeatures.names values are mapped into this column.
    
* In dfDataSet.molten, the SignalMeasure column is transformed back to a character vector
    that could be split by its 4 sub-characterisitcs:
    SensorType,SignalSource,SignalStatistic,SignalAxis.
    Example: ACCELEROMETER_BODY_MEAN_X is split into ACCELEROMETER,BODY,MEAN,X
    A data frame dfSignalMeasure is combined by columns with dfDataSet.molten.
    The 4 new characteristics are transformed into factors.
    
* dfDataSet.molten columns are reordered after excluding SignalMeasure column that is
    already split into 4 separate columns. The final data frame dfDataSet.molten has
    185382 obs. of 7 variables.
    
* Finally a summary data set dfDataSet.summary is created from dfDataSet.molten by
    applying ddply function from plyr library.
    SubjectID,Activity,SensorType,SignalSource,SignalStatistic,SignalAxis are
    treated as a vector of id variables used for summarising SignalStatisticValues
    into SignalStatisticAverage values using the mean function.
    dfDataSet.summary has 3240 obs. of 7 variables.
    The summary data set is written to a file "signal_measure_summary.txt" along with
    column headers.
    
    

==================================================================
### Reference:
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
