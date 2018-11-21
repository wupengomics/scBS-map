#!/usr/bin/perl -w

# scBSmap - qcreads.pl
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

    Trim low quality sequences

=head1 USAGE 

    qcreads -l <INT> -f <.fastq> -o <.trim.fastq.gz>

    Options:
    -f    File name for sequencing reads, .fastq format.
          - a compressed file (.fastq.gz) is also supported
    -l    Length of trimming bases from the 5' end of the read [default: 10].
    -o    Output file name, .fastq.gz format.
    -h    Help message.

=head1 AUTHOR

    Contact:     Peng Wu; wupeng1@ihcams.ac.cn
    Last update: 2018-10-24

=cut

## Parsing arguments from command line
my ($reads, $length, $out, $help);

GetOptions(
    'f:s' => \$reads,
    'l:i' => \$length,
    'o:s' => \$out,
    'h|help' => \$help
);

## Print usage  
pod2usage( { -verbose => 2, -output => \*STDERR } ) if ( $help );
( $reads and $length and $out ) or pod2usage();


## Set default 
$out ||= "trim.fastq.gz";
$length ||= 10;


## Step1. qcreads
if($reads=~/gz/){
    open IN, "gzip -dc $reads |" or die $!;
}else{
    open IN, $reads or die $!;
}
$reads=~s/.gz//;
$reads=~s/.fastq//;
$reads=~s/.fq//;
open OUT, "| gzip -c > $out" or die $!;

while (<IN>){
    chomp (my $line0 = $_);
    chomp (my $line1 = <IN>);
    chomp (my $line2 = <IN>);
    chomp (my $line3 = <IN>);

    my $line1_new=substr($line1, $length-1, length($line1));
    my $line3_new=substr($line3, $length-1, length($line3));

    if(length($line1_new)>=35){
        print OUT "$line0\n$line1_new\n$line2\n$line3_new\n";
    }
}

close IN;
close OUT;
