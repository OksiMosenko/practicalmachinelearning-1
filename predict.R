library(caret)
library(rpart)
library(parallel)
library(doParallel)

LinearModel <- train(classe ~ ., data = train2, 
                     method = "glm", family = )
class(train2$classe)

#Parallel processing
cluster <- makeCluster(detectCores() - 1)
registerDoParallel(cluster)

fitControl <- trainControl(method = "cv",
                           number = 10,
                           allowParallel = TRUE)

modelRF <- train(classe ~ .,
                 data = train2,
                 method = "rf",
                 prox = TRUE)

modelRF2 <- train(classe ~ .,
                 data = train2,
                 method = "rf")

#Run parallel
modelRF3 <- train(classe ~ .,
                  data = train2,
                  method = "rf",
                  trControl = fitControl,
                  prox = TRUE)

#De-register parallel processing cluster
stopCluster(cluster)

trainSmall <- createDataPartition(y = train2$classe, p = 0.3, list = FALSE)
train3 <- train2[trainSmall, ]

modelRF4 <- train(classe ~ .,
                  data = train3,
                  method = "rf",
                  trControl = trainControl(method = "cv", number = 10),
                  prox = TRUE)
modelRF4

pred4 <- predict(modelRF4, test)
pred4
#> pred4
#[1] B A B A - A E D B - A A B C - B A E E - A B B B
#Levels: A B C D E
#confusionMatrix(pred4, test)

modelTree <- train(classe ~ .,
                 data = train2,
                 method = "rpart")

rpart1 <- rpart(class3 ~ .,
                data = train2)