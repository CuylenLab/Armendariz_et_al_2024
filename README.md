# Armendariz_et_al_2024

## What this repository contains

Fiji and R codes used and described in detail in the following manuscript:

"A liquid-like coat mediates chromosome clustering during mitotic exit". <br />
A biorxiv version of the manuscript is available at https://doi.org/10.1101/2023.11.23.568026 

## Short description of Fiji scripts 

#### Generation of single slices:
Fiji code for extracting the center z-slice from a z-stack. The center z-slice was defined as the slice with the highest mean intensity in the chromatin channel. Used in Figures 6A, 6B, S1G–S1L, S5A–S5D, and S7C–S7F.

#### Manual tracking:
Fiji code for defining and measuring mean-intensity of a region of interest over time. Used in Figures 1G, 1H, S1G, S1H, S1M, and S1N.

#### Molecular extension: 
Fiji code to draw line profiles in single z-slices with two channels. Used in Figures 5G, 5H, and S2J.

#### Quantification of cytoplasmic condensates: 
Fiji code for segmenting and quantifying cytoplasmic condensates, while excluding chromatin-associated signal.  Used in Figures 1A, 1F, 2F, 2G, 3B, 3D, 4C, 4D, 5B, 5C, 6C, 6E, 6F, 6H, S1A, S1C, S1G, S1I, S3, S4A, S4C, S4D, S4H, S6A, and S6C.

#### Quantification of GEMs:
Fiji for defining a convex hull around chromosomes and quantifying its mean intensity in both channels. Used in Figures S7C–S7F.

## Short description of R scripts 
#### 1D Heatmap Charge:
R script to plot the charge distribution along an amino acid sequence as a 1D heatmap. Used in Figures 3A and 4B.

#### 2D Heatmap condensates:
R script to plot the number of condensates or total condensate area as a function of initial cytoplasmic concentration and time as a 2D heatmap. Used in Figure S3.

#### Concatenate molecular extension:
R script to concatenate line profile data into a single dataset. Used in Figures 5G, 5H, and S2J.

#### Molecular extension:
R script to calculate molecular extension and mean intensities from line profiles. Used in Figures 5G, 5H, and S2J.

#### Net charge calculation from FASTA:
R script to calculate the net charge and isoelectric point of a protein sequence. Used in Figure 7A.



## Reference


## Contact
https://www.embl.org/groups/cuylen/
