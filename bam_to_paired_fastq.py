#!/usr/bin/env python3

import argparse
import math
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def default_threads() -> int:
    cpu_count = os.cpu_count() or 1
    return max(1, math.floor(cpu_count * 0.8))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Convert a BAM file to ordered paired FASTQs using "
            "'samtools collate | samtools fastq'."
        )
    )
    parser.add_argument("bam", help="Input BAM file.")
    parser.add_argument(
        "output_prefix",
        help=(
            "Output prefix for paired FASTQs. The script writes "
            "<prefix>_R1.fastq.gz and <prefix>_R2.fastq.gz."
        ),
    )
    parser.add_argument(
        "--singletons",
        action="store_true",
        help="Write singleton reads to <prefix>_singletons.fastq.gz instead of discarding them.",
    )
    parser.add_argument(
        "--threads",
        type=int,
        default=default_threads(),
        help=(
            "Threads to pass to samtools where supported. "
            "Default: 80%% of available CPU cores."
        ),
    )
    return parser.parse_args()


def require_samtools() -> str:
    samtools = shutil.which("samtools")
    if not samtools:
        sys.exit("Error: 'samtools' was not found in PATH.")
    return samtools


def main() -> int:
    args = parse_args()
    samtools = require_samtools()

    bam_path = Path(args.bam)
    if not bam_path.is_file():
        sys.exit(f"Error: input BAM not found: {bam_path}")

    output_prefix = Path(args.output_prefix)
    r1_fastq = output_prefix.parent / f"{output_prefix.name}_R1.fastq.gz"
    r2_fastq = output_prefix.parent / f"{output_prefix.name}_R2.fastq.gz"
    singleton_fastq = (
        output_prefix.parent / f"{output_prefix.name}_singletons.fastq.gz"
        if args.singletons
        else Path("/dev/null")
    )

    r1_fastq.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(
        prefix=f"{output_prefix.name}_collate_tmp_", dir=str(output_prefix.parent.resolve())
    ) as tmpdir:
        collate_prefix = str(Path(tmpdir) / "collated")

        collate_cmd = [
            samtools,
            "collate",
            "-uO",
            "-@",
            str(args.threads),
            str(bam_path),
            collate_prefix,
        ]
        fastq_cmd = [
            samtools,
            "fastq",
            "-@",
            str(args.threads),
            "-n",
            "-N",
            "-1",
            str(r1_fastq),
            "-2",
            str(r2_fastq),
            "-0",
            "/dev/null",
            "-s",
            str(singleton_fastq),
            "-",
        ]

        try:
            with subprocess.Popen(collate_cmd, stdout=subprocess.PIPE) as collate_proc:
                with subprocess.Popen(fastq_cmd, stdin=collate_proc.stdout) as fastq_proc:
                    if collate_proc.stdout is not None:
                        collate_proc.stdout.close()
                    fastq_returncode = fastq_proc.wait()
                collate_returncode = collate_proc.wait()
        except OSError as exc:
            sys.exit(f"Error running samtools: {exc}")

    if collate_returncode != 0:
        return collate_returncode
    if fastq_returncode != 0:
        return fastq_returncode

    print(f"Wrote {r1_fastq}")
    print(f"Wrote {r2_fastq}")
    if args.singletons:
        print(f"Wrote {singleton_fastq}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
