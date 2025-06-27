#!/bin/bash
fastq-dump --split-3 SRR31825048
paste <(ls $PWD/SRR31825048_1.fastq) <(ls $PWD/SRR31825048_2.fastq) > rnaseq.txt
