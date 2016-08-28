# Measure How Well People Perform Weight Lifting Exercises
Natalie Phillips  
29 August 2016  





## Synopsis

It is now common for people to measure how much of an activity they are doing.
It is less common for people to measure how well are completing an activity.
Is possible to accruately predict whether barbell lifts have been performed 
correctly as the analysis below demostrates. This ability to predict how a person
is moving has great implications for automated coaching and feedback for poeple
both in and out of home and the gym.

A group of volunteers were asked to lift dumbells in an exercise called *Unilateral Dumbbell Biceps Curl*. They were asked to lift the weights using the correct technique or
one of four common errors.

Label for lift     |   Lift technique
-----------      |   --------------
class A         |   correct lift
class B         |   throwing elbows to the front
class C         |   lifting only half way
class D         |   lowering only half way
class E         |   throwing hips to the front.

The excercise was measured using sensors called accelerometers on various parts of the body as well 
as the dumbells. Sensors were placed on:

* arm
* forearm
* belt
* dumbell.

## Loading and processing data

The data were first downloaded. A check is performed to see if the data is already there.



The data are then loaded into test and train set. There are two *NA* strings, *NA* and *#DIV/0!* in the data.


```r
train <- read.csv(".\\data\\pml-training.csv",
                  na.strings = c("NA", "#DIV/0!")
                  )
test <- read.csv(".\\data\\pml-testing.csv",
                 na.strings = c("NA", "#DIV/0!")
                    )
```

The train set has 160 variables and 19622 observations. The test set has the same number of variables less the *classe* (results) column and 20 observations.

Cleaning of the data was performed in three ways:

* where most of the measurements were $NA$s the variable was removed
* names dates and indexes are not relevant to the prediction were removed
* one outlier was removed.

The outlier contained values well outside the range of the rest of the valuse could have been a miss read by the sensors or perhaps a dropped equipment.



all of the variables are useful for our model.

```r
library(plyr)
library(dplyr)
# Remove rows containing mainly NAs
nmissing <- function(x) {
    sum(is.na(x))   # Calculate the number of NAs
}

NA_Col <- which(colwise(nmissing)(train) > 19000)
train2 <- train[, -NA_Col] # Remove columns with NAs

# Remove names and dates
train2 <- train2[, -(1:5)]

# Remove outlier
summary(train2$gyros_dumbbell_x)
```

```
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
-204.0000   -0.0300    0.1300    0.1611    0.3500    2.2200 
```

```r
locat <- which(train2$gyros_dumbbell_x < -10)
train2 <- train2[-locat, ]
```

The new training set has 55 variables and 19621 observations. No other preprocessing was performed as Random Forests don't require normal data. Removing the outlier has allowed data for some of the variables to be less skewed. Take the variable *gyros_dumbbell_x* for example.You can see from the two graphs below the change removing the outlier allows us to see the true nature of the movement:

<div class="rimage center"><img src="fig/plot1-1.png" class="plot" /></div>

I chose Random Forests were chosen to model the type of movement due to their requation for accuracy. The error was calculated to be k-fold with 10 foldes to provide a reasonable out of sample estimage. Unfortunately the computer I was using for the machine learning could not build a model with all of the observations. The observation was bought down to a third to make the calculations more manageable. 


```r
library(caret)
library(rpart)

# Make the size more manageable and speed up computations
set.seed(1375)
trainSmall <- createDataPartition(y = train2$classe, p = 0.3, list = FALSE)
train3 <- train2[trainSmall, ]

# Train the Random Forest model with 10 fold Cross Validations 
modelRF <- train(classe ~ .,
                  data = train3,
                  method = "rf",
                  trControl = trainControl(method = "cv", number = 10),
                  prox = TRUE)
```

The model has over an 98% accuracy:

```r
confusionMatrix(modelRF)
```

```
Cross-Validated (10 fold) Confusion Matrix 

(entries are percentual average cell counts across resamples)
 
          Reference
Prediction    A    B    C    D    E
         A 28.4  0.3  0.0  0.0  0.0
         B  0.0 18.9  0.2  0.0  0.1
         C  0.0  0.2 17.2  0.3  0.0
         D  0.0  0.0  0.1 16.0  0.1
         E  0.0  0.0  0.0  0.0 18.2
                            
 Accuracy (average) : 0.9871
```

This model was applied to the test set with 100% success.

We have left over training data which we can apply and test the predictions on. We don't need to perform any preprocessing as no transformations were performed. Also the prediction model will only reference those named columns used in the model.


```r
# Predicting using the left over training data
test2 <- train2[-trainSmall, ]
pred <- predict(modelRF, test2)
confusionMatrix(pred, test2$classe)
```

```
Confusion Matrix and Statistics

          Reference
Prediction    A    B    C    D    E
         A 3904   17    0    0    0
         B    1 2614   17    0    3
         C    0   25 2373   32    1
         D    0    1    5 2219   16
         E    0    0    0    0 2504

Overall Statistics
                                          
               Accuracy : 0.9914          
                 95% CI : (0.9897, 0.9929)
    No Information Rate : 0.2844          
    P-Value [Acc > NIR] : < 2.2e-16       
                                          
                  Kappa : 0.9891          
 Mcnemar's Test P-Value : NA              

Statistics by Class:

                     Class: A Class: B Class: C Class: D Class: E
Sensitivity            0.9997   0.9838   0.9908   0.9858   0.9921
Specificity            0.9983   0.9981   0.9949   0.9981   1.0000
Pos Pred Value         0.9957   0.9920   0.9761   0.9902   1.0000
Neg Pred Value         0.9999   0.9961   0.9981   0.9972   0.9982
Prevalence             0.2844   0.1935   0.1744   0.1639   0.1838
Detection Rate         0.2843   0.1904   0.1728   0.1616   0.1823
Detection Prevalence   0.2855   0.1919   0.1770   0.1632   0.1823
Balanced Accuracy      0.9990   0.9910   0.9928   0.9919   0.9960
```

## Conclusions
With over 99% accuracy this model shows just how accurately motion can be captured. This will likely open  up many new coaching applications and gadgets in the fitness industry and beyond.



## Citation

I gratefully cite this paper and data collection work which made this analysis possible.

Velloso, E.; Bulling, A.; Gellersen, H.; Ugulino, W.; Fuks, H. **Qualitative Activity Recognition of Weight Lifting Exercises**. Proceedings of 4th International Conference in Cooperation with SIGCHI (Augmented Human '13) . Stuttgart, Germany: ACM SIGCHI, 2013.

## Further work
It appears one of the most important measures when predicting how well an excercise
is performed is **new_windowyes**. I wonder if this value can be known outside of
an experimental environment? Perhaps next time this variable along with **num_window**
should be removed.

I more powerful machine or would enable the model to be built with all of the observations which may improve the accuracy some what.
