
library (splitTools)
library (ranger)

setwd(file.path('C:', 'Users', 'bpickens','OneDrive - DOI', 'Desktop', 'R2_working', 
                'annotations'))

# Input dataset
data1 <- read.table ("whcr_annot_dataset.csv",sep = ",",header=TRUE, fill=TRUE)

#######################
## Partition types: 
# Basic- random
# Stratified- evenly split by a variable 
# Grouped- data blocks are kept together

#### 2 SPLITS!
part_image <- partition(data1$unique_image_jpg,type = "grouped", p = c(train =0.80, test = 0.20))

train1 <- data1[part_image$train,]
test1 <- data1[part_image$test,]

# Examine distribution of species by partition
table (train1$overall_family)
table (test1$overall_family)

## Write each split to a new table
write.table(test1,"new_test_Aug22.csv", col.names=TRUE, row.names=FALSE, sep=",")

write.table(train1,"new_train_Aug22.csv", col.names=TRUE, row.names=FALSE, sep=",")


# 3 SPLITS below- commented out
# part_image <- partition(data1$unique_image,type = "grouped", p =c(train =0.6, valid = 0.2, test = 0.2))

#train1 <- data1[part_image$train,]
#test1 <- data1[part_image$test,]
#test1 <- data1[part_image$valid,]

### Random split- commented out below
#part_image <- partition(data1$parent_image,type = "basic", p = c(train =0.70, test = 0.30))

#train1 <- data1[part_image$train,]
#test1 <- data1[part_image$test,]

#train1$status <- "train"
#test1$status <- "test"

# Examine distribution of species by partition
#table (train1$overall_family)
#table (test1$overall_family)





