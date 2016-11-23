require(xgboost)
require(methods)
require(R.matlab)
require(data.table)

mc.train1 <- read.table('freqTableL_noID.txt')
mc.train1 <- data.frame(mc.train1)
mc.train1 <- mc.train1[-5060,]
mc.train1 <- mc.train1[,-c(3,6,29)]

mc.train2 <- readMat('2gram_train.mat')
mc.train2 <- data.frame(mc.train2)

mc.train3 <- readMat('3gram_train.mat')
mc.train3 <- data.frame(mc.train3)

mc.train4 <- readMat('4gram_train.mat')
mc.train4 <- data.frame(mc.train4)

mc.train <- cbind(mc.train1,mc.train2,mc.train3,mc.train4)
remove(mc.train1,mc.train2,mc.train3,mc.train4)

mc.test1 <- read.table('freqTableL_test_noID.txt')
mc.test1 <- data.frame(mc.test1)
mc.test1 <- mc.test1[,-c(3,6,29)]

mc.test2 <- readMat('2gram_test.mat')
mc.test2 <- data.frame(mc.test2)


mc.test3 <- readMat('3gram_test.mat')
mc.test3 <- data.frame(mc.test3)

mc.test4 <- readMat('4gram_test.mat')
mc.test4 <- data.frame(mc.test4)

mc.test <- cbind(mc.test1,mc.test2,mc.test3,mc.test4)

remove(mc.test1,mc.test2,mc.test3,mc.test4)
#mc.test1 <- readMat('')
#mc.test1 <- data.frame(mc.test)

label <- readMat('label.mat')
label <- data.frame(label)

mc.train[,31360] <- label
mc.test[,31360] <- 0
#mc.train$total <- 0
#mc.train$test <- 0

#t <- rowSums(mc.train, na.rm = FALSE, dims = 1)
#mc.train$total <- t

#t1 <- rowSums(mc.test, na.rm = FALSE, dims = 1)
#mc.test$total <- t1
n <- nrow(mc.train)
y = mc.train[,31360]
y = as.integer(y)-1 #xgboost take features in [0,numOfClass)
names(mc.test) <- names(mc.train)
x = rbindlist(list(mc.train[,-31360],mc.test[,-31360]))
remove(mc.train,mc.test)

#x = mc.train[,-31360]#remove when doing actual thing 
x = as.matrix(x)
x = matrix(as.numeric(x),nrow(x),ncol(x))
trind = 1:length(y)
teind = (n+1):nrow(x)

# Set necessary parameter
param <- list("eta" = 0.05,
              "subsample" = 0.5,
              #"max_depth" = 25,
              "objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 9,
              "nthread" = 8)

# Run Cross Valication
#cv.nround = 500
#bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
#                nfold = 3, nrounds=cv.nround)

# Train the model
nround = 350
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)

# Make prediction
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)
# Output submission
pred = format(pred, digits=2,scientific=F) # shrink the size of submission
pred = data.frame(1:nrow(pred),pred)
#names(pred) = c('Id', paste0('Prediction',1:9))
write.csv(pred,file='merged.csv', quote=FALSE,row.names=FALSE)
