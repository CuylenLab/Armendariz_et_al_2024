####A liquid-like coat mediates chromosome clustering during mitotic exit
##Concatenate Extensions into single file
##Sara Cuylen-Haering
##Alberto Hernandez-Armendariz

### Input: Folder with text files with paramementers.
### Output: 1) CSV with parameters including extension.


#clean up
rm(list = ls(all = TRUE))

input_folder <- "//" 
dest_folder <-  "//"

#Loop over files in input folder
files <- list.files(path=input_folder, pattern="*.txt", full.names=T, recursive=FALSE)

summary_table <- data.frame(matrix(nrow=length(files), ncol=24))
colnames(summary_table) <- c("Cell_ID", 
                             "Green_mu1", "Green_sig1", "Green_scale1", "Green_mu2", "Green_sig2", "Green_scale2", "Green_converg","Green_pvalue", "Green_mean_max1","Green_mean_max2",
                             "Red_mu1", "Red_sig1", "Red_scale1", "Red_mu2", "Red_sig2", "Red_scale2", "Red_converg","Red_pvalue", "Red_mean_max1","Red_mean_max2",
                             "Green_dia", "Red_dia", "Green_red_shift")
i=1
for (i in 1:length(files))
{
  #Read in table
  filepath <- files[i]
  Mytable <- read.table(filepath, header = TRUE) 
  
  #Get filename
  name_ex <- basename(filepath) 
  name <- sub("^([^.]*).*", "\\1", name_ex) 
  
  #Write cell ID and parameters from Gauss fit in summary table
  summary_table[i,1] <- name
  summary_table[i,2] <- Mytable["green",1] 
  summary_table[i,3] <- Mytable["green",2]
  summary_table[i,4] <- Mytable["green",3]
  summary_table[i,5] <- Mytable["green",4]
  summary_table[i,6] <- Mytable["green",5]
  summary_table[i,7] <- Mytable["green",6]
  summary_table[i,8] <- Mytable["green",7]
  summary_table[i,9] <- Mytable["green",8]
  summary_table[i,10] <- Mytable["green",9]
  summary_table[i,11] <- Mytable["green",10]
  summary_table[i,12] <- Mytable["red",1]
  summary_table[i,13] <- Mytable["red",2]
  summary_table[i,14]<- Mytable["red",3]
  summary_table[i,15]<- Mytable["red",4]
  summary_table[i,16]<- Mytable["red",5]
  summary_table[i,17]<- Mytable["red",6]
  summary_table[i,18] <- Mytable["red",7]
  summary_table[i,19] <- Mytable["red",8]
  summary_table[i,20] <- Mytable["red",9]
  summary_table[i,21] <- Mytable["red",10]
}

#Calculate diameter and shift
summary_table[,22]<- (sqrt((summary_table[,"Green_mu1"]-summary_table[,"Green_mu2"])^2))*1000 #in nm
summary_table[,23]<- (sqrt((summary_table[,"Red_mu1"]-summary_table[,"Red_mu2"])^2))*1000 #in nm
summary_table[,24]<- (summary_table[,22] - summary_table[,23])/2

#Save table
write.table(summary_table, paste(dest_folder, "Concat_tables.csv",sep=""), row.names=FALSE, col.names=TRUE, sep=",")

