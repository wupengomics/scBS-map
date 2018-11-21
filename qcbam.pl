#!/usr/bin/perl -w

# scBSmap - qcbam.pl
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

    Remove the low confidence alignments within microhomology regions

=head1 USAGE 

    qcbam [options] -f <in.bam> -o <out.bam>

    Options:
    -f    File name for alignment data, .bam format.
    -o    Output file name, bam format.
    -p    Number of threads. [default: 12].
    -s    Path to samtools eg. /home/user/bin/samtools
          - By default, we try to search samtools in system PATH.
    -n    Length of removing microhomology regions from bam files [default: 10].
    -h    Help message.

=head1 AUTHOR

    Contact:     Peng Wu; wupeng1@ihcams.ac.cn
    Last update: 2018-10-24

=cut

## Parsing arguments from command line
my ($inbam, $samtools, $out, $threads, $num, $help);

GetOptions(
    'f:s' => \$inbam,
    's:s' => \$samtools,
    'o:s' => \$out,
    'p:i' => \$threads,
    'n:i' => \$num,
    'h|help' => \$help
);

## Print usage  
pod2usage( { -verbose => 2, -output => \*STDERR } ) if ( $help );
( $inbam and $out ) or pod2usage();


## Set default 
$samtools ||= `which samtools`;
chomp $samtools;
$samtools or pod2usage();

$out ||= "output.bam";
$threads ||= 12;
$num ||= 10;


## Step4. qcbam
open IN_bam,"$samtools view $inbam -h|" or die $!;
open OUT_tmp, "> tmp.sam";
open LOW, "> local.lowquality.sam";
while(<IN_bam>){
    chomp;
    my @l=split/\t/;
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

`samtools view -S -@ $threads tmp.sam -o $out`;
`rm tmp.sam`;

