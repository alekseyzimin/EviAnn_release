# EviAnn -- evidence-based eukaryotic genome annotation software

EviAnn (Evidence Annotation) is novel genome annotation software. It is purely evidence-based. EviAnn derives protein-coding gene and long non-coding RNA annotations from RNA-seq data and/or transcripts, and alignments of proteins from related species. EviAnn outputs annotations in GFF3 format. EviAnn does not require genome repeats to be soft-masked prior to running annotation. EviAnn is stable and fast. Annotation of a mouse (M.musculus)  genome takes less than one hour on a single 24 core Intel Xeon Gold server (assuming input of aligned RNA-seq reads in BAM format and ~346Mb of protein sequences from several related species including human). 

EviAnn manuscript is under review. The preprint is available here: https://www.biorxiv.org/content/10.1101/2025.05.07.652745v1

Benefits of using EviAnn:

1. EviAnn's output is fully compliant with NCBI annotation specifications, annotations can be easily submitted to NCBI GenBank using table2asn tool (see below)
2. Easy to install and run, few easy to install dependncies
3. Eviann is very fast -- annotation of a mammalian genome takes less than an hour, after all RNA-seq data has been aligned
4. 5' and 3' UTRs are present in most protein-coding transcripts
5. Annotates long non-coding RNA's
6. Processed pseudo-genes are automatically labelled and CDSs for them are not reported
7. Optional automatic functional annotation with UniProt-SwillProt database (-f switch)
8. Support for long and short transcriptome sequencing reads and mixed data sets
9. Support for genomes up to 32Gbp in size
10. If one or more close relatives are annotated, annotation is possible with transcripts and proteins from the related genomes, without any RNA-seq data.  Genomes must be on average >95% similar on the DNA level.
11. Supports annotation of mitochondria

Development of EviAnn is supported in part by NSF grant IOS-2432298, and by NIH grants R01-HG006677 and R35-GM130151.

# Installation instructions

## Bioconda
EviAnn is now available through Bioconda.  To install EviAnn we recommend to first create new environment called eviann:

conda create -n eviann

then install:

conda install eviann

Now you can use EviAnn (run eviann.sh).  To switch in and out of the EviAnn environment, use "conda activate eviann" or "conda deactivate".

## GitHub
To install from GitHub, first download the latest distribution tarball EviAnn-X.X.X.tar.gz (not one of the Source code files!) from the github release page https://github.com/alekseyzimin/EviAnn_release/releases. Replace X's below with the version number. Then run:
```
$ tar xvzf EviAnn-X.X.X.tar.gz
$ cd EviAnn-X.X.X
$ ./install.sh
```
The installation script will configure and make all necessary packages.  The EviAnn executables will appear under bin/.  You can run EviAnn from anywhere by executing /path_to/EviAnn-X.X.X/bin/eviann.sh


## Dependencies:
If you choose to install directly from GitHub package, EviAnn requires the following external dependencies to be installed and available on the system $PATH:

1. minimap2: https://github.com/lh3/minimap2
2. HISAT2: https://github.com/DaehwanKimLab/hisat2

Here is the list of the dependencies included with the EviAnn package:

1. StringTie version 3.0.0 -- static executable
2. gffread version 0.12.7 -- static executable
3. gffread version 0.12.6 -- static executable
4. makeblastdb and blastp version 2.8.1+ -- executables provided by NCBI, if you get a warning on install that these executables are not compatible, try getting an earlier version from https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/
5. TransDecoder version 5.7.1 -- modified to remove dependency on URI::Escape
6. samtools version 1.15.1 -- static executable
7. ufasta version 1.0 -- compiles on install
8. miniprot v0.15-r270 -- compiles on install

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
$ (cd build/inst/bin && tar -xzf TransDecoder-v5.7.1.tar.gz)
$ (cd build/inst/bin && tar -xzf miniprot.tgz && cd miniprot_source && make && mv miniprot ../ && cd .. && rm -rf  miniprot_source miniprot.tgz)
```
To create a distribution, run 'make install'. Run 'make' to compile the package. The binaries will appear under build/inst/bin.  The name of the distribution package is specified at the top of the Makefile.
Note that on some systems you may encounter a build error due to lack of xlocale.h file, because it was removed in glibc 2.26.  xlocale.h is used in Perl extension modules used by EviAnn.  To work around this error, you can upgrade the Perl extensions, or create a symlink for xlocale.h to /etc/local.h or /usr/include/locale.h, e.g.:
```
ln -s /usr/include/locale.h /usr/include/xlocale.h
```

# Usage:
```
Usage: eviann.sh [options]
Options:
 -t INT           number of threads, default: 1
 -g FILE          MANDATORY:genome fasta file default: none
 -r FILE          file containing list of filenames of reads from transcriptome sequencing experiments, default: none
 
  FORMAT OF THIS FILE:
  Each line in the file must refer to sequencing data from a single experiment.
  Please combine runs so that one file/pair/triplet of files contains a single sample.  
  The lines are in the following format:
 
 /path/filename /path/filename /path/filename tag
  or
 /path/filename /path/filename tag
  or
 /path/filename tag

  Fields are space-separated, no leading space. "tag" indicates type of data referred to in the preceding fields.  Possible values are:
 
  fastq -- indicates the data is Illumina RNA-seq in fastq format, expects one or a pair of /path/filename.fastq before the tag
  fasta -- indicates the data is Illumina RNA-seq in fasta format, expects one or a pair of /path/filename.fasta before the tag
  bam -- indicates the data is aligned Illumina RNA-seq reads, expects one /path/filename.bam before the tag
  bam_isoseq -- indicates the data is aligned PacBio Iso-seq reads, expects one /path/filename.bam before the tag
  isoseq -- indicates the data is PacBio Iso-seq reads in fasta or fastq format, expects one /path/filename.(fasta or fastq) before the tag
  mix -- indicates the data is from the sample sequenced with both Illumina RNA-seq provided in fastq format and long reads (Iso-seq or Oxford Nanopore) in fasta/fastq format, expects three /path/filename before the tag
  bam_mix -- indicates the data is from the same sample sequenced with both Illumina RNA-seq provided in bam format and long reads (Iso-seq or Oxford Nanopore) in bam format, expects two /path/filename.bam before the tag
 
  Absense of a tag assumes fastq tag and expects one or a pair of /path/filename.fastq on the line.
 
 -e FILE               fasta file with assembled transcripts from related species to be used in the annotation, default: none
 -p FILE               fasta file with protein sequences from several (ideally 10+) related species, uniprot proteins are used of this file is not provided, default: none
 -s FILE               fasta file with UniProt-SwissProt proteins to use in functional annotation or if proteins from close relatives are not available. 
                         EviAnn will download the most recent version of this database automatically.
                         To use a different version, supply it with this switch. The database is available at:
                         https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
 -m INT                max intron size, default: auto-determined as sqrt(genome size in kb)*1000
 --partial             include transcripts with partial (mising start or stop codon) CDS in the output
 -d INT                set ploidy for the genome, this value is used in estimating the maximum intron size, default 2
 -c FILE               GFF file with CDS sequences for THIS genome to be used in annotations. Each CDS must have gene/transcript/mRNA AND exon AND CDS attributes
 --lncrnamintpm FLOAT  minimum TPM to include non-coding transcript into the annotation as lncRNA, default: 1.0
 -f|--functional       perform functional annotation, default: not set
 --mito_contigs FILE   file with the list of input contigs to be treated as mitochondrial with different genetic code (stop is AGA,AGG,TAA,TAG)
 --extra FILE          extra features to add from an external GFF file.  Feautures MUST have gene records.  Any features that overlap with existing annotations will be ignored
 --debug               keep more intermediate output files, default: not set
 --verbose             verbose run, default: not set
 --version             report version and exit.
 --help                display this message and exit.

 IMPORTANT!!! -r or -e MUST be supplied.
```
EviAnn saves progress from all intermediate steps.  If EviAnn run stops for any reason (computer rebooted or out of disk space), just re-run the same command and EviAnn will continue from the last successfuly completed stage.  

EviAnn uses the input genome file name as \<PREFIX\> for intermediate/output files.  If the input genome file is genome.fasta, then the \<PREFIX\> is "genome.fasta", and final annotation files are named genome.fasta.pseudo_label.gff, genome.fasta.proteins.fasta and genome.fasta.transcripts.fasta. These files contain annotation is GFF3 format, sequences of proteins (amino-acids) and transcripts.  

# Interpreting the output

EviAnn outputs the annotation in GFF3 format, along with translated protein sequences and transcripts in FASTA format. Per GFF3 convention, stop codon is included into the CDS. Every "mRNA" line for a protein coding transcript contains the following attributes:

1. ID -- this is the transcript ID assigned by EviAnn
2. Parent -- this is the ID of the parent feature
3. EvidenceProteinID -- this is the ID of the protein that was used as evidence for the CDS annotation for this transcript. The protein ID is followed by its functional description, if available. If the EvidenceProteinID starts with XLOC... then the transcript was annotated from the transcript alignment alone, please refer to the EvidenceTranscriptID for the evidence
4. EvidenceTranscriptID -- this is the ID of the transcript that was used as evidence for the annotation for this transcript. All transcripts assembled from the evidence are listed in \<PREFIX\>.gtf.  The EvidenceTrasncriptID can be a source protein ID if Evidence is "protein_only".  For "complete" and "transcript_only" evidence, the format of the EvidenceTranscriptID is \<transcript_name\>:\<number of RNA-seq experiments containing the transcript\>:\<maximum TPM\>
5. StartCodon -- this is the start codon in the CDS
6. StopCodon -- this is the stop codon in the CDS
7. Class -- this is the match class of the source protein alignment to the transcript;  most reliable transcripts have class code "=" or "k"
8. Evidence -- this is the type of evidence that was used to annotate the transcript/CDS.  Possible values are: "complete", meaning that both transcript and protein alignment data was used, "protein_only", meaning that the only protein alignment data was used and "transcript_only" meaning that only transcript data was used.  For "transcript_only" evidence the CDS was derived with TransDecoder with subsequent confirmation by alignment to Uniprot database
9. Optional: pseudo=true -- this tag is present if EviAnn designated the gene/transcript as processed pseudo gene.  No CDS is output for these transcripts.

For long non-coding RNAs the "mRNA" line contains the following attributes:
1. ID -- this is the transcript ID assigned by EviAnn
2. Parent -- this is the ID of the parent feature
3. EvidenceTranscriptID -- this is the ID of the transcript that was used as evidence for the annotation for this transcript. All transcripts assembled from the evidence are listed in \<PREFIX\>.gtf. 

Here is an example of annotation of a protein coding gene, a pseudo-gene and a long non-coding RNA, with functional annotation:

```
NC_004353.4     EviAnn  gene    29462   43759   .       -       .       ID=XLOC_000048;geneID=XLOC_000048;type=protein_coding;Note=Similar to PLXNA2: Plexin-A2 (Homo sapiens);
NC_004353.4     EviAnn  mRNA    32745   43754   .       -       .       ID=XLOC_000048-mRNA-1;Parent=XLOC_000048;EvidenceProteinID=XP_001352289.2;EvidenceTranscriptID=MSTRG_00000148:4:7.702416;StartCodon=atg;StopCodon=TGA;Class==;Evidence=complete;Note=Similar to PLXNA2: Plexin-A2 (Homo sapiens);
NC_004353.4     EviAnn  exon    32745   33125   .       -       .       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  exon    33191   33373   .       -       .       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  exon    35874   36457   .       -       .       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  exon    36516   41285   .       -       .       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  exon    42914   43754   .       -       .       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  CDS     33018   33125   .       -       0       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  CDS     33191   33373   .       -       0       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  CDS     35874   36457   .       -       2       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  CDS     36516   41285   .       -       2       Parent=XLOC_000048-mRNA-1
NC_004353.4     EviAnn  CDS     42914   43424   .       -       0       Parent=XLOC_000048-mRNA-1

NC_004354.4     EviAnn  gene    23461776        23464767        .       -       .       ID=XLOC_001890;geneID=XLOC_001890;type=protein_coding;pseudo=true;Note=function unknown;
NC_004354.4     EviAnn  mRNA    23461776        23464767        .       -       .       ID=XLOC_001890-mRNA-1;Parent=XLOC_001890;EvidenceProteinID=XP_046868993.1;EvidenceTranscriptID=MSTRG_00006719:2:3.697180;StartCodon=atg;StopCodon=TAA;Class=k;Evidence=complete;pseudo=true;Note=function unknown;
NC_004354.4     EviAnn  exon    23461776        23464767        .       -       .       Parent=XLOC_001890-mRNA-1

NC_004353.4     EviAnn  gene    181423  182801  .       -       .       ID=XLOC_000055U_lncRNA;geneID=XLOC_000055U_lncRNA;type=lncRNA;junction_score=0;Note=function unknown;
NC_004353.4     EviAnn  ncRNA   181423  182801  .       -       .       ID=XLOC_000055U_lncRNA-mRNA-1;Parent=XLOC_000055U_lncRNA;EvidenceTranscriptID=MSTRG_00000163:5:11.129138
NC_004353.4     EviAnn  exon    181423  181516  .       -       .       Parent=XLOC_000055U_lncRNA-mRNA-1
NC_004353.4     EviAnn  exon    181569  182801  .       -       .       Parent=XLOC_000055U_lncRNA-mRNA-1
```


# Submission of EviAnn annotation to NCBI GenBank with table2asn tool

EviAnn produces annotations in a proper GFF3 format for ease of submission to NCBI Genbank.  Here are the steps to take to produce NCBI compliant submission input files from EviAnn output:

1. Fill out the form here to produce template.sbt file: https://submit.ncbi.nlm.nih.gov/genbank/template/submission/
2. Download and install table2asn tool from NCBI: https://www.ncbi.nlm.nih.gov/genbank/table2asn/
3. run this command in the EviAnn output folder:
```
table2asn -M n -J -c w -euk -t template.sbt -gaps-min 10 -l paired-ends -j "[organism=latin name][isolate=isolate]" -i assembly.fasta -f assembly.fasta.pseudo_label.gff -o output.sqn -Z -V b -locus-tag-prefix XXXX
```
This command assumes that the genome assembly fasta file is in the current folder and named "assembly.fasta", and thus the annotation file output by EviAnn is named "assembly.fasta.pseudo_label.gff". You can change the assembly name or path if it differs. XXXX is a four-letter locus tag prefix assigned by GenBank during assembly submission.  This command produces output.sqn and output.gbf files that can be used to submit the annotation to GenBank.

# Example use:

## Case 1. Annotation with RNA-seq data and proteins from related species

Suppose that you are annotating genome sequence in genome.fasta.  You have two pairs of RNA-seq files rna1_R1.fastq, rna1_R2.fastq, rna2_R1.fastq, rna2_R2.fastq, and protein sequences from several related species that you would like to use for annotation.  The proteins from all related species must be in fasta format.  Ideally you want about 5-10 times as many proteins from relates species as you expect to be present in the species you are annotating.  For example, about 100000 - 200000 proteins for an insect, or about 500000 proteins for a typical plant genome or a typical mammalian genome. The individual files containing protein sequences must be concatenated into a single fasta file:
```
cat protein1.faa protein2.faa > proteins_all.faa
```
Next you need to create a file that lists all RNA-seq data (e.g. paired.txt here). This file must contain the names of the reads files with absolute or relative (v1.0.8 and up) paths, two per line, forward and then reverse, for example:
```
$ cat paired.txt
/path/rna1_R1.fastq /path/rna1_R2.fastq
/path/rna2_R1.fastq /path/rna2_R2.fastq
```
This file can be easily created by the following command (assuming you are in the folder where the RNA-seq data is located):
```
paste <(ls $PWD/*_R1.fastq) <(ls $PWD/*_R2.fastq) > paired.txt
```
Adjust wildcards in the above example to the names of your read files. If some of all of your RNA-seq data are in fasta format, or aligned in the bam format, you can use the fasta/BAM files and indicate that by adding "fasta" or "bam" tag as the last field on the line, e.g.:
```
$ cat paired_mixed.txt
/path/rna1_R1.fastq /path/rna1_R2.fastq /path/IsoSeq_rna.fastq
/path/rna1_R1.fastq /path/rna1_R2.fastq
/path/rna2_R1.fa /path/rna2_R2.fa fasta
/path/rna3.bam bam
```
it is important to specify all input files to EviAnn with absolute paths if you are using a version earlier than 1.0.8.  If you wish to run EviAnn with 24 threads, you can now run EviAnn as follows:
```
/path/EviAnn-X.X.X/bin/eviann.sh -t 24 -g /path/genome.fasta -r /path/paired.txt -p /path/proteins_all.faa
```
Substitute EviAnn version number for the X's.

## Case 2. No RNA-seq data, annotation with transcripts and proteins from one or more related species

Suppose again that you are annotating genome sequence in genome.fasta.   In this scenario we assume that you have gff files containing the annotations of the related species that you are going to use as evidence. This scenario can also be descibed as "lifting over" annotation from one or more related species. The genome sequences for these species are also needed. The first step is to create transcripts and proteins files for each species with the following command:
```
/eviann_path/bin/gffread -W -y species1_prot.faa -w species1_transc.fa -g species1_genome.fa species1.gff
/eviann_path/bin/gffread -W -y species2_prot.faa -w species2_transc.fa -g species2_genome.fa species2.gff
etc...
```
The next step is to concatenate all proteins files and all transcript files into a single file:
```
cat species*_transc.fa > transcripts.fa
cat species*_prot.fa > proteins.faa
```
Then you can run EviAnn with 24 threads (for example) as follows:
```
/path/EviAnn-X.X.X/bin/eviann.sh -t 24 -g /path/genome.fasta -e $PWD/transcripts.fa -p $PWD/proteins.faa -l
```
Make sure that you use -l switch!  This will optimize internal parameters for liftover run. Substitute EviAnn version number for the X's.

# Downloading protein evidence from NCBI

## 1. Here are the steps you can follow to create and download protein evidence file from NCBI.  Go to https://www.ncbi.nlm.nih.gov/taxonomy:

![NCBI1](https://github.com/alekseyzimin/EviAnn_release/assets/27226909/bcfa658b-e998-4087-a046-adab51da86c8)

## 2. Enter the organism name into the search field and click "Search".

![NCBI2](https://github.com/alekseyzimin/EviAnn_release/assets/27226909/0912ef8c-bd01-49cb-acbe-16f5b4cd7fff)

## 3. NCBI will find the lineage and species name.  First try using the rightmost link in the lineage list (Malus).  If the subsequent steps result in fewer than 400,000 protein hits, you can move up to the next available lineage level on the left (in this case Maleae).

![NCBI3](https://github.com/user-attachments/assets/1a3ff0ec-e818-4cc4-9637-dd1b44f7a990)

## 4. Click on the lineage name in bold.

![NCBI4](https://github.com/alekseyzimin/EviAnn_release/assets/27226909/dce4b7a6-68da-4602-ab49-14fb0a29116b)

## 5. Look for the red "Protein" word in the table on the upper right. If the number to the right of the link is > 400,000, click on the number, otherwise go back to step 3 and choose lineage that is higher up in the tree.  For best results I recommend usng proteins from at least ten related species with a total number of input proteins exceeding the expected number of proteins for the species about 10-fold.

![NCBI5](https://github.com/user-attachments/assets/cad4a2e4-b64f-4e30-b595-f46e7baf26aa)

## 6. Click "Send to", choose "File" format "FASTA", and click "Create File" button.  Save the file as "proteins.faa".  You can use this file as input proteins to EviAnn ( -r proteins.faa ).

![NCBI6](https://github.com/alekseyzimin/EviAnn_release/assets/27226909/6be1aa9e-8634-428f-afd4-a5502dd6d412)
