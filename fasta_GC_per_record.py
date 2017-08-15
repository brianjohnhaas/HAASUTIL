#!/usr/bin/env python

import os, re, sys
import collections

usage = "\n\n\tusage: {} seqs.fasta\n\n".format(sys.argv[0])

if len(sys.argv) < 2:
    sys.stderr.write(usage)
    sys.exit(1)


def main():
    fasta_file = sys.argv[1]

    acc = None
    seq = ''
    with open(fasta_file) as fh:
        for line in fh:
            line = line.strip()
            m = re.search('>(\S+)', line)
            if m:
                if acc:
                    report_GC_content(acc, seq)
                acc = m.group(1)
                seq = ''
            else:
                seq += line

    # get last one
    report_GC_content(acc, seq)

    sys.exit(0)

def report_GC_content(acc, seq):
    
    seq = seq.upper()

    seqlen = len(seq)
    charcounter = collections.defaultdict(int)
    for char in seq:
        charcounter[char] += 1

    chars = charcounter.keys()
    probs = { 'G' : 0,
              'C' : 0 }
    for char in chars:
        char_count = charcounter[char]
        p = float(char_count) / seqlen
        probs[char] = p


    GC_content = probs['G'] + probs['C']

    print ">{}\t{:.3f}".format(acc, GC_content)


if __name__ == '__main__':
    main()
