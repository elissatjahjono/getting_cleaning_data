# Getting and Cleaning Data - Course Project #

## Load library
library(dplyr)

## Download and unzip datasets
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "./Project_Datasets.zip")
unzip("./Project_Datasets.zip", exdir = "./Project_Datasets_Unzip")

## Load files

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


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
featurenames <- allfeature$feature_name
mean_std <- grep("mean\\(\\)|std\\(\\)", featurenames, value = TRUE)
data_mean_std <- alldata[, mean_std]
subject_activity_data_mean_std <- cbind(subject_and_activity, data_mean_std) ### only mean and std measurements


## 3. Uses descriptive activity names to name the activities in the data set.

### Load the activity_labels file
activity_labels <- as.data.frame(read.table("./Project_Datasets_Unzip/UCI HAR Dataset/activity_labels.txt"))
colnames(activity_labels) <- c("activity_number", "activity_name")

### Change activity numbers into activity name in the 'subject_activity_data_mean_std' dataset
subject_activity_data_mean_std$Activity <- with(subject_activity_data_mean_std,
                                                factor(Activity, levels = activity_labels$activity_number,
                                                       labels = activity_labels$activity_name))


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


## 5. From the data set in step 4, creates a second, independent tidy data set
## with the average of each variable for each activity and each subject.

### Use 'aggregate' to calculate mean average for each activity and each subject
second_dataset <- aggregate(. ~ Subject - Activity, data = subject_activity_data_mean_std, mean)

### Sort the dataset based on subject first, and then activity
second_dataset <- arrange(second_dataset,Subject,Activity)

### Export into a .txt file
write.table(second_dataset, "Second_Tidy_Dataset.txt", row.name=FALSE)
