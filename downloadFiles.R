#Download file

#Create a data directory if one isn't already there
if (!file.exists("data")){
    dir.create("data")
}

#Location where files can be downloaded from
trainUrl <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
testUrl <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

#Have files already been downloaded? If not then download.
if (!file.exists(".\\data\\pml-training.csv")){
    download.file(trainUrl, destfile = ".\\data\\pml-training.csv", method = "curl")
}

if (!file.exists(".\\data\\pml-testing.csv")){
    download.file(testUrl, ".\\data\\pml-testing.csv", method = "curl")
}
