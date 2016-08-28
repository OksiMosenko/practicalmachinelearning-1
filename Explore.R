#Explore.R
library(ggplot2)
library(GGally)

my_fn <- function(data, mapping, ...){
    p <- ggplot(data = data, mapping = mapping) + 
        geom_point() + 
        geom_smooth(method=loess, fill="red", color="red", ...) +
        geom_smooth(method=lm, fill="blue", color="blue", ...)
    p
}

g = ggpairs(train2,columns = 1:4, lower = list(continuous = my_fn))
g



#Outliers
summary(train2$gyros_dumbbell_x)
locat <- which(train2$gyros_dumbbell_x < -10)

train2[(locat -2):(locat + 2), ]

train2 <- train2[-locat, ]

#Remove row count
train2 <- train2[, -1]

cor(train2[train2class == "numeric"])

#locate factor variables
which(train2class == "factor")
which(train2class == "integer")

#remove time stamp 1 and cvtd_timestamp
#I don't believe it made a difference which day the exercise was performed on
train2 <- train2[, -which(names(train2)== "raw_timestamp_part_1")]
train2 <- train2[, -which(names(train2)== "raw_timestamp_part_2")]
train2 <- train2[, -which(names(train2)== "cvtd_timestamp")]
train2 <- train2[, -which(names(train2)== "user_name")]


table(train2$classe)

lenUniq <- function(x){
    length(unique(x))
}
sapply(train2, lenUniq)
