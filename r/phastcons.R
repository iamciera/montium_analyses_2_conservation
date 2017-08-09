#!/usr/bin/env Rscript

## Phastcons Script
## This gets the conservation score of an alignment file
## Built for a particular alignment and particular set of species
## Not to be used with others
## Written By: Ciera Martinez

## Required Libraries
library(rphast)
library(Biostrings)
library(DECIPHER)
library(dplyr)
library(ape)
## library(ggplot2)

align <- read.msa("../data/fasta/kvon_alignments/output_VT0015.fa")
RefTree <- as.character(unlist(read.table('../data/RefTree.txt')))

align$names

# align$names <- c("MEMB002E", "MEMB003C", "MEMB003D", "MEMB002A", "MEMB002C", "MEMB002D", "MEMB002F", "MEMB003B", "MEMB003F")

# ?read.msa
RefTreePlot <- read.tree(text = RefTree)
plot(RefTreePlot, type = "phylogram")

#estimate treeeee
neutralMod <- phyloFit(align,tree=RefTree)

## Fitted Tree from nuetralMod
FitTree <- "((MEMB003D:0.00638976,(MEMB003F:0.0502536,(MEMB002D:0.054623,MEMB003B:0.0419702):0.00194355):0.115993):5.49069e-18,(MEMB002F:0.121095,(MEMB002A:0.0126087,(MEMB002E:0.159357,(MEMB002C:0.158617,MEMB003C:0.0142408):2.25824e-05):9.0819e-05):0.000423607):5.49069e-18);"
FitTreePlot <- read.tree(text = FitTree)
plot(FitTreePlot, type = "phylogram")


#sites for minimal es2 (~.47)
RHO <- .3 #I'm not sure about this value (relative evo rate). Check sensitivity
#results are quite robust to changes: .5--.32 cons,.3--.302,.1--.26
phast <- phastCons(align, neutralMod,rho=RHO)

cons_scores <- phast$post.prob.wig
plot(cons_scores) 
hist(cons_scores$post.prob) 

## ggplot(cons_scores, aes(coord, post.prob)) + 
  ## geom_line() +
  ## theme_bw()



