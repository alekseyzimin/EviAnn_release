# EviAnn -- evidence-based eukaryotic genome annotation software

EviAnn (Evidence Annotation) is a novel annotation software.  EviAnn does not use any de novo gene finders in its processing.  It is purely evidence-based.  EviAnn uses RNAseq data and/or transcripts, and proteins from related species as inputs.  EviAnn produces annotation of protein coding genes and transcripts, and outputs it in GFF3 format.  EviAnn does not require genome repeats to be soft-masked prior to running annotation.  EviAnn is stable and fast. Annotation of A.thaliana genome takes about 2 hours on a single 32-64 core server (not including time for aligning RNAseq reads, which could vary depending on the amount of data used.) 

# Installation insructions

To install, first download the latest distribution tarball EviAnn-X.X.X.tar.gz (not one of the Source files) from the github release page https://github.com/alekseyzimin/EviAnn_release/releases. Replace X's below with the version number. Then run:
```
$ tar xvzf EviAnn-X.X.X.tar.gz
$ cd EviAnn-X.X.X
$ ./install.sh
```
The installation script will configure and make all necessary packages.  The EviAnn executables will appear under bin/.  You can run EviAnn from anywhere by executing /path_to/EviAnn-X.X.X/bin/eviann.sh

## Dependencies:

EviAnn requires the following external dependencies to be installed and available on the $PATH:

1. minimap2: https://github.com/lh3/minimap2
2. HISAT2: https://github.com/DaehwanKimLab/hisat2

Here is the list of the dependencies included with the package:

1. stringtie version 2.2.1 -- static executable
2. gffread version 0.12.7 -- static executable
3. gffread version 0.12.6 -- static executable
4. blastp version 2.13.0+ -- static executable
5. tblastn version 2.13.0 -- static executable
6. makeblastdb version 2.13.0 -- static executable
7. exonerate version 2.4.0 -- static executable
8. TransDecoder version 5.7.1
9. samtools version 0.1.20
10. ufasta version 1

## Only for developers

You can clone the development tree, but then there are dependencies such as swig and yaggo (http://www.swig.org/ and https://github.com/gmarcais/yaggo) that must be available on the PATH:

```
$ git clone https://github.com/alekseyzimin/EviAnn_release
$ cd EviAnn_release
$ git submodule init
$ git submodule update
$ cd ../ufasta && git checkout master
$ cd ..
$ make
$ (cd build/inst/bin && tar xzf TransDecoder-v5.7.1.tar.gz)
```
To create a distribution, run 'make install'. Run 'make' to compile the package. The binaries will appear under build/inst/bin.  
Note that on some systems you may encounter a build error due to lack of xlocale.h file, because it was removed in glibc 2.26.  xlocale.h is used in Perl extension modules used by EviAnn.  To fix/work around this error, you can upgrade the Perl extensions, or create a symlink for xlocale.h to /etc/local.h or /usr/include/locale.h, e.g.:
```
ln -s /usr/include/locale.h /usr/include/xlocale.h
```

# Usage:
```
$ ./build/inst/bin/eviann.sh -h
Usage: eviann.sh [options]
Options:
-t <int: number of threads, default:1>
-g <string: MANDATORY:genome fasta file with full path>
-p <string: file containing list of filenames of paired Illumina reads from RNAseq experiments, one pair of /path/filename per line; fastq is expected by default, if files are fasta, add "fasta" as the third field on the line; if the reads are already aligned in bam format, put /path/filename.bam and add tag "bam" (without quotes) as second field on the line>
-u <string: file containing list of filenames of unpaired Illumina reads from RNAseq experiments, one /path/filename per line; fastq is expected by default, if files are fasta, add "fasta" as the third field on the line; if the reads are already aligned in bam format, put /path/filename.bam and add tag "bam" (without quotes) as second field on the line>
-e <string: fasta file with transcripts from related species>
-r <string: fasta file of protein sequences from related species>
-m <int: max intron size, default: 100000>
-l <flag: liftover mode, optimizes internal parameters for annotation liftover; also useful when supplying proteins from a single species, default: not set>
-f <flag: perform functional annotation, default: not set>
--debug <flag: debug, if used intermediate output files will be kept, default: not set>
-v <flag: verbose run, defalut: not set>
--version report version

-r AND one or more of the -p -u or -e must be supplied.
```

# Example use:

Suppose that you have two pairs of RNA-seq files rna1_R1.fastq, rna1_R2.fastq, rna2_R1.fastq, rna2_R2.fastq, and a set of proteins from several related species that you would like to use for annotation.  The proteins from all related species must be concatenated into a single fasta file:
```
cat protein1.faa protein2.faa > proteins.faa
```
Next you need to create a file that lists all RNA-seq data (e.g. paired.txt here). This file must contain the names of the reads files with absolute paths, two per line, forward and then reverse, for example:
```
$ cat paired.txt
/path/rna1_R1.fastq /path/rna1_R2.fastq
/path/rna2_R1.fastq /path/rna2_R2.fastq
```
This file can be easily created by the following command (assuming you are in the folder where the RNA-seq data is located):
```
paste <(ls $PWD/*_R1.fastq) <(ls $PWD/*_R2.fastq) > paired.txt
```
Adjust wildcards in the above example to the names of your read files. If some of all of your RNA-seq data are in fasta format, or aligned in the bam format you must indicate that by adding "fasta" or "bam" tag as the last field on the line, e.g.:
```
$ cat paired_mixed.txt
/path/rna1_R1.fastq /path/rna1_R2.fastq
/path/rna2_R1.fa /path/rna2_R2.fa fasta
/path/rna3.bam bam
```
it is important to specify all input files to EviAnn with absolute paths.  If you wish to run EviAnn with 24 threads, you can now run EviAnn as follows:
```
/path/EviAnn-X.X.X/bin/eviann.sh -t 24 -g /path/genome.fasta -p /path/paired.txt -r /path/proteins.faa
```
Substitute version number for the X's.
If EviAnn run stops for any reason (computer rebooted or out of disk space), just re-run the same command and EviAnn will pick up from the latest successfuly completed stage.  The name of the input genome file is used as prefix for the output files. Assuming the input genome sequence file is named genome.fasta, the final annotation files are named genome.fasta.functional_note.pseudo_label.gff, genome.fasta.functional_note.proteins.fasta and genome.fasta.functional_note.transcripts.fasta. These files contain annotation is gff format, sequences of proteins (amino-acids) and transcripts.
