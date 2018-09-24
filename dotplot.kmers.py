#!/usr/bin/env python

####
# BE562: Problem Set 1 - string hashing/dotplots
#
##  Modified by bhaas for more general dotplotting.
#

import sys
from collections import defaultdict
import argparse
from Bio.Seq import Seq

def readSeq(filename):
    """reads in a FASTA sequence"""

    stream = open(filename)
    seq = []

    for line in stream:
        if line.startswith(">"):
            continue
        seq.append(line.rstrip())

    return "".join(seq)


def makeDotplot(filename, seq1_len, seq2_len, hits):
    """generate a dotplot from a list of hits
       filename may end in the following file extensions:
         *.ps, *.png, *.jpg
    """
    import matplotlib.pyplot as plt
    x, y = zip(*hits)

    x2 = [0, seq1_len]
    y2 = [0, seq2_len]

    # create plot
    #plt.plot(x2, y2, 'b')
    plt.scatter(x, y, s=1, c='r', edgecolors='none', marker=',')
    plt.title("dotplot {} hits".format(len(x)))
    plt.xlabel("sequence 1")
    plt.ylabel("sequence 2")
    plt.xlim(x2)
    plt.ylim(y2)
    plt.tight_layout()

    # output plot
    plt.savefig(filename)







def main():

    parser = argparse.ArgumentParser(description="dotplotter based on kmers", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--seq1", dest="seq1_file", type=str, default="", required=True, help="seq1")
    parser.add_argument("--seq2", dest="seq2_file", type=str, default="", required=True, help="seq2")
    parser.add_argument("-K", dest="kmerlen", type=int, default=25, help="kmer length")
    parser.add_argument("--plot_file", dest="plot_file", type=str, default="dotplot.png", help="name of dotplot file")

    args = parser.parse_args()

    seq1_file = args.seq1_file
    seq2_file = args.seq2_file
    kmerlen = args.kmerlen
    plotfile = args.plot_file
    
    # read sequences
    print("reading sequences")
    seq1 = readSeq(seq1_file)
    seq2 = readSeq(seq2_file)

    #
    # You will need to modify the code below to

    # hash table for finding hits
    lookup = defaultdict(list)

    # store sequence hashes in hash table
    print("hashing seq1...")
    for i in xrange(len(seq1) - kmerlen + 1):
        key = seq1[i:i+kmerlen]
        lookup[key].append(i)

    # look up hashes in hash table
    print("hashing seq2...")
    hits = []
    for i in xrange(len(seq2) - kmerlen + 1):
        key = seq2[i:i+kmerlen]

        # store hits to hits list
        for hit in lookup.get(key, []):
            hits.append((i, hit))

        ## try reverse-complement
        seq = Seq(key)
        revcomp_key = str(seq.reverse_complement())
        #print("revcompkey: {}".format(revcomp_key))
        for hit in lookup.get(revcomp_key, []):
            print("Found revcomp hit: {}".format(hit))
            hits.append((i, hit))
    
    # hits should be a list of tuples
    # [(index1_in_seq2, index1_in_seq1),
    #  (index2_in_seq2, index2_in_seq1),
    #  ...]

    print("%d hits found" % len(hits))
    print("making plot...")

    seq1_len = len(seq1)
    seq2_len = len(seq2)
    
    makeDotplot(plotfile, seq1_len, seq2_len, hits)

if __name__ == "__main__":
    main()
