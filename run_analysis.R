## Programming Assignment - Run Analysis

## Optional: Clear working memory before starting
# gc()
# rm(list = ls())

## Downloading files and setting up
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("ra_datset.zip")) {
      download.file(url, "ra_datset.zip", method = "curl")
}
if (!file.exists("UCI HAR Dataset")) {
      unzip("ra_datset.zip")
}

## After unzipping the files, set newly created directory as working directory
setwd("~/UCI HAR Dataset")

## Read activity_labels and features
act_lbls <- read.table("activity_labels.txt")
ftrs <- read.table("features.txt")
ftrs[,2] <- as.character(ftrs[,2])

## Keep only Mean and Standard Deviations
ftrs2 <- grep(".*mean.*|.*std.*", ftrs[,2])
## Keep only the feature names as a separate value to assign as the variable names later on
ftrs.names <- ftrs[ftrs2,2]

## Reading the test data and keep only the mean/std variables
xtest <- read.table("test/X_test.txt")[ftrs2]
test_actvs <- read.table("test/y_test.txt")
test_sbjs <- read.table("test/subject_test.txt")
xtest <- cbind(test_sbjs,test_actvs,xtest) # Add columns with person id's and activity id's

## Reading the train data and keep only the mean/std variables
xtrain <- read.table("train/X_train.txt")[ftrs2]
train_actvs <- read.table("train/y_train.txt")
train_sbjs <- read.table("train/subject_train.txt")
xtrain <- cbind(train_sbjs,train_actvs,xtrain) # Add columns with person id's and activity id's

## Creating the joined table (train + test)
df_all <- rbind(xtrain, xtest)
colnames(df_all) <- c("person_id", "activity", ftrs.names)

## Assign activity and person values to a factor for sorting and grouping
df_all$activity <- factor(df_all$activity, levels = act_lbls[,1], labels = act_lbls[,2])
df_all$`person_id` <- factor(df_all$`person_id`)

## Grouping and retrieve mean values
library(data.table)
dt <- data.table(df_all)
library(plyr)
final <- aggregate(dt, by = list(Subject_ID = dt$`person_id`, Activity = dt$activity), FUN = mean)
final <- final[,c(1:2,5:83)]

## Rearrange the final table by assigning keys 
final2 <- data.table(final)
setkey(final2, Subject_ID, Activity)
final <- final2

## Write final table to a file
setwd('..')
write.table(final,file = "UCI_HAR_tidy.txt", row.names = FALSE)
