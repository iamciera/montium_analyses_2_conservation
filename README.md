## README

This directory is used for making indices that map conservation of TFBS across the montium species.

## Analysis 1

Testing using a small subset of non-coding regions and Bicoid. 

1. Get sequences 
    A. we can use the aligned sequences from `~/Dropbox/Research2/montium/analyses_1_alignment/pipeline_output_4/6a.output_alignment_onlyNine/`
2. concatenate all alignments into `allFastaAlignment.fa`
    A.  Make alignment dictionary to unaligned
    B.  Make sure the sequences are all the same length 
3. Make unaligned sequences for each species by removing all gaps. 
    A. Run pastr with BICOID on these sequences. Output should be a species specific vector for each position where Bicoid occurs. 
4. This species specific unaligned vector position is then converted to the aligned postion. 
5. Make new vector that is 0 for no TFBS and 1 if there is.
    - One question is if the position is really a range.
