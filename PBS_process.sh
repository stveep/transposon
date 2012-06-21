#!/bin/bash
#PBS -N process
#PBS -l nodes=uv:ppn=8,mem=64gb
#PBS -q ngs
#PBS -m a
#PBS -M spettitt@icr.ac.uk
#PBS -o process_fastq.out
#PBS -e process_fastq.err
#PBS -j oe
#PBS -V

rake -f rakefile-icr process_fastq
wait



