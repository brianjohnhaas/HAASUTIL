#!/usr/bin/env python3

import sys
import gzip, re

usage = "\n\n\tusage: {} sample_id fastq1 [fastq1]\n\n".format(sys.argv[0])

if len(sys.argv) < 3:
    exit(usage)

sample_id = sys.argv[1]
fastq1 = sys.argv[2]
fastq2 = None

if len(sys.argv) > 3:
    fastq2 = sys.argv[3]

filenames = [fastq1]
if fastq2 is not None and fastq2 != "":
    filenames.append(fastq2)

sum_seq_lens = 0
num_seqs = 0
num_SE_seqs = 0
PE = True if len(filenames) > 1 else False

for fastq in filenames:
    num_SE_seqs = 0
    if re.search("\\.gz$", fastq):
        fh = gzip.open(fastq, 'rt')
    else:
        fh = open(fastq, 'rt')
    linecounter = 0
    for line in fh:
        linecounter += 1
        if linecounter % 4 == 2:
            # seqline
            line = line.rstrip()
            sum_seq_lens += len(line)
            num_seqs += 1
            num_SE_seqs += 1

mean_read_length = sum_seq_lens / num_seqs



with open(sample_id + ".fq_stats.txt", "wt") as ofh:
    print("sample_id:\t{}\tPairedEnd:\t{}\tnum_SE_seqs:\t{}\tsum_bases:\t{}\tmean_seq_len:\t{}".format(sample_id, PE, num_SE_seqs,
                                                                       sum_seq_lens,
                                                                       round(sum_seq_lens/num_seqs)), file=ofh)


sys.exit(0)
