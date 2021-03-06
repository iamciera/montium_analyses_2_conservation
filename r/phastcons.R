#!/usr/bin/env Rscript
## phastcons.R
## Author: Ciera Martinez

## About
## This gets the conservation score of an alignment file
## Built for a particular alignment and particular set of species
## Not to be used with others.
## Important to note that how the alignment is sorted effectes where
## the conservation score is "mapped" to. All the files were sorted prior 
## so that the mapped conservation score is to MEMB200A.

## Input: 
## - alignment in fasta form  
## - tree with species in alignment

## Output:
## - probability scores per BP position in ref species
## - most conserved regions

## Required Libraries
library(rphast)
library(Biostrings)
library(DECIPHER)
library(dplyr)
library(ape)
## library(ggplot2)

## For Manual testing
## align <- read.msa("../data/fasta/kvon_alignments/output_VT0015.fa")

RefTree <- as.character(unlist(read.table('../data/RefTree.txt')))

path = "../data/fasta/kvon_alignments/sorted/"
file.names <- dir(path, pattern = ".fa")
length(file.names)

## remove output_VT10921.fa, which throws error for being too short.
file.names <- Filter(function(x) !any(grepl("output_VT10921.fa", x)), file.names)
file.names <- Filter(function(x) !any(grepl("output_VT51568.fa", x)), file.names)

file.names <- rev(file.names)

for (i in 1:length(file.names)) {
  align <- read.msa(paste0(path, file.names[54]))
  print(file.names[i])

## Remove junk in species identifiers (align$names)
alignNames <- align$names
alignNames_df  <- data.frame(do.call('rbind', strsplit(as.character(alignNames), split = "|", fixed = TRUE)))

## Replace align$Names
align$names <- as.character(alignNames_df$X6)

## Read Tree
RefTreePlot <- read.tree(text = RefTree)
plot(RefTreePlot, type = "phylogram")

## estimate treeeee
neutralMod <- phyloFit(align, tree = RefTree)

## Fitted Tree from nuetralMod
FitTree <- neutralMod$tree
FitTreePlot <- read.tree(text = FitTree)
plot(FitTreePlot, type = "phylogram")

RHO <- .3 ## I'm not sure about this value (relative evo rate). Check sensitivity
## results are quite robust to changes: .5--.32 cons,.3--.302,.1--.26
phast <- phastCons(align, neutralMod,rho = RHO)
most_conserved <- phast$most.conserved
cons_scores <- phast$post.prob.wig

getAnywhere(phastCons)

## Visualizing results
## plot(cons_scores) 
## hist(cons_scores$post.prob) 
## ggplot(cons_scores, aes(coord, post.prob)) + 
  ## geom_line() +
  ## theme_bw()

cons_scores$alignment <- file.names[i]
write.csv(cons_scores, paste0("../data/outputs/consScore2/", file.names[i], "_consScore.csv"))
  
if (nrow(most_conserved) > 0) {
    most_conserved$alignment <- file.names[i]
    write.csv(most_conserved, paste0("../data/outputs/mostConserved2/", file.names[i], "_mostConserved.csv"))
  } else {
    most_conserved <- as.data.frame("0") # Change this later
    write.csv(most_conserved, paste0("../data/outputs/mostConserved2/", file.names[i], "_mostConserved_none.csv"))  
  }
}

#### Test
## Write a test to see if MEMB002A is the first sequence
# for(i in 1:length(file.names)){
#     align <- read.msa(paste0(path, file.names[i]))
#     ## print(file.names[i])
# 
#     ## Remove Junk in Species identifiers (align$names)
#     alignNames <- align$names
#     alignNames_df  <- data.frame(do.call('rbind', strsplit(as.character(alignNames), split = "|", fixed = TRUE)))
#     n[i] <- alignNames_df[1,6] == "MEMB002A"
# }
# 
# summary(n) #no Falses, bitches.
```
 
