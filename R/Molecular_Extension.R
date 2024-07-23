####A liquid-like coat mediates chromosome clustering during mitotic exit
##Calculate Ki-67 extension from line profiles
##Sara Cuylen-Haering
##Alberto Hernandez-Armendariz

### Input: Folder with Line profiles
### Output: 1) Text file with parameters. 2) PDF with Fluorescence Density over Distance and calculated distance between peaks. 3) PDF with summary plots.


## Clean up

rm(list = ls(all = TRUE))

### Define paths and parameters*****************************************************************************

## Set input and output folder
inputdir<-paste("//")   #Input directory
outputdir<-paste("//")  #Output directory


### Preparations*****************************************************************************

## input files

setwd(inputdir) #### write the path, where the data is
getwd() ### gives current working dirrectory, where all the files will be read from and all the output will be written to
file_list<-list.files(pattern = ".txt")		#list of files to be analysed
print(file_list)
length(file_list)

## initialising output vectors

dens_green<-matrix(NA,length(range),length(file_list))
dens_red<-matrix(NA,length(range),length(file_list))


library(nnet) #for funciton which.is.max

### functions**********************************************************************************

## fit 2 Gaussians

fit2G <- function(x,y,mu1,sig1,scale1,mu2,sig2,scale2,...){  
  f = function(p){
    d = p[3]*dnorm(x,mean=p[1],sd=p[2]) + p[6]*dnorm(x,mean=p[4],sd=p[5])
    sum((d-y)^2)
  }
  optim(c(mu1,sig1,scale1,mu2,sig2,scale2),f,method = "L-BFGS-B",lower = c(0,0.1,0,0,0.1, 0), upper = c(Inf,0.5,Inf,Inf,0.5,Inf),...)
  #optim(c(mu1,sig1,scale1,mu2,sig2,scale2),f,...)
}


## find local maxima (first and last datapoint included)

localMaxima <- function(x) {
  # Use -Inf instead if x is numeric (non-integer)
  y <- diff(c(-.Machine$integer.max, x)) > 0L
  rle(y)$lengths
  y <- cumsum(rle(y)$lengths)
  y <- y[seq.int(1L, length(y), 2L)]
  if (x[[1]] == x[[2]]) {
    y <- y[-1]
  }
  y
}

## find local minima (first and last datapoint included)

localMinima <- function(x) {
  # Use -Inf instead if x is numeric (non-integer)
  y <- diff(c(.Machine$integer.max, x)) > 0L
  rle(y)$lengths
  y <- cumsum(rle(y)$lengths)
  y <- y[seq.int(1L, length(y), 2L)]
  if (x[[1]] == x[[2]]) {
    y <- y[-1]
  }
  y
}

##****************************************************************************************************
### loop over text files in input folder

for(j in 1:length(file_list))
{ 
  
  data<-as.matrix(read.delim(file_list[j], header=T, as.is=TRUE, sep=""))
  is.matrix(data)
  dim(data)
  colnames(data) <- c("coord", "green", "red")
  
  coord<-data[,1]
  
  ID_split <- strsplit(file_list[j], '[.]')[[1]]
  ID <- ID_split[1]
  
  ### plot raw data
  plot(data[,1],data[,2], col="green4", main=ID, ylim = c(0, max(data[,2:3])),pch=16, xlab="Distance, (um)", ylab="Intensity (a.u.)",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(data[,1],data[,3], col="red", pch=16)
  
  ### calculate the background (using lowest value as background)
  baground<-rep(NA,2)
  names(baground)<-colnames(data)[2:3]
  
  baground["green"]<-min(data[,"green"])
  baground["red"]<-min(data[,"red"])
  
  print(baground)
  
  ### substract background
  data_subst <- cbind(data[,1], t(apply(data[,2:3], 1, "-", baground)))
  colnames(data_subst)[1] <- "coord"
  
  ##plot with substracted background
  plot(data_subst[,"coord"],data_subst[,"green"], col="green4", main=ID, ylim = c(0, max(data_subst[,2:3])),pch=16, xlab="Distance, (um)", ylab="Intensity (a.u.)",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(data[,1],data_subst[,"red"], col="red", pch=16)
  
  ### calculate density
  sum_data <- colSums(data_subst)
  density <- cbind(data_subst[,"coord"], data_subst[,"green"]/sum_data["green"], data_subst[,"red"]/sum_data["red"])
  colnames(density) <- c("coord", "green", "red")
  
  ### plot the density
  plot(density[, "coord"],density[,"green"], col="green4", ylim=c(0,0.12), main=ID, pch=16, xlab="Distance, (um)", ylab="Density",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(density[, "coord"],density[,"red"], col="red", pch=16)
  
  
  ### Gaussian fit***************************************

  #estimate global maximum
  Max_green1 <- density[which.is.max(density[1:(dim(density)[1]/2) ,"green"]),"coord"]
  Max_green2 <- density[(which.is.max(density[((dim(density)[1]/2)+1):(dim(density)[1]) ,"green"])+ (dim(density)[1]/2)), "coord"]
  Max_red1 <- density[which.is.max(density[1:(dim(density)[1]/2) ,"red"]),"coord"]
  Max_red2 <- density[which.is.max(density[((dim(density)[1]/2)+1):(dim(density)[1]) ,"red"]) + (dim(density)[1]/2), "coord"]
  
  sig <- 0.5
  scale<-0.04	
  
  fit2_green = fit2G(density[,"coord"],density[,"green"],Max_green1, sig,scale, Max_green2 ,sig,scale,control=list(maxit=10000))
  p_green = fit2_green$par
  
  fit2_red = fit2G(density[,"coord"],density[,"red"],Max_red1, sig,scale,Max_red2,sig,scale,control=list(maxit=10000))
  p_red = fit2_red$par
  
  parameters<-matrix(NA, 2,10)
  colnames(parameters)<-c("mu1", "sig1", "scale1", "mu2", "sig2", "scale2", "convergence", "p_value", "mean_max1", "mean_max2")
  rownames(parameters)<-c("green", "red")
  
  parameters["green",1:6] <- p_green
  parameters["red",1:6] <- p_red
  parameters["green", "convergence"] <-  fit2_green$convergence #0 means successful completion of fit
  parameters["red", "convergence"] <- fit2_red$convergence #Number of iterations to get best fit
  
  
  #get mean green value of first peak (calculate closest coordinate from line profile from to mu1 and get mean value)
  mean_max1_green <- data[which.min(abs(data[,"coord"] - parameters["green", "mu1"])),"green"]
  mean_max2_green <- data[which.min(abs(data[,"coord"] - parameters["green", "mu2"])),"green"]
  
  mean_max1_red <- data[which.min(abs(data[,"coord"] - parameters["red", "mu1"])),"red"]
  mean_max2_red <- data[which.min(abs(data[,"coord"] - parameters["red", "mu2"])),"red"]
  
  #write in parameters vector
  parameters["green", "mean_max1"] <- mean_max1_green
  parameters["green", "mean_max2"] <- mean_max2_green
  parameters["red", "mean_max1"] <- mean_max1_red
  parameters["red", "mean_max2"] <- mean_max2_red
  
  range<-c(0:300)*0.01 #range for simulation of Gauss
  
  #**********************Kolmogorov Smirnow test*****************************
  twoGauss <- function(x,mu1,sig1,scale1,mu2,sig2,scale2){
  scale1*dnorm(x,mean=mu1,sd=sig1) + scale2*dnorm(x,mean=mu2,sd=sig2)
  }
  
  #calculate expected values for given parameters
  exp_values_green <- twoGauss(coord,p_green[1],p_green[2],p_green[3],p_green[4],p_green[5],p_green[6])
  exp_values_red <- twoGauss(coord,p_red[1],p_red[2],p_red[3],p_red[4],p_red[5],p_red[6])
  
  #plot green
  plot(density[,"coord"],density[,"green"], col="green4", pch=16, xlab="Distance (?m)", ylab="Density")
  points(coord, exp_values_green, col="black")
  lines(range, (p_green[3]*dnorm(range,p_green[1],p_green[2])) + (p_green[6]*dnorm(range,p_green[4],p_green[5])), col="limegreen")
  
  test_green <- ks.test(density[,"green"], exp_values_green)
  pvalue_green <- test_green$p.value
  test_red <- ks.test(density[,"red"], exp_values_red)
  pvalue_red <- test_red$p.value
  
  parameters["green", "p_value"] <-  pvalue_green #0 means successful completion of fit
  parameters["red", "p_value"] <- pvalue_red #Number of iterations to get best fit
  
  qqplot(density[,"green"], exp_values_green, xlab="Observed values", ylab="expected values")
  abline(0, 1, col="red")

  #***************************************************************************

  ###+++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ##generate pdf with Gauss fit
  pdf(paste(outputdir,ID,"_Gauss.pdf", sep=""), height=8, width=6)   # DIN A4
  
  plot(density[,"coord"],density[,"green"], col="green4", pch=16, xlab="Distance (?m)", ylab="Density")
  title(ID, line = 3.2)
  
  lines(range, p_green[3]*dnorm(range,p_green[1],p_green[2]), col="limegreen", lty=2)
  lines(range, p_green[6]*dnorm(range,p_green[4],p_green[5]),col="limegreen", lty=2)  
  lines(range, (p_green[3]*dnorm(range,p_green[1],p_green[2])) + (p_green[6]*dnorm(range,p_green[4],p_green[5])), col="limegreen")
  
  points(density[,"coord"],density[,"red"], col="red", pch=16)
  
  lines(range,p_red[3]*dnorm(range,p_red[1],p_red[2]), col="red3", lty=2)
  lines(range,p_red[6]*dnorm(range,p_red[4],p_red[5]),col="red3", lty=2)
  lines(range, (p_red[3]*dnorm(range,p_red[1],p_red[2])) + (p_red[6]*dnorm(range,p_red[4],p_red[5])), col="red3")
  
  ### calculate the distance between green and red
  
  dist_green <-sqrt((parameters["green","mu1"]-parameters["green","mu2"])^2)
  print(dist_green)
  
  dist_red <-sqrt((parameters["red","mu1"]-parameters["red","mu2"])^2)
  print(dist_red)
  
  shift <- (dist_green - dist_red)/2
  
  mtext(paste("Chromosome diameter green =", round(dist_green*1000), "nm"), line = 0.3)
  mtext(paste("Chromosome diameter red =", round(dist_red*1000), "nm"), line = 1.1)
  mtext(paste("Shift green to red =", round(shift*1000), "nm"), line = 1.9)
  
  dev.off(dev.cur())
  
  
  ###+++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ##generate one pdf with 4 graphs + distance measurement
  
  pdf(paste(outputdir,ID,"_summary.pdf", sep=""), height=11.69, width=8.27)   # DIN A4
  par(mfrow=c(2,2), oma = c(0, 0, 2, 0))
  
  ### plot raw data
  plot(data[,1],data[,2], col="green4", main=ID, ylim = c(0, max(data[,2:3])),pch=16, xlab="Distance, (um)", ylab="Intensity (a.u.)",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(data[,1],data[,3], col="red", pch=16)
  
  ##plot with substracted background
  plot(data_subst[,"coord"],data_subst[,"green"], col="green4", main=ID, ylim = c(0, max(data_subst[,2:3])),pch=16, xlab="Distance, (um)", ylab="Intensity (a.u.)",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(data[,1],data_subst[,"red"], col="red", pch=16)
  
  #pdf(paste(outputdir,ID,"_Gauss.pdf", sep=""), height=6, width=8)   
  plot(density[, "coord"],density[,"green"], col="green4", ylim=c(0,0.12), main=ID, pch=16, xlab="Distance, (um)", ylab="Density",cex.axis = 1.3, cex.lab = 1.3, cex.main=1.3 )
  points(density[, "coord"],density[,"red"], col="red", pch=16)
  
  ##plot Gaussian fit
  plot(density[,"coord"],density[,"green"], col="green4", pch=16, xlab="Distance (?m)", ylab="Density")
  title(ID, line = 3.2)
  
  lines(range,p_green[3]*dnorm(range,p_green[1],p_green[2]), col="limegreen", lty=2)
  lines(range,p_green[6]*dnorm(range,p_green[4],p_green[5]),col="limegreen", lty=2)  
  lines(range, (p_green[3]*dnorm(range,p_green[1],p_green[2])) + (p_green[6]*dnorm(range,p_green[4],p_green[5])), col="limegreen")
  
  points(density[,"coord"],density[,"red"], col="red", pch=16)
  
  lines(range,p_red[3]*dnorm(range,p_red[1],p_red[2]), col="red3", lty=2)
  lines(range,p_red[6]*dnorm(range,p_red[4],p_red[5]),col="red3", lty=2)
  lines(range, (p_red[3]*dnorm(range,p_red[1],p_red[2])) + (p_red[6]*dnorm(range,p_red[4],p_red[5])), col="red3")
  
  mtext(paste("Chromosome diameter green =", round(dist_green*1000), "nm"), line = 0.3)
  mtext(paste("Chromosome diameter red =", round(dist_red*1000), "nm"), line = 1.1)
  mtext(paste("Shift green to red =", round(shift*1000), "nm"), line = 1.9)

  
  dev.off(dev.cur())
  
  ###+++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ##save parameter table
  write.table(parameters, file=paste(outputdir,ID,"_Gauss_parameter.txt", sep=""), sep="\t", col.names=T, row.names=T)
  
}
