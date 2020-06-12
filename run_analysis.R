library(dplyr)
library(plyr)
library(reshape2)
library(stringr)
library(tidyr)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "Run_zip.zip")
Run_zip <- "Run_zip.zip"
Files <- as.character(unzip(Run_zip, list = TRUE)$Name)
subject_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/subject_test.txt"))
X_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/y_test.txt"))
subject_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/subject_train.txt"))
X_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/y_train.txt"))
Features <- read.table(unz(Run_zip, "UCI HAR Dataset/features.txt"))
activity_labels <- read.table(unz(Run_zip, "UCI HAR Dataset/activity_labels.txt"))
Test <- cbind(subject_test, y_test, X_test)
Train <- cbind(subject_train, y_train, X_train)
Merged_data <- rbind(Test, Train)
Features_Names <- as.character(Features$V2)
names(Merged_data)[3:563] <- Features_Names
names(Merged_data)[1] <- "Subject"
names(Merged_data)[2] <- "Activity"
columns <- grep(pattern = "[a-zA-Z]+\\-+(mean|std)\\()+\\-*[a-zA-Z]*", names(Merged_data), value = TRUE)
Merged_data %>%
        select(Subject, Activity, all_of(columns)) %>%
        group_by(Subject, Activity) %>%
        summarise_at(vars(columns), mean, na.rm=TRUE) -> Mean_by_Subject_Activity
Mean_by_Subject_Activity$Activity <- activity_labels[match(Mean_by_Subject_Activity$Activity, activity_labels$V1),2]
View(Mean_by_Subject_Activity)


