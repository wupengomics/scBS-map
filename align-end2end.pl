#!/usr/bin/perl -w

# scBSmap - align-end2end.pl
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

    Perform end-to-end alignment on clean reads.

=head1 USAGE 

    align-end2end [options] -f <.fastq> -g <genome.fa> -o <out.bam> -u <unmapped.fastq>

    Options:
    -f    File name for sequencing reads, .fastq format.
          - a compressed file (.fastq.gz) is also supported
    -g    Genome file name, fasta format.
    -o    Output file name, bam format.
    -u    File name for unmapped reads if needed.
    -s    Path to samtools eg. /home/user/bin/samtools
          - By default, we try to search samtools in system PATH.
    -a    Path to bs_seeker2-align eg. /home/user/bin/bs_seeker2-align.py
          - By default, we try to search bs_seeker2-ailgn in system PATH.
    -b    Path to bs_seeker2-build eg. /home/user/bin/bs_seeker2-build.py
          - By default, we try to search bs_seeker2-build in system PATH.
    -w    Logical to determine if the genome index needs to be built or not [default: FALSE].
    -h    Help message.

=head1 AUTHOR

    Contact:     Peng Wu; wupeng1@ihcams.ac.cn
    Last update: 2018-10-24

=cut

## Parsing arguments from command line
my ($reads, $bs_seeker2_align, $bs_seeker2_build, $buildornot, $genome, $out, $threads, $unmappedout, $help);

GetOptions(
    'f:s' => \$reads,
    'a:s' => \$bs_seeker2_align,
    'b:s' => \$bs_seeker2_build,
    'w:s' => \$buildornot,
    'g:s' => \$genome,
    'o:s' => \$out,
    'p:i' => \$threads,
    'u:s' => \$unmappedout,
    'h|help' => \$help
);

## Print usage  
pod2usage( { -verbose => 2, -output => \*STDERR } ) if ( $help );
( $reads and $genome and $out ) or pod2usage();


## Set default 
$bs_seeker2_align ||= `which bs_seeker2-align.py`;
chomp $bs_seeker2_align;
$bs_seeker2_align or pod2usage();

$bs_seeker2_build ||= `which bs_seeker2-build.py`;
chomp $bs_seeker2_build;
$bs_seeker2_build or pod2usage();

$out ||= "output.end2end.bam";
$buildornot ||= "FALSE";
$unmappedout ||= "unmapped.fastq";
$threads ||= 12;


## Step2. align-end2end
if($buildornot eq "TRUE"){
    `$bs_seeker2_build -f $genome --aligner=bowtie2`;
}

`$bs_seeker2_align -i $reads -g $genome -t Y -m 0.04 -o $out -u $unmappedout --bt2-p $threads --bt2--end-to-end --aligner=bowtie2`;

