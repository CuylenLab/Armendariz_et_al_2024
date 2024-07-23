####A liquid-like coat mediates chromosome clustering during mitotic exit
##Generate 1D Heatmap of protein charge distribution
##Sara Cuylen-Haering
##Alberto Hernandez-Armendariz

### Input: Csv file with Position (column 1) and corresponding charge (column 2)
### Output: Heatmap color-coded according to min/max charge distribution

file_name <- ".csv"
path <- ""
Mytable <- read.csv(paste(path,file_name, sep=""), sep=";", header=T,  fill=TRUE)

library(scales) 
library(ggplot2)


ggplot(data=Mytable, aes(x=Position, y=1)) + 
  geom_tile(aes(fill=Charge))+
  scale_fill_gradient2(low="red", high="blue",limits=c(-(max(Mytable$Charge)), max(Mytable$Charge)), breaks=c(-(max(Mytable$Charge)),0,max(Mytable$Charge)))+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()
ggsave("1.pdf",width=30,height=20,units="cm")


ggplot(data=Mytable, aes(x=Position, y=1)) + 
  geom_tile(aes(fill=Charge))+
  scale_fill_gradient2(low="red", high="blue",limits=c(min(Mytable$Charge), -(min(Mytable$Charge))), breaks=c(min(Mytable$Charge),0,-(min(Mytable$Charge))))+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()
ggsave("2.pdf",width=30,height=20,units="cm")

