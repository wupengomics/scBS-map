# scBS-map


- **Description**: Single-cell Bisulfite Sequencing Data Mapping

- **Version**: 1.0.0

- **Usage**: `scBS-map [options] [-f <.fastq>] [-g <genome.fa>] [-o <out.bam>]`

    ```
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
    -f    File name for sequencing reads, .fastq format.
          - a compressed file (.fastq.gz) is also supported.
    -g    Genome file name, fasta format.
    -o    Output file name, bam format.
    -h    Help message.
    ```

- **Example**: scBS-map -l 9 -p 40 -n 10 -f Sample1.R1.fastq.gz -g hg38.fa -o Sample1.R1.bam

- **Subcommands**:

    **qcreads**:         Trim low quality sequences.

    **align-end2end**:   Perform end-to-end alignment on clean reads.

    **align-local**:     Perform local alignment on clean reads.

    **qcbam**:           Remove the low confidence alignments within microhomology regions

    **mergebam**:        Merge alignments from end-to-end and local mapping if available

- **Authors**:

    Peng Wu; wupeng1@ihcams.ac.cn

    Ping Zhu; zhuping@ihcams.ac.cn

## qcreads

- **Description**: Trim low quality sequences.

- **Usage**: `qcreads [-f <.fastq>] [-l length] [-o output]`

    ```
    -f FILE               File name for sequencing data, fastq format.
    -l INT                Length of removed bases from the 5' end of the read [default: 10].
    -o OUTFILE            Output file name, .fastq.gz format.
    ```

- **Example**: qcreads -f Sample.R1.fastq.gz -l 10 -o Sample.R1.trim.fastq.gz

## align-end2end

- **Description**: Perform end-to-end alignment on clean reads.

- **Usage**: `align-end2end [-f input<.fastq>] [-g genome<.fa>] [-p threads] [-u unmappedreads] [-o output]`

    ```
    -f FILE               File name for clean data, fastq format.
    -g FILE               Genome file name, fasta format.
    -p INT                Number of launching threads [default: 12].
    -u OUTFILE            File name for unmapped reads if needed.
    -o OUTFILE            Output file name, bam format.
    ```

- **Example**: align-end2end -f Sample.R1.trim.fastq.gz -g hg38.genome.fa -p 40 -u Sample.R1.unmapped.bam -o Sample.R1.end2end.bam

## align-local

- **Description**: Perform local alignment on clean reads.

- **Usage**: `align-local [-f input<.fastq>] [-g genome<.fa>] [-p threads] [-o output]`

    ```
    -f FILE               File name for clean data, fastq format.
    -g FILE               Genome file name, fasta format.
    -p INT                Number of launching threads [default: 12].
    -o OUTFILE            Output file name, bam format.
    ```

- **Example**: align-local -f Sample.R1.clean.fastq.gz -g hg38.genome.fa -p 40 -o Sample.R1.local.bam

## qcbam

- **Description**: Remove the low confidence alignments within microhomology regions

- **Usage**: `qcbam [-f <in.bam>] [-n number] [-p threads] [-o <out.bam>]`

    ```
    -f FILE               File name for local alignment, bam format.
    -n INT                Number of trimming bases [default: 10]
    -p INT                Number of launching threads [default: 12].
    -o OUTFILE            Output file name, bam format.
    ```

- **Example**: qcbam -f Sample.R1.local.bam -n 10 -o Sample.R1.local.hc.bam

## mergebam

- **Description**: Merge alignments from end-to-end and local mapping

- **Usage**: `mergebam [-e <.end2end.bam>] [-l <.local.bam>] [-p threads] [-o output]`

    ```
    -e FILE               File name of end2end alignment, .bam format.
    -l FILE               File name of local alignment, .bam format.
    -p INT                Number of launching threads [default: 12].
    -o OUTFILE            Output file name, bam format.
    ```

- **Example**: mergebam -e Sample.R1.end2end.bam -l Sample.R1.local.hc.bam -p 40 -o Sample.R1.merge.bam

