#!/usr/bin/env python
#raw_to_alignment_key.py
#Ciera Martinez

import re
import pandas as pd
import numpy as np
import os, sys
from Bio import motifs
from Bio import SeqIO 
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet import IUPAC, generic_dna, generic_protein
from collections import defaultdict

#####################
## sys Inputs - to do
#####################

## read in alignment 
alignment = list(SeqIO.parse(sys.argv[1], "fasta"))

## Used later when marking output file
alignment_file_name =  os.path.basename(sys.argv[1])
print alignment_file_name

## Manual For testing
## alignment = list(SeqIO.parse("../data/fasta/output_ludwig_eve-striped-2.fa", "fasta"))

raw_sequences = []
for record in alignment:
    raw_sequences.append(SeqRecord(record.seq.ungap("-"), id = record.id))

## make raw sequences all IUPAC.IUPACUnambiguousDNA()
raw_sequences_2 = []
for seq in raw_sequences:
    raw_sequences_2.append(Seq(str(seq.seq), IUPAC.IUPACUnambiguousDNA()))

###################################
## Searching for motif in all raw_sequences
#################################

raw_id = []
for seq in raw_sequences:
    raw_id.append(seq.id)
    
record_length = []
for record in raw_sequences_2:
    record_length.append(len(record))

##################
## get alignment position 
#################

remap_list = []
nuc_list = ['A', 'a', 'G', 'g', 'C', 'c', 'T', 't', 'N', 'n']

for i in range(0,9):
    counter = 0
    for xInd, x in enumerate(alignment[i].seq):    
        if x in nuc_list:
            remaps = {'raw_position': counter, 'align_position':xInd, 'species':alignment[i].id}
            counter += 1
            remap_list.append(remaps)
            
remap_DF = pd.DataFrame(remap_list)


## Attach File Name
remap_DF['alignment_file'] = alignment_file_name

## Write out Files
remap_DF.to_csv('../data/outputs/alignment_keys/raw_to_alignment_key_output' + alignment_file_name + ".csv", sep='\t', na_rep="NA")
