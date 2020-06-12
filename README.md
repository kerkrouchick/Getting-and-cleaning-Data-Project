---
title: "Getting and Cleaning Data Project"
author: "Kerry K"
date: "6/12/2020"
output: html_document
---

## Project Background

The purpose of this project is to demonstrate that I can collect, work with, and clean a data set. The data used was collected from accelerometers from the Samsung Galaxy S smartphone, which measured 30 participants' linear acceleration and angular velocity while doing six different activities: Walking, Walking upstairs, Walking downstairs, sitting, standing, and laying. The data for the 30 participants was randomly divided into a training group and a test group. The data was in a zip found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip . It had several different files and it was my job to bring them all together in one tidy table. 

## Analysis Description/Script Walk Through

In this next section, I'm going to walk you through the script I wrote with explanations and descriptions for each part.

1. Loaded all packages I thought I would need during the script. 

```{r}
library(dplyr)
library(plyr)
library(reshape2)
library(stringr)
library(tidyr)
```
2. Downloaded the zip file and assigned it a name so I could easily refer to it later in the script ("Run_zip"). Then I wrote a code to grab the paths and names of all the files so I could read them into R and know the proper path of the files I wanted.

```{r}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "Run_zip.zip")
Run_zip <- "Run_zip.zip"
Files <- as.character(unzip(Run_zip, list = TRUE)$Name)
```

3. After reading through all the backup documentation and deciding which documents were relevant to the project, I compiled the names of the files I needed (from printing "Files" from code above) and read each of them into R under clear names. In all, 8 files read into R: 3 documents per test and train group (Subject = the subjects/participants involved from 1-30, X = all the measurements/variables, y = the activites), and then the Features file (names of all the measurements) and activity_lables (names and ID of all the activities).

```{r}
subject_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/subject_test.txt"))
X_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(unz(Run_zip, "UCI HAR Dataset/test/y_test.txt"))
subject_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/subject_train.txt"))
X_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unz(Run_zip, "UCI HAR Dataset/train/y_train.txt"))
Features <- read.table(unz(Run_zip, "UCI HAR Dataset/features.txt"))
activity_labels <- read.table(unz(Run_zip, "UCI HAR Dataset/activity_labels.txt"))
```

4. On the side (not shown), I looked into the dimensions of each of the tables I downloaded and realized all the 'test' files had the same number of rows (2947) and all the 'train' files had the same number of rows (7352). So I decided to cbind all 3 files for both Test and Train. Once this was completed, since both 'Test' and 'Train' had same number of columns (563) with similar info, I used rbind to combine them into one table called "Merged_data" with 10299 observations and 563 variables. 

```{r}
Test <- cbind(subject_test, y_test, X_test)
Train <- cbind(subject_train, y_train, X_train)
Merged_data <- rbind(Test, Train)
```
5. After viewing my "Merged_data" table, I knew I needed to update the column names. There were multiple "V1's" and nothing was descriptive at all. Since this is tidy data, and one of the steps for this project was labeling data set with descriptive variable names, the first thing I did was collect the names from "Features" table and make it into a character vector. Since columns 3:563 were the measurement variables / features in the merged_data, I first updated their names to the Features_Names. I then updated column 1 to be called "Subject" and column 2 to be "Activity" to clearly define what they were.  

```{r}
Features_Names <- as.character(Features$V2)
names(Merged_data)[3:563] <- Features_Names
names(Merged_data)[1] <- "Subject"
names(Merged_data)[2] <- "Activity"
```

6. Since the directions say to extract only the mean & std per measurement, I needed to first find the pattern of the column headers that were the mean and std. This was the pattern of containing "-mean()" or "-std()" anywhere in the string. So I first created a columns variable where I used grep function, value = TRUE to find all columns with this pattern in Merged_data. Then, I used dplyr select function to select only the columns I needed - "Select", "Activity", and all the columns in the variable 'columns'. Then, since the prompt asked to create a 2nd, independent dataset with average of each variable for each activity and each subject, I grouped by Subject and Activity and then summarized the data to find the mean of all the 'columns' (varialbes) and saved it in a new table called "Mean_by_Subject_Activity". Then, there was one more step to do - use descriptive activity names. So I used the match function to link the activity_labels IDs with the activity in the final table. Then, I viewed the final table to confirm it was tidy. 

```{r}
columns <- grep(pattern = "[a-zA-Z]+\\-+(mean|std)\\()+\\-*[a-zA-Z]*", names(Merged_data), value = TRUE)
Merged_data %>%
        select(Subject, Activity, all_of(columns)) %>%
        group_by(Subject, Activity) %>%
        summarise_at(vars(columns), mean, na.rm=TRUE) -> Mean_by_Subject_Activity
Mean_by_Subject_Activity$Activity <- activity_labels[match(Mean_by_Subject_Activity$Activity, activity_labels$V1),2]
View(Mean_by_Subject_Activity)
```

## Tidy Data Defense

According to the lecture, tidy data has 4 components: 
1. Each variable you measure should be in one column
2. Each different observation of that variable should be in a different row
3. There should be one table for each "kind" of variable
4. If you have multiple tables, they should include a column in the table that allows them to be linked. (https://github.com/DataScienceSpecialization/courses/blob/master/03_GettingData/lectures/01_03_componentsOfTidyData.pdf)

I started with several different files and combined them into one where each variable measured has its own column, each observation of that variable is in a different row (i.e. each of the 30 subjects has observations for 6 different activities, so there are 180 observations in total), and there's only one table for each "kind" of variable - in this case, the data collected from the Samsung Galaxy S for 30 people. 
