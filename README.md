# EviAnn -- evidence based eukaryotic genome annotation pipeline

EviAnn is a novel annotation pupeline.  EviAnn does not use any de novo gene finders in its processing.  it is purely evidence-based.  It used RNAseq data and/or transcripts and proteins from related species as inputs and produces annotation on GFF3 format.  

# Installation insructions

To install, first download the latest distribution from the github release page https://github.com/alekseyzimin/EviAnn_release/releases.Then untar/unzip the package EviAnn-X.X.X.tgz, cd to the resulting folder and run `./install.sh`.  The installation script will configure and make all necessary packages.  The EviAnn executables will appear under bin/

## Dependencies:

EviAnn requires the following dependencies to be installed and available on the $PATH:

1. minimap2: https://github.com/lh3/minimap2
2. HISAT2: https://github.com/DaehwanKimLab/hisat2
3. TransDecoder: https://github.com/TransDecoder/TransDecoder

## Only for developers

You can clone the development tree, but then there are dependencies such as swig and yaggo (http://www.swig.org/ and https://github.com/gmarcais/yaggo) that must be available on the PATH:

```
$ git clone https://github.com/alekseyzimin/EviAnn_release
$ cd EviAnn_release
$ git submodule init
$ git submodule update
$ cd ../ufasta && git checkout master
$ cd ..
```
after that you can run 'make' to compile the package.  The binaries will appear under build/inst/bin.  To create a distribution, run 'make install'.
Note that on some systems you may encounter a build error due to lack of xlocale.h file, because it was removed in glibc 2.26.  xlocale.h is used in Perl extension modules used by EviAnn.  To fix/work around this error, you can upgrade the Perl extensions, or create a symlink for xlocale.h to /etc/local.h or /usr/include/locale.h, e.g.:
```
ln -s /usr/include/locale.h /usr/include/xlocale.h
```

# Usage:
```
$ ./build/inst/bin/eviann.sh -h
Usage: eviann.sh [options]
Options:
-t <number of threads, default:1>
-g <MANDATORY:genome fasta file with full path>
-p <file containing list of filenames of paired Illumina reads from RNAseq experiments, one pair of /path/filename per line; fastq is expected by default, if files are fasta, add "fasta" as the third field on the line>
-u <file containing list of filenames of unpaired Illumina reads from RNAseq experiments, one /path/filename per line; fastq is expected by default, if files are fasta, add "fasta" as the third field on the line>
-e <fasta file with transcripts from related species>
-r <fasta file of protein sequences from related species>
-m <max intron size, default: 100000>
--debug <debug flag, if used intermediate output files will be kept>
-v <verbose flag>
-r AND one or more of the -p -u or -e must be supplied.
```


