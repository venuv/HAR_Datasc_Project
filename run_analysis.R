library(data.table)
library(dplyr)

# part 1 - Merges the training and the test sets to create one data set.
# thanks to http://brain.cin.ucsf.edu/~craig/rstuff/Data_Wrangling_Cheatsheet.pdf

setwd('train')
training_set <- read.table('X_train.txt')
training_activity_labels<-read.table('y_train.txt')
training_user_ids <- read.table('subject_train.txt')
#training_merged <- mutate(training_set,activity=training_activity_labels,user=training_user_ids)
training_merged <- mutate(data.table(training_set),activity=data.table(training_activity_labels),user=data.table(training_user_ids))


setwd('../test')
testing_set <- read.table('X_test.txt')
testing_activity_labels<-read.table('y_test.txt')
testing_user_ids <- read.table('subject_test.txt')
#testing_merged <- mutate(testing_set,activity=testing_activity_labels,user=testing_user_ids)
testing_merged <- mutate(data.table(testing_set),activity=data.table(testing_activity_labels),user=data.table(testing_user_ids))

merged_data <- bind_rows(training_merged,testing_merged)

# part 2 - Extracts only the measurements on the mean and standard deviation for each measurement. 
#merged_narrow <- merged_data[,grepl("mean()|std()",names(merged_data))]
setwd('..')
features<-read.table('features.txt')
full_features<- unlist(as.character(feature_labels))
feature_labels<- features$V2
full_features<- unlist(as.character(feature_labels))
filtered_features <- grep("mean|std()",full_features)
filtered_features <- append(filtered_features,c(562,563))
narrow_data <- select(merged_data,filtered_features)
#filtered_features <- append(full_features[filtered_features],c('activity','user'))
#narrow_data <- merged_data[,filtered_features]

# part 3 - Uses descriptive activity names to name the activities in the data set
activity_labels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
narrow_data$activity<- activity_labels[narrow_data$activity]



# part 4 - Appropriately labels the data set with descriptive variable names. 
#filtered_features <- grep("mean|std()",full_features)
names(narrow_data) <- append(full_features[grep("mean|std()",full_features)],c('activity','user'))
#names(narrow_data)<-append(full_features[filtered_features],c('activity','user'))

# part 5 - From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable for each activity and each subject.
myfunc<- function (x) return(grep(x,activity_labels)[1])
activity_integer<-sapply(narrow_data$activity,myfunc)
narrow_data$activity<- activity_integer
narrow_data_grouped <- group_by(narrow_data,activity,user)
# now compute average

