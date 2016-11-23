require(xgboost)
require(methods)
require(R.matlab)
require(data.table)

mc.train1 <- readMat('train.mat')
mc.train2 <- readMat('train.mat')
mc.train1  <- data.frame(mc.train1)
mc.train2  <- data.frame(mc.train2)
mc.train <- rbind(mc.train1,mc.train2)
remove(mc.train1,mc.train2)

mc.test1 <- readMat('test.mat')
mc.test2 <- readMat('test.mat')
mc.test1  <- data.frame(mc.test1)
mc.test2  <- data.frame(mc.test2)
mc.test <- rbind(mc.test1,mc.test2)
remove(mc.test1,mc.test2)

label <- readMat('label.mat')
label <- data.frame(label)

mc.train[,33667] <- label
mc.test[,33667] <- 0

n <- nrow(mc.train)
y = mc.train[,33667]
y = as.integer(y)-1 #xgboost take features in [0,numOfClass)
names(mc.test) <- names(mc.train)
x = rbindlist(list(mc.train[,-33667],mc.test[,-33667]))

remove(mc.train,mc.test)
#x = mc.train[,-33667]#remove when doing actual thing 
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
#               nfold = 3, nrounds=cv.nround)

# Train the model
nround = 500
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)

# Make prediction
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)
# Output submission
pred = format(pred, digits=2,scientific=F) # shrink the size of submission
pred = data.frame(1:nrow(pred),pred)
#names(pred) = c('Id', paste0('Prediction',1:9))
write.csv(pred,file='results.csv', quote=FALSE,row.names=FALSE)
