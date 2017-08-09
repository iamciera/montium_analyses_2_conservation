#!/bin/bash

for file in ./subset_test/fasta_subset/*
	for file2 in ./subset_test/fm_subset/*
do
  python ../py/map_motif.py $file $file2
done