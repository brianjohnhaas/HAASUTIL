#!/usr/bin/env python3

import sys


def fasta_to_tab(fin):
    accession = None
    seq_chunks = []
    for line in fin:
        line = line.strip()
        if not line:
            continue
        if line.startswith(">"):
            # flush previous entry
            if accession is not None:
                print(f"{accession}\t{''.join(seq_chunks)}")
            # new entry
            accession = line[1:].split()[0]  # take first token after '>'
            seq_chunks = []
        else:
            seq_chunks.append(line)
    # flush last entry
    if accession is not None:
        print(f"{accession}\t{''.join(seq_chunks)}")


if __name__ == "__main__":
    fasta_to_tab(sys.stdin)
