#!/bin/bash

for file in ../data/fasta/kvon_alignments/sorted/*
do
  python map_motif.py $file ../data/PWM/fm/gt_nar2008.fm
done