#!/bin/bash

for file in ../data/fasta/kvon_alignments/*
do
  python map_motif.py $file ../data/PWM/fm/todo/kr_FlyReg.fm
done