# EviAnn -- evidence-based eukaryotic genome annotation software

EviAnn (Evidence Annotation) is novel genome annotation software. It is purely evidence-based. EviAnn derives protein-coding gene and long non-coding RNA annotations from RNA-seq data and/or transcripts, and alignments of proteins from related species. EviAnn outputs annotations in GFF3 format. EviAnn does not require genome repeats to be soft-masked prior to running annotation. EviAnn is stable and fast. Annotation of a mouse (M.musculus)  genome takes less than one hour on a single 24 core Intel Xeon Gold server (assuming input of aligned RNA-seq reads in BAM format and ~346Mb of protein sequences from several related species including human). 

# Installation instructions

To install, first download the latest distribution tarball zgtools-EviAnn_2.0.2.tar.gz (not one of the Source code files!) from the github release page https://github.com/linyuiz/EviAnn_zgtools_version/releases/. 
```
$ wget https://github.com/linyuiz/EviAnn_zgtools_version/releases/download/v2.0.2/zgtools-EviAnn_2.0.2.tar.gz
$ tar -xvzf zgtools-EviAnn_2.0.2.tar.gz
$ cd zgtools-EviAnn_2.0.2
$ export LD_LIBRARY_PATH=/usr/lib64:/lib64
$ ./install.sh
#mamba install TransDecoder minimap2 hisat2 parallel #or conda install
```
The installation script will configure and make all necessary packages.  The EviAnn executables will appear under bin/.  You can run EviAnn from anywhere by executing /path_to/EviAnn-X.X.X/bin/eviann.sh

## Dependencies:

EviAnn requires the following external dependencies to be installed and available on the system $PATH:

1. minimap2: https://github.com/lh3/minimap2
2. HISAT2: https://github.com/DaehwanKimLab/hisat2

Here is the list of the dependencies included with the EviAnn package:

1. StringTie version 2.2.1 -- static executable
2. gffread version 0.12.7 -- static executable
3. gffread version 0.12.6 -- static executable
4. blastp version 2.8.1+ -- static executable
5. tblastn version 2.8.1+ -- static executable
6. makeblastdb version 2.8.1+ -- static executable
7. exonerate version 2.4.0 -- static executable
8. TransDecoder version 5.7.1 -- compiles on install
9. samtools version 1.15.1 -- compiles on install
10. ufasta version 1.0 -- compiles on install
11. miniprot v0.15-r270 -- compiles on install

# Prepare Data
You can prepare the data as I do: RNA data must end with .fq.gz or .fastq.gz, and protein files must end with .pep.fa. No GFF file is needed, only the protein file is required.
<div align="center"><img src="https://s2.loli.net/2025/05/17/PpWTgnz9wuBRviG.png" alt="Your Image Description" /></div>

# Usage:
```
Usage:

        zgtools EviAnn genome.fa Pep_dir/ RNAseq_dir/ 60 3

        genome.fa             --Genome File
	Pep_dir/              --Homo Pep Dir
        RNAseq_dir/           --RNAseq Dir
        60                    --Threads
        3                     --Parallel Task Num

Example1:

        zgtools EviAnn 00.used_data/genome.fa 00.used_data/00.homo_data/ 00.used_data/01.RNA_data/ 60 3
```

# Run log

<div align="center"><img src="https://s2.loli.net/2025/05/17/6xRF41vai3OtAqb.png" alt="Your Image Description" /></div>

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

