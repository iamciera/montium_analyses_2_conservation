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

## args = commandArgs(trailingOnly = TRUE)

## Manual
## align <- read.msa("../data/fasta/kvon_alignments/output_VT0015.fa")

RefTree <- as.character(unlist(read.table('../data/RefTree.txt')))

path = "../data/fasta/kvon_alignments/"
file.names <- dir(path, pattern =".fa")

for(i in 1:length(file.names)){
  align <- read.msa(paste0(path, file.names[i]))

## Remove Junk in Species identifiers (align$names)
  alignNames <- align$names
  alignNames_df  <- data.frame(do.call('rbind', strsplit(as.character(alignNames), split = "|", fixed = TRUE)))

## Replace align$Names
  align$names <- as.character(alignNames_df$X6)

## Read Tree
  RefTreePlot <- read.tree(text = RefTree)
  plot(RefTreePlot, type = "phylogram")

## estimate treeeee
  neutralMod <- phyloFit(align, tree=RefTree)


## Fitted Tree from nuetralMod
  FitTree <- neutralMod$tree
  FitTreePlot <- read.tree(text = FitTree)
## plot(FitTreePlot, type = "phylogram")


#sites for minimal es2 (~.47)
  RHO <- .3 #I'm not sure about this value (relative evo rate). Check sensitivity
#results are quite robust to changes: .5--.32 cons,.3--.302,.1--.26
  phast <- phastCons(align, neutralMod,rho=RHO)

  cons_scores <- phast$post.prob.wig
## plot(cons_scores) 
## hist(cons_scores$post.prob) 

## ggplot(cons_scores, aes(coord, post.prob)) + 
  ## geom_line() +
  ## theme_bw()

  cons_scores$alignment <- file.names[i]

  write.csv(cons_scores, paste0("../data/outputs/consScore/", file.names[i], "_consScore.csv"))
}

