#!/usr/bin/env python3
# encoding: utf-8

import os, sys, re
import logging
import argparse
import pysam

if sys.version_info[0] != 3:
    print("This script requires Python 3")
    exit(1)


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s : %(levelname)s : %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


def main():

    parser = argparse.ArgumentParser(
        description="given a list of read accessions, makes a bam containing just those entries from the larger input bam",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--accs_file",
        type=str,
        required=True,
        help="file containing the list of read names for targeted alignments",
    )

    parser.add_argument(
        "--input_bam",
        type=str,
        required=True,
        help="input bam filename",
    )

    parser.add_argument(
        "--output_bam", type=str, required=True, help="output_bam_filename"
    )

    args = parser.parse_args()

    accs_filename = args.accs_file
    input_bam_filename = args.input_bam
    output_bam_filename = args.output_bam

    read_names_want = set()

    with open(accs_filename, "rt") as fh:
        for line in fh:
            line = line.rstrip()
            read_name = line

    logger.info(
        "-read {} read_names from {}".format(len(read_names_want), accs_filename)
    )

    bamreader = pysam.AlignmentFile(input_bam_filename, "rb")

    bamwriter = pysam.AlignmentFile(output_bam_filename, "wb", template=bamreader)

    read_names_found = set()

    for read in bamreader:
        read_name = read.query_name
        if read_name in read_names_want:
            bamwriter.write(read)
            read_names_found.add(read_name)

    missing_reads = read_names_want - read_names_found
    if len(missing_reads) > 0:
        logger.error(
            "Missing read alignemnts for {} entries:\n{}".format(
                len(missing_reads), "\n".join(list(missing_reads))
            )
        )

        sys.exit(1)

    logger.info(
        "-all reads found and alignments written to: {}".format(output_bam_filename)
    )
    sys.exit(0)


if __name__ == "__main__":
    main()
