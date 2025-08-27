#!/usr/bin/env python3
"""
tab_to_fasta.py

Read a tab-delimited table from stdin and write FASTA to stdout.

Assumptions:
- Each input line has >= 2 tab-delimited columns.
- The LAST column is the sequence.
- All earlier columns form the FASTA header, joined by spaces.

Extras:
- Wrap sequence lines to a fixed width (default 60). Use --width 0 to disable wrapping.
- Lines that are empty or start with '#' are ignored.
"""

import sys
import argparse
from textwrap import wrap


def to_fasta_header(fields):
    """Join all but the last field with spaces to form the header."""
    header = " ".join(fields[:-1]).strip()
    # Fall back to first field if everything before the sequence is empty
    return header if header else fields[0].strip()


def emit_fasta(header, seq, width, out):
    """Write a single FASTA record to out."""
    print(f">{header}", file=out)
    if width and width > 0:
        for chunk in wrap(seq, width=width):
            print(chunk, file=out)
    else:
        print(seq, file=out)


def main():
    ap = argparse.ArgumentParser(description="Convert tab-delimited input to FASTA.")
    ap.add_argument(
        "--width",
        type=int,
        default=60,
        help="Line-wrap width for sequences (0 = no wrap, default: 60).",
    )
    args = ap.parse_args()

    for lineno, raw in enumerate(sys.stdin, start=1):
        line = raw.rstrip("\n")
        if not line or line.lstrip().startswith("#"):
            continue

        fields = line.split("\t")
        if len(fields) < 2:
            print(
                f"[warning] line {lineno}: expected >=2 columns, skipping.",
                file=sys.stderr,
            )
            continue

        header = to_fasta_header(fields)
        # Sequence is last field; strip whitespace inside it just in case
        seq = "".join(fields[-1].split())

        if not header:
            print(f"[warning] line {lineno}: empty header, skipping.", file=sys.stderr)
            continue
        if not seq:
            print(
                f"[warning] line {lineno}: empty sequence, skipping.", file=sys.stderr
            )
            continue

        emit_fasta(header, seq, args.width, sys.stdout)


if __name__ == "__main__":
    main()
