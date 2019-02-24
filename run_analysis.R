library(reshape)

filename <- "GetData.zip"

# download and unzip the data:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method="curl")}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename)}

#load train data
train<-read.table(
    file = "UCI HAR Dataset/train/X_train.txt")

train_lables<-read.table(
    file = "UCI HAR Dataset/train/y_train.txt")

train_subject<-read.table(
    file = "UCI HAR Dataset/train/subject_train.txt")

#pre process and merge train data
train_complete<-cbind(train, train_lables, train_subject)
colnames(train_complete)[c(562,563)]<-c("Activity_ID", "Subject")
train_complete<-as.data.frame(train_complete)

#load test data
test<-read.table(
    file = "UCI HAR Dataset/test/X_test.txt")

test_lables<-read.table(
    file = "UCI HAR Dataset/test/y_test.txt")

test_subject<-read.table(
    file = "UCI HAR Dataset/test/subject_test.txt")

#pre process and merge test data
test_complete<-cbind(test, test_lables, test_subject)
colnames(test_complete)[c(562,563)]<-c("Activity_ID", "Subject")
test_complete<-as.data.frame(test_complete)

#merge test and train sets
merged<-rbind(train_complete, test_complete)

#load feature names list and use the list to rename columns in the merged data set
features<-read.table(
    file = "UCI HAR Dataset/features.txt")

#extract positions of variables with mean and std
vector<-sort(c(grep("mean",features$V2),grep("std",features$V2)))
names<-as.vector(features$V2[vector])

#take only the necessary columns from the dataset and rename
col_numbers<-c(vector,562,563)
merged<-merged[,col_numbers]
colnames(merged)[1:79]<-names

#load activity names list and use the list to rename rows in the merged data set Activity_ID
activities<-read.table(
    file = "UCI HAR Dataset/activity_labels.txt")
colnames(activities)<-c("Activity_ID", "Activity_Name")
merged_final<-merge(activities, merged, by.y = "Activity_ID")
merged_final<-merged_final[,2:82]

# melt and cast the data in the right format
md<-melt(merged_final, id = (
    c("Activity_Name", "Subject")))

final<-cast(md, Subject + Activity_Name ~ variable, mean)

#write results
write.table(final, "tidy.txt", row.names = FALSE, quote = FALSE)

