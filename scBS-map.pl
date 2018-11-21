#!/usr/bin/perl -w

# scBSmap - scBSmap.pl
#
# Copyright (C) Peng Wu
# Contact: Peng Wu <wupeng1@ihcams.ac.cn>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

use strict;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
=pod

=head1 DESCRIPTION

    Single-cell Bisulfite Sequencing Data Mapping

=head1 USAGE 

    perl scBS-map.pl [options] -f <.fastq> -g <genome.fa> -o <out.bam>

    Options:
    -f    File name for sequencing reads, .fastq format.
          - a compressed file (.fastq.gz) is also supported
    -g    Genome file name, fasta format.
    -o    Output file name, bam format.
    -l    Length of trimming bases from the 5' end of the read [default: 10].
    -p    Number of threads. [default: 12].
    -s    Path to samtools eg. /home/user/bin/samtools
          - By default, we try to search samtools in system PATH.
    -a    Path to bs_seeker2-align eg. /home/user/bin/bs_seeker2-align.py
          - By default, we try to search bs_seeker2-ailgn in system PATH.
    -b    Path to bs_seeker2-build eg. /home/user/bin/bs_seeker2-build.py
          - By default, we try to search bs_seeker2-build in system PATH.
    -w    Logical to determine if the genome index needs to be built or not [default: FALSE].
    -n    Length of removing microhomology regions from bam files [default: 10].
    -k    Logical to determine whether to keep temporary files [default: FALSE].
    -h    Help message.

=head1 AUTHOR

    Contact:     Peng Wu; wupeng1@ihcams.ac.cn
    Last update: 2018-10-24

=cut

## Parsing arguments from command line
my ($reads, $length, $samtools, $bs_seeker2_align, $bs_seeker2_build, $buildornot, $genome, $out, $threads, $num, $keeptmp, $help);

GetOptions(
    'f:s' => \$reads,
    'l:i' => \$length,
    's:s' => \$samtools,
    'a:s' => \$bs_seeker2_align,
    'b:s' => \$bs_seeker2_build,
    'w:s' => \$buildornot,
    'g:s' => \$genome,
    'o:s' => \$out,
    'p:i' => \$threads,
    'n:i' => \$num,
    'k:s' => \$keeptmp,
    'h|help' => \$help
);

## Print usage  
pod2usage( { -verbose => 2, -output => \*STDERR } ) if ( $help );
( $reads and $genome and $out ) or pod2usage();


## Set default 
$samtools ||= `which samtools`;
chomp $samtools;
$samtools or pod2usage();

$bs_seeker2_align ||= `which bs_seeker2-align.py`;
chomp $bs_seeker2_align;
$bs_seeker2_align or pod2usage();

$bs_seeker2_build ||= `which bs_seeker2-build.py`;
chomp $bs_seeker2_build;
$bs_seeker2_build or pod2usage();


$out ||= "output.bam";
$buildornot ||= "FALSE";
$keeptmp ||= "FALSE";
$length ||= 10;
$threads ||= 12;
$num ||= 10;

## Step1. qcreads
my $datestring = localtime();
print "[$datestring] ------------------ scBS-map BEGIN -------------------\n";
print "[$datestring] Input file: $reads\n";
print "[$datestring] Start trimming the input reads...";
if($reads=~/gz/){
    open IN, "gzip -dc $reads |" or die $!;
}else{
    open IN, $reads or die $!;
}
$reads=~s/.gz//;
$reads=~s/.fastq//;
$reads=~s/.fq//;
open OUT, "| gzip -c > $reads.trim.fastq.gz" or die $!;

open REP, "> $reads.scBS-map.report";
print REP "--------------------------------------------------\n";
print REP "scBS-map report for $reads\n";
print REP "--------------------------------------------------\n";

my $readsnumber;
my $basesnumber;
my $readsnumber_qc;
my $basesnumber_qc;
while (<IN>){
    chomp (my $line0 = $_);
    chomp (my $line1 = <IN>);
    chomp (my $line2 = <IN>);
    chomp (my $line3 = <IN>);
    $readsnumber++;
    $basesnumber+=length($line1);
    my $line1_new=substr($line1, $length-1, length($line1));
    my $line3_new=substr($line3, $length-1, length($line3));

    if(length($line1_new)>=35){
        print OUT "$line0\n$line1_new\n$line2\n$line3_new\n";
        $readsnumber_qc++;
        $basesnumber_qc+=length($line1_new);
    }
}

close IN;
close OUT;

print REP "Number of reads: $readsnumber\n";
print REP "Number of bases: $basesnumber\n\n";
print REP "Number of reads after quality control: $readsnumber_qc\n";
print REP "Number of bases after quality control: $basesnumber_qc\n\n";

## Step2. align-end2end
$datestring = localtime();
print "Finish!\n[$datestring] Start mapping using the end-to-end mode...";
if($buildornot eq "TRUE"){
    `$bs_seeker2_build -f $genome --aligner=bowtie2`;
}

`$bs_seeker2_align -i $reads.trim.fastq.gz -g $genome -t Y -m 0.04 -o $reads.end2end.bam -M $reads.multihits.fq -u $reads.unaligned.fq --bt2-p $threads --bt2--end-to-end --aligner=bowtie2`;
`rm $reads.end2end.bam.bs_seeker2_log`;

my $end2end_basesnumber;
my $end2end_readsnumber;
open OUT_localbam,"$samtools view $reads.end2end.bam |" or die $!;
while(<OUT_localbam>){
    chomp;
    $end2end_readsnumber++;
    my @bamline=split/\t/;
    $end2end_basesnumber+=length($bamline[9]);
    if($bamline[5]=~/^(\d+)S/){
        $end2end_basesnumber-=$1;
    }
    if($bamline[5]=~/(\d+)S$/){
        $end2end_basesnumber-=$1;
    }
}

close OUT_localbam;

print REP "Number of mapped reads using the end-to-end mode: $end2end_readsnumber\n";
print REP "Number of mapped bases using the end-to-end mode: $end2end_basesnumber\n\n";

## Step3. align-local
$datestring = localtime();
print "Finish!\n[$datestring] Start mapping using the local mode...";
`$bs_seeker2_align -i $reads.unaligned.fq -g $genome -t Y -m 0.04 -o $reads.local.tmp.bam -M $reads.multihits.local.fq -u $reads.unaligned.local.fq --bt2-p $threads --aligner=bowtie2`;
`rm $reads.local.tmp.bam.bs_seeker2_log`;

`cat $reads.multihits.local.fq >>$reads.multihits.fq`;
`rm $reads.multihits.local.fq`;
`mv $reads.unaligned.local.fq $reads.unaligned.fq`;

## Step4. qcbam
$datestring = localtime();
print "Finish!\n[$datestring] Start removing the microhomology regions for local alignment...";
open IN_bam,"$samtools view $reads.local.tmp.bam -h|" or die $!;
open OUT_tmp, "> $reads.local.sam";
open LOW, "> $reads.local.lowquality.sam";
while(<IN_bam>){
    chomp;
    my @l = split/\t/;
    if(/^@/){
        print OUT_tmp "$_\n";
    }else{
	    if($l[5] !~ /S/){
	        print OUT_tmp "$_\n";
	    }elsif($l[5]=~/^(\d+)S(\d+)M$/){
	        my $len=$2-$num;
	        my $seq=substr($l[9],$1+$num,$len);
	        $l[9]=$seq;
	        $l[5]="$len"."M";
	        $l[3]+=$num;
	        my $ll=join ";",@l;
	        $ll=~s/;/\t/g;
	        print OUT_tmp "$ll\n";
	    }elsif($l[5]=~/^(\d+)M(\d+)S$/){
	        my $len=$1-$num;
	        my $seq=substr($l[9],0,$len);
	        $l[9]=$seq;
	        $l[5]="$len"."M";
	        my $ll=join ";",@l;
	        $ll=~s/;/\t/g;
	        print OUT_tmp "$ll\n";
	    }elsif($l[5]=~/^(\d+)S(\d+)M(\d+)S$/){
	        my $len=$2-$num-$num;
	        my $seq=substr($l[9],$1+$num,$len);
	        $l[9]=$seq;
	        $l[5]="$len"."M";
	        $l[3]+=$num;
	        my $ll=join ";",@l;
	        $ll=~s/;/\t/g;
	        print OUT_tmp "$ll\n";
	    }else{
	        print LOW "$_\n";
	    }
	}
}

close IN_bam;
close LOW;
close OUT_tmp;

`$samtools view -S -@ $threads $reads.local.sam -o $reads.local.bam`;
if($keeptmp eq "FALSE"){
    `rm $reads.local.sam`;
    `rm $reads.local.tmp.bam`;
    `rm $reads.local.lowquality.sam`;
}


my $local_basesnumber;
my $local_readsnumber;
open OUT_localbam,"$samtools view $reads.local.bam |" or die $!;
while(<OUT_localbam>){
    chomp;
    $local_readsnumber++;
    my @bamline=split/\t/;
    $local_basesnumber+=length($bamline[9]);
    if($bamline[5]=~/^(\d+)S/){
        $local_basesnumber-=$1;
    }
    if($bamline[5]=~/(\d+)S$/){
        $local_basesnumber-=$1;
    }
}

close OUT_localbam;

print REP "Number of mapped reads using the local mode: $local_readsnumber\n";
print REP "Number of mapped bases using the local mode: $local_basesnumber\n\n";

## Step5. mergebam
$datestring = localtime();
print "Finish!\n[$datestring] Start merging the end-to-end and local alignments...";
`$samtools merge -@ $threads -f $out $reads.end2end.bam $reads.local.bam`;

my $mapped_basesnumber;
my $mapped_readsnumber;
open OUT_bam,"$samtools view $out |" or die $!;
while(<OUT_bam>){
    chomp;
    $mapped_readsnumber++;
    my @bamline=split/\t/;
    $mapped_basesnumber+=length($bamline[9]);
    if($bamline[5]=~/^(\d+)S/){
        $mapped_basesnumber-=$1;
    }
    if($bamline[5]=~/(\d+)S$/){
        $mapped_basesnumber-=$1;
    }
}

close OUT_bam;

my $multinumber=`grep '^>' $reads.multihits.fq -c`;
my $unmappednumber=$readsnumber_qc-$multinumber-$mapped_readsnumber;
print REP "Number of unmapped reads: $unmappednumber\n";
print REP "Number of multi-hits reads: $multinumber\n";
print REP "Number of mapped reads in total: $mapped_readsnumber\n";
my $mapratio=sprintf "%.4f", $mapped_readsnumber/$readsnumber;
print REP "Mappability in total: ",$mapratio*100,"%\n\n";
print REP "Number of mapped bases in total: $mapped_basesnumber\n";
my $mapratio_base=sprintf "%.4f", $mapped_basesnumber/$basesnumber;
print REP "Mappability at base level in total: ",$mapratio_base*100,"%\n";
print REP "--------------------------------------------------\n";

close REP;

$datestring = localtime();
print "Finish!\n[$datestring] Output alignment file: $out\n";
print "[$datestring] ------------------- scBS-map END --------------------\n";
