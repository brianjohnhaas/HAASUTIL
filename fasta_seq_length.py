#!/usr/bin/env python

import os, sys, re

def report_seq_lengths(filename):
    fh = file(filename, 'r')
    acc = ""
    seqlen = 0
    for line in fh:
        line = line.rstrip()
        m = re.search('^\>(\S+)', line)
        #print "\t".join([`m`, line])
        if m:
            if acc:
                print "%s\t%d" % (acc, seqlen)
            acc = m.group(1)
            seqlen = 0

        else:
            seqlen += len(line)

    if acc:
        print "%s\t%d" % (acc, seqlen)
    


if __name__ == "__main__":
    
    if len(sys.argv) < 2:
        print >> sys.stderr, "\n\nusage: " + sys.argv[0] + " file.fasta\n\n"
        sys.exit(1)

    report_seq_lengths(sys.argv[1])
    sys.exit(0)
