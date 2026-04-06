library(dplyr)
library(readr)

run_prog <- function(){
    train_doc <- docprod("Train")
    test_doc <- docprod("Test")
    
    combined <- rbind(train_doc, test_doc) %>% relocate(Activity, .after = 1)
    write_csv(combined, "combined data.csv")
    
    cal <- combined %>% group_by(Subject, Activity, DataType) %>%
            summarise(across(where(is.numeric), mean), recordCount = n()) %>%
            relocate(recordCount, .after = 3)
    colnames(cal)[5:ncol(cal)] <- paste0("Ave of ", colnames(cal)[5:ncol(cal)])
    
    write_csv(cal, "processed data.csv")
    cal
}


docprod <- function(my_type){
    data_orig <- paste0("UCI HAR Dataset/", my_type , "/X_", my_type, ".txt")
    data_subj <- paste0("UCI HAR Dataset/", my_type , "/subject_", my_type, ".txt")
    data_y <- paste0("UCI HAR Dataset/", my_type , "/y_", my_type, ".txt")
    
    features <- read.table("UCI HAR Dataset/features.txt")
    activity <- read.table("UCI HAR Dataset/activity_labels.txt")
    
    my_orig <- read.table(data_orig)
    colnames(my_orig) <- features[[2]]
    my_orig <- my_orig[, grep("mean\\(\\)|std\\(\\)", features[[2]])]
    
    my_subj <- read.table(data_subj)
    
    my_y <- read.table(data_y) %>% merge(activity, by.x = "V1", , by.y = "V1") 
    
    my_doc <- cbind(my_subj, my_orig, my_y[[1]])
    
    my_doc <- rename(my_doc, Subject = V1, Activity = `my_y[[1]]`)
    my_doc <- my_doc %>% mutate(Activity = factor(Activity, levels = activity[[1]], labels = activity[[2]])) %>% 
                mutate(DataType = my_type) %>% relocate(DataType, .after = 1)
    my_doc
}
