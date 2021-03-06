
#set working directory
# setwd("F:/Credit scoring")
setwd("C:\\Users\\Eva\\Google Drive\\Admissions\\NYU\\Admitted\\Courses\\DSGA 3001_9 Responsible DS\\Project\\nutritional-label-for-loan-recommendation-system\\data\\raw")

install.packages('abind')
install.packages('zoo')
install.packages('xts')
install.packages('quantmod')
install.packages('ROCR')
install.packages("DMwR")
library("DMwR")

test_set <- read.csv("cs-test.csv", header = T)
sample_entry <- read.csv("sampleEntry.csv", header=T)

data <- read.csv("cs-training.csv", header=T)
# data <- read.csv("data.csv", header=T)
colnames (data)

##############
# create validation 
##############
#
train <- sample(nrow(data), floor(nrow(data) * 0.66)) 
training <- data[train, ] 
validation <- data[-train, ] 
remove (train)   # remove data to free up space 

#######################
# SMOTE
#######################
# Literature: http://cran.r-project.org/web/packages/DMwR/DMwR.pdf

require(DMwR)
data$ydata <- as.factor(data$SeriousDlqin2yrs)
# must set ydata as factor and has to be placed at the end!!!!!!!!
data$ydata <- as.factor(data$ydata)
data <- SMOTE(ydata ~ ., data
                ,k = 5
                ,perc.over = 700,perc.under=200)
table(data$ydata)



####################################################
#modelling procedure
####################################################

################
#GBM  
################
require(gbm)

model <- gbm(
  ydata ~ ., 
  distribution = "adaboost", 
  data = data, 
  #var.monotone = NULL,
  n.trees = 5000,
  interaction.depth = 4,
  n.minobsinnode = 30,
  shrinkage = 0.05,
  bag.fraction = 0.2,
  train.fraction = 0.8,
  #cv.folds=5,
  #keep.data = TRUE,
  verbose = TRUE)

predict <- predict.gbm (model, test_set, n.trees = 5000, type = "response")

# Save to file
write.csv(predict,'test_preds_gbm_.csv')
################
# Random Forest
################
require(randomForest)
data$ydata <- as.factor(data$ydata)

model <- randomForest (ydata ~ ., data, ntree = 250, nodesize = 100)
predict <- predict (model, test_set, type = "prob")

# Save to file
write.csv(predict,'test_preds_randomForest.csv')

################
#caret
################
#http://cran.r-project.org/web/packages/caret/caret.pdf
require(caret)
require(MASS)

data$ydata <- as.factor(data$ydata)
model <- train (ydata ~ ., data, method = "xxx")
# replace xxx with a function found in caret

predict <- predict (model, test_set)

# Save to file
# write.csv(predict,'test_preds_final.csv')

#################
# write output
#################

# write.csv(predict, file = "predict.csv", quote = FALSE, row.names = FALSE)
# Save to file
write.csv(predict,'test_preds_.csv')

