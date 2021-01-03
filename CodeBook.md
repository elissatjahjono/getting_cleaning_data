---
title: "CodeBook"
output: html_document
---

# Getting and Cleaning Data - Course Project #
The aim of this project is to get and clean data, and to create tidy dataset.
Tidy dataset is necessary for further data analysis. Raw data were obtained from:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


First, load dplyr library that is needed to tidy the raw dataset
## Load library
library(dplyr)


Next, download and store raw datasets in working directory
Unzipped raw datasets are stored in the folder 'Project_Datasets_Unzip'.
## Download and unzip datasets
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "./Project_Datasets.zip")
unzip("./Project_Datasets.zip", exdir = "./Project_Datasets_Unzip")


There are several files in the folder and 2 subfolders 'train' and 'test', each containing raw datasets.
The 'README.txt' file explains the contents of all these files.
What we need for this project: 
1. 'features.txt': List of all the variable names for the main dataset
2. 'activity_labels.txt': List the names of the activities
3. 'train/subject_train.txt': List the subject in the Training set
4. 'train/X_train.txt': Training set
5. 'train/y_train.txt': Training labels
6. 'test/subject_test.txt': List the subject in the Test set
7. 'test/X_test.txt': Test set
8. 'test/y_test.txt': Test labels


Next, load these files into R as data frames.
Modify the column names to better understand what they are.

### Load the feature file
allfeature <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/features.txt"))
colnames(allfeature) <- c("feature_number", "feature_name")

### Load the subject files
subjecttrain <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/train/subject_train.txt"))
subjecttest  <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/test/subject_test.txt"))

### Load the data files
datatrain <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/train/X_train.txt"))
datatest  <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/test/X_test.txt"))

### Load the activity files
activitytrain <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/train/Y_train.txt"))
activitytest  <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/test/Y_test.txt"))


The first task is to merge the Training and the Test sets into one dataset.
First, merge the Training and Test sets of each of the files by using rbind.
The resulting datasets each have 10299 observations (rows).
Second, merge the subject, data, and activity files into one large dataset by using cbind.
The resulting dataset contain 10299 observations (rows) of 563 variables (columns).

## 1. Merges the training and the test sets to create one data set.

### Merge subject files into one
allsubject <- rbind(subjecttest, subjecttrain)
### Name the variable
colnames(allsubject) <- "Subject"

### Merge data files into one
alldata <- rbind(datatest, datatrain)
### Name the variables
colnames(alldata) <- allfeature$feature_name

### Merge activity files into one
allactivity <- rbind(activitytest, activitytrain)
### Name the variable
colnames(allactivity) <- "Activity"

### Merge subject, data, and activity files into one
subject_and_activity <- cbind(allsubject, allactivity)
subject_activity_data <- cbind(subject_and_activity, alldata) ### all measurements included


The second task is to obtain only the mean and standard deviation for each measurement.
These can be found in the features.txt file.
Variables of interests should contain the word 'mean()' or 'std()'.
Once the names of these variables are obtained, the large dataset from Step 1 above can be subsetted.
This step reduces the number of columns in the dataset into 66 columns.
However, we also add the "Subject" and "Activity" variables, so there are 68 columns in total.

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
featurenames <- allfeature$feature_name
mean_std <- grep("mean\\(\\)|std\\(\\)", featurenames, value = TRUE)
data_mean_std <- alldata[, mean_std]
subject_activity_data_mean_std <- cbind(subject_and_activity, data_mean_std) ### only mean and std measurements


The third task is to use the descriptive activity names (rather than activity number 1-6) in the dataset.
Obtain the descriptive activity names from the 'activity_labels.txt' file.
There are 2 columns in this file, one column is the activity number and the other one is activity name.
By using this file, change the activity number in the dataset from Step 2 into its corresponding name.

## 3. Uses descriptive activity names to name the activities in the data set.

### Load the activity_labels file
activity_labels <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/activity_labels.txt"))
colnames(activity_labels) <- c("activity_number", "activity_name")

### Change activity numbers into activity name in the 'subject_activity_data_mean_std' dataset
subject_activity_data_mean_std$Activity <- with(subject_activity_data_mean_std,
                                                factor(Activity, levels = activity_labels$activity_number,
                                                       labels = activity_labels$activity_name))


The fourth task is to change the variable names of the dataset to be more descriptive.
Description of variable (feature) names can be found in the 'features_info.txt' file.
't' denotes time, 'f' denotes frequency.
'Acc' means signals come from acceloremeter while 'Gyro' means signals comes from 'gyroscope'.
Signals were separated into 'Body' or 'Gravity'.
Magnitudes or 'Mag' from these signals were calculated as well.
Several variables were estimated from these signals, including the Mean (mean()) and standard deviation/SD (std())

## 4. Appropriately labels the data set with descriptive variable names. 
variable_names <- names(subject_activity_data_mean_std)
variable_names <- gsub("^t", "Time", variable_names)
variable_names <- gsub("^f", "Frequency", variable_names)
variable_names <- gsub("Acc", "Accelerometer", variable_names)
variable_names <- gsub("Gyro", "Gyroscope", variable_names)
variable_names <- gsub("Mag", "Magnitude", variable_names)
variable_names <- gsub("BodyBody", "Body", variable_names)
variable_names <- gsub("std()", "SD", variable_names)
variable_names <- gsub("mean()", "Mean", variable_names)

colnames(subject_activity_data_mean_std) <- variable_names
### Export into a .txt file
write.table(subject_activity_data_mean_std, "First_Tidy_Dataset.txt")


Finally, a second tidy data set is created from Step 4.
This second dataset contains the average of each variable, clustered by each activity and each subject.
As there are 6 activities and 30 subjects, there are 180 observations (rows) in total, with 68 features (columns).
This second dataset is exported into a .txt file and is included in the repository.

## 5. From the data set in step 4, creates a second, independent tidy data set
## with the average of each variable for each activity and each subject.

### Use 'aggregate' to calculate mean average for each activity and each subject
second_dataset <- aggregate(. ~ Subject - Activity, data = subject_activity_data_mean_std, mean)

### Sort the dataset based on subject first, and then activity
second_dataset <- arrange(second_dataset,Subject,Activity)

### Export into a .txt file
write.table(second_dataset, "Second_Tidy_Dataset.txt", row.name=FALSE)
