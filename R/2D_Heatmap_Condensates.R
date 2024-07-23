####A liquid-like coat mediates chromosome clustering during mitotic exit
##Generate 2D Heatmap of condensed volume as a function of initial cytoplasmic concentration and time
##Sara Cuylen-Haering
##Alberto Hernandez-Armendariz

### Input: Csv file with: Frame, Mutant, File, Condensed_volume, and Initial Cytoplasmic Concentration (icyto_mInt)
### Output: 2D Heatmap color-coded according to Condensed_volume, Initial Cytoplasmic Concentration and Frame.

library(ggplot2)
library(viridisLite)
library(ggrepel)
library(reshape2)
library(Rmisc)
library(dplyr)
library(tidyverse)
library(viridis)

### Import file
setwd('') #Indicate working directory
all<-read.csv(".csv",sep = ";") # Indicate file name

all<-select(all,"Frame","Mutant","File","Condensed_volume","icyto_mInt") #Condensed_volume can be substituted with number of condensates
all$Frame<-as.numeric(all$Frame)
all$Mutant=factor(all$Mutant,levels=c("")) #Indicate mutant
all$File=factor(all$File)

summary(all)

############## Plot

aspect_ratio <- 1.3

p3 <- ggplot(subset(all,all$Mutant=="X"), aes(Frame, icyto_mInt, fill=Condensed_volume)) + 
  geom_point(aes(color = Condensed_volume)) + 
  labs( title="X", x = "Time after flavopiridol addition (min)", y = "Initial Cytoplasmic Mean Intensity")+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()+
  coord_cartesian(ylim=c(15,45))+
  scale_y_continuous(breaks = seq(15, 45, by = 15))+
  scale_color_viridis(option="viridis", discrete = F, limits = c(0,70), breaks= c(0,35,70))+
  guides(fill = FALSE)
p3
ggsave("X_1.pdf",height=10,width=10*aspect_ratio, units="cm")

p3 <- ggplot(subset(all,all$Mutant=="X"), aes(Frame, icyto_mInt, fill=Condensed_volume)) + 
  geom_point(aes(color = Condensed_volume)) + 
  labs( title="X", x = "Time after flavopiridol addition (min)", y = "Initial Cytoplasmic Mean Intensity")+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()+
  coord_cartesian(ylim=c(0,70))+
  scale_y_continuous(breaks = seq(0, 70, by = 10))+
  scale_color_viridis(option="magma", discrete = F, limits = c(0,70), breaks= c(0,35,70))+
  guides(fill = FALSE)
p3
ggsave("X_icytomInt_time_Condensed_volume_2.pdf",height=10,width=10*aspect_ratio, units="cm")

p3 <- ggplot(subset(all,all$Mutant=="X"), aes(Frame, icyto_mInt, fill=Condensed_volume)) + 
  geom_point(aes(color = Condensed_volume)) + 
  labs( title="X", x = "Time after flavopiridol addition (min)", y = "Initial Cytoplasmic Mean Intensity")+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()+
  coord_cartesian(ylim=c(0,70))+
  scale_y_continuous(breaks = seq(0, 70, by = 10))+
  scale_color_viridis(option="viridis", discrete = F, limits = c(0,70), breaks= c(0,35,70))+
  guides(fill = FALSE)
p3
ggsave("X_icytomInt_time_Condensed_volume_3.pdf",height=10,width=10*aspect_ratio, units="cm")

p3 <- ggplot(subset(all,all$Mutant=="X"), aes(Frame, icyto_mInt, fill=Condensed_volume)) + 
  geom_point(aes(color = Condensed_volume)) + 
  labs( title="X", x = "Time after flavopiridol addition (min)", y = "Initial Cytoplasmic Mean Intensity")+
  theme(text = element_text(size = 16,face="bold"))+
  theme_classic()+
  coord_cartesian(ylim=c(15,45))+
  scale_y_continuous(breaks = seq(15, 45, by = 15))+
  scale_color_viridis(option="magma", discrete = F, limits = c(0,70), breaks= c(0,35,70))+
  guides(fill = FALSE)
p3
ggsave("X_icytomInt_time_Condensed_volume_4.pdf",height=10,width=10*aspect_ratio, units="cm")
