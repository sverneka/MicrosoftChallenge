# Kaggle Feature Extraction code :- malware classification problem
#######################################################################
# This code crawls through the files and 
# collects position sequence of each instruction pattern for each file
# It also prepares final single frequency table for all the files.
library(parallel)

train.filenames <- list.files("trainM", pattern="*.asm")
noTrain = length(train.filenames)
keyw <- c("movzx","sub","push","lea","mov","call","retn","jmp","end","add","pop","test","jz","inc","jnz","popf","cmp","or","xor","push","ja","div","call","not","jnb","shl","imul","pushf")
l1 <- list(train.filenames)
l2 <- list(keyw)


# function to calculate position for each pattern in a file, 
# also updates frequency matrix
parproc <- function (i) {
  print(i)
  print(train.filenames[i])
  fullpath = paste("trainM/", train.filenames[i], sep = "")
  temp <- scan(fullpath, what = "character")
  pat <- sapply(keyw,grep,temp)  
  
  #adding frequencies for each pattern in matrix
  freqTable<- sapply(pat,length)
  
  #writing frequency to a file
  freqfile <- paste("trainM/", "freq-", train.filenames[i], ".txt", sep = "")
  write.table(freqTable, file = freqfile, sep = " ", row.names = FALSE, col.names = FALSE)  
  
  #writing features to a file
  featurefile <- paste("trainM/", train.filenames[i], ".txt", sep = "")
  lapply(pat, write, file=featurefile, append=TRUE, ncolumns=100000)
}

# calling the above function in parallel. 
# By default, It utilizes max. No. of cores available on the machine, here it is set to 4

mclapply(1:noTrain, parproc, mc.cores = 4) # use mc.cores to set no of cores
