#!/usr/bin/env python
# encoding: utf-8


import os, sys, re
import logging
import argparse
from collections import defaultdict

logging.basicConfig(stream=sys.stderr, level=logging.INFO)
logger = logging.getLogger(__name__)



def main():

    parser = argparse.ArgumentParser(description="counts kmers of size ksmallest to k", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("--fasta", type=str, required=True, help="fasta file")

    parser.add_argument("--seqtype", type=str, choices = ["prot", "nucl"], required=True, help="prot or nuc sequence type")

    parser.add_argument("--no_rc", action='store_true', default=False, help="exclude reverse complement, only forward strand is counted")

    parser.add_argument("--ksmallest", type=int, required=False, default=1, help="smallest value of k")

    parser.add_argument("-k", type=int, required=True, help="max value of k")

    parser.add_argument("--debug", required=False, action="store_true", default=False, help="debug mode")

    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)      


    fasta_filename = args.fasta
    seqtype = args.seqtype
    exclude_revcomp = args.no_rc
    ksmallest = args.ksmallest
    k = args.k

    kmer_counter = defaultdict(int)

    currentseq = ""
    with open(fasta_filename) as fh:
        for line in fh:
            line = line.rstrip()
            if len(line) == 0:
                continue
            if line[0] == ">":
                # header line
                if currentseq != "":
                    count_seq_kmers(currentseq, ksmallest, k, seqtype, exclude_revcomp, kmer_counter)
                    currentseq = "" # reinit
            else:
                currentseq += line

                    
    # get the last sequence entry
    if currentseq != "":
        count_seq_kmers(currentseq, ksmallest, k, seqtype, exclude_revcomp, kmer_counter)
    

    for kmer, count in kmer_counter.items():
        print("\t".join([kmer, str(count)]))
        



def count_seq_kmers(seqstring, ksmall, klarge, seqtype, exclude_revcomp, kmer_counter):

    seqstring = seqstring.upper()

    rc_seqstring = None
    if seqtype == "nucl" and exclude_revcomp is False:
        rc_seqstring = reverse_complement_seq(seqstring)

    elif seqtype == "prot":
        if re.search("\\*$", seqstring) is not None:
            logger.debug("-chopping off translated stop codons")
            seqstring = seqstring[0:-1]


    for k in range(ksmall, klarge+1):
        count_kmers(seqstring, k, kmer_counter)

        if rc_seqstring is not None:
            count_kmers(rc_seqstring, k, kmer_counter)

    return


def count_kmers(seqstring, k, kmer_counter):

    for i in range(len(seqstring) - k + 1):
        kmer = seqstring[i:i+k]
        kmer_counter[kmer] += 1

    return


def reverse_complement_seq(seqstring):

    rc_seqstring = list()

    rc = { 'G' : 'C',
           'A' : 'T',
           'C' : 'G',
           'T' : 'A',
           'N' : 'N' }

    for seqchar in seqstring:
        rc_seqstring.append(rc[seqchar])

    rc_seqstring.reverse()
    rc_seqstring = "".join(rc_seqstring)

    return rc_seqstring

  
if __name__ == "__main__":
    main()
