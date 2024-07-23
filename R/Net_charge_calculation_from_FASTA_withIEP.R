#load packages (need to be installed the first time)
library(ade4)
library(seqinr)

#read in fasta file
fastafile <- "***.fasta"
myProts <- read.fasta(fastafile, seqtype = "AA", as.string = TRUE, set.attributes = FALSE)
No_seq <- length(myProts)
dest_folder <- "***"

#---------------------------------------------------
#function to calculate charge
computeCharge <- function(pH, compoAA, pK, nTermResidue, cTermResidue){
  cter <- 10^(-SEQINR.UTIL$pk[cTermResidue,1]) /
    (10^(-SEQINR.UTIL$pk[cTermResidue,1]) + 10^(-pH))
  nter <- 10^(-pH) / (10^(-SEQINR.UTIL$pk[nTermResidue,2]) + 10^(-pH))
  carg <- as.vector(compoAA['R'] * 10^(-pH) / (10^(-pK['R']) + 10^(-pH)))
  chis <- as.vector(compoAA['H'] * 10^(-pH) / (10^(-pK['H']) + 10^(-pH)))
  clys <- as.vector(compoAA['K'] * 10^(-pH) / (10^(-pK['K']) + 10^(-pH)))
  casp <- as.vector(compoAA['D'] * 10^(-pK['D']) /(10^(-pK['D']) + 10^(-pH)))
  cglu <- as.vector(compoAA['E'] * 10^(-pK['E']) / (10^(-pK['E']) + 10^(-pH)))
  ccys <- as.vector(compoAA['C'] * 10^(-pK['C']) / (10^(-pK['C']) + 10^(-pH)))
  ctyr <- as.vector(compoAA['Y'] * 10^(-pK['Y']) / (10^(-pK['Y']) + 10^(-pH)))
  charge <- carg + clys + chis + nter - (casp + cglu + ctyr + ccys + cter)
  return(charge)
}

#load compilation of pK values from Joanna Kiraga (2008)
data(pK)

#You need to decide which pK values you want to use (e. g. Bjellqvist, EMBOSS)
pkC <- pK$EMBOSS #Alternative use pK$Bjellqvist
names(pkC) <- rownames(pK)

#for N and C terminal pK values
data(SEQINR.UTIL) 

#_______________________________________________________________________
#Enter variables here
pH = 7

#_______________________________________________________________________
column1 <- c(length(No_seq)) 
column2 <- c(length(No_seq))
column3 <- c(length(No_seq))
column4 <- c(length(No_seq))
column5 <- c(length(No_seq))
column6 <- c(length(No_seq))
column7 <- c(length(No_seq))
column8 <- c(length(No_seq))
column9 <- c(length(No_seq))

#i=100
for (i in 1:No_seq)
{
  print(i)
  aa= myProts[[i]] #get amino acid sequence
  name = names(myProts[i]) #get ID of protein

#convert sequence to single string for further analysis
prot <- s2c(aa)

#calculate composition, determine N and C terminal aa
compoAA <- table(factor(prot, levels = LETTERS)) #composition of charged aa
nTermR <- which(LETTERS == prot[1]) #extracts N-terminal aa
cTermR <- which(LETTERS == prot[length(seq)]) #extracts C-terminal

netC <- computeCharge(pH, compoAA, pkC, nTermR, cTermR)

#Make table with protein ID and sequence
column1[i]  <- name # latitude 
column4[i] <- aa # longitude 
column5[i] <- compoAA[["K"]]
column6[i] <- compoAA[["T"]]
column7[i] <- compoAA[["P"]]
column8[i] <- compoAA[["E"]]
column9[i] <- compoAA[["L"]]


if (length(netC > 0)){
  column2[i] <- netC   
  }else print(paste(i, " - Charge could not be calculated", sep=""))
  
if (length(prot) > 50){
  AAstats <- AAstat(prot, plot = FALSE)
  IEP <- AAstats$Pi
  column3[i] <- IEP # longitude 
  }else print(paste(i, " - AAstats could not be calculated (less than 50 aa)", sep=""))

} 

my.data <- data.frame(column1, column2, column3, column4, column5, column6, column7, column8, column9) 
colnames(my.data) <- c("Protein_ID", "Charge", "IEP", "Sequence", "aa_K", "aa_T", "aa_P", "aa_E", "aa_L")
write.table(my.data, paste(dest_folder,"NetCharge_output_IEP.txt", sep=""), row.names=FALSE, append = FALSE, sep = "\t")

#plot data
smoothScatter(my.data$IEP)

