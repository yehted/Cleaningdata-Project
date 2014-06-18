library(plyr)
## Read data
X_test <- read.csv("./UCI HAR Dataset/test/X_test.txt", header = F, sep = "")
y_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = F, sep = "")
X_train <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = F, sep = "")
y_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = F, sep = "")
activity_labels <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = F, sep = "")
features <- read.csv("./UCI HAR Dataset/features.txt", header = F, sep = "", stringsAsFactors=F)
subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header=F, sep = "")
subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header=F, sep = "")

## Merge training and test data
X_total <- rbind(X_train, X_test)
names(X_total) <- features[, 2]
y_total <- rbind(y_train, y_test)
names(y_total) <- "Activity"
subject_total <- rbind(subject_train, subject_test)
names(subject_total) <- "Subject"

## Merge and label activities
names(activity_labels) <- c("Activity", "Description")
merged_y <- join(y_total, activity_labels, by= "Activity")

## Merge data, activity, and subject data
total <- cbind(X_total, merged_y, subject_total)

## Extract mean and std columns
mean_features <- grep("mean\\(\\)", features$V2)
std_features <- grep("std\\(\\)", features$V2)
total_meanstd <- total[,c(mean_features, std_features)]
total_extract <- cbind(total_meanstd, merged_y[,2], subject_total)
colnames(total_extract)[67] <- "Activity"

## Generate tidy data
data <- ddply(total_extract, c("Activity", "Subject"), numcolwise(mean))

## Tidy up variable names
names.data <- names(data)
names.data <- gsub("-",".",names.data)
names.data <- gsub("\\(\\)","",names.data)

## Write to file
library(gdata)
write.fwf(data, file="tidyfwf.txt")