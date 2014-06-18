# Getting and Cleaning Data
## Course Project

This document explains what each section of "run_analysis.R" does. The variables are described in the codebook.

1. Reading in data

Uses read.csv to read in training, test, activity, feature, and subject data.

        X_test <- read.csv("./UCI HAR Dataset/test/X_test.txt", header = F, sep = "")
        y_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = F, sep = "")
        X_train <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = F, sep = "")
        y_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = F, sep = "")
        activity_labels <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = F, sep = "")
        features <- read.csv("./UCI HAR Dataset/features.txt", header = F, sep = "", stringsAsFactors=F)
        subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header=F, sep = "")
        subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header=F, sep = "")

2. Merge training and test data

First, merge X, y, and subject training and test data. Then, use the features data to name the variables (column names) of X. Then, rename y data column to "Activity" and subject data to "Subject" for ease of reading.

        X_total <- rbind(X_train, X_test)
        names(X_total) <- features[, 2]
        y_total <- rbind(y_train, y_test)
        names(y_total) <- "Activity"
        subject_total <- rbind(subject_train, subject_test)
        names(subject_total) <- "Subject"


3. Merge and label activities

Then, use "activity_labels.txt" to label activities by description, merging with y data. Join is used instead of merge because it preserves the order of the y data.

        names(activity_labels) <- c("Activity", "Description")
        merged_y <- join(y_total, activity_labels, by= "Activity")


4. Merge everything

Finally, column bind the X data, merged y data, and subject data into the large dataset called "total".

        total <- cbind(X_total, merged_y, subject_total)


5. Extract mean and standard deviation data

This creates a smaller data subset, "total_extract", that pulls any variable column containing "mean()" (meanFreq() excluded), and "std()". Then binds with activity and subject data.

        mean_features <- grep("mean\\(\\)", features$V2)
        std_features <- grep("std\\(\\)", features$V2)
        total_meanstd <- total[,c(mean_features, std_features)]
        total_extract <- cbind(total_meanstd, merged_y[,2], subject_total)
        colnames(total_extract)[67] <- "Activity"

6. Create tidy data set

These commands create the tidy data set, splitting "total_extract" by Activity and Subject, and summarising the remaining columns. Column names are then cleaned up to remove any special characters.

        data <- ddply(total_extract, c("Activity", "Subject"), numcolwise(mean))
        names.data <- names(data)
        names.data <- gsub("-",".",names.data)
        names.data <- gsub("\\(\\)","",names.data)

7. Write to file

Uses a fixed width file format to keep the data in nice looking tables.

        library(gdata)
        write.fwf(data, file="tidyfwf.txt")
